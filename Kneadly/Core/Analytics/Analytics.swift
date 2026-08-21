import Foundation
import os

/// Anonymous, aggregate, no user identifier, no IDFA, no ATT prompt.
/// Health answers never appear here — only the count of flags, never which ones.
///
/// v1 logs to the unified log. Swap `sink` for TelemetryDeck or PostHog in one place.
enum Analytics {

    enum Event {
        case onboardingStepViewed(Int)
        case modeSelected(String)
        case contraindicationFlagged(count: Int)
        case routineOpened(String)
        case sessionStarted(routine: String, mode: String)
        case stepAdvanced(index: Int)
        case stepRepeated(index: Int)
        case sessionPaused(index: Int)
        case sessionCompleted(routine: String, seconds: Int)
        case sessionAbandoned(routine: String, index: Int)
        case pressureFeedback(String)
        case paywallShown(trigger: String)
        case purchaseCompleted(plan: String)
        case voiceToggled(Bool)
        case searchPerformed

        var name: String {
            switch self {
            case .onboardingStepViewed: return "onboarding_step_viewed"
            case .modeSelected: return "mode_selected"
            case .contraindicationFlagged: return "contraindication_flagged"
            case .routineOpened: return "routine_opened"
            case .sessionStarted: return "session_started"
            case .stepAdvanced: return "step_advanced"
            case .stepRepeated: return "step_repeated"
            case .sessionPaused: return "session_paused"
            case .sessionCompleted: return "session_completed"
            case .sessionAbandoned: return "session_abandoned"
            case .pressureFeedback: return "pressure_feedback_given"
            case .paywallShown: return "paywall_shown"
            case .purchaseCompleted: return "purchase_completed"
            case .voiceToggled: return "voice_toggled"
            case .searchPerformed: return "search_performed"
            }
        }

        var parameters: [String: String] {
            switch self {
            case let .onboardingStepViewed(i): return ["index": "\(i)"]
            case let .modeSelected(m): return ["mode": m]
            case let .contraindicationFlagged(c): return ["count": "\(c)"]
            case let .routineOpened(r): return ["routine": r]
            case let .sessionStarted(r, m): return ["routine": r, "mode": m]
            case let .stepAdvanced(i): return ["index": "\(i)"]
            case let .stepRepeated(i): return ["index": "\(i)"]
            case let .sessionPaused(i): return ["index": "\(i)"]
            case let .sessionCompleted(r, s): return ["routine": r, "seconds": "\(s)"]
            case let .sessionAbandoned(r, i): return ["routine": r, "index": "\(i)"]
            case let .pressureFeedback(v): return ["value": v]
            case let .paywallShown(t): return ["trigger": t]
            case let .purchaseCompleted(p): return ["plan": p]
            case let .voiceToggled(on): return ["on": on ? "1" : "0"]
            case .searchPerformed: return [:]
            }
        }
    }

    private static let logger = Logger(subsystem: AppBrand.bundleID, category: "analytics")

    static func log(_ event: Event) {
        let params = event.parameters
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        logger.info("\(event.name, privacy: .public) \(params, privacy: .public)")
    }
}
