import SwiftUI

struct DisinfectionFormView: View {
    let hiveId: Int
    @Environment(HiveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var produto = ""
    @State private var data = Date()
    @State private var metodo = DisinfMethod.sublimacao
    @State private var dose = ""
    @State private var hasProximaData = false
    @State private var proximaData = Date()
    @State private var notas = ""

    private var isValid: Bool { !produto.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FormSection(title: "PRODUTO E DATA") {
                    FormRow {
                        Text("Produto")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .frame(width: 90, alignment: .leading)
                        TextField("Ex: Ácido Oxálico", text: $produto)
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
                            .tint(Color.amberAccent)
                    }
                }

                FormSection(title: "MÉTODO E DOSE") {
                    HStack(spacing: 3) {
                        ForEach(DisinfMethod.allCases, id: \.self) { m in
                            Button { metodo = m } label: {
                                Text(m.rawValue)
                                    .font(.system(size: 11.5,
                                                  weight: metodo == m ? .semibold : .regular))
                                    .foregroundStyle(metodo == m ? .white : Color.brownMedium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(metodo == m ? Color.amberAccent : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(8)
                    formDivider
                    FormRow {
                        Text("Dose")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownDark)
                            .frame(width: 90, alignment: .leading)
                        TextField("Ex: 35ml por colmeia", text: $dose)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.brownMedium)
                            .multilineTextAlignment(.trailing)
                    }
                }

                FormSection(title: "SEGUIMENTO") {
                    FormRow {
                        Text("Próxima desinfecção")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.brownDark)
                        Spacer()
                        Toggle("", isOn: $hasProximaData)
                            .labelsHidden()
                            .tint(Color.amberAccent)
                    }
                    if hasProximaData {
                        formDivider
                        FormRow {
                            Spacer()
                            DatePicker("", selection: $proximaData, displayedComponents: .date)
                                .labelsHidden()
                                .tint(Color.amberAccent)
                        }
                    }
                    formDivider
                    TextField("Notas adicionais...", text: $notas, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brownMedium)
                        .lineLimit(3, reservesSpace: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                Button { submitForm() } label: {
                    Text("Registar Desinfecção")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Color.amberAccent : Color(hex: "D0C0B0"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: isValid ? Color.amberAccent.opacity(0.3) : .clear,
                                radius: 8, y: 4)
                        .opacity(isValid ? 1 : 0.6)
                }
                .disabled(!isValid)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .background(Color.creamSecondary)
        .navigationTitle("Nova Desinfecção")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(Color.amberAccent)
            }
        }
    }

    private var formDivider: some View {
        Rectangle()
            .fill(Color.amberDark.opacity(0.12))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    private func submitForm() {
        guard isValid else { return }
        let d = Disinfection(
            id: "d\(Int(Date().timeIntervalSince1970))",
            data: data,
            produto: produto.trimmingCharacters(in: .whitespaces),
            dose: dose.isEmpty ? "—" : dose,
            metodo: metodo,
            proximaData: hasProximaData ? proximaData : nil,
            notas: notas
        )
        store.addDisinfection(d, to: hiveId)
        dismiss()
    }
}

// MARK: - Form Helpers

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brownLight)
                .padding(.leading, 4)
                .padding(.bottom, 8)
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background(Color.cream)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.amberDark.opacity(0.2), lineWidth: 0.5)
            )
        }
    }
}

struct FormRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack { content }
            .padding(.horizontal, 16)
            .frame(minHeight: 50)
    }
}
