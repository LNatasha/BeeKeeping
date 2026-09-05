import SwiftUI

struct ProfileView: View {
    @Binding var isPresented: Bool
    @Environment(ProfileStore.self) private var store

    @State private var numeroApicultor = ""
    @State private var nomeAssociacao = ""
    @State private var numeroColmeiasRegistadas = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var locationFetcher = LocationFetcher()

    var body: some View {
        NavigationStack {
            Form {
                Section("Apicultor") {
                    LabeledContent("Número de Apicultor") {
                        TextField("", text: $numeroApicultor)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Nome da Associação") {
                        TextField("", text: $nomeAssociacao)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Número de Colmeias Registadas") {
                        TextField("", text: $numeroColmeiasRegistadas)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("Localização") {
                    LabeledContent("Latitude") {
                        TextField("", text: $latitude)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Longitude") {
                        TextField("", text: $longitude)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Button {
                        locationFetcher.requestLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Usar Localização Atual")
                            if locationFetcher.isFetching {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(locationFetcher.isFetching)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { isPresented = false }
                        .foregroundStyle(Color.amberAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        store.profile = BeekeeperProfile(
                            numeroApicultor: numeroApicultor,
                            nomeAssociacao: nomeAssociacao,
                            numeroColmeiasRegistadas: numeroColmeiasRegistadas,
                            latitude: latitude,
                            longitude: longitude
                        )
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.amberAccent)
                }
            }
            .onAppear {
                numeroApicultor = store.profile.numeroApicultor
                nomeAssociacao = store.profile.nomeAssociacao
                numeroColmeiasRegistadas = store.profile.numeroColmeiasRegistadas
                latitude = store.profile.latitude
                longitude = store.profile.longitude
            }
            .onChange(of: locationFetcher.coordinate?.latitude) {
                guard let coord = locationFetcher.coordinate else { return }
                latitude = String(coord.latitude)
                longitude = String(coord.longitude)
            }
        }
    }
}

#Preview {
    ProfileView(isPresented: .constant(true))
        .environment(ProfileStore())
}
