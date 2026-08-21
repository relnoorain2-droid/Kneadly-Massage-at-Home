import SwiftUI
import SwiftData

/// The screen the whole product exists to deliver.
///
/// Nine simultaneous information channels — photo, body map, stroke direction,
/// step counter, countdown, pressure, rhythm, instruction, sensation cue —
/// kept calm by three rules: only one thing moves at a time, the body map never
/// changes position, and anything longer than two sentences goes to the voice.
struct StepPlayerView: View {
    let request: SessionRequest

    @Environment(AppEnvironment.self) private var env
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var model: StepPlayerModel?
    @State private var log: SessionLog?
    @State private var showQuitConfirm = false

    var body: some View {
        ZStack {
            K.ink900.ignoresSafeArea()

            if let model {
                content(model)
                    .opacity(model.isTransitioning ? 0 : 1)
                    .animation(reduceMotion ? nil : KMotion.step, value: model.isTransitioning)

                if model.isTransitioning, let next = model.nextStep {
                    TransitionCard(step: next)
                        .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(false)
        .onAppear(perform: start)
        .onDisappear { model?.end() }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active: model?.resync()
            case .background: model?.pause()
            default: break
            }
        }
        .confirmationDialog("End this session?", isPresented: $showQuitConfirm, titleVisibility: .visible) {
            Button("End session", role: .destructive) { quit() }
            Button("Keep going", role: .cancel) { }
        } message: {
            Text("Your progress so far will be saved.")
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(_ model: StepPlayerModel) -> some View {
        VStack(spacing: 0) {
            topBar(model)
            progressBar(model)
            hero(model)
            info(model)
            transport(model)
            toggles(model)
        }
    }

    private func topBar(_ model: StepPlayerModel) -> some View {
        HStack {
            Button { showQuitConfirm = true } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .frame(width: 32, height: 32)
                    .background(K.bone.opacity(0.1), in: Circle())
            }
            .accessibilityLabel("End session")

            Spacer()
            Text("STEP \(model.index + 1) OF \(model.stepCount)")
                .font(.system(size: 12.5, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(K.bone.opacity(0.62))
            Spacer()

            Text(model.totalRemainingLabel)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(K.bone.opacity(0.45))
                .frame(width: 62, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    private func progressBar(_ model: StepPlayerModel) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<model.stepCount, id: \.self) { i in
                Capsule()
                    .fill(i < model.index ? K.terracotta500
                          : (i == model.index ? K.clay400 : K.bone.opacity(0.16)))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 11)
        .accessibilityHidden(true)
    }

    private func hero(_ model: StepPlayerModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            KPhoto(id: model.step.heroImage, placeholderHex: model.step.heroPlaceholderHex)
            LinearGradient(colors: [.clear, K.ink900.opacity(0.55)], startPoint: .center, endPoint: .bottom)

            BodyMapMini(zones: model.step.bodyMapZones, strokePath: model.step.strokePath)
                .padding(5)
                .frame(width: 74, height: 98)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(K.bone.opacity(0.1), lineWidth: 1))
                .padding(10)

            Text(model.timeLabel)
                .font(.kTimer)
                .foregroundStyle(K.bone)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .accessibilityLabel("\(model.remaining) seconds remaining")
        }
        .frame(height: 252)
        .clipShape(RoundedRectangle(cornerRadius: KRadius.lg, style: .continuous))
        .padding(.horizontal, 18)
        .padding(.top, 13)
    }

    private func info(_ model: StepPlayerModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(model.viewpoint == .giver ? model.step.overline : "RECEIVER")
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(K.clay400)
                    .padding(.bottom, 6)

                Text(titleText(model))
                    .font(.kStepTitle)
                    .foregroundStyle(K.bone)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 9)

                Text(bodyText(model))
                    .font(.system(size: 15.5))
                    .foregroundStyle(K.bone.opacity(0.83))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 13)

                SensationCue(text: model.step.sensationCue, onDark: true)
                    .padding(.bottom, 13)

                if let caution = model.step.caution {
                    SafetyBanner(title: "Careful", message: caution, tone: .stop)
                        .padding(.bottom, 13)
                }

                HStack(alignment: .top, spacing: 22) {
                    metric("Pressure") {
                        HStack(spacing: 7) {
                            PressureMeter(level: model.displayedPressure, showLabel: true, onDark: true)
                            if model.isPressureCapped {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 11))
                                    .foregroundStyle(K.sage300)
                                    .accessibilityLabel("Pressure capped for your health answers")
                            }
                        }
                    }
                    metric("Hands") {
                        Text(model.step.handPosition.title)
                            .font(.system(size: 13.5, weight: .semibold))
                            .foregroundStyle(K.bone)
                    }
                }
                .padding(.bottom, 10)

                if let rhythm = model.step.rhythm {
                    metric("Rhythm") {
                        Text(rhythm).font(.system(size: 13.5)).foregroundStyle(K.bone.opacity(0.75))
                    }
                    .padding(.bottom, 10)
                }

                if reduceMotion, let stroke = model.step.strokePath {
                    metric("Direction") {
                        Text(stroke.motion.staticDescription)
                            .font(.system(size: 13.5)).foregroundStyle(K.bone.opacity(0.75))
                    }
                    .padding(.bottom, 10)
                }

                if let mistake = model.step.commonMistake {
                    Text(mistake)
                        .font(.system(size: 12.5))
                        .foregroundStyle(K.bone.opacity(0.5))
                        .padding(.bottom, 10)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(model.step.accessibilityDescription)
    }

    private func metric<Content: View>(_ key: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(key)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundStyle(K.bone.opacity(0.42))
            content()
        }
    }

    private func transport(_ model: StepPlayerModel) -> some View {
        HStack {
            Button { model.repeatStep() } label: {
                Label("Repeat", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    .background(K.bone.opacity(0.09), in: Capsule())
            }

            Spacer()

            Button { model.togglePlay() } label: {
                ZStack {
                    Circle().fill(K.terracotta500).frame(width: 66, height: 66)
                    TimerRing(progress: model.stepProgress).frame(width: 78, height: 78)
                    Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(K.bone)
                }
            }
            .accessibilityLabel(model.isPlaying ? "Pause" : "Play")

            Spacer()

            Button { model.advance() } label: {
                Label("Next", systemImage: "arrow.right")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(K.bone)
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    .background(K.bone.opacity(0.09), in: Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func toggles(_ model: StepPlayerModel) -> some View {
        HStack(spacing: 8) {
            toggleButton(env.user.voiceEnabled ? "Voice on" : "Voice off",
                         systemImage: env.user.voiceEnabled ? "speaker.wave.2" : "speaker.slash",
                         isOn: env.user.voiceEnabled) {
                env.user.voiceEnabled.toggle()
                env.user.save()
                env.narration.enabled = env.user.voiceEnabled
                if !env.user.voiceEnabled { env.narration.stop() }
                Analytics.log(.voiceToggled(env.user.voiceEnabled))
            }

            if request.routine.mode.needsConsentRitual {
                toggleButton(model.viewpoint.title,
                             systemImage: "eye",
                             isOn: model.viewpoint == .receiver) {
                    model.toggleViewpoint()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    private func toggleButton(_ title: String, systemImage: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(isOn ? K.bone : K.bone.opacity(0.7))
                .background(isOn ? K.terracotta500.opacity(0.25) : K.bone.opacity(0.07), in: Capsule())
                .overlay(Capsule().strokeBorder(isOn ? K.terracotta500 : K.bone.opacity(0.1), lineWidth: 1))
        }
    }

    // MARK: - Text

    private func titleText(_ model: StepPlayerModel) -> String {
        model.viewpoint == .giver ? model.step.title : "Breathe out as they press"
    }

    private func bodyText(_ model: StepPlayerModel) -> String {
        model.viewpoint == .giver
            ? model.step.body
            : "Let yourself be heavy. If this goes above a 7, say so now — not in a minute. \(model.step.breathCue ?? "")"
    }

    // MARK: - Lifecycle

    private func start() {
        guard model == nil else { return }
        let steps = env.content.steps(for: request.routine)
        let entry = SessionLog(routineID: request.routine.id,
                               routineTitle: request.routine.title,
                               mode: request.routine.mode,
                               stepsTotal: steps.count)
        entry.partnerName = request.partnerName
        context.insert(entry)
        log = entry

        let player = StepPlayerModel(
            routine: request.routine,
            steps: steps,
            pressureCap: request.pressureCap,
            partnerName: request.partnerName,
            narration: env.narration
        ) { seconds, completed in
            complete(seconds: seconds, stepsCompleted: completed)
        }
        model = player
        player.begin()
    }

    private func complete(seconds: Int, stepsCompleted: Int) {
        if let log {
            log.completedAt = Date()
            log.durationSeconds = seconds
            log.stepsCompleted = stepsCompleted
        }
        try? context.save()
        env.user.completedSessionCount += 1
        env.user.save()
        env.activeSession = nil
        env.completedSession = CompletedSession(routine: request.routine,
                                                seconds: seconds,
                                                stepsCompleted: stepsCompleted,
                                                logID: log?.id)
    }

    private func quit() {
        if let model, let log {
            log.durationSeconds = model.elapsedSeconds
            log.stepsCompleted = model.stepsCompleted
            log.abandonedAtStepIndex = model.index
            model.abandon()
        }
        try? context.save()
        env.activeSession = nil
        dismiss()
    }
}

struct TransitionCard: View {
    let step: Step

    var body: some View {
        ZStack {
            K.ink900.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("CHANGE POSITION")
                    .font(.system(size: 10.5, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(K.clay400)
                Text(step.title)
                    .font(.kDisplay(26))
                    .foregroundStyle(K.bone)
                    .multilineTextAlignment(.center)
                BodyMapMini(zones: step.bodyMapZones, strokePath: step.strokePath)
                    .frame(width: 78)
            }
            .padding(40)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Next: \(step.title)")
    }
}
