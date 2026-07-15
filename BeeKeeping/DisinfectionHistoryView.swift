import SwiftUI

struct DisinfectionHistoryView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store

    private var desinfeccoes: [Disinfection] {
        store.hives.first { $0.id == hiveId }?.desinfeccoes ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(desinfeccoes) { d in
                    DisinfCard(desinfeccao: d, hiveId: hiveId)
                }
            }
            .padding(16)

            NavigationLink(value: NavTarget.desinfForm(hiveId)) {
                Text("+ Nova Desinfecção")
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
        .navigationTitle("Historial")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct DisinfCard: View {
    let desinfeccao: Disinfection
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @State private var showEdit = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(desinfeccao.data.ddMMYYYY)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.brownDark)
                    Text(desinfeccao.produto)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.brownMedium)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(desinfeccao.metodo.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(desinfeccao.metodo.badgeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(desinfeccao.metodo.badgeBackground)
                        .clipShape(Capsule())
                    Button {
                        showEdit = true
                    } label: {
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

            VStack(spacing: 7) {
                HStack {
                    Text("Dose")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brownLight)
                    Spacer()
                    Text(desinfeccao.dose)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.brownMedium)
                }
                HStack {
                    Text("Próxima desinfecção")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brownLight)
                    Spacer()
                    Text(desinfeccao.proximaData?.ddMMYYYY ?? "—")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(desinfeccao.isOverdue ? Color(hex: "D03020") : Color.brownMedium)
                }
                let trimmed = desinfeccao.notas.trimmingCharacters(in: .whitespaces)
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
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "502800").opacity(0.07), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.amberDark.opacity(0.18), lineWidth: 0.5)
        )
        .sheet(isPresented: $showEdit) {
            EditDisinfectionView(desinfeccao: desinfeccao, hiveId: hiveId)
                .environment(store)
        }
    }
}

#Preview {
    let store = HiveStore()
    store.hives = [Hive.sample]
    return NavigationStack {
        DisinfectionHistoryView(hiveId: 1)
    }
    .environment(store)
}
