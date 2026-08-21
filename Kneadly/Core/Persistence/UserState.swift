import Foundation
import Observation

/// Everything the user told us, plus derived preferences.
/// Health answers live here and are written to UserDefaults on this device only —
/// they are never synced to iCloud and never transmitted anywhere.
@Observable
final class UserState {

    // Onboarding answers
    var name: String = ""
    var selectedModes: Set<SessionMode> = [.solo]
    var soreZones: Set<BodyZone> = []
    var maxMinutes: Int = 20
    var level: Level = .beginner

    // Health — device-local only
    var healthAnswers: [String] = []
    var affectedZones: Set<BodyZone> = []

    // Preferences
    var voiceEnabled: Bool = true
    var ambienceEnabled: Bool = false
    var hapticsEnabled: Bool = true
    var autoAdvance: Bool = true
    var figureStyle: String = "neutral"
    var pressureBias: Int = 0
    var reminderHour: Int = 21
    var reminderMinute: Int = 30
    var remindersEnabled: Bool = false

    // Flags
    var hasCompletedOnboarding: Bool = false
    var hasAcceptedDisclaimer: Bool = false
    var disclaimerVersion: Int = 0
    var completedSessionCount: Int = 0

    static let currentDisclaimerVersion = 1

    private let defaults: UserDefaults
    private static let key = "kneadly.userstate.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    /// Level rises automatically once the user has real sessions behind them.
    var effectiveLevel: Level {
        if completedSessionCount >= 12 { return max(level, .advanced) }
        if completedSessionCount >= 5 { return max(level, .intermediate) }
        return level
    }

    var needsDisclaimer: Bool {
        !hasAcceptedDisclaimer || disclaimerVersion < Self.currentDisclaimerVersion
    }

    func recordPressureFeedback(_ feedback: PressureFeedback) {
        pressureBias = min(2, max(-2, pressureBias + feedback.adjustment))
        save()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var name = ""
        var selectedModes: [String] = ["solo"]
        var soreZones: [String] = []
        var maxMinutes = 20
        var level = "beginner"
        var healthAnswers: [String] = []
        var affectedZones: [String] = []
        var voiceEnabled = true
        var ambienceEnabled = false
        var hapticsEnabled = true
        var autoAdvance = true
        var figureStyle = "neutral"
        var pressureBias = 0
        var reminderHour = 21
        var reminderMinute = 30
        var remindersEnabled = false
        var hasCompletedOnboarding = false
        var hasAcceptedDisclaimer = false
        var disclaimerVersion = 0
        var completedSessionCount = 0
    }

    func save() {
        var s = Snapshot()
        s.name = name
        s.selectedModes = selectedModes.map(\.rawValue)
        s.soreZones = soreZones.map(\.rawValue)
        s.maxMinutes = maxMinutes
        s.level = level.rawValue
        s.healthAnswers = healthAnswers
        s.affectedZones = affectedZones.map(\.rawValue)
        s.voiceEnabled = voiceEnabled
        s.ambienceEnabled = ambienceEnabled
        s.hapticsEnabled = hapticsEnabled
        s.autoAdvance = autoAdvance
        s.figureStyle = figureStyle
        s.pressureBias = pressureBias
        s.reminderHour = reminderHour
        s.reminderMinute = reminderMinute
        s.remindersEnabled = remindersEnabled
        s.hasCompletedOnboarding = hasCompletedOnboarding
        s.hasAcceptedDisclaimer = hasAcceptedDisclaimer
        s.disclaimerVersion = disclaimerVersion
        s.completedSessionCount = completedSessionCount
        if let data = try? JSONEncoder().encode(s) {
            defaults.set(data, forKey: Self.key)
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key),
              let s = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        name = s.name
        selectedModes = Set(s.selectedModes.compactMap(SessionMode.init(rawValue:)))
        if selectedModes.isEmpty { selectedModes = [.solo] }
        soreZones = Set(s.soreZones.compactMap(BodyZone.init(rawValue:)))
        maxMinutes = s.maxMinutes
        level = Level(rawValue: s.level) ?? .beginner
        healthAnswers = s.healthAnswers
        affectedZones = Set(s.affectedZones.compactMap(BodyZone.init(rawValue:)))
        voiceEnabled = s.voiceEnabled
        ambienceEnabled = s.ambienceEnabled
        hapticsEnabled = s.hapticsEnabled
        autoAdvance = s.autoAdvance
        figureStyle = s.figureStyle
        pressureBias = s.pressureBias
        reminderHour = s.reminderHour
        reminderMinute = s.reminderMinute
        remindersEnabled = s.remindersEnabled
        hasCompletedOnboarding = s.hasCompletedOnboarding
        hasAcceptedDisclaimer = s.hasAcceptedDisclaimer
        disclaimerVersion = s.disclaimerVersion
        completedSessionCount = s.completedSessionCount
    }

    func resetEverything() {
        defaults.removeObject(forKey: Self.key)
        name = ""
        selectedModes = [.solo]
        soreZones = []
        maxMinutes = 20
        level = .beginner
        healthAnswers = []
        affectedZones = []
        pressureBias = 0
        hasCompletedOnboarding = false
        hasAcceptedDisclaimer = false
        disclaimerVersion = 0
        completedSessionCount = 0
    }
}

extension Level: Comparable {
    private var order: Int {
        switch self {
        case .beginner: return 0
        case .intermediate: return 1
        case .advanced: return 2
        }
    }
    static func < (lhs: Level, rhs: Level) -> Bool { lhs.order < rhs.order }
}
