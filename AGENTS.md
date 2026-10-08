# AGENTS.md — riwayat_perjalanan

Flutter app: pencatat odometer + BBM per kendaraan, SQLite lokal, Riverpod.

## Commands
- Deps: `flutter pub get`
- Verify: `flutter analyze && flutter test` (analyzer excludes `build/`, `android/`)
- Run: `flutter run` (Android only; no ios/, web/, windows/ folders)

## Structure
- `lib/main.dart` — bootstrap only (`ProviderScope`, `initializeDateFormatting('id_ID')`, `HomeScreen`).
- `lib/models/` — `Vehicle`, `FuelLog` (+ `OdometerException`); plain `toMap/fromMap`, no codegen.
- `lib/core/database/app_db.dart` — singleton `AppDb.instance.db`, file `riwayat.db`, version 1. No migrations yet; bump version + `onUpgrade` when changing schema.
- `lib/repositories/` — `VehicleRepo`, `FuelRepo`; all validation lives in `FuelRepo` (liter > 0, odometer monoton naik per vehicle, no future dates).
- `lib/providers/app_providers.dart` — Riverpod source of truth (`VehicleList`, `FuelList` family, `selectedVehicleIdProvider`, `statsProvider` family); UI must go through these, not repos directly.
- `lib/providers/stats.dart` — pure `FuelStats.compute(logsAsc)`; full-to-full method with per-entry fallback when < 2 full-tank.
- `lib/screens/` — `home` (dashboard), `garage` (CRUD kendaraan), `fuel_form` (add/edit), `history` (list + swipe delete/undo).

## Conventions
- Dates stored as ms-since-epoch (`INTEGER`); `isFullTank` as `0/1`; money as `int` Rp; odo/liter as `REAL`.
- Locale `id_ID` for dates (`DateFormat`) and Rp (`NumberFormat.currency`); form parsing accepts `,` as decimal separator.
- `DropdownButtonFormField` uses `initialValue`, not `value` (Flutter 3.47 deprecation).
- Tests in `test/` are pure unit tests on `FuelStats.compute`; no sqflite/widget tests currently.
