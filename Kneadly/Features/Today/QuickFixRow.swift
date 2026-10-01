import SwiftUI

/// Symptom-first entry. People don't open a massage app thinking "petrissage";
/// they open it thinking "my head hurts". One tap from the complaint to the
/// routine that addresses it.
struct QuickFix: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let routineID: String

    static let all: [QuickFix] = [
        .init(id: "headache", title: "Tension headache", symbol: "brain.head.profile", routineID: "head.solo.headache"),
        .init(id: "neck", title: "Stiff desk neck", symbol: "desktopcomputer", routineID: "neck.solo.reset"),
        .init(id: "sleep", title: "Can't switch off", symbol: "moon.zzz", routineID: "scalp.solo.sleep"),
        .init(id: "jaw", title: "Clenched jaw", symbol: "mouth", routineID: "jaw.solo.tmj"),
        .init(id: "wrist", title: "Typing wrists", symbol: "keyboard", routineID: "forearm.solo.rescue"),
        .init(id: "back", title: "Low back after sitting", symbol: "chair", routineID: "lowerback.solo.ball"),
        .init(id: "feet", title: "Tired feet", symbol: "shoeprints.fill", routineID: "foot.solo.relief"),
        .init(id: "calves", title: "Runner's calves", symbol: "figure.run", routineID: "calf.solo.release")
    ]
}

struct QuickFixRow: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "What's bothering you?")
                .padding(.horizontal, KSpace.screenMargin)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(QuickFix.all) { fix in
                        if let routine = env.content.routine(fix.routineID) {
                            Button {
                                Haptics.light()
                                Analytics.log(.routineOpened("quickfix.\(fix.id)"))
                                env.open(routine)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: fix.symbol)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(K.terracotta600)
                                        .frame(width: 34, height: 34)
                                        .background(K.terracotta500.opacity(0.1), in: Circle())
                                    Text(fix.title)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(K.textPrimary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(routine.minutes) min")
                                        .font(.system(size: 11))
                                        .foregroundStyle(K.textSecondary)
                                }
                                .frame(width: 118, height: 118, alignment: .topLeading)
                                .padding(12)
                                .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous)
                                    .strokeBorder(K.separator, lineWidth: 1))
                            }
                            .buttonStyle(PressScaleStyle())
                            .accessibilityLabel("\(fix.title). \(routine.minutes) minute routine.")
                        }
                    }
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
        }
    }
}
