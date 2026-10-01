import SwiftUI

// MARK: - Relief Score
//
// The one thing no consumer massage app does: measure whether it helped.
// Before a session the user rates tension 0–10; afterwards, again. Over
// time Kneadly can say "Neck & Shoulder Reset takes you from 6 to 3" —
// proof of value, and the basis for recommending what works for *you*.
// Ratings never leave the device.

/// An 11-point tension scale, tappable, with a live word label.
struct TensionPicker: View {
    @Binding var value: Int?
    var title: String = "How tight does it feel right now?"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundStyle(K.textPrimary)
                Spacer(minLength: 8)
                Text(value.map(Self.word) ?? "Tap a number")
                    .font(.kFootnote)
                    .foregroundStyle(value == nil ? K.ink300 : Self.color(value!))
                    .animation(.easeOut(duration: 0.15), value: value)
            }
            HStack(spacing: 4) {
                ForEach(0...10, id: \.self) { n in
                    let isOn = value == n
                    Button {
                        Haptics.selection()
                        value = n
                    } label: {
                        Text("\(n)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .foregroundStyle(isOn ? K.bone : K.textPrimary)
                            .background(isOn ? Self.color(n) : Self.color(n).opacity(0.13),
                                        in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(PressScaleStyle())
                    .accessibilityLabel("\(n), \(Self.word(n))")
                    .accessibilityAddTraits(isOn ? [.isSelected] : [])
                }
            }
            HStack {
                Text("Loose").font(.system(size: 10.5)).foregroundStyle(K.ink300)
                Spacer()
                Text("Very tight").font(.system(size: 10.5)).foregroundStyle(K.ink300)
            }
        }
    }

    static func word(_ n: Int) -> String {
        switch n {
        case 0: return "Completely loose"
        case 1...2: return "Barely there"
        case 3...4: return "Noticeable"
        case 5...6: return "Tight"
        case 7...8: return "Very tight"
        default: return "As bad as it gets"
        }
    }

    static func color(_ n: Int) -> Color {
        switch n {
        case 0...2: return K.sage600
        case 3...4: return Color(hex: "#B9A24A")
        case 5...6: return Color(hex: "#D08A4E")
        default: return K.terracotta600
        }
    }
}

// MARK: - Stats

struct ReliefEntry: Identifiable {
    let id: UUID
    let date: Date
    let routineID: String
    let routineTitle: String
    let before: Int
    let after: Int
    var drop: Int { before - after }
}

struct RoutineRelief: Identifiable {
    let id: String
    let title: String
    let sessions: Int
    let averageBefore: Double
    let averageAfter: Double
    var averageDrop: Double { averageBefore - averageAfter }
}

enum ReliefStats {
    static func entries(_ logs: [SessionLog]) -> [ReliefEntry] {
        logs.compactMap { log in
            guard log.isComplete, let b = log.tensionBefore, let a = log.tensionAfter else { return nil }
            return ReliefEntry(id: log.id, date: log.startedAt, routineID: log.routineID,
                               routineTitle: log.routineTitle, before: b, after: a)
        }
        .sorted { $0.date < $1.date }
    }

    static func byRoutine(_ entries: [ReliefEntry]) -> [RoutineRelief] {
        let groups: [String: [ReliefEntry]] = Dictionary(grouping: entries, by: { $0.routineID })
        var result: [RoutineRelief] = []
        for (id, group) in groups {
            let count = Double(group.count)
            let beforeSum: Int = group.reduce(0) { $0 + $1.before }
            let afterSum: Int = group.reduce(0) { $0 + $1.after }
            let title: String = group.last?.routineTitle ?? id
            result.append(RoutineRelief(id: id, title: title, sessions: group.count,
                                        averageBefore: Double(beforeSum) / count,
                                        averageAfter: Double(afterSum) / count))
        }
        return result.sorted { $0.averageDrop > $1.averageDrop }
    }

    static func averageDrop(_ entries: [ReliefEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let total: Int = entries.reduce(0) { $0 + $1.drop }
        return Double(total) / Double(entries.count)
    }

    /// The routine that has helped this person most, once there is enough
    /// evidence to say so (2+ rated sessions and a real drop).
    static func bestRoutineID(_ logs: [SessionLog]) -> String? {
        byRoutine(entries(logs)).first { $0.sessions >= 2 && $0.averageDrop >= 1 }?.id
    }

    /// "6 → 3, down 50%" — honest, specific, never a medical claim.
    static func headline(before: Int, after: Int) -> String {
        if after < before {
            let pct = before == 0 ? 0 : Int((Double(before - after) / Double(before) * 100).rounded())
            return "\(before) → \(after). Down \(pct)%."
        }
        if after == before { return "\(before) → \(after). Holding steady." }
        return "\(before) → \(after). A little higher."
    }
}
