import SwiftUI
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



struct HomeView: View {
    @Environment(HiveStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var showAddHive = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showImporter = false
    @State private var pendingImportData: Data? = nil
    @State private var showImportConfirm = false
    @State private var importFailed = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.creamSecondary.ignoresSafeArea()

            if store.hives.isEmpty {
                HiveWelcomeView(onAdd: { showAddHive = true })
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(store.hives.count) \(store.hives.count == 1 ? "colmeia" : "colmeias")")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(Color.brownDark)

                            if !phaseCounts.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(phaseCounts, id: \.0.rawValue) { phase, count in
                                        Text("\(count) \(phase.label)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(phase.badgeColor)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(phase.badgeBackground)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.cream)

                        Spacer().frame(height: 10)

                        LazyVGrid(
                            columns: sizeClass == .regular
                                ? [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                                : [GridItem(.flexible())],
                            spacing: 12
                        ) {
                            ForEach(store.hives) { hive in
                                NavigationLink(value: NavTarget.hiveDetail(hive.id)) {
                                    HiveCardView(hive: hive)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        Text("Toca numa colmeia para ver os detalhes")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.brownLight)
                            .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("Colmeias")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button("Exportar Dados", systemImage: "square.and.arrow.up") {
                        exportData()
                    }
                    Button("Importar Dados", systemImage: "square.and.arrow.down") {
                        showImporter = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.amberDark)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddHive = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.amberAccent)
                            .frame(width: 32, height: 32)
                            .shadow(color: Color.amberAccent.opacity(0.4), radius: 4, y: 2)
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddHive) {
            AddHiveSheet(isPresented: $showAddHive)
                .environment(store)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
                .ignoresSafeArea()
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    pendingImportData = data
                    showImportConfirm = true
                } else {
                    importFailed = true
                }
            case .failure:
                importFailed = true
            }
        }
        .confirmationDialog("Importar Dados", isPresented: $showImportConfirm) {
            Button("Substituir dados existentes", role: .destructive) {
                if let data = pendingImportData {
                    try? store.importData(data)
                }
                pendingImportData = nil
            }
            Button("Cancelar", role: .cancel) { pendingImportData = nil }
        } message: {
            Text("Os dados actuais serão substituídos pelos dados do ficheiro. Esta acção não pode ser desfeita.")
        }
        .alert("Erro ao importar", isPresented: $importFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Não foi possível ler o ficheiro. Confirma que é um ficheiro de dados Colmeias válido.")
        }
    }

    private func exportData() {
        guard let data = try? store.exportData() else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let filename = "colmeias_\(formatter.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        guard (try? data.write(to: url)) != nil else { return }
        shareItems = [url]
        showShareSheet = true
    }

    private var phaseCounts: [(HivePhase, Int)] {
        var counts: [HivePhase: Int] = [:]
        store.hives.forEach { counts[$0.fase, default: 0] += 1 }
        return HivePhase.allCases.compactMap { phase in
            guard let c = counts[phase], c > 0 else { return nil }
            return (phase, c)
        }
    }
}

// MARK: - Welcome Empty State

struct HiveWelcomeView: View {
    let onAdd: () -> Void
    @State private var beeFloat = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BeeView()
                .frame(width: 148, height: 184)
                .offset(y: beeFloat ? -12 : 0)
                .rotationEffect(.degrees(beeFloat ? 2 : -2))
                .animation(
                    .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                    value: beeFloat
                )

            VStack(spacing: 8) {
                Text("O teu apiário aguarda!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.brownDark)
                Text("Ainda não tens nenhuma colmeia.\nAdiciona a tua primeira para começar.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.brownLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Adicionar Colmeia")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color.cream)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.amberAccent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.amberAccent.opacity(0.4), radius: 10, y: 4)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { beeFloat = true }
    }
}

// MARK: - Hive Card

struct HiveCardView: View {
    let hive: Hive

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(hive.nome)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.brownDark)
                    Text("📍 \(hive.localizacao)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brownLight)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(hive.fase.label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(hive.fase.badgeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(hive.fase.badgeBackground)
                        .clipShape(Capsule())
                    HStack(spacing: 3) {
                        Image(systemName: hive.status.icon)
                            .font(.system(size: 9))
                        Text(hive.status.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(hive.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(hive.status.badgeBackground)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Rectangle()
                .fill(Color.amberDark.opacity(0.15))
                .frame(height: 0.5)
                .padding(.horizontal, 16)

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ESTRUTURA")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(Color.brownLight)
                    Text(hive.estruturaSummary)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.brownMedium)
                }
                Spacer()
                HStack(spacing: 10) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("DESINFECÇÃO")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(Color.brownLight)
                        Text(hive.desinfeccoes.first?.data.ddMMYYYY ?? "Sem registo")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.brownMedium)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.amberDark)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "502800").opacity(0.10), radius: 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.amberDark.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Add Hive Sheet

struct AddHiveSheet: View {
    @Binding var isPresented: Bool
    @Environment(HiveStore.self) private var store

    @State private var nome = ""
    @State private var localizacao = ""
    @State private var fase = HivePhase.crescimento

    private var canAdd: Bool { !nome.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informação") {
                    TextField("Nome", text: $nome)
                    TextField("Localização", text: $localizacao)
                }
                Section("Fase") {
                    Picker("Fase", selection: $fase) {
                        ForEach(HivePhase.allCases, id: \.self) { f in
                            Text(f.label).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Nova Colmeia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { isPresented = false }
                        .foregroundStyle(Color.amberAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Adicionar") {
                        store.addHive(nome: nome, localizacao: localizacao, fase: fase)
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canAdd ? Color.amberAccent : Color.brownLight)
                    .disabled(!canAdd)
                }
            }
        }
    }
}

#Preview {
    let store = HiveStore()
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    store.hives = [
        Hive(id: 1, nome: "Amendoeira 1", localizacao: "Quinta do Souto", fase: .producao, status: .saudavel,
             dataInstalacao: df.date(from: "2024-03-15")!,
             estrutura: [
                HiveBox(id: "n1", tipo: .ninho, label: "Ninho", quadros: (1...10).map { HiveFrame(id: $0, tipo: .vazio) }),
                HiveBox(id: "a1", tipo: .alca, label: "Alça 1", quadros: (1...10).map { HiveFrame(id: $0, tipo: .vazio) }),
             ],
             desinfeccoes: [Disinfection(id: "d1", data: df.date(from: "2025-04-15")!, produto: "Ácido Oxálico", dose: "35ml", metodo: .sublimacao, proximaData: df.date(from: "2025-07-15"), notas: "")],
             alimentacoes: [], varroaTestes: []),
        Hive(id: 2, nome: "Carvalho Velho", localizacao: "Monte das Abelhas", fase: .crescimento, status: .infectada,
             dataInstalacao: df.date(from: "2025-01-10")!,
             estrutura: [HiveBox(id: "n2", tipo: .ninho, label: "Ninho", quadros: (1...10).map { HiveFrame(id: $0, tipo: .vazio) })],
             desinfeccoes: [], alimentacoes: [], varroaTestes: []),
        Hive(id: 3, nome: "Sobreiro 3", localizacao: "Herdade da Serra", fase: .manutencao, status: .baixasReservas,
             dataInstalacao: df.date(from: "2023-09-05")!,
             estrutura: [
                HiveBox(id: "n3", tipo: .ninho, label: "Ninho", quadros: (1...10).map { HiveFrame(id: $0, tipo: .vazio) }),
                HiveBox(id: "a3", tipo: .meiaAlca, label: "½ Alça", quadros: (1...8).map { HiveFrame(id: $0, tipo: .vazio) }),
             ],
             desinfeccoes: [], alimentacoes: [], varroaTestes: []),
    ]
    return NavigationStack {
        HomeView()
    }
    .environment(store)
}
