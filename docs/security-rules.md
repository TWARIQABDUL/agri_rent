# Firestore Security Rules

Draft of the security section for the final report. It explains what
`firestore.rules` at the repository root enforces and why each rule exists.

## The problem the rules solve

AgriRent is a Flutter client talking straight to Firestore. There is no backend
of our own between the phone and the database, and the app ships with its
Firebase configuration embedded in the binary. Anyone can extract those keys,
sign in as a legitimate user, and issue arbitrary reads and writes with the
Firestore SDK. Client-side validation in the Dart code is a convenience for
honest users; it stops nobody who is determined.

Firestore security rules are therefore the only enforcement point. Every request
is re-checked on the server against three questions:

1. **Who is asking?** `request.auth.uid`, established by Firebase Authentication.
2. **Do they own the record?** The uid is compared against the `ownerId` or
   `renterId` already stored on the document.
3. **Is the payload legal?** Types, ranges and the exact set of fields being
   changed are validated on create and on update.

## Data model the rules protect

| Collection | Holds | Written by |
| --- | --- | --- |
| `users/{uid}` | role, display name, contact, KYC verification flag | the user, except `verified` |
| `equipment/{id}` | a listing: name, category, rate, location, status, rating | its verified owner |
| `rentals/{id}` | a booking: dates, amount, status, payout flag | the renter, then the owner |

## Owner verification is the gate on listings

An owner can only publish or edit equipment once an administrator has set
`verified: true` on their profile after checking their identity documents. The
rules express this with a helper that reads the caller's own profile:

```
function isVerifiedOwner() {
  return hasProfile() && profile().role == 'owner' && profile().verified == true;
}
```

The important half of the design is that the client can never set that flag
itself. On create, a profile is only accepted when it arrives with
`verified == false`. On update, the allowed field list simply does not contain
`verified`, so any write touching it is rejected:

```
allow update: if isSelf(uid)
  && incoming().role in ['owner', 'farmer']
  && changedKeys().hasOnly([
    'role', 'displayName', 'email', 'phone', 'district', 'updatedAt'
  ]);
```

Without that, an owner could flip their own KYC flag and the verification
requirement would be decoration. Verification is applied out of band, by an
administrator in the Firebase console or by a trusted backend process.

`profile()` performs a document read, which is billed and adds latency to every
listing write. It is written as a single helper and called from one predicate so
the read happens once per request rather than once per condition.

## Ownership and immutability on listings

```
allow create: if isVerifiedOwner()
  && incoming().ownerId == request.auth.uid
  && validListing()
  && incoming().status == 'available'
  && incoming().rating == 0
  && incoming().bookingCount == 0
  && incoming().createdAt == request.time;
```

Two attacks are closed here. Pinning `ownerId` to the caller's uid stops an owner
publishing a listing attributed to somebody else, which would let them divert
another owner's bookings. Pinning `rating` and `bookingCount` to zero stops a new
listing arriving with a fabricated reputation. `createdAt == request.time` forces
the value to be a server timestamp rather than a date the client chose.

Updates reuse the same validation and add a field allow-list:

```
allow update: if isVerifiedOwner()
  && resource.data.ownerId == request.auth.uid
  && validListing()
  && incoming().updatedAt == request.time
  && changedKeys().hasOnly([
    'name', 'category', 'description', 'pricePerDay', 'pricePerMonth',
    'location', 'image', 'status', 'updatedAt'
  ]);
```

`resource.data.ownerId` is the value already in the database, so ownership is
judged on the stored document rather than on anything the request supplies.
Because `ownerId`, `createdAt`, `rating` and `bookingCount` are missing from the
allowed keys, an edit cannot reassign a listing or inflate its rating. Pausing
and resuming a listing goes through this same rule: the app writes only `status`
and `updatedAt`, which the allow-list permits.

`validListing()` runs on both operations. Validating only on create is a common
mistake: it leaves an owner free to update `pricePerDay` to a negative number or
to a string afterwards, and every consumer of that field then has to defend
itself.

Deletes are refused outright. Listings are paused instead, so the rental history
that references them stays intact and an owner cannot erase a machine that is
the subject of a dispute.

## Rentals: two parties, different powers

Reads are restricted to the two parties on the booking:

```
allow read: if isSignedIn()
  && (resource.data.renterId == request.auth.uid
    || resource.data.ownerId == request.auth.uid);
```

Rules do not filter query results; a query that could return a document failing
this rule is rejected in full. The owner dashboard therefore queries
`rentals` with `where('ownerId', isEqualTo: uid)`, which guarantees every
returned document satisfies the rule.

Writes are split by role. The renter opens the request and may withdraw it while
it is still unanswered; the owner is the only party who can accept, decline, or
advance it. Neither may touch the money:

```
allow update: if isSignedIn()
  && changedKeys().hasOnly(['status', 'updatedAt'])
  && (
    (resource.data.ownerId == request.auth.uid
      && incoming().status in ['accepted', 'declined', 'active', 'completed'])
    ||
    (resource.data.renterId == request.auth.uid
      && resource.data.status == 'pending'
      && incoming().status == 'cancelled')
  );
```

`totalAmount` and `paidOut` are outside the allowed keys, so an owner cannot mark
their own earnings as cleared and a renter cannot reduce what they owe after the
fact. Earnings shown on the dashboard are derived from these fields, which is why
they must stay server-controlled.

## Default deny

The rule set ends with a catch-all that denies everything not matched above, so a
collection added later is closed until somebody writes rules for it, rather than
open by oversight.

## Consequence for the app

Because the rules read `users/{uid}` before permitting a listing write, the app
creates that profile document when the owner workspace opens
(`EnsureOwnerProfile`), writing only `role` and contact details. A permission
error from Firestore is translated in `OwnerRepositoryImpl` into a message the
owner can act on rather than a raw error code:

> Your owner account is not verified yet, so listings cannot be changed.
> Verification is completed by the AgriRent team.

## Verifying the rules

Rules are code and deserve the same treatment. They are exercised against the
emulator before deployment:

```bash
firebase emulators:start --only firestore
firebase deploy --only firestore:rules
```

The cases worth covering are the ones the rules exist for: an unverified owner
attempting to publish, an owner editing a listing they do not own, a client
setting its own `verified` flag, an update that changes `rating`, and a renter
trying to move a rental to `completed`.
