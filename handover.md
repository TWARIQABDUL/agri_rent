# AgriRent handover

Everything needed to pick up this codebase without reading it end to end.
Pair it with `progress.md`, which tracks what is done and what is next.

Last updated: 25 July 2026.

## What the product is

A marketplace for farm equipment in Rwanda. Farmers browse and book machines;
owners list machines, answer booking requests, and get paid. One account can act
as either, chosen at sign-up and switchable from Profile.

## Running it

```bash
flutter pub get
dart run build_runner build      # after touching any @injectable annotation
flutter run
```

Gate before every commit:

```bash
dart format .
flutter analyze                  # must print "No issues found!"
flutter test
```

Firebase project: `agri-rent-66546`. Rules live in `firestore.rules` and deploy
with `firebase deploy --only firestore:rules`.

## Architecture

Feature-first clean architecture. Each feature is a vertical slice and nothing
crosses a layer except through the abstractions below.

```
lib/
  core/
    constants/equipment_categories.dart   shared category catalogue (value/label/icon)
    error/app_exception.dart              errors that already carry a user-facing message
    services/preferences_service.dart     role, language, currency, notification prefs
    theme/app_colors.dart                 design tokens
    usecases/usecase.dart                 UseCase<T, Params> contract
    utils/                                money and date formatting
  features/
    auth/          sign-in, sign-up, role selection, profile, settings
    equipment/     the shared catalogue: browse queries and the Equipment entity
    home/          farmer browse screen and its widgets
    main_shell/    farmer tab shell, plus RoleHome which picks a shell by role
    owner/         owner workspace: dashboard, listings, add/edit, earnings
```

Inside a feature:

- `domain/` entities (Equatable, no Flutter, no Firebase), repository contracts,
  and one use case class per operation.
- `data/` models extending the entity with `fromFirestore`/`toMap`, data sources
  talking to `FirebaseFirestore`, and repository implementations that translate
  `FirebaseException` into `AppException`.
- `presentation/` blocs (events and states in `part` files), pages, widgets.

Dependency injection is `injectable` + `get_it`. Blocs are `@injectable`
(new instance per screen), everything else `@lazySingleton`. The generated
`lib/injection_container.config.dart` is checked in; regenerate it rather than
editing it.

## Firestore schema

### `users/{uid}`

| Field | Type | Notes |
| --- | --- | --- |
| `role` | string | `owner` or `farmer` |
| `displayName`, `email`, `phone`, `district` | string | client-writable |
| `verified` | bool | KYC gate. **Never client-writable.** Set by an admin |
| `createdAt`, `updatedAt` | timestamp | server timestamps |

The document is created by `EnsureOwnerProfile` when the owner workspace opens,
because the security rules read `role` and `verified` from it before allowing any
listing write.

### `equipment/{id}`

| Field | Type | Notes |
| --- | --- | --- |
| `ownerId` | string | uid of the owner, immutable after create |
| `name`, `description`, `location`, `image` | string | owner-editable |
| `category` | string | one of `Tractors`, `Pumps`, `Sprayers`, `Harvesters` |
| `pricePerDay`, `pricePerMonth` | number | RWF, monthly optional |
| `status` | string | `available` or `paused`; paused is hidden from browse |
| `rating`, `bookingCount` | number | derived, not client-writable |
| `createdAt`, `updatedAt` | timestamp | server timestamps |

### `rentals/{id}`

| Field | Type | Notes |
| --- | --- | --- |
| `equipmentId`, `equipmentName` | string | denormalised for list rendering |
| `ownerId`, `renterId`, `renterName` | string | the two parties |
| `startDate`, `endDate` | timestamp | inclusive of both days |
| `totalAmount` | number | RWF |
| `status` | string | `pending`, `accepted`, `active`, `completed`, `declined`, `cancelled` |
| `paidOut` | bool | true once the money reached the owner's bank |
| `createdAt`, `updatedAt` | timestamp | server timestamps |

`rentals` is read by the owner dashboard today. The write side (request review,
accept and decline) belongs to the rentals module and is not implemented yet.

Queries deliberately avoid `orderBy` on a field other than the equality filter,
so no composite index is needed; ordering is done in Dart.

## Security rules

`firestore.rules`, explained in `docs/security-rules.md`. The three rules that
matter most:

1. `verified` is never writable by a client, so the KYC gate cannot be
   self-granted.
2. `ownerId` is pinned to the caller on create and excluded from the updatable
   field set, so a listing cannot be reassigned.
3. Derived fields (`rating`, `bookingCount`, `paidOut`, `totalAmount`) are
   excluded from every client-writable field set.

Because of rule 1, a freshly created owner cannot publish until somebody sets
`verified: true` on their `users/{uid}` document in the Firebase console. That is
intentional, and the app surfaces it as a readable message rather than an error
code.

## Design language

Figma exports live in `designs/` as SVG. All text in them is converted to vector
paths, so grepping them returns nothing; render them to PNG slices first (see
`.claude/skills/design-slice`). Not every screen has an export; compose the
missing ones from the tokens below.

| Token | Value | Used for |
| --- | --- | --- |
| `AppColors.green` | `#2E7D32` | primary actions, live status |
| `AppColors.greenDeep` | `#1B5E20` | icons on tinted wells |
| `AppColors.greenTint` | `#E8F1E5` | icon wells, selected rows |
| `AppColors.amber` / `amberText` / `amberTint` | `#F5A623` / `#9A7400` / `#FEF3D6` | paused, pending, money not yet cleared |
| `AppColors.outline` | `#E5E7EB` | 1.5px borders |
| `AppColors.ink` / `muted` | `#1A1A1A` / `#6B7280` | text |

Screen chrome: white `AppBar`, `elevation: 0`, `scrolledUnderElevation: 0`,
title 22/w800, `centerTitle: false`, 1px outline divider as `bottom`. Body padding
`fromLTRB(20, 20, 20, 120)` when the floating bottom nav is present. Cards are
white, 1.5px outline, radius 16.

Note that `app_colors.dart` also holds an older palette (`primaryDark`,
`borderColor`, `textSecondary`) used by the screens built before the current
exports. New work should use the tokens in the table.

## Owner workspace (this work stream)

Entry point is `RoleHome`, which reads the saved role and shows `OwnerShell` or
the farmer `MainShell`.

`OwnerShell` provides `OwnerDashboardBloc` and `OwnerListingsBloc` above all five
tabs, so a listing written from the dashboard refreshes the shelf behind it.
Tabs: Dashboard, My Listings, Rental Requests (placeholder), Earnings, Profile.

- `OwnerDashboardPage` — payout balance, counters, quick actions, machines out on
  rent.
- `MyListingsPage` — the shelf, with pause, activate and edit per card.
- `AddEquipmentPage` — the three-step publish and edit wizard. Step one is what
  the machine is, step two the rate and location, step three the description and
  a review. The primary button is styled inactive while a step is incomplete but
  stays tappable, and the tap reveals which fields are missing.
- `EarningsPage` — payout balance, lifetime and pending totals, activity trail.

`OwnerSummary.from` is the projection that turns raw rentals and listings into
the dashboard numbers. It is pure and lives in the domain layer, so the rules for
what counts as earned money are testable without Firestore.

## Known gaps

- **Photos.** The form takes an image link and previews it; there is no upload.
  Adding `firebase_storage` plus an image picker is the next step, and
  `image` on the listing already carries a URL.
- **Rental requests.** The owner Requests tab shows the real pending count but
  cannot open a request. Accept and decline belong to the rentals module.
- **Payouts.** The Withdraw action explains the monthly payout schedule; there is
  no payouts collection and no disbursement.
- **Owner verification** is a manual console step until an admin surface exists.
