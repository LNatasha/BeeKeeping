import SwiftUI

struct HiveDetailView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false

    private var hive: Hive? { store.hives.first { $0.id == hiveId } }

    var body: some View {
        Group {
            if let hive {
                HiveDetailContent(hive: hive)
            }
        }
        .navigationTitle(hive?.nome ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") { showEdit = true }
                    .foregroundStyle(Color.amberAccent)
            }
        }
        .sheet(isPresented: $showEdit) {
            EditHiveView(isPresented: $showEdit, hiveId: hiveId)
                .environment(store)
        }
        .onChange(of: store.hives.count) { _, _ in
            if hive == nil { dismiss() }
        }
    }
}

struct HiveDetailContent: View {
    let hive: Hive

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient header
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color(hex: "E8A020"), Color(hex: "C47A10")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(hive.fase.label)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.cream)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.22))
                                .clipShape(Capsule())
                            HStack(spacing: 4) {
                                Image(systemName: hive.status.icon)
                                    .font(.system(size: 10))
                                Text(hive.status.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(hive.status.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(hive.status.badgeBackground)
                            .clipShape(Capsule())
                        }

                        Text(hive.nome)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color.cream)

                        Text("📍 \(hive.localizacao)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.cream.opacity(0.65))

                        Text("📅 Instalada em \(hive.dataInstalacao.ddMMYYYY)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.cream.opacity(0.50))
                    }
                    .padding(20)
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 12) {
                    StructureCard(hiveId: hive.id, estrutura: hive.estrutura)

                    VarroaSummaryCard(lastTest: hive.varroaTestes.first)

                    HStack(spacing: 10) {
                        LastDesinfCard(desinfeccao: hive.desinfeccoes.first)
                        NextDesinfCard(desinfeccao: hive.desinfeccoes.first)
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            NavigationLink(value: NavTarget.desinfForm(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("+ Desinfecção")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("Novo registo")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: NavTarget.desinfHistory(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Historial")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("\(hive.desinfeccoes.count) registos")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 10) {
                            NavigationLink(value: NavTarget.varroaForm(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("+ Varroa")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("Novo teste")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: NavTarget.varroaHistory(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Historial Varroa")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("\(hive.varroaTestes.count) testes")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 10) {
                            NavigationLink(value: NavTarget.feedingForm(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("+ Alimentação")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("Novo registo")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: NavTarget.feedingHistory(hive.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Historial Alim.")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.amberDark)
                                    Text("\(hive.alimentacoes.count) registos")
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.brownLight)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.amberDark.opacity(0.25), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
                .padding(.top, 16)
                .background(Color.creamSecondary)
            }
        }
        .background(Color.creamSecondary)
    }
}

// MARK: - Varroa Summary Card

struct VarroaSummaryCard: View {
    let lastTest: VarroaTest?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ÚLTIMO TESTE VARROA")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brownLight)
                .padding(.bottom, 10)

            if let test = lastTest {
                let risk = test.risco
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f%%", test.percentagem))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(risk.color)
                            Text("infestação")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brownLight)
                        }
                        Text(test.data.ddMMYYYY)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.brownLight)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: risk.icon)
                                .font(.system(size: 12))
                            Text(risk.shortLabel)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(risk.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(risk.badgeBackground)
                        .clipShape(Capsule())
                        Text("\(test.nAcaros) ácaros / \(test.nAbelhas) abelhas")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.brownLight)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "shield.slash")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.brownLight.opacity(0.6))
                    Text("Sem testes registados")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.brownLight)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "502800").opacity(0.06), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.amberDark.opacity(0.15), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Structure Card

struct StructureCard: View {
    let hiveId: Int
    let estrutura: [HiveBox]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ESTRUTURA DA COLMEIA")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brownLight)
                .padding(.bottom, 16)

            VStack(spacing: 2) {
                ForEach(Array(estrutura.reversed())) { box in
                    if box.quadros != nil {
                        NavigationLink(value: NavTarget.frames(hiveId, box.id)) {
                            HiveBoxRow(box: box, isNavigable: true)
                        }
                        .buttonStyle(.plain)
                    } else {
                        HiveBoxRow(box: box, isNavigable: false)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color(hex: "502800").opacity(0.07), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.amberDark.opacity(0.18), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

struct HiveBoxRow: View {
    let box: HiveBox
    var isNavigable: Bool = false

    private var boxWidth: CGFloat {
        switch box.tipo {
        case .ninho:    return 260
        case .alca:     return 234
        case .meiaAlca: return 210
        }
    }

    private var boxHeight: CGFloat {
        switch box.tipo {
        case .ninho:    return 68
        case .alca:     return 48
        case .meiaAlca: return 32
        }
    }

    private var bgColor: Color {
        switch box.tipo {
        case .ninho:    return Color.amberDark
        case .alca:     return Color.amberAccent
        case .meiaAlca: return Color(hex: "F6E070")
        }
    }

    private var labelColor: Color {
        box.tipo == .meiaAlca ? Color.brownDark : Color.cream
    }

    private var cornerRadii: RectangleCornerRadii {
        switch box.tipo {
        case .ninho:
            return RectangleCornerRadii(
                topLeading: 0, bottomLeading: 14,
                bottomTrailing: 14, topTrailing: 0
            )
        default:
            return RectangleCornerRadii(
                topLeading: 10, bottomLeading: 0,
                bottomTrailing: 0, topTrailing: 10
            )
        }
    }

    var body: some View {
        HStack {
            Text(box.label)
                .font(.system(size: box.tipo == .ninho ? 16 : 14,
                              weight: box.tipo == .ninho ? .bold : .semibold))
                .foregroundStyle(labelColor)
            Spacer()
            if let count = box.quadros?.count {
                Text("\(count) quadros")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(labelColor.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Capsule())
            } else {
                Text(box.tipo.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(labelColor.opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Capsule())
            }
            if isNavigable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(labelColor.opacity(0.5))
                    .padding(.leading, 2)
            }
        }
        .padding(.horizontal, 16)
        .frame(width: boxWidth, height: boxHeight)
        .background(bgColor)
        .clipShape(UnevenRoundedRectangle(cornerRadii: cornerRadii))
        .overlay(
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .stroke(Color.black.opacity(0.08), lineWidth: 2)
        )
    }
}

// MARK: - Info Cards

struct LastDesinfCard: View {
    let desinfeccao: Disinfection?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ÚLTIMA DESINFECÇÃO")
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color.brownLight)
            Text(desinfeccao?.data.ddMMYYYY ?? "Sem registo")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.brownDark)
            Text(desinfeccao?.produto ?? "—")
                .font(.system(size: 11))
                .foregroundStyle(Color.brownMedium)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "502800").opacity(0.06), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.amberDark.opacity(0.15), lineWidth: 0.5)
        )
    }
}

struct NextDesinfCard: View {
    let desinfeccao: Disinfection?

    private var overdue: Bool { desinfeccao?.isOverdue ?? false }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PRÓXIMA")
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color.brownLight)
            Text(desinfeccao?.proximaData?.ddMMYYYY ?? "—")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(overdue ? Color(hex: "D03020") : Color.brownDark)
            Text(overdue ? "⚠ Em atraso" : "Prevista")
                .font(.system(size: 11))
                .foregroundStyle(Color.brownMedium)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(overdue ? Color(hex: "FFF0EE") : Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(hex: "502800").opacity(0.06), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.amberDark.opacity(0.15), lineWidth: 0.5)
        )
    }
}

#Preview {
    let store = HiveStore()
    store.hives = [Hive.sample]
    return NavigationStack {
        HiveDetailView(hiveId: 1)
    }
    .environment(store)
}
