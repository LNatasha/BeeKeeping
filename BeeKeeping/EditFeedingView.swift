import SwiftUI

struct EditFeedingView: View {
    let feeding: Feeding
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var produto: String
    @State private var data: Date
    @State private var tipo: FeedingType
    @State private var dose: String
    @State private var notas: String
    @State private var showDeleteConfirm = false

    init(feeding: Feeding, hiveId: Int) {
        self.feeding = feeding
        self.hiveId = hiveId
        _produto = State(initialValue: feeding.produto)
        _data = State(initialValue: feeding.data)
        _tipo = State(initialValue: feeding.tipo)
        _dose = State(initialValue: feeding.dose)
        _notas = State(initialValue: feeding.notas)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FormSection(title: "Produto") {
                        FormRow {
                            TextField("Nome do produto", text: $produto)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                        }
                    }

                    FormSection(title: "Data") {
                        FormRow {
                            DatePicker("", selection: $data, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }

                    FormSection(title: "Tipo de Alimentação") {
                        FormRow {
                            HStack(spacing: 10) {
                                ForEach(FeedingType.allCases, id: \.self) { t in
                                    Button {
                                        tipo = t
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: t.icon)
                                                .font(.system(size: 11))
                                            Text(t.rawValue)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(tipo == t ? Color.amberAccent : Color.amberDark.opacity(0.08))
                                        .foregroundStyle(tipo == t ? Color.cream : Color.brownDark)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    FormSection(title: "Dose") {
                        FormRow {
                            TextField("Ex: 1 kg", text: $dose)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                        }
                    }

                    FormSection(title: "Notas") {
                        FormRow {
                            TextField("Observações (opcional)", text: $notas, axis: .vertical)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                                .lineLimit(3, reservesSpace: true)
                        }
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Eliminar Registo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(hex: "D03020"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: "FFF0EE"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
                .padding(.top, 16)
            }
            .background(Color.creamSecondary)
            .navigationTitle("Editar Alimentação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.amberAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.amberAccent)
                }
            }
            .confirmationDialog("Eliminar este registo?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Eliminar", role: .destructive) {
                    store.deleteFeeding(id: feeding.id, hiveId: hiveId)
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func save() {
        var updated = feeding
        updated.produto = produto
        updated.data = data
        updated.tipo = tipo
        updated.dose = dose
        updated.notas = notas
        store.updateFeeding(updated, hiveId: hiveId)
        dismiss()
    }
}
