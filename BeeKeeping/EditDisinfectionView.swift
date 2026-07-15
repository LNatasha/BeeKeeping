import SwiftUI

struct EditDisinfectionView: View {
    let desinfeccao: Disinfection
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var produto: String
    @State private var data: Date
    @State private var metodo: DisinfMethod
    @State private var dose: String
    @State private var hasProximaData: Bool
    @State private var proximaData: Date
    @State private var notas: String
    @State private var showDeleteConfirm = false

    init(desinfeccao: Disinfection, hiveId: Int) {
        self.desinfeccao = desinfeccao
        self.hiveId = hiveId
        _produto = State(initialValue: desinfeccao.produto)
        _data = State(initialValue: desinfeccao.data)
        _metodo = State(initialValue: desinfeccao.metodo)
        _dose = State(initialValue: desinfeccao.dose)
        _hasProximaData = State(initialValue: desinfeccao.proximaData != nil)
        _proximaData = State(initialValue: desinfeccao.proximaData ?? Date().addingTimeInterval(30 * 24 * 3600))
        _notas = State(initialValue: desinfeccao.notas)
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

                    FormSection(title: "Método de Aplicação") {
                        VStack(spacing: 0) {
                            ForEach(Array(DisinfMethod.allCases.enumerated()), id: \.element) { idx, m in
                                if idx > 0 { formDivider }
                                Button {
                                    metodo = m
                                } label: {
                                    FormRow {
                                        HStack {
                                            Text(m.rawValue)
                                                .font(.system(size: 15))
                                                .foregroundStyle(Color.brownDark)
                                            Spacer()
                                            if metodo == m {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(Color.amberAccent)
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    FormSection(title: "Dose") {
                        FormRow {
                            TextField("Ex: 35ml por colmeia", text: $dose)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                        }
                    }

                    FormSection(title: "Próxima Desinfecção") {
                        VStack(spacing: 0) {
                            FormRow {
                                Toggle("Definir data", isOn: $hasProximaData)
                                    .tint(Color.amberAccent)
                            }
                            if hasProximaData {
                                formDivider
                                FormRow {
                                    DatePicker("", selection: $proximaData, displayedComponents: .date)
                                        .labelsHidden()
                                }
                            }
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
            .navigationTitle("Editar Desinfecção")
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
                    store.deleteDisinfection(id: desinfeccao.id, hiveId: hiveId)
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func save() {
        var updated = desinfeccao
        updated.produto = produto
        updated.data = data
        updated.metodo = metodo
        updated.dose = dose
        updated.proximaData = hasProximaData ? proximaData : nil
        updated.notas = notas
        store.updateDisinfection(updated, hiveId: hiveId)
        dismiss()
    }

    private var formDivider: some View {
        Rectangle().fill(Color.amberDark.opacity(0.12)).frame(height: 0.5).padding(.horizontal, 16)
    }
}
