import XCTest
@testable import StjernelobCore

/// Tests for kropssignalet efter en tur (skadesforebyggelse).
final class BodySignalTests: XCTestCase {
    func testOnlySpecificPainNeedsCare() {
        XCTAssertTrue(BodySignal.specificPain.needsCare)
        XCTAssertFalse(BodySignal.goodSore.needsCare)
        XCTAssertFalse(BodySignal.allGood.needsCare)
    }

    func testRoundTripsThroughRawValue() {
        for signal in BodySignal.allCases {
            XCTAssertEqual(BodySignal(rawValue: signal.rawValue), signal)
        }
    }
}
