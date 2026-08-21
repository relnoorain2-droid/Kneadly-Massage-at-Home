import XCTest
@testable import Kneadly

final class ContraindicationEngineTests: XCTestCase {

    private var store: ContentStore!
    private var engine: ContraindicationEngine!

    override func setUp() {
        super.setUp()
        store = ContentStore()
        store.load()
        engine = ContraindicationEngine(store: store)
    }

    private func routine(_ id: String) throws -> Routine {
        try XCTUnwrap(store.routine(id), "Missing routine \(id)")
    }

    func testNoAnswersAllowsAdvancedUser() throws {
        let r = try routine("back.partner.basics")
        let verdict = engine.verdict(for: r, answers: [], level: .advanced)
        XCTAssertFalse(verdict.isBlocked)
    }

    func testBeginnerGetsPressureCapped() throws {
        guard let deep = store.routines.first(where: { $0.maxPressure > 3 }) else {
            throw XCTSkip("No routine with pressure above 3")
        }
        let verdict = engine.verdict(for: deep, answers: [], level: .beginner)
        XCTAssertEqual(verdict.pressureCap, 3, "Beginners must be capped at 3 of 5")
    }

    func testAbsoluteContraindicationBlocksEverything() throws {
        let r = try routine("back.partner.basics")
        let verdict = engine.verdict(for: r, answers: ["feverOrInfection"], level: .advanced)
        XCTAssertTrue(verdict.isBlocked, "A fever must block all routines")
    }

    func testDeclaredSkipIfBlocksThatRoutine() throws {
        guard let r = store.routines.first(where: { $0.skipIf.contains("dvtOrBloodThinners") }) else {
            throw XCTSkip("No routine declares dvtOrBloodThinners")
        }
        let verdict = engine.verdict(for: r, answers: ["dvtOrBloodThinners"], level: .advanced)
        XCTAssertTrue(verdict.isBlocked)
    }

    func testBlockedRoutinesOfferAnAlternativeWhereOneExists() throws {
        // The product rule: we never leave the user at a dead end.
        let answers = ["dvtOrBloodThinners"]
        var blockedCount = 0
        var withAlternative = 0
        for r in store.routines {
            if case let .blocked(_, alternative, _) = engine.verdict(for: r, answers: answers, level: .advanced) {
                blockedCount += 1
                if alternative != nil { withAlternative += 1 }
            }
        }
        XCTAssertGreaterThan(blockedCount, 0, "DVT should block at least the leg routines")
        XCTAssertGreaterThan(withAlternative, 0, "Blocked routines must offer alternatives")
    }

    func testDVTBlocksTheLegZones() {
        let zones = engine.blockedZones(answers: ["dvtOrBloodThinners"])
        XCTAssertTrue(zones.contains(.calves))
        XCTAssertTrue(zones.contains(.thighs))
    }

    func testPressureCapNeverRaisesPressure() throws {
        let r = try routine("back.partner.basics")
        let verdict = engine.verdict(for: r, answers: ["osteoporosis"], level: .advanced)
        if let cap = verdict.pressureCap {
            XCTAssertLessThanOrEqual(cap, r.maxPressure)
        }
    }

    func testEveryContraindicationHasAnExplanation() {
        for c in Contraindication.all {
            XCTAssertFalse(c.explanation.isEmpty, "\(c.id) has no explanation")
            XCTAssertFalse(c.plainQuestion.isEmpty, "\(c.id) has no plain-language question")
        }
    }
}

final class UserStateTests: XCTestCase {

    func testPressureBiasIsClamped() {
        let defaults = UserDefaults(suiteName: "kneadly.tests")!
        defaults.removePersistentDomain(forName: "kneadly.tests")
        let state = UserState(defaults: defaults)
        for _ in 0..<10 { state.recordPressureFeedback(.tooFirm) }
        XCTAssertEqual(state.pressureBias, -2)
        for _ in 0..<10 { state.recordPressureFeedback(.tooLight) }
        XCTAssertEqual(state.pressureBias, 2)
    }

    func testLevelRisesWithCompletedSessions() {
        let defaults = UserDefaults(suiteName: "kneadly.tests.level")!
        defaults.removePersistentDomain(forName: "kneadly.tests.level")
        let state = UserState(defaults: defaults)
        state.level = .beginner
        XCTAssertEqual(state.effectiveLevel, .beginner)
        state.completedSessionCount = 6
        XCTAssertEqual(state.effectiveLevel, .intermediate)
        state.completedSessionCount = 15
        XCTAssertEqual(state.effectiveLevel, .advanced)
    }
}
