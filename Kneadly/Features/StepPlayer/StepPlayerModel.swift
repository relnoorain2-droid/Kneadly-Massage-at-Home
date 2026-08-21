import Foundation
import Observation
import SwiftData
import UIKit

/// Timing is deadline-based rather than tick-based so that backgrounding,
/// interruptions and clock changes never desynchronise the session.
@MainActor
@Observable
final class StepPlayerModel {

    let routine: Routine
    let steps: [Step]
    let pressureCap: Int?
    let partnerName: String?

    private(set) var index = 0
    private(set) var remaining: Int
    private(set) var isPlaying = false
    private(set) var isTransitioning = false
    private(set) var stepsCompleted = 0
    private(set) var elapsedSeconds = 0

    var viewpoint: Viewpoint = .giver

    private var deadline: Date?
    private var ticker: Timer?
    private let narration: NarrationPlayer
    private let onFinish: (Int, Int) -> Void

    init(routine: Routine,
         steps: [Step],
         pressureCap: Int?,
         partnerName: String?,
         narration: NarrationPlayer,
         onFinish: @escaping (Int, Int) -> Void) {
        self.routine = routine
        self.steps = steps.isEmpty ? [Step.placeholder] : steps
        self.pressureCap = pressureCap
        self.partnerName = partnerName
        self.narration = narration
        self.onFinish = onFinish
        self.remaining = self.steps[0].durationSeconds
    }

    // MARK: - Derived

    var step: Step { steps[min(index, steps.count - 1)] }
    var stepCount: Int { steps.count }
    var isLastStep: Bool { index >= steps.count - 1 }

    var nextStep: Step? {
        index + 1 < steps.count ? steps[index + 1] : nil
    }

    /// Pressure is lowered, never raised, by the safety cap.
    var displayedPressure: Int {
        guard let pressureCap else { return step.pressure }
        return min(step.pressure, pressureCap)
    }

    var isPressureCapped: Bool { displayedPressure < step.pressure }

    var stepProgress: Double {
        let total = Double(step.durationSeconds)
        guard total > 0 else { return 0 }
        return 1 - (Double(remaining) / total)
    }

    var timeLabel: String {
        String(format: "%d:%02d", remaining / 60, remaining % 60)
    }

    var totalRemainingLabel: String {
        let remainingSteps = steps.dropFirst(index + 1).reduce(0) { $0 + $1.durationSeconds }
        let total = remaining + remainingSteps
        return String(format: "%d:%02d left", total / 60, total % 60)
    }

    // MARK: - Lifecycle

    func begin() {
        UIApplication.shared.isIdleTimerDisabled = true
        narration.configureAudioSession()
        play()
    }

    func end() {
        pause()
        UIApplication.shared.isIdleTimerDisabled = false
        narration.stop()
        narration.deactivateAudioSession()
    }

    func play() {
        guard !isTransitioning else { return }
        isPlaying = true
        deadline = Date().addingTimeInterval(TimeInterval(remaining))
        startTicker()
        narration.speak(step: step, viewpoint: viewpoint)
    }

    func pause() {
        isPlaying = false
        ticker?.invalidate()
        ticker = nil
        deadline = nil
        narration.stop()
        Analytics.log(.sessionPaused(index: index))
    }

    func togglePlay() {
        isPlaying ? pause() : play()
    }

    func repeatStep() {
        Analytics.log(.stepRepeated(index: index))
        remaining = step.durationSeconds
        if isPlaying {
            deadline = Date().addingTimeInterval(TimeInterval(remaining))
        }
        narration.speak(step: step, viewpoint: viewpoint)
    }

    func toggleViewpoint() {
        viewpoint = viewpoint == .giver ? .receiver : .giver
        narration.speak(step: step, viewpoint: viewpoint)
    }

    func advance(auto: Bool = false) {
        guard !isTransitioning else { return }
        Analytics.log(.stepAdvanced(index: index))
        stepsCompleted = max(stepsCompleted, index + 1)

        guard !isLastStep else {
            finish()
            return
        }

        let resume = isPlaying || auto
        pauseWithoutLogging()
        isTransitioning = true
        Haptics.medium()

        // Give the giver time to physically move their hands.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1600))
            isTransitioning = false
            index += 1
            remaining = step.durationSeconds
            if resume { play() }
        }
    }

    func goBack() {
        guard index > 0, !isTransitioning else { return }
        let resume = isPlaying
        pauseWithoutLogging()
        index -= 1
        remaining = step.durationSeconds
        if resume { play() }
    }

    func skip() { advance(auto: false) }

    func finish() {
        end()
        Analytics.log(.sessionCompleted(routine: routine.id, seconds: elapsedSeconds))
        Haptics.sessionComplete()
        onFinish(elapsedSeconds, max(stepsCompleted, steps.count))
    }

    func abandon() {
        end()
        Analytics.log(.sessionAbandoned(routine: routine.id, index: index))
    }

    // MARK: - Ticking

    private func pauseWithoutLogging() {
        isPlaying = false
        ticker?.invalidate()
        ticker = nil
        deadline = nil
        narration.stop()
    }

    private func startTicker() {
        ticker?.invalidate()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func tick() {
        guard isPlaying, let deadline else { return }
        let left = Int(ceil(deadline.timeIntervalSinceNow))
        if left != remaining {
            elapsedSeconds += max(0, remaining - left)
            remaining = max(0, left)
            Haptics.tick(remaining: remaining)
        }
        if remaining <= 0 { advance(auto: true) }
    }

    /// Called when the app returns from the background — the deadline is authoritative.
    func resync() {
        guard isPlaying, let deadline else { return }
        remaining = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
        if remaining <= 0 { advance(auto: true) }
    }
}

extension Step {
    /// Never shown in practice — protects the player from an empty routine.
    static let placeholder = Step(
        id: "placeholder",
        regionID: "shouldersUpperTrap",
        techniqueID: "staticHold",
        title: "Rest your hands",
        body: "Place both palms flat and take three slow breaths.",
        sensationCue: "Warmth, and shoulders dropping.",
        handPosition: .flatPalm,
        pressure: 1,
        durationSeconds: 30,
        rhythm: "Still",
        breathCue: nil,
        heroImage: "img.reg.rest",
        heroPlaceholderHex: "#C9A188",
        bodyMapZones: [.shoulders],
        strokePath: nil,
        voiceScript: "Rest both palms flat and take three slow breaths.",
        commonMistake: nil,
        caution: nil,
        modes: [.solo, .partner, .friends, .together],
        contraindications: []
    )
}
