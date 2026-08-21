import XCTest
@testable import Kneadly

final class ContentPackTests: XCTestCase {

    private var store: ContentStore!

    override func setUp() {
        super.setUp()
        store = ContentStore()
        store.load()
    }

    func testContentPackLoads() {
        XCTAssertNil(store.loadError, store.loadError ?? "")
        XCTAssertFalse(store.routines.isEmpty, "No routines decoded from content.json")
        XCTAssertFalse(store.stepsByID.isEmpty, "No steps decoded from content.json")
    }

    func testEveryRoutineResolvesAllOfItsSteps() {
        for routine in store.routines {
            let steps = store.steps(for: routine)
            XCTAssertEqual(steps.count, routine.allStepIDs.count,
                           "\(routine.id) references steps that do not exist")
        }
    }

    func testEveryRoutineHasAWarmUpAndACoolDown() {
        for routine in store.routines {
            let kinds = Set(routine.sections.map(\.kind))
            XCTAssertTrue(kinds.contains(.warmUp), "\(routine.id) has no warm-up")
            XCTAssertTrue(kinds.contains(.coolDown), "\(routine.id) has no cool-down")
        }
    }

    func testEveryStepHasAVisual() {
        // A step without a visual does not ship. This is a product rule, not a nicety.
        for (id, step) in store.stepsByID {
            XCTAssertFalse(step.heroImage.isEmpty, "\(id) has no hero image")
            XCTAssertFalse(step.bodyMapZones.isEmpty, "\(id) has no body map zone")
        }
    }

    func testContentCopyStaysWithinLimits() {
        for (id, step) in store.stepsByID {
            XCTAssertLessThanOrEqual(step.title.split(separator: " ").count, 6, "\(id) title too long")
            XCTAssertLessThanOrEqual(step.body.count, 200, "\(id) body too long")
            XCTAssertLessThanOrEqual(step.sensationCue.count, 90, "\(id) sensation cue too long")
        }
    }

    func testNoBannedClaimsAnywhere() {
        let banned = ["cure", "heal", "diagnos", "detox", "toxin", "realign", "clinically proven"]
        for (id, step) in store.stepsByID {
            let haystack = [step.title, step.body, step.sensationCue, step.voiceScript,
                            step.commonMistake ?? "", step.caution ?? ""]
                .joined(separator: " ").lowercased()
            for word in banned {
                XCTAssertFalse(haystack.contains(word), "\(id) contains banned claim '\(word)'")
            }
        }
    }

    func testFreeRoutinesExistForEveryEntryPoint() {
        let free = store.freeRoutines()
        XCTAssertGreaterThanOrEqual(free.count, 4, "Not enough free routines to make the free tier useful")
        XCTAssertTrue(free.contains { $0.mode == .solo }, "No free solo routine")
        XCTAssertTrue(free.contains { $0.mode == .partner }, "No free partner routine")
    }

    func testFriendsRoutinesNeverRequireOil() {
        // Friends & Family mode is fully clothed, always. "No oil" in the needs
        // list is a reassurance, not a requirement — only a bare mention fails.
        for routine in store.routines where routine.mode == .friends {
            for need in routine.needs {
                let low = need.lowercased()
                guard low.contains("oil") else { continue }
                let disclaims = low.contains("no oil") || low.contains("without oil")
                XCTAssertTrue(disclaims, "\(routine.id) is a Friends routine but asks for oil: \(need)")
            }
        }
    }

    func testStepDurationsRoughlyMatchRoutineDuration() {
        for routine in store.routines {
            let total = store.steps(for: routine).reduce(0) { $0 + $1.durationSeconds }
            XCTAssertLessThanOrEqual(abs(total - routine.durationSeconds), 90,
                                     "\(routine.id) step durations sum to \(total) but claim \(routine.durationSeconds)")
        }
    }

    func testSearchFindsRoutinesBySymptom() {
        XCTAssertFalse(store.search("headache").isEmpty, "Symptom search failed for 'headache'")
        XCTAssertFalse(store.search("feet").isEmpty, "Symptom search failed for 'feet'")
    }
}
