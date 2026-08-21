import SwiftUI

struct RoutineHeroCard: View {
    let routine: Routine
    var locked: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex)
            PhotoScrim()
            VStack(alignment: .leading, spacing: 8) {
                Text(routine.title)
                    .font(.kDisplay(22))
                    .foregroundStyle(K.bone)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                HStack(spacing: 6) {
                    KChip(text: routine.mode.title, systemImage: routine.mode.symbol, style: .translucent)
                    KChip(text: routine.durationLabel, style: .translucent)
                    KChip(text: routine.pressureLabel, style: .translucent)
                }
            }
            .padding(KSpace.md)

            if locked {
                LockBadge()
                    .padding(KSpace.sm)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(height: 212)
        .clipShape(RoundedRectangle(cornerRadius: KRadius.xl, style: .continuous))
        .kShadow(.e2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(routine.title). \(routine.mode.title). \(routine.durationLabel). \(routine.level.title).\(locked ? " Requires Kneadly Plus." : "")")
        .accessibilityAddTraits(.isButton)
    }
}

struct RoutineMiniCard: View {
    let routine: Routine
    var locked: Bool = false
    var width: CGFloat = 152

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ZStack {
                KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex)
                PhotoScrim(strength: 0.7)
                if locked {
                    LockBadge().padding(7).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))

            Text(routine.title)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(K.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(routine.mode.title) · \(routine.durationLabel)")
                .font(.system(size: 11.5))
                .foregroundStyle(K.textSecondary)
        }
        .frame(width: width, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(routine.title). \(routine.mode.title). \(routine.durationLabel).\(locked ? " Requires Kneadly Plus." : "")")
        .accessibilityAddTraits(.isButton)
    }
}

struct RoutineRow: View {
    let routine: Routine
    var locked: Bool = false
    var verdict: SafetyVerdict = .allowed

    var body: some View {
        HStack(spacing: KSpace.sm) {
            ZStack {
                KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex, showsGrade: false)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text(routine.title)
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(K.textPrimary)
                        .lineLimit(1)
                    if locked { Image(systemName: "lock.fill").font(.system(size: 10)).foregroundStyle(K.ink300) }
                }
                HStack(spacing: 7) {
                    Text("\(routine.durationLabel) · \(routine.level.title)")
                        .font(.system(size: 11.5))
                        .foregroundStyle(K.textSecondary)
                    PressureMeter(level: routine.maxPressure, showLabel: false)
                }
                if verdict.isBlocked {
                    Text("Modified for your health answers")
                        .font(.system(size: 11))
                        .foregroundStyle(K.sage800)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(K.ink300)
        }
        .padding(11)
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(routine.title). \(routine.durationLabel). \(routine.level.title). Maximum pressure \(routine.maxPressure) of 5.\(locked ? " Requires Kneadly Plus." : "")")
        .accessibilityAddTraits(.isButton)
    }
}

struct ProgramCard: View {
    let program: Program
    var progress: Double = 0
    var locked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                KPhoto(id: program.coverImage, placeholderHex: program.coverPlaceholderHex)
                PhotoScrim(strength: 0.7)
                if locked {
                    LockBadge().padding(7).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 126)
            .clipShape(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))

            Text(program.title)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(K.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(program.dayCount) days")
                .font(.system(size: 11.5))
                .foregroundStyle(K.textSecondary)
            if progress > 0 {
                ProgressBar(value: progress).frame(height: 5)
            }
        }
        .frame(width: 212, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(program.title). \(program.dayCount) day program.\(locked ? " Requires Kneadly Plus." : "")")
    }
}

struct LockBadge: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(K.bone)
            .frame(width: 24, height: 24)
            .background(.ultraThinMaterial, in: Circle())
            .accessibilityHidden(true)
    }
}

struct ProgressBar: View {
    let value: Double
    var tint: Color = K.terracotta500

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(K.sand200)
                Capsule().fill(tint).frame(width: geo.size.width * max(0, min(1, value)))
            }
        }
        .accessibilityHidden(true)
    }
}

struct StreakRing: View {
    /// Seven booleans, Monday first.
    let days: [Bool]
    let todayIndex: Int

    private let letters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                let done = index < days.count && days[index]
                Text(letters[index])
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(done ? K.bone : (index == todayIndex ? K.terracotta700 : K.ink300))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background {
                        if done { Circle().fill(K.terracotta500) }
                        else if index == todayIndex { Circle().fill(K.surface).overlay(Circle().strokeBorder(K.terracotta500, lineWidth: 2)) }
                        else { Circle().fill(K.sand200) }
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("This week: \(days.filter { $0 }.count) of 7 days completed.")
    }
}

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.kDisplay(25))
            Text(label).kOverline()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: KRadius.md, style: .continuous).strokeBorder(K.separator, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}
