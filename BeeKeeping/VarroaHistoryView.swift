import SwiftUI

struct VarroaHistoryView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store

    private var testes: [VarroaTest] {
        store.hives.first { $0.id == hiveId }?.varroaTestes ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if testes.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "shield.slash")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.amberAccent.opacity(0.4))
                        Text("Sem testes de varroa")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.brownLight)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                } else {
                    ForEach(testes) { t in
                        VarroaCard(teste: t, hiveId: hiveId)
                    }
                }
            }
            .padding(16)

            NavigationLink(value: NavTarget.varroaForm(hiveId)) {
                Text("+ Novo Teste Varroa")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.amberAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.amberAccent.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color.creamSecondary)
        .navigationTitle("Historial Varroa")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct VarroaCard: View {
    let teste: VarroaTest
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @State private var showEdit = false

    var body: some View {
        let risk = teste.risco
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(teste.data.ddMMYYYY)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.brownDark)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.2f%%", teste.percentagem))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(risk.color)
                        Text("infestação")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.brownLight)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: risk.icon)
                            .font(.system(size: 10))
                        Text(risk.shortLabel)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(risk.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(risk.badgeBackground)
                    .clipShape(Capsule())

                    Button { showEdit = true } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.brownLight)
                            .padding(6)
                            .background(Color.creamSecondary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .overlay(
                Rectangle()
                    .fill(Color.amberDark.opacity(0.15))
                    .frame(height: 0.5),
                alignment: .bottom
            )

            HStack {
                Text("\(teste.nAcaros) ácaros")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brownLight)
                Spacer()
                Text("\(teste.nAbelhas) abelhas")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.brownMedium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            let trimmed = teste.notas.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                Text(trimmed)
                    .font(.system(size: 12))
                    .italic()
                    .foregroundStyle(Color.brownMedium)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.creamSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "502800").opacity(0.07), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.amberDark.opacity(0.18), lineWidth: 0.5)
        )
        .sheet(isPresented: $showEdit) {
            EditVarroaView(teste: teste, hiveId: hiveId)
                .environment(store)
        }
    }
}

#Preview {
    let store = HiveStore()
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    var hive = Hive.sample
    hive.varroaTestes = [
        VarroaTest(id: "v1", data: df.date(from: "2025-05-10")!, nAcaros: 2, nAbelhas: 300, notas: "Inverno — baixa infestação."),
        VarroaTest(id: "v2", data: df.date(from: "2025-02-20")!, nAcaros: 12, nAbelhas: 300, notas: "Primavera — tratar urgente."),
        VarroaTest(id: "v3", data: df.date(from: "2024-11-05")!, nAcaros: 3, nAbelhas: 300, notas: ""),
    ]
    store.hives = [hive]
    return NavigationStack {
        VarroaHistoryView(hiveId: 1)
    }
    .environment(store)
}
