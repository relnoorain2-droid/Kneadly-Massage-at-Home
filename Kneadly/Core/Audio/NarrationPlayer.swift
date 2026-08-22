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
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.88
        utterance.pitchMultiplier = 0.96
        utterance.preUtteranceDelay = 0.15
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
        let code = String((Locale.preferredLanguages.first ?? "en-GB").prefix(2))
        let candidates = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(code) }

        func best(_ quality: AVSpeechSynthesisVoiceQuality) -> AVSpeechSynthesisVoice? {
            let preferredNames = ["Serena", "Sonia", "Ava", "Kate", "Zoe", "Nathan", "Daniel"]
            let pool = candidates.filter { $0.quality == quality }
            for name in preferredNames {
                if let match = pool.first(where: { $0.name.contains(name) }) { return match }
            }
            return pool.first
        }

        return best(.premium)
            ?? best(.enhanced)
            ?? best(.default)
            ?? AVSpeechSynthesisVoice(language: "en-GB")
    }

    static var isUsingCompactVoiceOnly: Bool {
        let code = String((Locale.preferredLanguages.first ?? "en-GB").prefix(2))
        return !AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(code) }
            .contains { $0.quality != .default }
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
