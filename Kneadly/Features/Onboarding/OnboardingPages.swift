import SwiftUI

// MARK: - 3. Where does it hurt?

struct WhereHurtsPage: View {
    let onNext: () -> Void
    @Environment(AppEnvironment.self) private var env
    @State private var front = true

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Where does it hurt?").font(.kDisplay(28))
                Text("Tap up to three spots. We'll start there.")
                    .font(.kSubhead).foregroundStyle(K.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.top, 40)

            ZStack(alignment: .bottomTrailing) {
                BodyMapView(selection: env.user.soreZones, front: front) { zone in
                    toggle(zone)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, KSpace.md)

                FrontBackToggle(front: $front)
                    .padding(.trailing, KSpace.md)
                    .padding(.bottom, KSpace.sm)
            }
            .frame(maxHeight: .infinity)

            VStack(spacing: 10) {
                Text(selectionSummary)
                    .font(.kFootnote)
                    .foregroundStyle(K.textSecondary)
                    .frame(minHeight: 18)
                    .multilineTextAlignment(.center)
                PrimaryButton(title: "Continue", action: onNext)
                Button("Nothing hurts, I just want to relax") {
                    env.user.soreZones = []
                    env.user.save()
                    onNext()
                }
                .font(.kFootnote)
                .foregroundStyle(K.textSecondary)
            }
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.bottom, KSpace.md)
        }
    }

    private var selectionSummary: String {
        guard !env.user.soreZones.isEmpty else { return "Tap the body to choose" }
        return "Selected: " + env.user.soreZones.map { $0.title(front: front) }.sorted().joined(separator: ", ")
    }

    private func toggle(_ zone: BodyZone) {
        var zones = env.user.soreZones
        if zones.contains(zone) {
            zones.remove(zone)
        } else {
            if zones.count >= 3, let first = zones.first { zones.remove(first) }
            zones.insert(zone)
        }
        env.user.soreZones = zones
        env.user.save()
    }
}

struct FrontBackToggle: View {
    @Binding var front: Bool

    var body: some View {
        HStack(spacing: 3) {
            toggleButton("Front", isOn: front) { front = true }
            toggleButton("Back", isOn: !front) { front = false }
        }
        .padding(3)
        .background(K.surface, in: Capsule())
        .kShadow(.e2)
    }

    private func toggleButton(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(isOn ? K.bone : K.ink300)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isOn ? K.terracotta500 : .clear, in: Capsule())
        }
    }
}

// MARK: - 4. Time & experience

struct TimeAndLevelPage: View {
    let onNext: () -> Void
    @Environment(AppEnvironment.self) private var env

    private let times: [(Int, String, String, String)] = [
        (10, "bolt", "5–10 minutes", "A quick reset"),
        (20, "moon", "15–20 minutes", "A proper session"),
        (45, "flame", "30+ minutes", "The full experience")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("How much time do\nyou usually have?")
                        .font(.kDisplay(28)).padding(.top, 40)
                    Text("We'll suggest routines that fit.")
                        .font(.kSubhead).foregroundStyle(K.textSecondary)
                        .padding(.top, 8).padding(.bottom, 18)

                    ForEach(times, id: \.0) { minutes, symbol, title, subtitle in
                        SelectRow(symbol: symbol, title: title, subtitle: subtitle,
                                  isSelected: env.user.maxMinutes == minutes) {
                            Haptics.selection()
                            env.user.maxMinutes = minutes
                            env.user.save()
                        }
                    }

                    SectionHeader(title: "Your experience")

                    ForEach(Level.allCases, id: \.self) { level in
                        SelectRow(symbol: symbol(for: level), title: level.title, subtitle: level.blurb,
                                  isSelected: env.user.level == level) {
                            Haptics.selection()
                            env.user.level = level
                            env.user.save()
                        }
                    }
                    Spacer(minLength: KSpace.md)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            PrimaryButton(title: "Continue", action: onNext)
                .padding(.horizontal, KSpace.screenMargin)
                .padding(.bottom, KSpace.md)
        }
    }

    private func symbol(for level: Level) -> String {
        switch level {
        case .beginner: return "leaf"
        case .intermediate: return "tree"
        case .advanced: return "mountain.2"
        }
    }
}

struct SelectRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(K.terracotta600)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(K.textPrimary)
                    Text(subtitle).font(.kCaption).foregroundStyle(K.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                CheckBox(isOn: isSelected)
            }
            .padding(15)
            .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? K.terracotta500 : K.separator, lineWidth: 1.5)
            )
            .padding(.bottom, 9)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct CheckBox: View {
    let isOn: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(isOn ? K.terracotta500 : .clear)
            .frame(width: 22, height: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(isOn ? K.terracotta500 : K.sand200, lineWidth: 2)
            )
            .overlay {
                if isOn {
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(K.bone)
                }
            }
    }
}

// MARK: - 5. Safety screening (blocking)

struct SafetyScreenPage: View {
    let onNext: () -> Void
    @Environment(AppEnvironment.self) private var env
    @State private var noneSelected = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 22))
                        .foregroundStyle(K.sage600)
                        .frame(width: 46, height: 46)
                        .background(K.sage300.opacity(0.28), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.top, 40)
                        .padding(.bottom, 13)

                    Text("Two quick\nhealth questions.").font(.kDisplay(28))
                    Text("Massage is safe for almost everyone. These questions make sure it's safe for you — and they never leave your phone.")
                        .font(.kSubhead).foregroundStyle(K.textSecondary)
                        .padding(.top, 8).padding(.bottom, 6)
                        .fixedSize(horizontal: false, vertical: true)

                    SectionHeader(title: "Does any of this apply?")

                    ForEach(Contraindication.all) { item in
                        CheckRow(title: item.plainQuestion,
                                 isOn: env.user.healthAnswers.contains(item.id)) {
                            toggle(item.id)
                        }
                    }

                    CheckRow(title: "None of these apply to me", isOn: noneSelected) {
                        Haptics.selection()
                        noneSelected = true
                        env.user.healthAnswers = []
                        env.user.save()
                    }

                    SafetyBanner(
                        title: "Why we ask",
                        message: "If something applies we don't just hide routines — we show you a safe, modified version instead, and tell you plainly why."
                    )
                    .padding(.top, 14)

                    Spacer(minLength: KSpace.md)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            PrimaryButton(title: "Continue") {
                Analytics.log(.contraindicationFlagged(count: env.user.healthAnswers.count))
                onNext()
            }
            .padding(.horizontal, KSpace.screenMargin)
            .padding(.bottom, KSpace.md)
        }
        .background(
            LinearGradient(colors: [Color(hex: "#F2F5F1"), K.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear { noneSelected = env.user.healthAnswers.isEmpty }
    }

    private func toggle(_ id: String) {
        Haptics.selection()
        var answers = env.user.healthAnswers
        if let index = answers.firstIndex(of: id) { answers.remove(at: index) } else { answers.append(id) }
        env.user.healthAnswers = answers
        noneSelected = answers.isEmpty
        env.user.save()
    }
}

struct CheckRow: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                CheckBox(isOn: isOn)
                Text(title)
                    .font(.system(size: 14.5))
                    .foregroundStyle(K.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(K.surface, in: RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous)
                    .strokeBorder(isOn ? K.terracotta500 : K.separator, lineWidth: 1.5)
            )
            .padding(.bottom, 8)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

// MARK: - 6. Ready

struct ReadyPage: View {
    let onStart: () -> Void
    let onBrowse: () -> Void
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        ZStack {
            KPhoto(id: "img.onb.07", placeholderHex: "#A8836B").ignoresSafeArea()
            LinearGradient(colors: [K.ink900.opacity(0.30), K.ink900.opacity(0.55), K.ink900.opacity(0.95)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("You're ready.").font(.kDisplay(33)).foregroundStyle(K.bone)
                Text("Based on what you told us, start here:")
                    .font(.kCallout).foregroundStyle(K.bone.opacity(0.82))
                    .padding(.top, 8).padding(.bottom, 18)

                if let routine = suggestion {
                    HStack(spacing: 12) {
                        KPhoto(id: routine.coverImage, placeholderHex: routine.coverPlaceholderHex, showsGrade: false)
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(routine.title).font(.system(size: 15.5, weight: .semibold)).foregroundStyle(K.bone)
                            HStack(spacing: 6) {
                                KChip(text: routine.mode.title, style: .translucent)
                                KChip(text: routine.durationLabel, style: .translucent)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.bottom, 18)
                }

                PrimaryButton(title: "Start my first massage", action: onStart)
                Button("Look around first", action: onBrowse)
                    .font(.kFootnote)
                    .foregroundStyle(K.bone.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
            }
            .padding(.horizontal, KSpace.xl)
            .padding(.bottom, KSpace.xxl)
        }
    }

    private var suggestion: Routine? {
        env.content.suggestion(modes: env.user.selectedModes,
                               zones: env.user.soreZones,
                               maxMinutes: env.user.maxMinutes,
                               isPlus: env.subscriptions.isPlus)
    }
}

// MARK: - Disclaimer

struct DisclaimerSheet: View {
    let onAccept: () -> Void
    @State private var scrolledToEnd = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: KSpace.md) {
                    Text("Before you start").font(.kDisplay(26)).padding(.top, KSpace.xl)
                    Text(AppBrand.disclaimer)
                        .font(.kCallout)
                        .foregroundStyle(K.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Color.clear.frame(height: 1)
                        .onAppear { scrolledToEnd = true }
                    Spacer(minLength: KSpace.md)
                }
                .padding(.horizontal, KSpace.screenMargin)
            }
            PrimaryButton(title: scrolledToEnd ? "I understand" : "Scroll to continue",
                          isEnabled: scrolledToEnd,
                          action: onAccept)
                .padding(.horizontal, KSpace.screenMargin)
                .padding(.bottom, KSpace.md)
        }
        .background(K.background.ignoresSafeArea())
    }
}
