import SwiftUI
import Observation

@Observable
class HiveStore {
    var hives: [Hive] = [] {
        didSet { save() }
    }

    private static let storageKey = "colmeias_hives_v1"

    init() {
        load()
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(hives) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let saved = try? decoder.decode([Hive].self, from: data) {
            hives = saved
        }
    }

    private var nextId: Int { (hives.map(\.id).max() ?? 0) + 1 }

    func cycleFrame(hiveId: Int, boxId: String, frameId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        guard let bi = hives[hi].estrutura.firstIndex(where: { $0.id == boxId }) else { return }
        guard var quadros = hives[hi].estrutura[bi].quadros else { return }
        if let fi = quadros.firstIndex(where: { $0.id == frameId }) {
            quadros[fi].tipo = quadros[fi].tipo.next
            hives[hi].estrutura[bi].quadros = quadros
        }
    }

    func setFrame(hiveId: Int, boxId: String, frameId: Int, tipo: FrameType) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        guard let bi = hives[hi].estrutura.firstIndex(where: { $0.id == boxId }) else { return }
        guard var quadros = hives[hi].estrutura[bi].quadros else { return }
        if let fi = quadros.firstIndex(where: { $0.id == frameId }) {
            quadros[fi].tipo = tipo
            hives[hi].estrutura[bi].quadros = quadros
        }
    }

    func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(hives)
    }

    func importData(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        hives = try decoder.decode([Hive].self, from: data)
    }

    func addDisinfection(_ d: Disinfection, to hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].desinfeccoes.insert(d, at: 0)
    }

    func updateDisinfection(_ d: Disinfection, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        if let di = hives[hi].desinfeccoes.firstIndex(where: { $0.id == d.id }) {
            hives[hi].desinfeccoes[di] = d
        }
    }

    func deleteDisinfection(id: String, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].desinfeccoes.removeAll { $0.id == id }
    }

    func addFeeding(_ f: Feeding, to hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].alimentacoes.insert(f, at: 0)
    }

    func updateFeeding(_ f: Feeding, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        if let fi = hives[hi].alimentacoes.firstIndex(where: { $0.id == f.id }) {
            hives[hi].alimentacoes[fi] = f
        }
    }

    func deleteFeeding(id: String, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].alimentacoes.removeAll { $0.id == id }
    }

    func addVarroaTest(_ t: VarroaTest, to hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].varroaTestes.insert(t, at: 0)
    }

    func updateVarroaTest(_ t: VarroaTest, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        if let ti = hives[hi].varroaTestes.firstIndex(where: { $0.id == t.id }) {
            hives[hi].varroaTestes[ti] = t
        }
    }

    func deleteVarroaTest(id: String, hiveId: Int) {
        guard let hi = hives.firstIndex(where: { $0.id == hiveId }) else { return }
        hives[hi].varroaTestes.removeAll { $0.id == id }
    }

    func updateHive(_ hive: Hive) {
        guard let idx = hives.firstIndex(where: { $0.id == hive.id }) else { return }
        hives[idx] = hive
    }

    func deleteHive(id: Int) {
        hives.removeAll { $0.id == id }
    }

    func addHive(nome: String, localizacao: String, fase: HivePhase) {
        let id = nextId
        let hive = Hive(
            id: id,
            nome: nome,
            localizacao: localizacao,
            fase: fase,
            status: .saudavel,
            dataInstalacao: Date(),
            estrutura: [
                HiveBox(
                    id: "ninho-\(id)",
                    tipo: .ninho,
                    label: "Ninho",
                    quadros: (1...10).map { HiveFrame(id: $0, tipo: .vazio) }
                )
            ],
            desinfeccoes: [],
            alimentacoes: [],
            varroaTestes: []
        )
        hives.append(hive)
    }
}
