#if DEBUG
import SwiftUI
import SwiftData

/// App Store screenshots, generated in CI on a simulator — see
/// .github/workflows/screenshots.yml. Debug builds only; this file does not
/// exist in the binary that ships.
///
///     -screenshot today|body|routine|player|complete|me|paywall
enum ScreenshotMode {

    static var screen: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }

    static var initialTab: Int {
        switch screen {
        case "body": return 1
        case "me": return 3
        default: return 0
        }
    }

    @MainActor
    static func apply(env: AppEnvironment, context: ModelContext) {
        guard let screen else { return }

        env.user.name = "Sara"
        env.user.hasCompletedOnboarding = true
        env.user.hasAcceptedDisclaimer = true
        env.user.disclaimerVersion = UserState.currentDisclaimerVersion
        env.user.soreZones = [.neck]
        env.user.voiceEnabled = false
        env.narration.enabled = false
        env.user.save()

        seedHistory(context: context, env: env)

        let neck = env.content.routine("neck.solo.reset") ?? env.content.routines.first
        switch screen {
        case "routine":
            env.presentedRoutine = neck
        case "player":
            if let neck { env.activeSession = SessionRequest(routine: neck, pressureCap: nil, partnerName: nil) }
        case "complete":
            if let neck {
                let log = SessionLog(routineID: neck.id, routineTitle: neck.title, mode: neck.mode, stepsTotal: 9)
                log.completedAt = Date(); log.durationSeconds = 480; log.stepsCompleted = 9
                log.tensionBefore = 7; log.tensionAfter = 3
                context.insert(log); try? context.save()
                env.completedSession = CompletedSession(routine: neck, seconds: 480, stepsCompleted: 9, logID: log.id)
            }
        case "paywall":
            env.showPaywall = .settings
        default:
            break
        }
    }

    @MainActor
    private static func seedHistory(context: ModelContext, env: AppEnvironment) {
        let existing = (try? context.fetchCount(FetchDescriptor<SessionLog>())) ?? 0
        guard existing == 0 else { return }
        let plan: [(String, Int, Int)] = [
            ("neck.solo.reset", 7, 3), ("scalp.solo.sleep", 6, 2), ("desk.solo.reset", 6, 4),
            ("neck.solo.reset", 6, 2), ("foot.solo.relief", 5, 2), ("head.solo.headache", 8, 4),
            ("neck.solo.reset", 7, 3), ("jaw.solo.tmj", 6, 3), ("scalp.solo.sleep", 5, 1)
        ]
        for (offset, item) in plan.enumerated() {
            guard let routine = env.content.routine(item.0) else { continue }
            let log = SessionLog(routineID: routine.id, routineTitle: routine.title, mode: routine.mode,
                                 startedAt: Calendar.current.date(byAdding: .day, value: -(plan.count - offset - 1), to: Date()) ?? Date(),
                                 stepsTotal: 9)
            log.completedAt = log.startedAt.addingTimeInterval(Double(routine.durationSeconds))
            log.durationSeconds = routine.durationSeconds
            log.stepsCompleted = 9
            log.tensionBefore = item.1
            log.tensionAfter = item.2
            log.feelAfterRaw = FeelAfter.better.rawValue
            context.insert(log)
        }
        try? context.save()
    }
}
#endif
