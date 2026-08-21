import Foundation

// MARK: - Severity

enum ContraindicationSeverity: String, Codable, Sendable {
    /// No massage at all until a doctor has been seen.
    case absolute
    /// Massage may proceed, modified: lower pressure, changed position, areas avoided.
    case relative
    /// Work everywhere else, skip the affected area only.
    case local
}

// MARK: - Contraindication

struct Contraindication: Identifiable, Codable, Sendable, Hashable {
    let id: String
    /// Plain language, no medical jargon — this is what appears in the checklist.
    let plainQuestion: String
    let severity: ContraindicationSeverity
    let blockedZones: [BodyZone]
    /// When set, pressure is capped rather than the routine being blocked.
    let maxPressure: Int?
    /// Shown to the user. Calm, clear, never alarming.
    let explanation: String
    let seeDoctor: Bool

    static let all: [Contraindication] = [
        Contraindication(
            id: "pregnancy",
            plainQuestion: "Pregnant or recently gave birth",
            severity: .relative,
            blockedZones: [.abdomen],
            maxPressure: 3,
            explanation: "We'll skip deep abdominal work and strong pressure near the ankles, and keep everything side-lying. Talk to your midwife or doctor before starting.",
            seeDoctor: true
        ),
        Contraindication(
            id: "dvtOrBloodThinners",
            plainQuestion: "Blood clot, DVT, or on blood thinners",
            severity: .local,
            blockedZones: [.calves, .thighs],
            maxPressure: 2,
            explanation: "Massage can dislodge a clot, so we leave the legs alone entirely. If one leg is swollen, warm, red, or painful on one side only, please see a doctor rather than massaging it.",
            seeDoctor: true
        ),
        Contraindication(
            id: "cancerTreatment",
            plainQuestion: "Cancer, current or recent treatment",
            severity: .relative,
            blockedZones: [],
            maxPressure: 2,
            explanation: "Gentle massage is often fine and can be comforting, but pressure stays light and we avoid any treatment sites. Please get your care team's OK first.",
            seeDoctor: true
        ),
        Contraindication(
            id: "heartOrBloodPressure",
            plainQuestion: "Heart condition or uncontrolled blood pressure",
            severity: .relative,
            blockedZones: [],
            maxPressure: 3,
            explanation: "We'll keep pressure moderate and skip anything vigorous. Check with your doctor if you're not sure.",
            seeDoctor: true
        ),
        Contraindication(
            id: "recentSurgeryOrFracture",
            plainQuestion: "Surgery or fracture in the last 3 months",
            severity: .local,
            blockedZones: [],
            maxPressure: 2,
            explanation: "We'll stay well away from the area that's healing and keep everything else light.",
            seeDoctor: true
        ),
        Contraindication(
            id: "diabetesNeuropathy",
            plainQuestion: "Diabetes with nerve or circulation problems",
            severity: .relative,
            blockedZones: [.feet],
            maxPressure: 2,
            explanation: "Reduced sensation means you may not feel pressure that's too strong. Check the skin first, keep it light, and skip the feet if there's any numbness.",
            seeDoctor: false
        ),
        Contraindication(
            id: "skinConditionOrWound",
            plainQuestion: "Skin condition, open wound, rash or infection",
            severity: .local,
            blockedZones: [],
            maxPressure: nil,
            explanation: "Work everywhere else and leave that patch of skin completely alone.",
            seeDoctor: false
        ),
        Contraindication(
            id: "feverOrInfection",
            plainQuestion: "Currently have a fever or an infection",
            severity: .absolute,
            blockedZones: [],
            maxPressure: nil,
            explanation: "Massage isn't a good idea while you're fighting something off, and it isn't fair on whoever is giving it. Come back when you're better.",
            seeDoctor: false
        ),
        Contraindication(
            id: "osteoporosis",
            plainQuestion: "Osteoporosis or fragile bones",
            severity: .relative,
            blockedZones: [],
            maxPressure: 2,
            explanation: "We'll keep pressure gentle everywhere and remove any tapping or percussion.",
            seeDoctor: false
        ),
        Contraindication(
            id: "recentNeckInjury",
            plainQuestion: "Recent neck injury, or numbness in your arms",
            severity: .local,
            blockedZones: [.neck, .head],
            maxPressure: 2,
            explanation: "We'll leave the neck alone. Numbness or tingling down an arm is worth getting looked at.",
            seeDoctor: true
        ),
        Contraindication(
            id: "carpalTunnel",
            plainQuestion: "Carpal tunnel or wrist nerve pain",
            severity: .local,
            blockedZones: [],
            maxPressure: 3,
            explanation: "We'll work around the wrist rather than pressing into it.",
            seeDoctor: false
        ),
        Contraindication(
            id: "tmjDisorder",
            plainQuestion: "Diagnosed jaw or TMJ disorder",
            severity: .relative,
            blockedZones: [],
            maxPressure: 2,
            explanation: "Gentle only, and never force the jaw open.",
            seeDoctor: false
        )
    ]

    static func find(_ id: String) -> Contraindication? {
        all.first { $0.id == id }
    }
}

// MARK: - Verdict

enum SafetyVerdict: Sendable, Equatable {
    case allowed
    case allowedWithCap(maxPressure: Int, note: String)
    case blocked(reason: String, alternativeRoutineID: String?, seeDoctor: Bool)

    var isBlocked: Bool {
        if case .blocked = self { return true }
        return false
    }

    var pressureCap: Int? {
        if case let .allowedWithCap(cap, _) = self { return cap }
        return nil
    }

    var note: String? {
        switch self {
        case .allowed: return nil
        case let .allowedWithCap(_, note): return note
        case let .blocked(reason, _, _): return reason
        }
    }
}
