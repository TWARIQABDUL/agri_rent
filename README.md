# AgriRent

AgriRent is a cross-platform mobile application designed to connect farmers with agricultural equipment owners for easy, reliable, and affordable equipment rentals.

## Tech Stack
- **Framework:** Flutter
- **State Management:** BLoC (Business Logic Component)
- **Architecture:** Clean Architecture
- **Dependency Injection:** GetIt & Injectable
- **Backend:** Firebase (Firestore)

## Database Schema (Firestore)

To ensure consistency and help other developers understand the data structure, here is the current schema used in our Firestore database.

### Collection: `equipment`
This collection stores all agricultural equipment available for rent.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| **`name`** | `String` | The title or name of the equipment (e.g., "John Deere 5050D"). |
| **`ownerId`** | `String` | The unique identifier or name of the equipment owner. |
| **`description`**| `String` | A detailed description of the equipment and its condition. |
| **`pricePerDay`**| `Number` | Rental price per day in RWF. |
| **`pricePerMonth`**| `Number`| Rental price per month in RWF. |
| **`status`** | `String` | Current availability status (e.g., `"available"`, `"rented"`, `"maintenance"`). |
| **`category`** | `String` | The classification of the equipment (e.g., `"Tractors"`, `"Pumps"`, `"Harvesters"`). |
| **`image`** | `String` | URL pointing to the equipment's image. |
| **`location`** | `String` | The district or city where the equipment is located (e.g., `"Kigali"`, `"Muhanga"`). |
| **`rating`** | `Number` | The average user rating of the equipment (from `0.0` to `5.0`). |

> **Note on Numbers (Web Compatibility):** When fetching numbers from Firestore on Flutter Web, always cast safely using `(data['field'] as num?)?.toDouble() ?? 0.0` to avoid `Int64` serialization crashes.

## Getting Started

1. Ensure you have Flutter installed and configured.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` whenever you add new `@injectable` dependencies.
4. Run the app using `flutter run` (Use `-d chrome` for web).
