import Foundation
import CoreGraphics

// MARK: - Stroke path

/// Normalised coordinates on the 200 x 400 body silhouette, stored 0...1.
struct StrokePath: Codable, Sendable, Hashable {
    let points: [[Double]]
    let motion: StrokeMotion
    let loop: Bool

    var cgPoints: [CGPoint] {
        points.compactMap { pair in
            guard pair.count >= 2 else { return nil }
            return CGPoint(x: pair[0], y: pair[1])
        }
    }

    var isDrawable: Bool { cgPoints.count >= 2 }
}

// MARK: - Step

struct Step: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let regionID: String
    let techniqueID: String
    let title: String
    let body: String
    let sensationCue: String
    let handPosition: HandPosition
    let pressure: Int
    let durationSeconds: Int
    let rhythm: String?
    let breathCue: String?
    let heroImage: String
    let heroPlaceholderHex: String?
    let bodyMapZones: [BodyZone]
    let strokePath: StrokePath?
    let voiceScript: String
    let commonMistake: String?
    let caution: String?
    let modes: [SessionMode]
    let contraindications: [String]

    var pressureLevel: PressureLevel { PressureLevel.clamped(pressure) }

    /// The photo that shows *this* technique on *this* body part, e.g.
    /// `img.tech.neck.petrissage`. There are 88 such combinations across the
    /// 225 steps, so 88 photographs cover every step precisely. Until one
    /// exists on disk the view falls back to `heroImage`.
    var techniqueImage: String { "img.tech.\(regionID).\(techniqueID)" }

    var overline: String {
        let region = ContentStore.regionTitle(regionID).uppercased()
        let technique = ContentStore.techniqueTitle(techniqueID).uppercased()
        return "\(region) · \(technique)"
    }

    /// Read aloud by the narrator. Falls back to the on-screen text.
    var spokenText: String { voiceScript.isEmpty ? body : voiceScript }

    var accessibilityDescription: String {
        var parts = ["Step: \(title).", body]
        parts.append("Hands: \(handPosition.title).")
        parts.append("Pressure \(pressure) of 5, \(pressureLevel.title).")
        parts.append("You should feel \(sensationCue)")
        if let caution { parts.append("Caution: \(caution)") }
        return parts.joined(separator: " ")
    }
}

// MARK: - Routine

struct RoutineSection: Codable, Sendable, Hashable {
    let kind: SectionKind
    let stepIDs: [String]
}

struct Routine: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let regionIDs: [String]
    let mode: SessionMode
    let level: Level
    let durationSeconds: Int
    let minPressure: Int
    let maxPressure: Int
    let position: BodyPosition
    let needs: [String]
    let skipIf: [String]
    let coverImage: String
    let coverPlaceholderHex: String?
    let isPremium: Bool
    let reviewedBy: String?
    let aftercare: String?
    let sections: [RoutineSection]

    var allStepIDs: [String] { sections.flatMap(\.stepIDs) }
    var stepCount: Int { allStepIDs.count }
    var minutes: Int { max(1, Int((Double(durationSeconds) / 60.0).rounded())) }
    var durationLabel: String { "\(minutes) min" }
    var pressureLabel: String {
        minPressure == maxPressure ? "Pressure \(minPressure)" : "Pressure \(minPressure)–\(maxPressure)"
    }

    var primaryZone: BodyZone? {
        ContentStore.zone(forRegionID: regionIDs.first ?? "")
    }

    var searchHaystack: String {
        ([title, subtitle, mode.title, level.title] + regionIDs + needs)
            .joined(separator: " ")
            .lowercased()
    }
}

// MARK: - Program

struct ProgramDay: Codable, Sendable, Hashable {
    let day: Int
    let routineID: String
    let note: String?
}

struct Program: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let coverImage: String
    let coverPlaceholderHex: String?
    let isPremium: Bool
    let requiresAcknowledgement: Bool
    let days: [ProgramDay]

    var dayCount: Int { days.count }
}

// MARK: - Content pack

struct ContentPack: Codable, Sendable {
    let schemaVersion: Int
    let packID: String
    let routines: [Routine]
    let steps: [Step]
    var programs: [Program]?
}
