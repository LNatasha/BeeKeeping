import SwiftUI

struct EditHiveView: View {
    @Binding var isPresented: Bool
    let hiveId: Int
    @Environment(HiveStore.self) private var store

    @State private var nome = ""
    @State private var localizacao = ""
    @State private var fase = HivePhase.crescimento
    @State private var status = HiveStatus.saudavel
    @State private var dataInstalacao = Date()
    @State private var estrutura: [HiveBox] = []
    @State private var showDeleteConfirm = false

    private var hive: Hive? { store.hives.first { $0.id == hiveId } }
    private var canSave: Bool { !nome.trimmingCharacters(in: .whitespaces).isEmpty }

    private var formDivider: some View {
        Rectangle()
            .fill(Color.amberDark.opacity(0.1))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // MARK: Informação
                    FormSection(title: "INFORMAÇÃO") {
                        FormRow {
                            Text("Nome")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                                .frame(width: 100, alignment: .leading)
                            TextField("Nome da colmeia", text: $nome)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownMedium)
                                .multilineTextAlignment(.trailing)
                        }
                        formDivider
                        FormRow {
                            Text("Localização")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                                .frame(width: 100, alignment: .leading)
                            TextField("Local", text: $localizacao)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownMedium)
                                .multilineTextAlignment(.trailing)
                        }
                        formDivider
                        FormRow {
                            Text("Instalação")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.brownDark)
                                .frame(width: 100, alignment: .leading)
                            Spacer()
                            DatePicker("", selection: $dataInstalacao, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Fase
                    FormSection(title: "FASE") {
                        HStack(spacing: 8) {
                            ForEach(HivePhase.allCases, id: \.self) { f in
                                Button {
                                    fase = f
                                } label: {
                                    Text(f.label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(fase == f ? .white : Color.brownMedium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(fase == f ? Color.amberAccent : Color(hex: "F0E8DC"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                    }
                    .padding(.horizontal, 16)

                    // MARK: Estado
                    FormSection(title: "ESTADO DE SAÚDE") {
                        VStack(spacing: 0) {
                            ForEach(Array(HiveStatus.allCases.enumerated()), id: \.element) { idx, s in
                                if idx > 0 { formDivider }
                                Button {
                                    status = s
                                } label: {
                                    FormRow {
                                        HStack(spacing: 10) {
                                            Image(systemName: s.icon)
                                                .font(.system(size: 14))
                                                .foregroundStyle(s.color)
                                            Text(s.rawValue)
                                                .font(.system(size: 15))
                                                .foregroundStyle(Color.brownDark)
                                            Spacer()
                                            if status == s {
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
                    .padding(.horizontal, 16)

                    // MARK: Estrutura
                    FormSection(title: "ESTRUTURA") {
                        VStack(spacing: 0) {
                            ForEach(Array(estrutura.enumerated()), id: \.element.id) { idx, box in
                                if idx > 0 { formDivider }
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(box.label)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Color.brownDark)
                                        HStack(spacing: 4) {
                                            Text(box.tipo.label)
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.brownLight)
                                            if box.tipo == .ninho {
                                                Text("principal")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundStyle(Color.amberDark)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color(hex: "FFF3E0"))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    Spacer()
                                    if box.tipo != .ninho {
                                        let boxId = box.id
                                        Button {
                                            estrutura.removeAll { $0.id == boxId }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(Color(hex: "D03020"))
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(minHeight: 56)
                            }

                            formDivider

                            HStack(spacing: 8) {
                                addBoxButton(.alca, label: "+ Alça")
                                addBoxButton(.meiaAlca, label: "+ ½ Alça")
                            }
                            .padding(12)
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Eliminar
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Text("Eliminar Colmeia")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "C62020"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(hex: "FFF0EE"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "C62020").opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
                .padding(.top, 20)
            }
            .background(Color.creamSecondary)
            .navigationTitle("Editar Colmeia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { isPresented = false }
                        .foregroundStyle(Color.amberAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(canSave ? Color.amberAccent : Color.brownLight)
                        .disabled(!canSave)
                }
            }
        }
        .onAppear { loadFromHive() }
        .confirmationDialog(
            "Eliminar \"\(nome)\"?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                store.deleteHive(id: hiveId)
                isPresented = false
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acção não pode ser desfeita.")
        }
    }

    @ViewBuilder
    private func addBoxButton(_ tipo: BoxType, label: String) -> some View {
        Button {
            addBox(tipo)
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.amberDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(hex: "FFF3E0"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.amberDark.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func loadFromHive() {
        guard let h = hive else { return }
        nome = h.nome
        localizacao = h.localizacao
        fase = h.fase
        status = h.status
        dataInstalacao = h.dataInstalacao
        estrutura = h.estrutura
    }

    private func addBox(_ tipo: BoxType) {
        let count = estrutura.filter { $0.tipo == tipo }.count + 1
        let label: String
        switch tipo {
        case .alca:     label = "Alça \(count)"
        case .meiaAlca: label = count == 1 ? "½ Alça" : "½ Alça \(count)"
        case .ninho:    label = "Ninho"
        }
        let newId = "\(tipo.rawValue)-\(UUID().uuidString.prefix(8))"
        let quadros: [HiveFrame]?
        switch tipo {
        case .alca:     quadros = (1...10).map { HiveFrame(id: $0, tipo: .vazio) }
        case .meiaAlca: quadros = (1...8).map { HiveFrame(id: $0, tipo: .vazio) }
        case .ninho:    quadros = nil
        }
        estrutura.append(HiveBox(id: newId, tipo: tipo, label: label, quadros: quadros))
    }

    private func save() {
        guard var h = hive else { return }
        h.nome = nome
        h.localizacao = localizacao
        h.fase = fase
        h.status = status
        h.dataInstalacao = dataInstalacao
        h.estrutura = estrutura
        store.updateHive(h)
        isPresented = false
    }
}

#Preview {
    EditHiveView(isPresented: .constant(true), hiveId: 1)
        .environment(HiveStore())
}
