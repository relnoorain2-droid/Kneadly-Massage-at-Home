import SwiftUI
import SwiftData

@main
struct KneadlyApp: App {

    @State private var env = AppEnvironment()

    /// Session history and program progress. Health answers deliberately live
    /// outside SwiftData in device-local storage so they can never be synced.
    private let container: ModelContainer = {
        let schema = Schema([SessionLog.self, PartnerProfile.self, ProgramProgress.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // A corrupt store must never brick the app — fall back to memory.
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(env)
                .modelContainer(container)
                .tint(K.terracotta500)
                .preferredColorScheme(nil)
                .task { await env.bootstrap() }
        }
    }
}

struct RootView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        @Bindable var env = env

        Group {
            if !env.user.hasCompletedOnboarding {
                OnboardingFlow()
            } else {
                RootTabView()
            }
        }
        .animation(KMotion.screen, value: env.user.hasCompletedOnboarding)
        .fullScreenCover(item: $env.activeSession) { request in
            StepPlayerView(request: request)
        }
        .fullScreenCover(item: $env.completedSession) { completed in
            SessionCompleteView(completed: completed)
        }
        .sheet(item: $env.showPaywall) { trigger in
            PaywallView(trigger: trigger)
        }
        .sheet(item: $env.presentedRoutine) { routine in
            RoutineDetailView(routine: routine)
        }
    }
}

