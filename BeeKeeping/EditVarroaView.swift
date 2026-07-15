import SwiftUI

private enum BeesEditMode { case count, weight }
private enum WeightEditUnit { case gramas, miligramas }

struct EditVarroaView: View {
    let teste: VarroaTest
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var data: Date
    @State private var inputMode: BeesEditMode = .count
    @State private var beesText: String
    @State private var weightText = ""
    @State private var weightUnit: WeightEditUnit = .gramas
    @State private var acarosText: String
    @State private var notas: String
    @State private var showDeleteConfirm = false

    init(teste: VarroaTest, hiveId: Int) {
        self.teste = teste
        self.hiveId = hiveId
        _data = State(initialValue: teste.data)
        _beesText = State(initialValue: "\(teste.nAbelhas)")
        _acarosText = State(initialValue: "\(teste.nAcaros)")
        _notas = State(initialValue: teste.notas)
    }

    private var calculatedBees: Int {
        switch inputMode {
        case .count:
            return Int(beesText) ?? 0
        case .weight:
            let val = Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
            return weightUnit == .gramas ? Int(val * 10) : Int(val / 100)
        }
    }

    private var nAcaros: Int { Int(acarosText) ?? 0 }

    private var percentagem: Double {
        guard calculatedBees > 0 else { return 0 }
        return Double(nAcaros) / Double(calculatedBees) * 100
    }

    private var risco: VarroaRisk { VarroaRisk(percentagem: percentagem) }
    private var canSave: Bool { calculatedBees > 0 && nAcaros >= 0 }

    private var formDivider: some View {
        Rectangle().fill(Color.amberDark.opacity(0.12)).frame(height: 0.5).padding(.horizontal, 16)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    FormSection(title: "Data") {
                        FormRow {
                            DatePicker("", selection: $data, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }

                    FormSection(title: "Método de Contagem") {
                        FormRow {
                            HStack(spacing: 10) {
                                ForEach([(BeesEditMode.count, "Contagem"), (.weight, "Por Peso")], id: \.1) { mode, label in
                                    Button { inputMode = mode } label: {
                                        Text(label)
                                            .font(.system(size: 13, weight: .medium))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(inputMode == mode ? Color.amberAccent : Color.amberDark.opacity(0.08))
                                            .foregroundStyle(inputMode == mode ? Color.cream : Color.brownDark)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                        }
                    }

                    if inputMode == .count {
                        FormSection(title: "Número de Abelhas") {
                            FormRow {
                                TextField("Ex: 100", text: $beesText)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.brownDark)
                            }
                        }
                    } else {
                        FormSection(title: "Peso da Amostra") {
                            VStack(spacing: 0) {
                                FormRow {
                                    HStack(spacing: 12) {
                                        TextField("Ex: 10", text: $weightText)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.brownDark)
                                        HStack(spacing: 0) {
                                            ForEach([(WeightEditUnit.gramas, "g"), (.miligramas, "mg")], id: \.1) { unit, label in
                                                Button { weightUnit = unit } label: {
                                                    Text(label)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(weightUnit == unit ? Color.amberAccent : Color.amberDark.opacity(0.08))
                                                        .foregroundStyle(weightUnit == unit ? Color.cream : Color.brownDark)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .clipShape(Capsule())
                                    }
                                }
                                if calculatedBees > 0 {
                                    formDivider
                                    FormRow {
                                        HStack {
                                            Text("Abelhas calculadas")
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.brownLight)
                                            Spacer()
                                            Text("≈ \(calculatedBees) abelhas")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(Color.brownMedium)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    FormSection(title: "Número de Ácaros") {
                        FormRow {
                            TextField("Ex: 3", text: $acarosText)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                        }
                    }

                    // Live result
                    if calculatedBees > 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(String(format: "%.2f%%", percentagem))
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundStyle(risco.color)
                                    Text("\(nAcaros) ácaros em \(calculatedBees) abelhas")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.brownLight)
                                }
                                Spacer()
                                HStack(spacing: 5) {
                                    Image(systemName: risco.icon).font(.system(size: 12))
                                    Text(risco.label).font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(risco.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(risco.badgeBackground)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(16)
                        .background(Color.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(risco.color.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, 16)
                        .animation(.easeInOut(duration: 0.2), value: percentagem)
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
            .navigationTitle("Editar Teste Varroa")
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
                        .foregroundStyle(canSave ? Color.amberAccent : Color.brownLight)
                        .disabled(!canSave)
                }
            }
            .confirmationDialog("Eliminar este teste?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Eliminar", role: .destructive) {
                    store.deleteVarroaTest(id: teste.id, hiveId: hiveId)
                    dismiss()
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func save() {
        var updated = teste
        updated.data = data
        updated.nAcaros = nAcaros
        updated.nAbelhas = calculatedBees
        updated.notas = notas
        store.updateVarroaTest(updated, hiveId: hiveId)
        dismiss()
    }
}
