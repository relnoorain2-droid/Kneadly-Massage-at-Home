import XCTest
import SwiftUI
@testable import Kneadly

@MainActor
final class StepPlayerModelTests: XCTestCase {

    private func makeModel(steps: [Step], cap: Int? = nil) -> StepPlayerModel {
        let store = ContentStore()
        store.load()
        let routine = store.routines.first!
        return StepPlayerModel(routine: routine,
                               steps: steps,
                               pressureCap: cap,
                               partnerName: nil,
                               narration: NarrationPlayer()) { _, _ in }
    }

    func testStartsOnTheFirstStep() {
        let store = ContentStore(); store.load()
        let routine = store.routines.first!
        let steps = store.steps(for: routine)
        let model = makeModel(steps: steps)
        XCTAssertEqual(model.index, 0)
        XCTAssertEqual(model.remaining, steps[0].durationSeconds)
        XCTAssertFalse(model.isPlaying)
    }

    func testPressureCapLowersButNeverRaises() {
        let store = ContentStore(); store.load()
        let routine = store.routines.first { $0.maxPressure >= 4 } ?? store.routines.first!
        let steps = store.steps(for: routine)
        let capped = makeModel(steps: steps, cap: 2)
        XCTAssertLessThanOrEqual(capped.displayedPressure, 2)

        let uncapped = makeModel(steps: steps, cap: nil)
        XCTAssertEqual(uncapped.displayedPressure, uncapped.step.pressure)
    }

    func testEmptyStepListFallsBackToPlaceholder() {
        let model = makeModel(steps: [])
        XCTAssertEqual(model.stepCount, 1)
        XCTAssertEqual(model.step.id, "placeholder")
    }

    func testTimeLabelFormatsAsMinutesAndSeconds() {
        let store = ContentStore(); store.load()
        let steps = store.steps(for: store.routines.first!)
        let model = makeModel(steps: steps)
        XCTAssertTrue(model.timeLabel.contains(":"))
    }

    func testRepeatResetsTheStepClock() {
        let store = ContentStore(); store.load()
        let steps = store.steps(for: store.routines.first!)
        let model = makeModel(steps: steps)
        model.repeatStep()
        XCTAssertEqual(model.remaining, model.step.durationSeconds)
    }

    func testGoBackDoesNothingOnTheFirstStep() {
        let store = ContentStore(); store.load()
        let steps = store.steps(for: store.routines.first!)
        let model = makeModel(steps: steps)
        model.goBack()
        XCTAssertEqual(model.index, 0)
    }
}

final class BodyGeometryTests: XCTestCase {

    func testEveryZoneProducesANonEmptyPath() {
        for zone in BodyZone.allCases {
            let spec = BodyGeometry.path(for: zone)
            XCTAssertFalse(spec.path.isEmpty, "\(zone.rawValue) produced an empty path")
        }
    }

    func testScalingKeepsPathsInsideTheFrame() {
        let size = CGSize(width: 200, height: 400)
        for zone in BodyZone.allCases {
            let scaled = BodyGeometry.scaled(BodyGeometry.path(for: zone).path, to: size)
            let box = scaled.boundingRect
            XCTAssertGreaterThanOrEqual(box.minX, -2, "\(zone.rawValue) spills left")
            XCTAssertLessThanOrEqual(box.maxX, size.width + 2, "\(zone.rawValue) spills right")
            XCTAssertLessThanOrEqual(box.maxY, size.height + 2, "\(zone.rawValue) spills below")
        }
    }

    func testEveryZoneHasATitleForBothViews() {
        for zone in BodyZone.allCases {
            XCTAssertFalse(zone.title(front: true).isEmpty)
            XCTAssertFalse(zone.title(front: false).isEmpty)
            XCTAssertFalse(zone.note(front: true).isEmpty)
        }
    }
}
