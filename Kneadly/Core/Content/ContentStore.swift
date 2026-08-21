import Foundation
import Observation

/// Loads the bundled content pack and answers every content question the app has.
/// Content is immutable once loaded, so lookups are dictionary-backed and cheap.
@Observable
final class ContentStore {

    private(set) var routines: [Routine] = []
    private(set) var programs: [Program] = []
    private(set) var stepsByID: [String: Step] = [:]
    private(set) var loadError: String?

    static let shared = ContentStore()

    init() {}

    // MARK: - Loading

    func load() {
        guard routines.isEmpty else { return }
        guard let url = Bundle.main.url(forResource: "content", withExtension: "json") else {
            loadError = "content.json is missing from the app bundle."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let pack = try JSONDecoder().decode(ContentPack.self, from: data)
            routines = pack.routines
            programs = pack.programs ?? Program.builtIn
            stepsByID = Dictionary(uniqueKeysWithValues: pack.steps.map { ($0.id, $0) })
            loadError = nil
        } catch {
            loadError = "Could not read the content pack: \(error.localizedDescription)"
        }
    }

    // MARK: - Lookups

    func routine(_ id: String) -> Routine? { routines.first { $0.id == id } }
    func step(_ id: String) -> Step? { stepsByID[id] }

    func steps(for routine: Routine) -> [Step] {
        routine.allStepIDs.compactMap { stepsByID[$0] }
    }

    func routines(mode: SessionMode?) -> [Routine] {
        guard let mode else { return routines }
        return routines.filter { $0.mode == mode }
    }

    func routines(zone: BodyZone, mode: SessionMode? = nil) -> [Routine] {
        routines.filter { routine in
            guard mode == nil || routine.mode == mode else { return false }
            let zones = Set(steps(for: routine).flatMap(\.bodyMapZones))
            return zones.contains(zone)
        }
    }

    func freeRoutines() -> [Routine] { routines.filter { !$0.isPremium } }

    func search(_ query: String) -> [Routine] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard q.count >= 2 else { return [] }
        let synonymHits = Self.symptomMap
            .filter { $0.key.contains(q) || q.contains($0.key) }
            .flatMap(\.value)
        var results = routines.filter { $0.searchHaystack.contains(q) }
        for id in synonymHits {
            if let r = routine(id), !results.contains(where: { $0.id == id }) { results.append(r) }
        }
        return results
    }

    func program(_ id: String) -> Program? { programs.first { $0.id == id } }

    // MARK: - Suggestion

    /// The single suggestion on Today. One, not three — decision fatigue is the enemy at 10pm.
    func suggestion(modes: Set<SessionMode>, zones: Set<BodyZone>, maxMinutes: Int, isPlus: Bool) -> Routine? {
        let pool = routines.filter { r in
            (isPlus || !r.isPremium) && (modes.isEmpty || modes.contains(r.mode))
        }
        guard !pool.isEmpty else { return routines.first }

        func score(_ r: Routine) -> Int {
            var s = 0
            let rZones = Set(steps(for: r).flatMap(\.bodyMapZones))
            s += rZones.intersection(zones).count * 10
            if r.minutes <= maxMinutes { s += 5 }
            if !r.isPremium { s += 1 }
            return s
        }
        return pool.max { score($0) < score($1) }
    }

    // MARK: - Static naming

    static func regionTitle(_ id: String) -> String {
        regionTitles[id] ?? id.humanised
    }

    static func techniqueTitle(_ id: String) -> String {
        techniqueTitles[id] ?? id.humanised
    }

    static func zone(forRegionID id: String) -> BodyZone? {
        regionToZone[id]
    }

    private static let regionTitles: [String: String] = [
        "scalp": "Scalp", "face": "Face", "jaw": "Jaw", "ears": "Ears",
        "neck": "Neck", "suboccipitals": "Base of the skull",
        "shouldersUpperTrap": "Upper trapezius", "upperBack": "Upper back",
        "lowerBack": "Lower back", "chest": "Chest", "abdomen": "Abdomen",
        "upperArm": "Upper arm", "forearm": "Forearm", "hand": "Hand",
        "glutesHips": "Glutes & hips", "thigh": "Thigh", "knee": "Knee",
        "calfShin": "Calf & shin", "foot": "Foot"
    ]

    private static let techniqueTitles: [String: String] = [
        "effleurage": "Gliding", "petrissage": "Kneading", "friction": "Small circles",
        "tapotement": "Tapping", "vibration": "Shaking", "deepTissue": "Deep tissue",
        "triggerPoint": "Trigger point", "myofascial": "Myofascial release",
        "shiatsu": "Acupressure", "reflexology": "Reflexology", "thai": "Thai",
        "lymphatic": "Lymphatic", "indianHead": "Indian head", "abhyanga": "Abhyanga",
        "guaSha": "Gua sha", "lomiLomi": "Lomi lomi", "sports": "Sports",
        "chair": "Chair", "prenatal": "Prenatal", "selfMyofascial": "Ball release",
        "stretch": "Stretch", "staticHold": "Static hold"
    ]

    private static let regionToZone: [String: BodyZone] = [
        "scalp": .head, "face": .head, "jaw": .head, "ears": .head,
        "neck": .neck, "suboccipitals": .neck,
        "shouldersUpperTrap": .shoulders, "upperBack": .chest,
        "lowerBack": .abdomen, "chest": .chest, "abdomen": .abdomen,
        "upperArm": .arms, "forearm": .forearms, "hand": .hands,
        "glutesHips": .hips, "thigh": .thighs, "knee": .knees,
        "calfShin": .calves, "foot": .feet
    ]

    /// Search by symptom, not just body part.
    static let symptomMap: [String: [String]] = [
        "headache": ["head.solo.headache", "scalp.partner.winddown"],
        "migraine": ["head.solo.headache"],
        "sleep": ["scalp.solo.sleep", "scalp.partner.winddown"],
        "insomnia": ["scalp.solo.sleep"],
        "desk": ["desk.solo.reset", "forearm.solo.rescue", "neck.solo.reset"],
        "computer": ["desk.solo.reset", "forearm.solo.rescue"],
        "laptop": ["desk.solo.reset"],
        "phone": ["hand.solo.reset", "forearm.solo.rescue"],
        "gym": ["legs.partner.recovery", "calf.solo.release"],
        "workout": ["legs.partner.recovery"],
        "sore": ["legs.partner.recovery", "back.partner.basics"],
        "stress": ["scalp.partner.winddown", "neck.solo.reset"],
        "anxious": ["scalp.solo.sleep", "hand.solo.reset"],
        "feet": ["foot.solo.relief", "foot.partner.ritual", "foot.friends.reflex"],
        "standing": ["foot.solo.relief"],
        "jaw": ["jaw.solo.tmj"],
        "grinding": ["jaw.solo.tmj"],
        "clenching": ["jaw.solo.tmj"],
        "back": ["back.partner.basics", "lowerback.solo.ball", "lowerback.partner.relief"],
        "sciatica": ["glute.solo.ball", "lowerback.partner.relief"],
        "hips": ["glute.solo.ball", "lowerback.partner.relief"],
        "office": ["chair.friends.office", "desk.solo.reset"],
        "date night": ["full.partner.express", "back.partner.basics"],
        "couple": ["back.partner.basics", "full.partner.express", "together.handexchange"]
    ]
}

extension String {
    /// "shouldersUpperTrap" -> "Shoulders upper trap"
    var humanised: String {
        guard !isEmpty else { return self }
        var out = ""
        for (i, ch) in enumerated() {
            if i > 0 && ch.isUppercase { out.append(" ") }
            out.append(i == 0 ? Character(ch.uppercased()) : ch)
        }
        return out
    }
}
