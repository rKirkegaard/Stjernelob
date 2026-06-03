import XCTest

/// UI-smoketest: appen starter og viser onboarding (spec afsnit 7.1). En enkel,
/// robust kontrol af, at kerneflowet kan nås — udvides efter behov.
final class OnboardingUITests: XCTestCase {
    func testAppLaunchesToOnboarding() {
        let app = XCUIApplication()
        app.launch()
        // Tjek et stabilt element øverst (knappen kan ligge under skærmkanten i
        // en Form og er derfor ikke instansieret før der scrolles).
        XCTAssertTrue(
            app.staticTexts["onboarding.welcome"].waitForExistence(timeout: 15),
            "Onboardingen skulle vises ved start"
        )
    }
}
