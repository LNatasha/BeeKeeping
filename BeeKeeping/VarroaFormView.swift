import SwiftUI

private enum BeesInputMode { case count, weight }
private enum WeightUnit { case gramas, miligramas }

struct VarroaFormView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var data = Date()
    @State private var inputMode: BeesInputMode = .count
    @State private var beesText = ""
    @State private var weightText = ""
    @State private var weightUnit: WeightUnit = .gramas
    @State private var acarosText = ""
    @State private var notas = ""

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
        ScrollView {
            VStack(spacing: 16) {

                FormSection(title: "Data") {
                    FormRow {
                        DatePicker("", selection: $data, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

                FormSection(title: "Método de Contagem das Abelhas") {
                    FormRow {
                        HStack(spacing: 10) {
                            ForEach([(BeesInputMode.count, "Contagem"), (.weight, "Por Peso")], id: \.1) { mode, label in
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
                                        ForEach([(WeightUnit.gramas, "g"), (.miligramas, "mg")], id: \.1) { unit, label in
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
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                        Text("1 abelha ≈ 0,1 g (100 mg)")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(Color.brownLight)
                    .padding(.horizontal, 16)
                    .padding(.top, -8)
                }

                FormSection(title: "Número de Ácaros") {
                    FormRow {
                        TextField("Ex: 3", text: $acarosText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                    }
                }

                // Live result card
                if calculatedBees > 0 {
                    resultCard
                }

                FormSection(title: "Notas") {
                    FormRow {
                        TextField("Observações (opcional)", text: $notas, axis: .vertical)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .lineLimit(3, reservesSpace: true)
                    }
                }

                Button {
                    save()
                } label: {
                    Text("Guardar Teste")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(canSave ? Color.amberAccent : Color.brownLight)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSave)
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .padding(.top, 16)
        }
        .background(Color.creamSecondary)
        .navigationTitle("Novo Teste Varroa")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RESULTADO DO TESTE")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brownLight)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.2f%%", percentagem))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(risco.color)
                        Text("infestação")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.brownLight)
                    }
                    Text("\(nAcaros) ácaros em \(calculatedBees) abelhas")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.brownLight)
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: risco.icon)
                        .font(.system(size: 13))
                    Text(risco.label)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(risco.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(risco.badgeBackground)
                .clipShape(Capsule())
            }

            // Risk scale bar
            riskBar
        }
        .padding(16)
        .background(Color.cream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "502800").opacity(0.07), radius: 5, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(risco.color.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.2), value: percentagem)
    }

    private var riskBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.amberDark.opacity(0.1))
                        .frame(height: 8)
                    // Colored fill (capped at 5% → 100% width)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(risco.color)
                        .frame(width: geo.size.width * min(percentagem / 5, 1), height: 8)
                    // Threshold markers
                    Rectangle()
                        .fill(Color.brownLight.opacity(0.4))
                        .frame(width: 1.5, height: 12)
                        .offset(x: geo.size.width * 0.2 - 0.75, y: -2)  // 1%
                    Rectangle()
                        .fill(Color.brownLight.opacity(0.4))
                        .frame(width: 1.5, height: 12)
                        .offset(x: geo.size.width * 0.6 - 0.75, y: -2)  // 3%
                }
            }
            .frame(height: 8)

            HStack {
                Text("0%")
                Spacer()
                Text("1%")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Text("3%")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Text("5%+")
            }
            .font(.system(size: 9))
            .foregroundStyle(Color.brownLight)
        }
    }

    private func save() {
        let test = VarroaTest(
            id: UUID().uuidString,
            data: data,
            nAcaros: nAcaros,
            nAbelhas: calculatedBees,
            notas: notas
        )
        store.addVarroaTest(test, to: hiveId)
        dismiss()
    }
}
