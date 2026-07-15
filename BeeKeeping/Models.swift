import SwiftUI

// MARK: - Enums

enum HivePhase: String, CaseIterable, Codable {
    case crescimento, manutencao, producao

    var label: String {
        switch self {
        case .crescimento: return "Crescimento"
        case .manutencao:  return "Manutenção"
        case .producao:    return "Produção"
        }
    }

    var badgeBackground: Color {
        switch self {
        case .crescimento: return Color(hex: "E8F5E9")
        case .manutencao:  return Color(hex: "FFF3E0")
        case .producao:    return Color(hex: "FFF8E1")
        }
    }

    var badgeColor: Color {
        switch self {
        case .crescimento: return Color(hex: "2E7D32")
        case .manutencao:  return Color(hex: "E65100")
        case .producao:    return Color(hex: "F57F17")
        }
    }
}

enum HiveStatus: String, CaseIterable, Codable {
    case saudavel       = "Saudável"
    case infectada      = "Infectada"
    case baixasReservas = "Baixas Reservas"

    var icon: String {
        switch self {
        case .saudavel:       return "checkmark.circle.fill"
        case .infectada:      return "exclamationmark.triangle.fill"
        case .baixasReservas: return "chart.bar.fill"
        }
    }

    var color: Color {
        switch self {
        case .saudavel:       return Color(hex: "2E7D32")
        case .infectada:      return Color(hex: "C62828")
        case .baixasReservas: return Color(hex: "E65100")
        }
    }

    var badgeBackground: Color {
        switch self {
        case .saudavel:       return Color(hex: "E8F5E9")
        case .infectada:      return Color(hex: "FFEBEE")
        case .baixasReservas: return Color(hex: "FFF3E0")
        }
    }
}

enum BoxType: String, CaseIterable, Codable {
    case ninho, alca, meiaAlca

    var label: String {
        switch self {
        case .ninho:    return "Ninho"
        case .alca:     return "Alça"
        case .meiaAlca: return "½ Alça"
        }
    }
}

enum FrameType: String, CaseIterable, Codable {
    case vazio, criacao, alimentacao

    var shortLabel: String {
        switch self {
        case .vazio:       return "Vazio"
        case .criacao:     return "Criação"
        case .alimentacao: return "Aliment."
        }
    }

    var fullLabel: String {
        switch self {
        case .vazio:       return "Vazio"
        case .criacao:     return "Criação"
        case .alimentacao: return "Alimentação"
        }
    }

    var legendDescription: String {
        switch self {
        case .vazio:       return "Quadro sem ocupação"
        case .criacao:     return "Ovos, larvas e pupas"
        case .alimentacao: return "Mel, pólen, alimentação artificial"
        }
    }

    var color: Color {
        switch self {
        case .vazio:       return Color(hex: "E0D8D0")
        case .criacao:     return Color(hex: "F4923A")
        case .alimentacao: return Color(hex: "F6CC4A")
        }
    }

    var textColor: Color {
        return self == .vazio ? Color(hex: "A09888") : .white
    }

    var next: FrameType {
        switch self {
        case .vazio:       return .criacao
        case .criacao:     return .alimentacao
        case .alimentacao: return .vazio
        }
    }
}

enum DisinfMethod: String, CaseIterable, Codable {
    case sublimacao   = "Sublimação"
    case gotejamento  = "Gotejamento"
    case pulverizacao = "Pulverização"
    case outro        = "Outro"

    var badgeBackground: Color {
        switch self {
        case .sublimacao:   return Color(hex: "E8F5E9")
        case .gotejamento:  return Color(hex: "E3F2FD")
        case .pulverizacao: return Color(hex: "F3E5F5")
        case .outro:        return Color(hex: "F5F5F5")
        }
    }

    var badgeColor: Color {
        switch self {
        case .sublimacao:   return Color(hex: "2E7D32")
        case .gotejamento:  return Color(hex: "1565C0")
        case .pulverizacao: return Color(hex: "6A1B9A")
        case .outro:        return Color(hex: "616161")
        }
    }
}

enum FeedingType: String, CaseIterable, Codable {
    case solido  = "Sólido"
    case liquido = "Líquido"

    var icon: String {
        switch self {
        case .solido:  return "cube.fill"
        case .liquido: return "drop.fill"
        }
    }

    var badgeBackground: Color {
        switch self {
        case .solido:  return Color(hex: "FFF8E1")
        case .liquido: return Color(hex: "E3F2FD")
        }
    }

    var badgeColor: Color {
        switch self {
        case .solido:  return Color(hex: "F57F17")
        case .liquido: return Color(hex: "1565C0")
        }
    }
}

// Varroa risk level — computed from percentage, not stored
enum VarroaRisk {
    case seguro, atencao, alarme

    init(percentagem: Double) {
        if percentagem < 1 { self = .seguro }
        else if percentagem <= 3 { self = .atencao }
        else { self = .alarme }
    }

    var label: String {
        switch self {
        case .seguro:  return "Nível Seguro"
        case .atencao: return "Atenção"
        case .alarme:  return "Risco/Alarme"
        }
    }

    var shortLabel: String {
        switch self {
        case .seguro:  return "Seguro"
        case .atencao: return "Atenção"
        case .alarme:  return "Alarme"
        }
    }

    var color: Color {
        switch self {
        case .seguro:  return Color(hex: "2E7D32")
        case .atencao: return Color(hex: "E65100")
        case .alarme:  return Color(hex: "C62828")
        }
    }

    var badgeBackground: Color {
        switch self {
        case .seguro:  return Color(hex: "E8F5E9")
        case .atencao: return Color(hex: "FFF3E0")
        case .alarme:  return Color(hex: "FFEBEE")
        }
    }

    var icon: String {
        switch self {
        case .seguro:  return "checkmark.shield.fill"
        case .atencao: return "exclamationmark.triangle.fill"
        case .alarme:  return "xmark.shield.fill"
        }
    }
}

// MARK: - Models

struct HiveFrame: Identifiable, Codable {
    let id: Int
    var tipo: FrameType
}

struct HiveBox: Identifiable, Codable {
    let id: String
    let tipo: BoxType
    let label: String
    var quadros: [HiveFrame]?
}

struct Feeding: Identifiable, Codable {
    let id: String
    var produto: String
    var tipo: FeedingType
    var data: Date
    var dose: String
    var notas: String
}

struct Disinfection: Identifiable, Codable {
    let id: String
    var data: Date
    var produto: String
    var dose: String
    var metodo: DisinfMethod
    var proximaData: Date?
    var notas: String

    var isOverdue: Bool {
        guard let next = proximaData else { return false }
        return next <= Date()
    }
}

struct VarroaTest: Identifiable, Codable {
    let id: String
    var data: Date
    var nAcaros: Int
    var nAbelhas: Int
    var notas: String

    var percentagem: Double {
        guard nAbelhas > 0 else { return 0 }
        return Double(nAcaros) / Double(nAbelhas) * 100
    }

    var risco: VarroaRisk { VarroaRisk(percentagem: percentagem) }
}

struct Hive: Identifiable, Codable {
    let id: Int
    var nome: String
    var localizacao: String
    var fase: HivePhase
    var status: HiveStatus
    var dataInstalacao: Date
    var estrutura: [HiveBox]
    var desinfeccoes: [Disinfection]
    var alimentacoes: [Feeding]
    var varroaTestes: [VarroaTest]

    var estruturaSummary: String {
        var ninhos = 0, alcas = 0, meiaAlcas = 0
        for box in estrutura {
            switch box.tipo {
            case .ninho:    ninhos += 1
            case .alca:     alcas += 1
            case .meiaAlca: meiaAlcas += 1
            }
        }
        var parts: [String] = []
        if ninhos    > 0 { parts.append("\(ninhos) Ninho\(ninhos > 1 ? "s" : "")") }
        if alcas     > 0 { parts.append("\(alcas) Alça\(alcas > 1 ? "s" : "")") }
        if meiaAlcas > 0 { parts.append("\(meiaAlcas) ½ Alça\(meiaAlcas > 1 ? "s" : "")") }
        return parts.joined(separator: " + ")
    }
}

// MARK: - Color Helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255
        let g = Double((int & 0x00FF00) >>  8) / 255
        let b = Double( int & 0x0000FF        ) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let cream          = Color(hex: "FFF8EE")
    static let creamSecondary = Color(hex: "F4EDE3")
    static let amberAccent    = Color(hex: "E8A020")
    static let amberDark      = Color(hex: "C47A10")
    static let brownDark      = Color(hex: "2D1600")
    static let brownMedium    = Color(hex: "7A5020")
    static let brownLight     = Color(hex: "B08050")
    static let cardBg         = Color(hex: "FFFDF8")
}

extension Date {
    var ddMMYYYY: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: self)
    }
}

// MARK: - Sample Data

extension Hive {
    static let sample: Hive = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return Hive(
            id: 1,
            nome: "Amendoeira 1",
            localizacao: "Quinta do Souto",
            fase: .producao,
            status: .saudavel,
            dataInstalacao: df.date(from: "2024-03-15")!,
            estrutura: [
                HiveBox(id: "ninho-1", tipo: .ninho, label: "Ninho", quadros: [
                    HiveFrame(id: 1, tipo: .criacao),
                    HiveFrame(id: 2, tipo: .criacao),
                    HiveFrame(id: 3, tipo: .criacao),
                    HiveFrame(id: 4, tipo: .alimentacao),
                    HiveFrame(id: 5, tipo: .criacao),
                    HiveFrame(id: 6, tipo: .criacao),
                    HiveFrame(id: 7, tipo: .vazio),
                    HiveFrame(id: 8, tipo: .criacao),
                    HiveFrame(id: 9, tipo: .alimentacao),
                    HiveFrame(id: 10, tipo: .vazio),
                ]),
                HiveBox(id: "alca-1", tipo: .alca, label: "Alça 1"),
                HiveBox(id: "alca-2", tipo: .meiaAlca, label: "½ Alça"),
            ],
            desinfeccoes: [
                Disinfection(
                    id: "d1",
                    data: df.date(from: "2025-04-15")!,
                    produto: "Ácido Oxálico",
                    dose: "35ml por colmeia",
                    metodo: .sublimacao,
                    proximaData: df.date(from: "2025-07-15"),
                    notas: "Aplicado ao entardecer. Colmeia sem criação. Excelente resposta."
                ),
                Disinfection(
                    id: "d2",
                    data: df.date(from: "2025-01-10")!,
                    produto: "Apibioxal",
                    dose: "2,3g por quadro",
                    metodo: .gotejamento,
                    proximaData: df.date(from: "2025-04-10"),
                    notas: ""
                ),
            ],
            alimentacoes: [],
            varroaTestes: []
        )
    }()
}
