import Foundation
import UIKit

/// Haptics carry meaning in this app: the rhythm guide lets a giver match their
/// hands to their pocket without ever looking at the screen.
enum Haptics {

    static var enabled = true

    @MainActor static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @MainActor static func medium() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @MainActor static func soft(intensity: CGFloat = 0.4) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: intensity)
    }

    @MainActor static func rigid() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    @MainActor static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @MainActor static func warning() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    @MainActor static func selection() {
        guard enabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Called every second of a step. Soft tick each 15s, double-tick at 5s left.
    @MainActor static func tick(remaining: Int) {
        guard enabled else { return }
        if remaining == 5 {
            soft(intensity: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { soft(intensity: 0.5) }
        } else if remaining > 0 && remaining % 15 == 0 {
            soft(intensity: 0.25)
        }
    }

    /// Three soft swells, decreasing. Used when a session finishes.
    @MainActor static func sessionComplete() {
        guard enabled else { return }
        let intensities: [CGFloat] = [0.9, 0.6, 0.35]
        for (i, value) in intensities.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.28) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: value)
            }
        }
    }
}
