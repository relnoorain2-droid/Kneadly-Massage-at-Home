import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppEnvironment.self) private var env
    @State private var page = 0
    @State private var showDisclaimer = false

    private let pageCount = 6

    var body: some View {
        ZStack {
            K.background.ignoresSafeArea()

            switch page {
            case 0: WelcomePage(onNext: next)
            case 1: WhoPage(onNext: next)
            case 2: WhereHurtsPage(onNext: next)
            case 3: TimeAndLevelPage(onNext: next)
            case 4: SafetyScreenPage(onNext: next)
            default: ReadyPage(onStart: finish, onBrowse: finishAndBrowse)
            }
        }
        .overlay(alignment: .top) {
            if page > 0 { ProgressDots(count: pageCount, index: page).padding(.top, 8) }
        }
        .animation(KMotion.screen, value: page)
        .sheet(isPresented: $showDisclaimer) {
            DisclaimerSheet {
                env.user.hasAcceptedDisclaimer = true
                env.user.disclaimerVersion = UserState.currentDisclaimerVersion
                env.user.save()
                showDisclaimer = false
            }
            .interactiveDismissDisabled()
        }
        .onAppear {
            if env.user.needsDisclaimer { showDisclaimer = true }
        }
    }

    private func next() {
        Analytics.log(.onboardingStepViewed(page + 1))
        page = min(pageCount - 1, page + 1)
    }

    private func finish() {
        complete()
        if let routine = suggestion { env.presentedRoutine = routine }
    }

    private func finishAndBrowse() { complete() }

    private func complete() {
        env.user.hasCompletedOnboarding = true
        env.user.save()
    }

    private var suggestion: Routine? {
        env.content.suggestion(modes: env.user.selectedModes,
                               zones: env.user.soreZones,
                               maxMinutes: env.user.maxMinutes,
                               isPlus: env.subscriptions.isPlus)
    }
}

struct ProgressDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? K.bone : K.bone.opacity(0.32))
                    .frame(width: 20, height: 3)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - 1. Welcome

struct WelcomePage: View {
    let onNext: () -> Void
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        ZStack {
            KPhoto(id: "img.onb.01", placeholderHex: "#B98F76").ignoresSafeArea()
            PhotoScrim().ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("Good hands\naren't a talent.")
                    .font(.kDisplay(33))
                    .foregroundStyle(K.bone)
                    .padding(.bottom, 10)
                Text("They're ten steps and a bit of guidance. Let's teach yours.")
                    .font(.kCallout)
                    .foregroundStyle(K.bone.opacity(0.85))
                    .padding(.bottom, 22)
                PrimaryButton(title: "Begin", action: onNext)
                Button("Already have Kneadly Plus? Restore") {
                    Task { await env.subscriptions.restore() }
                }
                .font(.kFootnote)
                .foregroundStyle(K.bone.opacity(0.75))
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
            }
            .padding(.horizontal, KSpace.xl)
            .padding(.bottom, KSpace.xxl)
        }
    }
}

// MARK: - 2. Who

struct WhoPage: View {
    let onNext: () -> Void
    @Environment(AppEnvironment.self) private var env

    private let images = ["img.reg.hand", "img.reg.back", "img.mood.hands", "img.mood.couple"]

    var body: some View {
        ZStack {
            KPhoto(id: "img.onb.02", placeholderHex: "#A8836B").ignoresSafeArea()
            LinearGradient(colors: [K.ink900.opacity(0.42), K.ink900.opacity(0.72), K.ink900.opacity(0.95)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("Who will you be\nmassaging?")
                    .font(.kDisplay(31))
                    .foregroundStyle(K.bone)
                    .padding(.bottom, 8)
                Text("Pick all that apply — nothing is locked in.")
                    .font(.kSubhead)
                    .foregroundStyle(K.bone.opacity(0.82))
                    .padding(.bottom, 16)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)], spacing: 11) {
                    ForEach(Array(SessionMode.allCases.enumerated()), id: \.element) { index, mode in
                        ModeCard(mode: mode,
                                 imageID: images[index],
                                 isSelected: env.user.selectedModes.contains(mode)) {
                            toggle(mode)
                        }
                    }
                }
                .padding(.bottom, 18)

                PrimaryButton(title: "Continue", isEnabled: !env.user.selectedModes.isEmpty, action: onNext)
            }
            .padding(.horizontal, KSpace.xl)
            .padding(.bottom, KSpace.xxl)
        }
    }

    private func toggle(_ mode: SessionMode) {
        Haptics.selection()
        if env.user.selectedModes.contains(mode) {
            env.user.selectedModes.remove(mode)
        } else {
            env.user.selectedModes.insert(mode)
            Analytics.log(.modeSelected(mode.rawValue))
        }
        env.user.save()
    }
}

struct ModeCard: View {
    let mode: SessionMode
    let imageID: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                KPhoto(id: imageID, placeholderHex: "#C2A58E")
                PhotoScrim(strength: 0.9)
                Image(systemName: mode.symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                Text(mode.longTitle)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .multilineTextAlignment(.leading)
                    .padding(11)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(K.bone)
                        .frame(width: 22, height: 22)
                        .background(K.terracotta500, in: Circle())
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 118)
            .clipShape(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? K.terracotta500 : .clear, lineWidth: 2.5)
            )
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(mode.longTitle)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
