import Foundation

/// A demonstration video for a routine, played through YouTube's official
/// embedded player.
///
/// IMPORTANT — this content is deliberately **free**. YouTube's Developer
/// Policies (III.F.3, Playback Integrity) state that API Clients "must not
/// charge users to watch content in an embedded YouTube player" and "must not
/// otherwise gate access to a video by requiring a user to take an action other
/// than clicking the play button". Putting these behind Kneadly Plus would
/// breach that, so `VideoLibrary` is never checked against subscription state.
/// If you ever add a paywall check around a video, you are breaking YouTube's
/// terms and risking removal of the app.
///
/// Every ID below was verified against the oEmbed endpoint
/// (`https://www.youtube.com/oembed?url=…`) — a valid response means the video
/// exists *and* its owner allows embedding. Re-run that check before each
/// release: creators can delete a video or switch embedding off at any time.
struct RoutineVideo: Sendable, Hashable {
    let videoID: String
    let title: String
    let channel: String
}

enum VideoLibrary {

    static func video(for routineID: String) -> RoutineVideo? { map[routineID] }

    static let map: [String: RoutineVideo] = [
        "neck.solo.reset": .init(
            videoID: "DBBprCxfdLc",
            title: "Upper Traps Massage — Neck and Shoulder Tension Relief",
            channel: "CU Anschutz Health and Wellness Center"),
        "foot.solo.relief": .init(
            videoID: "FarLNmeL5ZQ",
            title: "Self-Massage — Foot and Calf Massage with a Ball",
            channel: "University of Michigan"),
        "hand.solo.reset": .init(
            videoID: "A4lHc2WTJZk",
            title: "Wrist Pain & Carpal Tunnel Self Massage and Stretches",
            channel: "HM Massage"),
        "scalp.solo.sleep": .init(
            videoID: "ZQYbJEdfA7c",
            title: "Soothing Head Self-Massage for Better Sleep",
            channel: "Rachel Richards Massage"),
        "face.solo.lymph": .init(
            videoID: "iEU_BKDqqAI",
            title: "How To Do a Lymphatic Drainage Massage for the Face",
            channel: "Face Yoga Expert"),
        "jaw.solo.tmj": .init(
            videoID: "DZ-IfNIPFXM",
            title: "Self-massage for TMJ and jaw pain",
            channel: "Massage Sloth"),
        "head.solo.headache": .init(
            videoID: "EoHUanQLnJM",
            title: "Sinus Self-Massage for Drainage and Pressure Relief",
            channel: "Dr. Alan Mandell, DC"),
        "forearm.solo.rescue": .init(
            videoID: "TJ0sWKist0w",
            title: "Self Massage for Wrist, Forearm and Hand Pain",
            channel: "James Chapman Yoga & Massage"),
        "lowerback.solo.ball": .init(
            videoID: "iB9-ULq2SQU",
            title: "Back Pain — Self Myofascial Release with a Ball",
            channel: "Dr. Brian Abelson"),
        "glute.solo.ball": .init(
            videoID: "l3flN43z-EQ",
            title: "Ball Self-Massage for Your Glutes and Piriformis",
            channel: "The Online Physiotherapist"),
        "calf.solo.release": .init(
            videoID: "IDvHxir7bXM",
            title: "Self Massage of the Calf",
            channel: "Heather Wibbels, LMT"),
        "desk.solo.reset": .init(
            videoID: "2cpJ6qD5gdA",
            title: "Self-massage techniques for desk workers",
            channel: "Progressive Motion"),
        "back.partner.basics": .init(
            videoID: "G7VV-AFiRwU",
            title: "Back Protocol — Effleurage and Petrissage Technique",
            channel: "Soma Institute"),
        "neck.partner.reset": .init(
            videoID: "sP5SmDftmQo",
            title: "Guide to Neck and Upper Back Massage Techniques",
            channel: "myPhysioSA"),
        "scalp.partner.winddown": .init(
            videoID: "lZdXTqrg0NU",
            title: "Indian Head Massage, Step By Step",
            channel: "Learn Ayurvedic Massage"),
        "upperback.partner.knots": .init(
            videoID: "RvLqmrKHG6g",
            title: "Massage Tutorial — Trigger Points",
            channel: "Rebel Massage"),
        "lowerback.partner.relief": .init(
            videoID: "X6ghJKqG5hk",
            title: "Clothed low back and hip routine with stretching",
            channel: "Massage Sloth"),
        "foot.partner.ritual": .init(
            videoID: "SFrc1EvQ80k",
            title: "How to Give a Foot Massage, Step-by-Step",
            channel: "WebMD"),
        "legs.partner.recovery": .init(
            videoID: "C7XysykwuFU",
            title: "Recovery Massage of the Hamstrings and Calves",
            channel: "Premax"),
        "full.partner.express": .init(
            videoID: "k3ElilBkOzU",
            title: "Swedish Massage — Full Body Routine",
            channel: "The Beauty Academy"),
        "chair.friends.office": .init(
            videoID: "X3zR4yIKWRE",
            title: "How to perform a chair massage routine",
            channel: "Corporate Hands"),
        "hand.friends.seated": .init(
            videoID: "_Fx54W0-yZs",
            title: "Massage Tutorial — The Hand",
            channel: "Rebel Massage"),
        "foot.friends.reflex": .init(
            videoID: "EkSjTAAzNsQ",
            title: "Reflexology basics, techniques and routine",
            channel: "Massage Sloth"),
        "together.handexchange": .init(
            videoID: "Oeml6UdpFvk",
            title: "Soothing Partner Hand Massage",
            channel: "Goodful")
    ]
}
