import Foundation
import AVFoundation

/// Speaks each step aloud. The giver's hands are busy and oily — this is not a
/// nice-to-have, it is how the app is actually used.
///
/// v1 uses AVSpeechSynthesizer. Recorded voice-over drops in behind the same
/// interface in v1.1 by giving each step an audio file and preferring it here.
@MainActor
final class NarrationPlayer: NSObject {

    private(set) var isSpeaking = false
    var enabled = true

    private let synth = AVSpeechSynthesizer()

    override init() {
        super.init()
        synth.delegate = self
    }

    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback,
                                    mode: .spokenAudio,
                                    options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
        } catch {
            // Audio is an enhancement, never a blocker. Fail silently and carry on.
        }
    }

    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func speak(_ text: String) {
        guard enabled, !text.isEmpty else { return }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        utterance.pitchMultiplier = 0.98
        utterance.postUtteranceDelay = 0.2
        utterance.voice = Self.preferredVoice()
        synth.speak(utterance)
    }

    func speak(step: Step, viewpoint: Viewpoint) {
        switch viewpoint {
        case .giver:
            speak(step.spokenText)
        case .receiver:
            speak("Breathe out slowly. You should feel \(step.sensationCue) If it goes above a seven, say so now.")
        }
    }

    func stop() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
    }

    private static func preferredVoice() -> AVSpeechSynthesisVoice? {
        let language = Locale.preferredLanguages.first ?? "en-GB"
        if let enhanced = AVSpeechSynthesisVoice.speechVoices().first(where: {
            $0.language.hasPrefix(String(language.prefix(2))) && $0.quality != .default
        }) { return enhanced }
        return AVSpeechSynthesisVoice(language: language) ?? AVSpeechSynthesisVoice(language: "en-GB")
    }
}

extension NarrationPlayer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = true }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
