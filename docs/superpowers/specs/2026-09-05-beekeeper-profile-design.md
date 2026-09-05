# Beekeeper Profile — Design

## Purpose

The app currently tracks hives but has no concept of the beekeeper
operating them. This feature adds a single-record profile capturing
regulatory/identity details: apiarist registration number,
association name, officially registered hive count, and the
apiary's GPS location.

## Data Model

New struct in `Models.swift`:

```swift
struct BeekeeperProfile: Codable {
    var numeroApicultor = ""
    var nomeAssociacao = ""
    var numeroColmeiasRegistadas = ""
    var latitude = ""
    var longitude = ""
}
```

All fields are `String` and default to empty. This mirrors how
`Hive.localizacao` and other free-text fields in the app already
handle "no value" (empty string), rather than introducing `Optional`
handling inconsistent with the rest of the codebase.

`numeroColmeiasRegistadas` is a manual field, independent from
`HiveStore.hives.count` — it represents the official registered
count, which may legitimately differ from what's tracked in-app
(e.g. for regulatory reporting), per user decision during
brainstorming.

There is exactly one profile per app installation — no multi-profile
support, no id.

## Storage

New file `ProfileStore.swift`, following the exact persistence
pattern already established by `HiveStore`:

```swift
@Observable
class ProfileStore {
    var profile = BeekeeperProfile() {
        didSet { save() }
    }

    private static let storageKey = "colmeias_profile_v1"

    init() { load() }

    private func save() { /* JSONEncoder -> UserDefaults, mirrors HiveStore.save() */ }
    private func load() { /* JSONDecoder <- UserDefaults, mirrors HiveStore.load() */ }
}
```

No date encoding strategy is needed (no `Date` fields). No
import/export integration — profile is out of scope for the existing
JSON export/import feature, which is hive-data-only.

## Location

New file `LocationFetcher.swift`: a small `NSObject` wrapping
`CLLocationManager` to perform a single one-shot "get current
location" request, exposing the result (or failure) via a completion
closure or `@Observable` state consumed by `ProfileView`. Requests
`when-in-use` authorization if not already determined.

`Info.plist` needs `NSLocationWhenInUseUsageDescription` added (a
Portuguese-language justification string, e.g. "Usada para preencher
automaticamente a localização do teu apiário.").

If the user denies permission or location fails, the button simply
does nothing further than what `CLLocationManager` reports — no
custom error alert; the manual lat/long fields remain editable as the
fallback path.

## View

New file `ProfileView.swift`, presented as a sheet (`Form` inside a
`NavigationStack`), styled consistently with `AddHiveSheet`:

- Section "Apicultor": Número de Apicultor, Nome da Associação,
  Número de Colmeias Registadas text fields.
- Section "Localização": Latitude and Longitude text fields, plus a
  "Usar localização atual" button (location-icon) that invokes
  `LocationFetcher` and overwrites both fields with the fetched
  coordinates.
- Toolbar: "Cancelar" (discards in-progress edits) and "Guardar"
  (always enabled — no required fields) buttons, matching
  `AddHiveSheet`'s toolbar pattern.

Edits are made to local `@State` copies of the profile fields and
only committed to `ProfileStore.profile` on Guardar, so Cancelar
correctly discards changes — same pattern as how `Hive` edits are
expected to work via `EditHiveView`.

## Wiring

- `ContentView` instantiates `@State private var profileStore =
  ProfileStore()` and injects it via `.environment(profileStore)`
  alongside the existing `HiveStore` injection.
- `HomeView`'s existing `⋯` toolbar `Menu` gets a new item "Perfil"
  (`person.circle` system image) placed above the existing
  "Exportar Dados" / "Importar Dados" items. Tapping it presents
  `ProfileView` as a sheet, following the same `@State private var
  showX: Bool` + `.sheet(isPresented:)` pattern already used for
  `showAddHive`.

## Out of Scope

- No multi-profile / multi-apiary support.
- No validation or required fields — all fields optional, per user
  decision.
- No integration with the existing JSON export/import feature.
- No reverse-geocoding or map display of the coordinates — plain
  text fields only.

## Testing

Manual verification (no automated UI test infra exists in this
project currently):

1. Open Perfil from the toolbar menu, fill in all fields, tap
   Guardar, reopen — values persist.
2. Tap Cancelar after editing — changes are discarded on reopen.
3. Tap "Usar localização atual", grant permission — lat/long fields
   populate from the simulator's simulated location.
4. Deny location permission — button does nothing harmful; manual
   entry still works.
5. Existing Exportar Dados / Importar Dados menu items still work
   unaffected by the new menu item.
