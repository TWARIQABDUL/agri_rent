# Progress

Status of the owner dashboard and asset management work stream (Leny Pascal
IHIRWE). Architecture, schema and conventions live in `handover.md`.

Last updated: 25 July 2026.

## Scope of this stream

1. Owner Dashboard with earnings and an active rentals summary.
2. Multi-step Add New Equipment form.
3. Firestore create and update so owners can publish, edit, and pause listings.
4. Firebase security rules, plus the explanation section for the final report.
5. A widget test covering the Add New Equipment form submission.

## Done

| Item | Where |
| --- | --- |
| Owner domain layer: draft, rental, summary entities, repository contract, six use cases | `lib/features/owner/domain/` |
| Firestore reads and writes for listings, rentals, and the owner profile | `lib/features/owner/data/` |
| Blocs for the shelf, the dashboard, and the wizard | `lib/features/owner/presentation/bloc/` |
| Owner Dashboard: payout balance, four counters, pending clearance, quick actions, machines out on rent | `owner_dashboard_page.dart` |
| My Listings: publish, edit, pause, activate, empty and error states | `my_listings_page.dart` |
| Add New Equipment: three steps, per-step validation, review summary, edit mode | `add_equipment_page.dart` |
| Earnings: payout card, lifetime and pending totals, activity trail | `earnings_page.dart` |
| Owner shell with five tabs and a real pending-request badge | `owner_shell.dart` |
| Role-aware entry so owners land in the owner workspace | `lib/features/main_shell/role_home.dart` |
| Security rules for `users`, `equipment`, `rentals` | `firestore.rules` |
| Report section on the rules | `docs/security-rules.md` |
| Widget test: full three-step submission, plus step and description validation | `test/features/owner/presentation/pages/add_equipment_page_test.dart` |

Gate at the time of writing: `dart format`, `flutter analyze` (no issues), and
`flutter test` (12 tests) all pass.

## Decisions worth knowing

- **Pausing hides a listing from browse.** `EquipmentRemoteDataSource.getEquipment`
  now filters on `status == 'available'`, so pausing has a real effect for
  farmers. Both filters are equality checks, so no composite index is needed.
- **Categories are one shared catalogue.** `EquipmentCategory` holds the stored
  value, the label, and the icon. Stored values stay plural (`Tractors`) to match
  the data that already exists; the form shows the singular label.
- **Owner-editable fields are separated from derived ones.** `ListingWriteModel`
  builds a create payload and an update payload, and the update payload contains
  no `ownerId`, `rating`, `bookingCount`, or `createdAt`. The security rules
  reject writes that touch them, so keeping them out of the map is what lets a
  legitimate edit through.
- **Earnings are a projection, not stored numbers.** `OwnerSummary.from` derives
  every figure from the owner's rentals, so nothing needs to be kept in sync.
- **The wizard's primary button looks disabled but stays tappable.** The design
  shows a muted Publish button; a dead button would not explain itself, so the
  tap reveals which fields are missing.
- **Deletes are refused by the rules.** Listings are paused instead, so rental
  history keeps pointing at something real.

## Outstanding, and who it belongs to

- **Owner verification is manual.** The rules require `verified: true` on
  `users/{uid}` before any listing write, and the client can never set that flag.
  Until an admin surface exists, set it in the Firebase console for demo
  accounts. The app reports the refusal as "Your owner account is not verified
  yet" rather than an error code.
- **Photo upload.** The form takes an image link and previews it. Real uploads
  need `firebase_storage` plus an image picker; the `image` field already holds a
  URL, so nothing in the schema changes.
- **Rental requests.** The owner Requests tab shows the real pending count but
  cannot open a request. Review, accept, and decline belong to the rentals
  module, along with the `request-details-screen` design.
- **Payouts.** Withdraw explains the monthly schedule. Actual disbursement needs
  a payouts collection and a backend, which is out of scope for this milestone.
- **Rules are not yet emulator-tested.** `docs/security-rules.md` lists the cases
  to cover. Run `firebase emulators:start --only firestore` before deploying.

## Note for anyone writing widget tests here

Build the bloc inside the `testWidgets` body, not in `setUp`. A bloc created in
`setUp` belongs to the zone outside the widget test's fake clock, so its state
stream never reaches the widgets and every rebuild-dependent assertion fails for
reasons that look like a bug in the page. `add_equipment_page_test.dart` does this
and says why.
