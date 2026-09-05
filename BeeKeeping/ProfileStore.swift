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
