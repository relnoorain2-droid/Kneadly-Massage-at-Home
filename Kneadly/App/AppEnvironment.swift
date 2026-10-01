import SwiftUI
import Observation

/// Plain protocol-free dependency container. At this size a DI framework is overhead.
@MainActor
@Observable
final class AppEnvironment {
    let content = ContentStore()
    let user = UserState()
    let narration = NarrationPlayer()
    let subscriptions = SubscriptionService()

    var engine: ContraindicationEngine { ContraindicationEngine(store: content) }

    /// Router state — modal presentation is centralised so any screen can push a session.
    var presentedRoutine: Routine?
    var activeSession: SessionRequest?
    var showPaywall: PaywallTrigger?
    var completedSession: CompletedSession?

    /// Tension the user rated in Prepare, carried into the session log.
    var pendingTensionBefore: Int?
    /// Set when a routine was launched as a program day, so completing it
    /// advances that program.
    var activeProgramID: String?

    init() {
        content.load()
        narration.enabled = user.voiceEnabled
        Haptics.enabled = user.hapticsEnabled
    }

    func bootstrap() async {
        await subscriptions.loadProducts()
    }

    // MARK: - Gating

    func isLocked(_ routine: Routine) -> Bool {
        routine.isPremium && !subscriptions.isPlus
    }

    func verdict(for routine: Routine) -> SafetyVerdict {
        engine.verdict(for: routine, answers: user.healthAnswers, level: user.effectiveLevel)
    }

    func open(_ routine: Routine) {
        Analytics.log(.routineOpened(routine.id))
        if isLocked(routine) {
            showPaywall = .lockedRoutine(routine.id)
        } else {
            presentedRoutine = routine
        }
    }

    func startSession(_ routine: Routine, partner: String? = nil) {
        let cap = verdict(for: routine).pressureCap
        activeSession = SessionRequest(routine: routine, pressureCap: cap, partnerName: partner)
        Analytics.log(.sessionStarted(routine: routine.id, mode: routine.mode.rawValue))
    }
}

struct SessionRequest: Identifiable, Equatable {
    let id = UUID()
    let routine: Routine
    let pressureCap: Int?
    let partnerName: String?

    static func == (lhs: SessionRequest, rhs: SessionRequest) -> Bool { lhs.id == rhs.id }
}

struct CompletedSession: Identifiable, Equatable {
    let id = UUID()
    let routine: Routine
    let seconds: Int
    let stepsCompleted: Int
    let logID: UUID?
}

enum PaywallTrigger: Identifiable, Equatable {
    case firstSessionComplete
    case lockedRoutine(String)
    case lockedProgram(String)
    case settings

    var id: String {
        switch self {
        case .firstSessionComplete: return "first_session"
        case let .lockedRoutine(id): return "routine_\(id)"
        case let .lockedProgram(id): return "program_\(id)"
        case .settings: return "settings"
        }
    }
}
