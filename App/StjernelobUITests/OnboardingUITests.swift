import XCTest

/// UI-smoketest: appen starter og viser onboarding (spec afsnit 7.1). En enkel,
/// robust kontrol af, at kerneflowet kan nås — udvides efter behov.
final class OnboardingUITests: XCTestCase {
    func testAppLaunchesToOnboarding() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.buttons["onboarding.start"].waitForExistence(timeout: 15),
            "Onboardingens 'Kom i gang'-knap skulle være synlig ved start"
        )
    }
}
