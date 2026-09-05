# Beekeeper Profile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a single-record beekeeper profile (apiarist number, association name, registered hive count, GPS coordinates) accessible from the Home toolbar menu, persisted the same way hives are.

**Architecture:** A new `BeekeeperProfile` Codable struct (all `String` fields, empty = unset) backed by a new `@Observable ProfileStore` that persists to `UserDefaults` exactly like the existing `HiveStore`. A new `ProfileView` sheet edits a local copy of the fields and commits to the store on save. A `LocationFetcher` wraps `CLLocationManager` for a one-shot "use current location" button. Wiring: `ContentView` injects `ProfileStore` into the environment; `HomeView`'s existing `⋯` menu gets a "Perfil" entry that presents `ProfileView`.

**Tech Stack:** Swift 5 / SwiftUI, `Observation` framework (`@Observable`), `CoreLocation`, `UserDefaults` + `JSONEncoder`/`JSONDecoder`. No test target exists in this project (`xcodebuild -list` shows no test scheme) — verification is build success (`xcodebuild build`) plus manual steps in the simulator, per the spec's own Testing section.

**Spec:** `docs/superpowers/specs/2026-09-05-beekeeper-profile-design.md`

## Global Constraints

- All profile fields are `String`, default `""` — no `Optional` types, matching how `Hive.localizacao` and other free-text fields already represent "no value" in this codebase.
- `numeroColmeiasRegistadas` is a manual field, independent of `HiveStore.hives.count` — never auto-computed.
- No required-field validation anywhere — Guardar is always enabled.
- No integration with the existing JSON export/import feature — profile is out of scope for it.
- Exactly one profile per install — no id, no multi-profile support.
- UI copy is European Portuguese, matching the rest of the app (e.g. "Guardar", "Cancelar", "Localização").
- New `.swift` files go directly in `BeeKeeping/` — the project uses `PBXFileSystemSynchronizedRootGroup`, so no `.pbxproj` editing is needed for Xcode to pick them up.
- Build verification command: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build` (run from the repo root, i.e. `/Users/Natasha/Documents/IOS Apps/BeeKeeping`). Expect `** BUILD SUCCEEDED **` in the output.

---

### Task 1: BeekeeperProfile model

**Files:**
- Modify: `BeeKeeping/Models.swift` (append to end of file, after the `extension Hive` sample-data block)

**Interfaces:**
- Produces: `struct BeekeeperProfile: Codable, Equatable` with fields `numeroApicultor: String`, `nomeAssociacao: String`, `numeroColmeiasRegistadas: String`, `latitude: String`, `longitude: String`, each defaulting to `""`.

- [ ] **Step 1: Add the model**

Append to `BeeKeeping/Models.swift`:

```swift

// MARK: - Beekeeper Profile

struct BeekeeperProfile: Codable, Equatable {
    var numeroApicultor: String = ""
    var nomeAssociacao: String = ""
    var numeroColmeiasRegistadas: String = ""
    var latitude: String = ""
    var longitude: String = ""
}
```

`Equatable` is added (harmless, zero extra code since all members are
`String`) so `ProfileView` can compare the local draft against the
stored value if needed later — no other task currently depends on it,
it's just free with a struct of only `String` members.

- [ ] **Step 2: Verify it builds**

Run: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add BeeKeeping/Models.swift
git commit -m "Add BeekeeperProfile model"
```

---

### Task 2: ProfileStore persistence

**Files:**
- Create: `BeeKeeping/ProfileStore.swift`

**Interfaces:**
- Consumes: `BeekeeperProfile` (Task 1).
- Produces: `@Observable class ProfileStore` with `var profile: BeekeeperProfile` (persists on `didSet`), used by `ContentView` (Task 5) and `ProfileView` (Task 4).

- [ ] **Step 1: Create the store**

Create `BeeKeeping/ProfileStore.swift`:

```swift
import SwiftUI
import Observation

@Observable
class ProfileStore {
    var profile: BeekeeperProfile = BeekeeperProfile() {
        didSet { save() }
    }

    private static let storageKey = "colmeias_profile_v1"

    init() {
        load()
    }

    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else { return }
        let decoder = JSONDecoder()
        if let saved = try? decoder.decode(BeekeeperProfile.self, from: data) {
            profile = saved
        }
    }
}
```

This is a direct copy of `HiveStore`'s `save()`/`load()` pattern
(`HiveStore.swift:16-31`), minus the `dateEncodingStrategy` (no `Date`
fields on `BeekeeperProfile`) and minus the array wrapper (single
value, not `[Hive]`).

- [ ] **Step 2: Verify it builds**

Run: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add BeeKeeping/ProfileStore.swift
git commit -m "Add ProfileStore persistence"
```

---

### Task 3: LocationFetcher + Info.plist permission string

**Files:**
- Create: `BeeKeeping/LocationFetcher.swift`
- Modify: `BeeKeeping/Info.plist`

**Interfaces:**
- Produces: `@Observable class LocationFetcher` with:
  - `var coordinate: (latitude: Double, longitude: Double)?` — the last successfully fetched coordinate, set once a request completes.
  - `var isFetching: Bool` — true while a request is in flight, for disabling the button / showing a spinner.
  - `func requestLocation()` — kicks off a one-shot location request (requests authorization first if needed).
  - Consumed by `ProfileView` (Task 4).

- [ ] **Step 1: Add the location permission string**

In `BeeKeeping/Info.plist`, add a new key-value pair inside the root
`<dict>`, alongside the existing `NSMicrophoneUsageDescription` entry
(around line 9-10):

```xml
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>A Colmeias usa a localização para preencher automaticamente as coordenadas GPS do teu apiário no perfil.</string>
```

- [ ] **Step 2: Create LocationFetcher**

Create `BeeKeeping/LocationFetcher.swift`:

```swift
import CoreLocation
import Observation

@Observable
class LocationFetcher: NSObject, CLLocationManagerDelegate {
    var coordinate: (latitude: Double, longitude: Double)?
    var isFetching: Bool = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        isFetching = true
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isFetching = false
        @unknown default:
            isFetching = false
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            isFetching = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isFetching = false
        guard let loc = locations.last else { return }
        coordinate = (latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isFetching = false
    }
}
```

Per the spec, there's no custom error alert on failure/denial — the
fields simply stay whatever they were, and `isFetching` resets so the
button becomes usable again.

- [ ] **Step 3: Verify it builds**

Run: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add BeeKeeping/LocationFetcher.swift BeeKeeping/Info.plist
git commit -m "Add LocationFetcher and location permission string"
```

---

### Task 4: ProfileView

**Files:**
- Create: `BeeKeeping/ProfileView.swift`

**Interfaces:**
- Consumes: `ProfileStore` (Task 2, via `@Environment(ProfileStore.self)`), `LocationFetcher` (Task 3, via local `@State`), `BeekeeperProfile` (Task 1).
- Produces: `struct ProfileView: View` with `@Binding var isPresented: Bool`, presented as a sheet from `HomeView` (Task 5).

- [ ] **Step 1: Create the view**

Create `BeeKeeping/ProfileView.swift`:

```swift
import SwiftUI

struct ProfileView: View {
    @Binding var isPresented: Bool
    @Environment(ProfileStore.self) private var store

    @State private var numeroApicultor = ""
    @State private var nomeAssociacao = ""
    @State private var numeroColmeiasRegistadas = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var locationFetcher = LocationFetcher()

    var body: some View {
        NavigationStack {
            Form {
                Section("Apicultor") {
                    TextField("Número de Apicultor", text: $numeroApicultor)
                    TextField("Nome da Associação", text: $nomeAssociacao)
                    TextField("Número de Colmeias Registadas", text: $numeroColmeiasRegistadas)
                        .keyboardType(.numberPad)
                }
                Section("Localização") {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                    Button {
                        locationFetcher.requestLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Usar Localização Atual")
                            if locationFetcher.isFetching {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(locationFetcher.isFetching)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { isPresented = false }
                        .foregroundStyle(Color.amberAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        store.profile = BeekeeperProfile(
                            numeroApicultor: numeroApicultor,
                            nomeAssociacao: nomeAssociacao,
                            numeroColmeiasRegistadas: numeroColmeiasRegistadas,
                            latitude: latitude,
                            longitude: longitude
                        )
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.amberAccent)
                }
            }
            .onAppear {
                numeroApicultor = store.profile.numeroApicultor
                nomeAssociacao = store.profile.nomeAssociacao
                numeroColmeiasRegistadas = store.profile.numeroColmeiasRegistadas
                latitude = store.profile.latitude
                longitude = store.profile.longitude
            }
            .onChange(of: locationFetcher.coordinate?.latitude) {
                guard let coord = locationFetcher.coordinate else { return }
                latitude = String(coord.latitude)
                longitude = String(coord.longitude)
            }
        }
    }
}

#Preview {
    ProfileView(isPresented: .constant(true))
        .environment(ProfileStore())
}
```

This follows `AddHiveSheet`'s exact toolbar/sheet pattern
(`HomeView.swift:319-364`): `NavigationStack` + `Form`, Cancelar on
`topBarLeading`, a bold action button on `topBarTrailing`, fields
seeded `onAppear` and committed to the store only when Guardar is
tapped — so Cancelar discards edits, matching the spec's requirement.

- [ ] **Step 2: Verify it builds**

Run: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add BeeKeeping/ProfileView.swift
git commit -m "Add ProfileView"
```

---

### Task 5: Wire ProfileStore and Perfil menu item into the app

**Files:**
- Modify: `BeeKeeping/ContentView.swift`
- Modify: `BeeKeeping/HomeView.swift`

**Interfaces:**
- Consumes: `ProfileStore` (Task 2), `ProfileView` (Task 4).

- [ ] **Step 1: Inject ProfileStore in ContentView**

In `BeeKeeping/ContentView.swift`, add a second `@State` store next to
the existing one and inject it into the environment alongside
`HiveStore`:

```swift
struct ContentView: View {
    @State private var store = HiveStore()
    @State private var profileStore = ProfileStore()
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
```

And update the `.environment(store)` line to also inject
`profileStore`:

```swift
            .tint(.amberAccent)
            .environment(store)
            .environment(profileStore)
```

- [ ] **Step 2: Add the Perfil menu item in HomeView**

In `BeeKeeping/HomeView.swift`, add a `showProfile` state var next to
the existing `showAddHive` one:

```swift
    @State private var showAddHive = false
    @State private var showProfile = false
```

Add "Perfil" as the first item in the existing toolbar `Menu` (the one
containing "Exportar Dados" / "Importar Dados", around
`HomeView.swift:88-100`):

```swift
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Perfil", systemImage: "person.circle") {
                        showProfile = true
                    }
                    Button("Exportar Dados", systemImage: "square.and.arrow.up") {
                        exportData()
                    }
                    Button("Importar Dados", systemImage: "square.and.arrow.down") {
                        showImporter = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.amberDark)
                }
            }
```

Add a `.sheet` for it next to the existing `showAddHive` sheet (around
`HomeView.swift:117-120`):

```swift
        .sheet(isPresented: $showAddHive) {
            AddHiveSheet(isPresented: $showAddHive)
                .environment(store)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(isPresented: $showProfile)
        }
```

`ProfileView` doesn't need an explicit `.environment(profileStore)`
here since `ContentView` already injects `ProfileStore` into the whole
`NavigationStack` environment, and sheets presented from within it
inherit that environment automatically — same reason `AddHiveSheet`
doesn't need `.environment(store)` re-declared either, but it's
already there in the existing code for `HiveStore` explicitly, so:
double check by building (next step) — `@Environment(ProfileStore.self)`
in `ProfileView` will crash at runtime with a clear "No Observable
object of type ProfileStore found" message if this assumption is
wrong, at which point add `.environment(profileStore)` to the
`ProfileView` sheet explicitly, mirroring `AddHiveSheet`.

- [ ] **Step 3: Verify it builds**

Run: `xcodebuild -project BeeKeeping.xcodeproj -scheme BeeKeeping -destination 'generic/platform=iOS Simulator' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Manual verification in the simulator**

Run the app in a simulator (Xcode ▶ or `xcodebuild ... -destination
'platform=iOS Simulator,name=iPhone 16' build` then launch via
Simulator/Xcode) and check:

1. Tap `⋯` on Home → "Perfil" appears above "Exportar Dados". Tap it →
   `ProfileView` sheet opens.
2. Fill in all five fields, tap Guardar, reopen Perfil → values persist.
3. Edit a field, tap Cancelar, reopen Perfil → previous saved values
   are shown (edit was discarded).
4. Tap "Usar Localização Atual" → simulator prompts for location
   permission (Simulator → Features → Location → Custom Location can
   set a fake one) → Latitude/Longitude fields populate.
5. Exportar Dados / Importar Dados still work as before (unaffected by
   the new menu item).

- [ ] **Step 5: Commit**

```bash
git add BeeKeeping/ContentView.swift BeeKeeping/HomeView.swift
git commit -m "Wire beekeeper profile into app navigation"
```

---

## Self-Review Notes

- **Spec coverage:** model (Task 1), storage (Task 2), location (Task
  3), view (Task 4), wiring + manual test script (Task 5) — every spec
  section has a task.
- **Placeholder scan:** no TBD/TODO; all code blocks are complete,
  copy-pasteable Swift.
- **Type consistency:** `BeekeeperProfile` field names match exactly
  across Task 1 (definition), Task 2 (`ProfileStore.profile`), and
  Task 4 (`ProfileView`'s `@State` vars and the `Guardar` action).
  `LocationFetcher.coordinate`/`isFetching`/`requestLocation()` match
  between Task 3 (definition) and Task 4 (usage).
