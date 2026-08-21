import Foundation

/// Decides, before a routine list is ever rendered, whether a routine is safe for this user.
///
/// The rule that matters: `.blocked` must always carry an alternative where one exists.
/// A dead end is a bad product and a worse safety outcome — a user told only "no"
/// will go and do it wrong somewhere else.
struct ContraindicationEngine {

    let store: ContentStore

    func verdict(for routine: Routine,
                 answers: [String],
                 level: Level) -> SafetyVerdict {

        guard !answers.isEmpty else {
            return capVerdict(base: nil, level: level, routine: routine)
        }

        let flagged = answers.compactMap(Contraindication.find)

        // 1. Absolute — nothing at all until a doctor has been seen.
        if let absolute = flagged.first(where: { $0.severity == .absolute }) {
            return .blocked(reason: absolute.explanation,
                            alternativeRoutineID: nil,
                            seeDoctor: absolute.seeDoctor)
        }

        // 2. The routine explicitly declares that it should be skipped.
        if let declared = flagged.first(where: { routine.skipIf.contains($0.id) }) {
            return .blocked(reason: declared.explanation,
                            alternativeRoutineID: alternative(to: routine, avoiding: flagged),
                            seeDoctor: declared.seeDoctor)
        }

        // 3. Local — does this routine actually touch a blocked zone?
        let routineZones = Set(store.steps(for: routine).flatMap(\.bodyMapZones))
        for c in flagged where c.severity == .local {
            if !routineZones.isDisjoint(with: Set(c.blockedZones)) {
                return .blocked(reason: c.explanation,
                                alternativeRoutineID: alternative(to: routine, avoiding: flagged),
                                seeDoctor: c.seeDoctor)
            }
        }

        // 4. Relative — allow, but cap the pressure and say why.
        let caps = flagged.compactMap(\.maxPressure)
        let relative = flagged.first { $0.severity == .relative }
        return capVerdict(base: caps.min(), level: level, routine: routine, note: relative?.explanation)
    }

    private func capVerdict(base: Int?,
                            level: Level,
                            routine: Routine,
                            note: String? = nil) -> SafetyVerdict {
        let cap = min(base ?? 5, level.pressureCap)
        guard cap < routine.maxPressure else { return .allowed }
        let text = note ?? "We're keeping pressure at \(cap) out of 5 while you're getting started. You can lift the cap in Settings once you've done a few sessions."
        return .allowedWithCap(maxPressure: cap, note: text)
    }

    /// The gentlest routine that touches none of the blocked zones.
    private func alternative(to routine: Routine, avoiding flagged: [Contraindication]) -> String? {
        let blocked = Set(flagged.flatMap(\.blockedZones))
        let skipIDs = Set(flagged.map(\.id))
        let candidates = store.routines.filter { candidate in
            guard candidate.id != routine.id, candidate.mode == routine.mode else { return false }
            guard skipIDs.isDisjoint(with: Set(candidate.skipIf)) else { return false }
            let zones = Set(store.steps(for: candidate).flatMap(\.bodyMapZones))
            return zones.isDisjoint(with: blocked)
        }
        return candidates.min { $0.maxPressure < $1.maxPressure }?.id
    }

    /// Zones that should render hatched-out on the body map.
    func blockedZones(answers: [String]) -> Set<BodyZone> {
        Set(answers.compactMap(Contraindication.find).flatMap(\.blockedZones))
    }
}
