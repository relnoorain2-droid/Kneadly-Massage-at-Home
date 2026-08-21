import Foundation

// MARK: - Session mode

enum SessionMode: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case solo, partner, friends, together

    var id: String { rawValue }

    var title: String {
        switch self {
        case .solo: return "Solo"
        case .partner: return "Partner"
        case .friends: return "Friends"
        case .together: return "Together"
        }
    }

    var longTitle: String {
        switch self {
        case .solo: return "Myself"
        case .partner: return "My partner"
        case .friends: return "A friend or family member"
        case .together: return "Both of us, together"
        }
    }

    var blurb: String {
        switch self {
        case .solo: return "Reachable on your own body, one-handed, in bed or at a desk."
        case .partner: return "One gives, one receives. Giver and receiver views, with draping guidance."
        case .friends: return "Fully clothed, chair-based. Nothing awkward, ever."
        case .together: return "Both of you at once. Nobody is the therapist."
        }
    }

    var symbol: String {
        switch self {
        case .solo: return "hand.raised"
        case .partner: return "hands.sparkles"
        case .friends: return "person.2"
        case .together: return "infinity"
        }
    }

    /// Friends & Family mode is always clothed. Drives copy and draping guidance.
    var isAlwaysClothed: Bool { self == .friends }

    /// Partner-style modes need the two-tap consent ritual before a session.
    var needsConsentRitual: Bool { self != .solo }
}

// MARK: - Level

enum Level: String, Codable, CaseIterable, Sendable {
    case beginner, intermediate, advanced

    var title: String { rawValue.capitalized }

    var blurb: String {
        switch self {
        case .beginner: return "Slower steps, more guidance, gentler pressure"
        case .intermediate: return "Standard pacing"
        case .advanced: return "Compact steps, full pressure range"
        }
    }

    /// Beginners are capped until they have a few sessions behind them.
    var pressureCap: Int {
        switch self {
        case .beginner: return 3
        case .intermediate: return 4
        case .advanced: return 5
        }
    }
}

// MARK: - Sections

enum SectionKind: String, Codable, CaseIterable, Sendable {
    case warmUp, main, coolDown

    var title: String {
        switch self {
        case .warmUp: return "Warm-up"
        case .main: return "Main work"
        case .coolDown: return "Cool-down"
        }
    }
}

// MARK: - Hand position

enum HandPosition: String, Codable, CaseIterable, Sendable {
    case flatPalm, palmHeel, thumbPad, doubleThumb, fingertips
    case knuckles, forearm, cGrip, pincerGrip, cuppedHand, tool, none

    var title: String {
        switch self {
        case .flatPalm: return "Flat palms"
        case .palmHeel: return "Palm heel"
        case .thumbPad: return "Thumb pad"
        case .doubleThumb: return "Double thumb"
        case .fingertips: return "Fingertips"
        case .knuckles: return "Knuckles"
        case .forearm: return "Forearm"
        case .cGrip: return "C-grip"
        case .pincerGrip: return "Pincer grip"
        case .cuppedHand: return "Cupped hand"
        case .tool: return "Ball or tool"
        case .none: return "No hands"
        }
    }

    var howTo: String {
        switch self {
        case .flatPalm: return "Whole palm flat, fingers relaxed. Broad warming strokes."
        case .palmHeel: return "The firm pad below your thumb. Broad, deep pressure on big muscles."
        case .thumbPad: return "The flat pad of the thumb, never the tip. Precision work."
        case .doubleThumb: return "Both thumbs side by side, walking down either side of the spine."
        case .fingertips: return "Four fingertips, soft. Scalp, face and the base of the skull."
        case .knuckles: return "Loose fist, middle knuckles. Deep work on feet and glutes."
        case .forearm: return "The flat of your forearm. Deep pressure that saves your hands."
        case .cGrip: return "Thumb and fingers wrapped in a C around a limb."
        case .pincerGrip: return "Thumb opposite flat fingers, squeezing and lifting the muscle."
        case .cuppedHand: return "Hand cupped, fingers together. Light rhythmic tapping."
        case .tool: return "A ball, roller or stone doing the pressing for you."
        case .none: return "No hands needed for this step."
        }
    }

    var symbol: String {
        switch self {
        case .flatPalm, .palmHeel: return "hand.raised"
        case .thumbPad, .doubleThumb: return "hand.point.up.left"
        case .fingertips: return "hand.point.up"
        case .knuckles: return "hand.raised.fingers.spread"
        case .forearm: return "figure.arms.open"
        case .cGrip, .pincerGrip: return "hands.clap"
        case .cuppedHand: return "hand.wave"
        case .tool: return "circle.circle"
        case .none: return "minus"
        }
    }
}

// MARK: - Stroke motion

enum StrokeMotion: String, Codable, CaseIterable, Sendable {
    case glide, knead, circle, hold, walk, rake, stretch, press

    var title: String {
        switch self {
        case .glide: return "Glide"
        case .knead: return "Knead"
        case .circle: return "Circle"
        case .hold: return "Hold still"
        case .walk: return "Walk"
        case .rake: return "Rake"
        case .stretch: return "Stretch"
        case .press: return "Press"
        }
    }

    /// Direction description used when Reduce Motion is on and the path cannot animate.
    var staticDescription: String {
        switch self {
        case .glide: return "Move along the line, in the arrow's direction"
        case .knead: return "Squeeze and roll along the marked band"
        case .circle: return "Small circles on the marked spot"
        case .hold: return "Stay still on the marked spot"
        case .walk: return "Move a thumb-width at a time along the line"
        case .rake: return "Draw down the line, alternating hands"
        case .stretch: return "Ease slowly in the arrow's direction"
        case .press: return "Press straight in on the marked spot"
        }
    }

    var isAnimated: Bool { self != .hold && self != .press }
}

// MARK: - Body position

enum BodyPosition: String, Codable, CaseIterable, Sendable {
    case proneBed, supine, sideLying, seatedChairReversed, seatedUpright, floorMat, standing

    var title: String {
        switch self {
        case .proneBed: return "Lying face down"
        case .supine: return "Lying face up"
        case .sideLying: return "Lying on one side"
        case .seatedChairReversed: return "Seated backwards on a chair"
        case .seatedUpright: return "Seated upright"
        case .floorMat: return "On a mat on the floor"
        case .standing: return "Standing"
        }
    }

    var receiverNote: String {
        switch self {
        case .proneBed:
            return "Lie face down with a pillow under your chest and another under your ankles. Turn your head to whichever side is comfortable."
        case .supine:
            return "Lie on your back with a pillow under your knees and a thin one under your head."
        case .sideLying:
            return "Lie on your side with a pillow between your knees and one hugged to your chest."
        case .seatedChairReversed:
            return "Sit facing the chair back with a cushion against your chest. Rest your forehead on your folded arms and let your shoulders hang."
        case .seatedUpright:
            return "Sit upright with both feet flat on the floor and your back supported."
        case .floorMat:
            return "Lie on a firm mat on the floor. No pillows for this one."
        case .standing:
            return "Stand with your feet hip-width apart and your knees soft."
        }
    }

    var giverNote: String {
        switch self {
        case .proneBed:
            return "Kneel or stand beside them. Keep your own back straight and lean your weight in rather than pushing with your arms."
        case .supine:
            return "Sit at their head or beside them, whichever the step asks for."
        case .sideLying:
            return "Kneel behind them. Work the upper side only, then ask them to turn over."
        case .seatedChairReversed:
            return "Stand behind, feet apart, knees soft. Pressure comes from leaning your body weight in — not from your arms."
        case .seatedUpright:
            return "Sit or stand beside them so that you are never reaching."
        case .floorMat:
            return "Kneel beside them with your weight over your hands."
        case .standing:
            return "Stand where you can reach comfortably without stretching."
        }
    }

    var symbol: String {
        switch self {
        case .proneBed, .supine, .sideLying: return "bed.double"
        case .seatedChairReversed, .seatedUpright: return "chair"
        case .floorMat: return "rectangle.portrait"
        case .standing: return "figure.stand"
        }
    }
}

// MARK: - Body map zones

enum BodyZone: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case head, neck, shoulders, chest, abdomen, hips
    case arms, forearms, hands, thighs, knees, calves, feet

    var id: String { rawValue }

    func title(front: Bool) -> String {
        switch self {
        case .head: return front ? "Scalp, Face & Jaw" : "Scalp & Skull Base"
        case .neck: return front ? "Neck & Throat Sides" : "Neck & Suboccipitals"
        case .shoulders: return "Shoulders & Upper Trapezius"
        case .chest: return front ? "Chest & Sternum" : "Upper Back & Shoulder Blades"
        case .abdomen: return front ? "Abdomen" : "Mid & Lower Back"
        case .hips: return front ? "Hips & Front of Pelvis" : "Glutes, Hips & Piriformis"
        case .arms: return "Upper Arms"
        case .forearms: return "Forearms & Elbows"
        case .hands: return "Hands, Wrists & Fingers"
        case .thighs: return front ? "Thighs — Quads & IT Band" : "Hamstrings"
        case .knees: return front ? "Knees" : "Backs of Knees"
        case .calves: return "Calves & Shins"
        case .feet: return front ? "Ankles, Arches & Toes" : "Heels & Soles"
        }
    }

    func note(front: Bool) -> String {
        switch self {
        case .head: return front
            ? "Where a tension headache actually starts — temples, jaw and the base of the skull."
            : "The suboccipitals: four small muscles behind most desk headaches."
        case .neck: return "Never press the front or centre of the throat. Work the sides and the back."
        case .shoulders: return "The muscle that carries your stress and your bag. The most-worked area in the app."
        case .chest: return front
            ? "Tight chest muscles pull the shoulders forward and shorten your breathing."
            : "Rhomboids and mid-trap. Work beside the spine, never on it."
        case .abdomen: return front
            ? "Always clockwise — that is the direction the colon runs."
            : "Erector spinae and QL. The kidney area stays light."
        case .hips: return front
            ? "Hip flexors shorten from sitting and quietly pull on the lower back."
            : "Where most lower back pain is actually coming from."
        case .arms: return "Deltoid, biceps and triceps. Easy to reach, usually forgotten."
        case .forearms: return "Gold for anyone who types or holds a phone. Most people have never touched them."
        case .hands: return "Reflexology, thumb circles and traction. Works fully clothed, anywhere."
        case .thighs: return "Big muscles. Use a forearm and save your thumbs."
        case .knees: return "Work around the kneecap. Never press into the back of the knee."
        case .calves: return "Check first: swollen, warm, red or one-sided pain means stop and see a doctor."
        case .feet: return "The most under-rated ten minutes in the whole app."
        }
    }
}

// MARK: - Feedback

enum FeelAfter: String, Codable, CaseIterable, Sendable {
    case better, same, worse
    var title: String { rawValue.capitalized }
}

enum PressureFeedback: String, Codable, CaseIterable, Sendable {
    case tooLight, justRight, tooFirm

    var title: String {
        switch self {
        case .tooLight: return "Too light"
        case .justRight: return "Just right"
        case .tooFirm: return "Too firm"
        }
    }

    /// How much to shift this user's default pressure next time.
    var adjustment: Int {
        switch self {
        case .tooLight: return 1
        case .justRight: return 0
        case .tooFirm: return -1
        }
    }
}

// MARK: - Pressure

enum PressureLevel: Int, Codable, CaseIterable, Sendable, Identifiable {
    case feather = 1, light, medium, firm, deep

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .feather: return "Feather"
        case .light: return "Light"
        case .medium: return "Medium"
        case .firm: return "Firm"
        case .deep: return "Deep"
        }
    }

    /// The plain-language anchor. "Level 4" means nothing to a beginner;
    /// "like pressing a ripe avocado" means exactly the right thing.
    var anchor: String {
        switch self {
        case .feather: return "Barely touching the skin"
        case .light: return "Like stroking a cat"
        case .medium: return "Like rubbing tired eyes"
        case .firm: return "Like pressing a ripe avocado"
        case .deep: return "Like leaning on a stuck jar lid"
        }
    }

    static func clamped(_ value: Int) -> PressureLevel {
        PressureLevel(rawValue: min(5, max(1, value))) ?? .medium
    }
}

// MARK: - Viewpoint

enum Viewpoint: String, CaseIterable, Sendable {
    case giver, receiver
    var title: String { self == .giver ? "Giver view" : "Receiver view" }
}
