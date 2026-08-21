import Foundation
import SwiftData

@Model
final class SessionLog {
    @Attribute(.unique) var id: UUID
    var routineID: String
    var routineTitle: String
    var modeRaw: String
    var startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int
    var stepsCompleted: Int
    var stepsTotal: Int
    var feelAfterRaw: String?
    var pressureFeedbackRaw: String?
    var partnerName: String?
    var abandonedAtStepIndex: Int?

    init(routineID: String,
         routineTitle: String,
         mode: SessionMode,
         startedAt: Date = Date(),
         stepsTotal: Int) {
        self.id = UUID()
        self.routineID = routineID
        self.routineTitle = routineTitle
        self.modeRaw = mode.rawValue
        self.startedAt = startedAt
        self.durationSeconds = 0
        self.stepsCompleted = 0
        self.stepsTotal = stepsTotal
    }

    var mode: SessionMode { SessionMode(rawValue: modeRaw) ?? .solo }
    var feelAfter: FeelAfter? { feelAfterRaw.flatMap(FeelAfter.init(rawValue:)) }
    var pressureFeedback: PressureFeedback? { pressureFeedbackRaw.flatMap(PressureFeedback.init(rawValue:)) }
    var isComplete: Bool { completedAt != nil }
    var minutes: Int { max(1, durationSeconds / 60) }
}

@Model
final class PartnerProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var preferredPressure: Int
    var sensitiveZoneRaws: [String]
    /// Health answers for this person. Local only — never synced, never transmitted.
    var contraindicationIDs: [String]
    var avatarColorHex: String
    var createdAt: Date

    init(name: String, preferredPressure: Int = 3, avatarColorHex: String = "#C0664A") {
        self.id = UUID()
        self.name = name
        self.preferredPressure = preferredPressure
        self.sensitiveZoneRaws = []
        self.contraindicationIDs = []
        self.avatarColorHex = avatarColorHex
        self.createdAt = Date()
    }

    var initial: String { String(name.prefix(1)).uppercased() }
    var sensitiveZones: [BodyZone] { sensitiveZoneRaws.compactMap(BodyZone.init(rawValue:)) }
}

@Model
final class ProgramProgress {
    @Attribute(.unique) var programID: String
    var currentDay: Int
    var completedDays: [Int]
    var startedAt: Date

    init(programID: String) {
        self.programID = programID
        self.currentDay = 1
        self.completedDays = []
        self.startedAt = Date()
    }

    func complete(day: Int, of total: Int) {
        if !completedDays.contains(day) { completedDays.append(day) }
        currentDay = min(total, day + 1)
    }

    func progress(of total: Int) -> Double {
        total == 0 ? 0 : Double(completedDays.count) / Double(total)
    }
}
