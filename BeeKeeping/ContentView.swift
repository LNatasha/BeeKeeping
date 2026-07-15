import SwiftUI

// MARK: - Navigation

enum NavTarget: Hashable {
    case hiveDetail(Int)
    case frames(Int, String)
    case desinfForm(Int)
    case desinfHistory(Int)
    case feedingForm(Int)
    case feedingHistory(Int)
    case varroaForm(Int)
    case varroaHistory(Int)
}

struct ContentView: View {
    @State private var store = HiveStore()
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            NavigationStack {
                HomeView()
                    .navigationDestination(for: NavTarget.self) { target in
                        switch target {
                        case .hiveDetail(let id):
                            HiveDetailView(hiveId: id)
                        case .frames(let hiveId, let boxId):
                            FramesView(hiveId: hiveId, boxId: boxId)
                        case .desinfForm(let id):
                            DisinfectionFormView(hiveId: id)
                        case .desinfHistory(let id):
                            DisinfectionHistoryView(hiveId: id)
                        case .feedingForm(let id):
                            FeedingFormView(hiveId: id)
                        case .feedingHistory(let id):
                            FeedingHistoryView(hiveId: id)
                        case .varroaForm(let id):
                            VarroaFormView(hiveId: id)
                        case .varroaHistory(let id):
                            VarroaHistoryView(hiveId: id)
                        }
                    }
            }
            .tint(.amberAccent)
            .environment(store)

            if !hasCompletedOnboarding && !showSplash {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }

            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
    }
}

#Preview {
    ContentView()
}
