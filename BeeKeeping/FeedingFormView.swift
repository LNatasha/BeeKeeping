import SwiftUI

struct FeedingFormView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var produto = ""
    @State private var tipo = FeedingType.liquido
    @State private var data = Date()
    @State private var dose = ""
    @State private var notas = ""

    private var isValid: Bool { !produto.trimmingCharacters(in: .whitespaces).isEmpty }

    private var formDivider: some View {
        Rectangle()
            .fill(Color.amberDark.opacity(0.1))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Produto e Data
                FormSection(title: "PRODUTO E DATA") {
                    FormRow {
                        Text("Produto")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .frame(width: 90, alignment: .leading)
                        TextField("Ex: Xarope de açúcar", text: $produto)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownMedium)
                            .multilineTextAlignment(.trailing)
                    }
                    formDivider
                    FormRow {
                        Text("Data")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .frame(width: 90, alignment: .leading)
                        Spacer()
                        DatePicker("", selection: $data, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 16)

                // MARK: Tipo
                FormSection(title: "TIPO DE ALIMENTAÇÃO") {
                    HStack(spacing: 8) {
                        ForEach(FeedingType.allCases, id: \.self) { t in
                            Button {
                                tipo = t
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: t.icon)
                                        .font(.system(size: 13))
                                    Text(t.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(tipo == t ? .white : Color.brownMedium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(tipo == t ? Color.amberAccent : Color(hex: "F0E8DC"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
                .padding(.horizontal, 16)

                // MARK: Dose e Notas
                FormSection(title: "DETALHES") {
                    FormRow {
                        Text("Dose")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .frame(width: 90, alignment: .leading)
                        TextField("Ex: 500ml por colmeia", text: $dose)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownMedium)
                            .multilineTextAlignment(.trailing)
                    }
                    formDivider
                    FormRow {
                        TextField("Notas (opcional)", text: $notas, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.brownMedium)
                            .lineLimit(3...6)
                    }
                }
                .padding(.horizontal, 16)

                // MARK: Guardar
                Button {
                    save()
                } label: {
                    Text("Guardar Alimentação")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isValid ? Color.cream : Color.brownLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(isValid ? Color.amberAccent : Color(hex: "E0D8D0"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: isValid ? Color.amberAccent.opacity(0.3) : .clear, radius: 8, y: 4)
                }
                .disabled(!isValid)
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .padding(.top, 20)
        }
        .background(Color.creamSecondary)
        .navigationTitle("Nova Alimentação")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(Color.amberAccent)
            }
        }
    }

    private func save() {
        let feeding = Feeding(
            id: UUID().uuidString,
            produto: produto.trimmingCharacters(in: .whitespaces),
            tipo: tipo,
            data: data,
            dose: dose.trimmingCharacters(in: .whitespaces),
            notas: notas.trimmingCharacters(in: .whitespaces)
        )
        store.addFeeding(feeding, to: hiveId)
        dismiss()
    }
}
