import Foundation

/// Programs are authored in code for v1 because they are only day -> routine mappings.
/// They move into the content pack in v1.1 alongside remote content updates.
extension Program {
    static let builtIn: [Program] = [
        Program(
            id: "program.sleep7",
            title: "7 Nights to Better Sleep",
            subtitle: "Wind down properly, seven nights in a row.",
            coverImage: "img.prep.candle",
            coverPlaceholderHex: "#A8836B",
            isPremium: true,
            requiresAcknowledgement: false,
            days: [
                ProgramDay(day: 1, routineID: "scalp.solo.sleep", note: "Start in bed. Lights already off."),
                ProgramDay(day: 2, routineID: "neck.solo.reset", note: "Where the day collects."),
                ProgramDay(day: 3, routineID: "foot.solo.relief", note: "Warm feet fall asleep faster."),
                ProgramDay(day: 4, routineID: "scalp.partner.winddown", note: "Ask someone tonight."),
                ProgramDay(day: 5, routineID: "hand.solo.reset", note: "Small, quiet, close your eyes."),
                ProgramDay(day: 6, routineID: "back.partner.basics", note: "The long one."),
                ProgramDay(day: 7, routineID: "scalp.solo.sleep", note: "Back where you started. Notice the difference.")
            ]
        ),
        Program(
            id: "program.neck10",
            title: "10-Day Neck & Shoulder Reset",
            subtitle: "For anyone who works at a screen.",
            coverImage: "img.reg.shoulder",
            coverPlaceholderHex: "#C9A188",
            isPremium: true,
            requiresAcknowledgement: false,
            days: [
                ProgramDay(day: 1, routineID: "neck.solo.reset", note: nil),
                ProgramDay(day: 2, routineID: "desk.solo.reset", note: "Do this one at work."),
                ProgramDay(day: 3, routineID: "neck.partner.reset", note: nil),
                ProgramDay(day: 4, routineID: "forearm.solo.rescue", note: "The cause is often further down."),
                ProgramDay(day: 5, routineID: "upperback.partner.knots", note: nil),
                ProgramDay(day: 6, routineID: "desk.solo.reset", note: nil),
                ProgramDay(day: 7, routineID: "scalp.partner.winddown", note: nil),
                ProgramDay(day: 8, routineID: "neck.solo.reset", note: nil),
                ProgramDay(day: 9, routineID: "chair.friends.office", note: "Try it on a colleague."),
                ProgramDay(day: 10, routineID: "upperback.partner.knots", note: "Compare it to day 5.")
            ]
        ),
        Program(
            id: "program.couples14",
            title: "Couples Connection",
            subtitle: "Fourteen days, from an eight-minute shoulder rub to a full ritual.",
            coverImage: "img.mood.couple",
            coverPlaceholderHex: "#B98F76",
            isPremium: true,
            requiresAcknowledgement: false,
            days: [
                ProgramDay(day: 1, routineID: "neck.partner.reset", note: "Clothed. Keep it short."),
                ProgramDay(day: 2, routineID: "hand.friends.seated", note: nil),
                ProgramDay(day: 3, routineID: "scalp.partner.winddown", note: nil),
                ProgramDay(day: 4, routineID: "together.handexchange", note: "Both of you at once."),
                ProgramDay(day: 5, routineID: "back.partner.basics", note: "Swap over afterwards."),
                ProgramDay(day: 6, routineID: "foot.partner.ritual", note: nil),
                ProgramDay(day: 7, routineID: "neck.partner.reset", note: "Other person gives tonight."),
                ProgramDay(day: 8, routineID: "upperback.partner.knots", note: nil),
                ProgramDay(day: 9, routineID: "together.handexchange", note: nil),
                ProgramDay(day: 10, routineID: "lowerback.partner.relief", note: nil),
                ProgramDay(day: 11, routineID: "legs.partner.recovery", note: nil),
                ProgramDay(day: 12, routineID: "foot.partner.ritual", note: nil),
                ProgramDay(day: 13, routineID: "scalp.partner.winddown", note: nil),
                ProgramDay(day: 14, routineID: "full.partner.express", note: "The whole thing. No phones.")
            ]
        )
    ]
}
