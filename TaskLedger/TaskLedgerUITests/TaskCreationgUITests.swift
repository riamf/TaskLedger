import XCTest

final class TaskCreationgUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += [
            "UI-TESTING",
            "UI-TESTING-IN-MEMORY-STORE",
            "UI-TESTING-SKIP-ONBOARDING"
        ]
    }

    @MainActor
    func testCreateTaskOfEachType() throws {
        app.launch()

        createCounterTask(name: "UI Counter Task")
        createCostTask(name: "UI Cost Task", amount: "4")
        createIncomeTask(name: "UI Income Task", amount: "500")
        createTimeTask(name: "UI Time Task", hours: "1", minutes: "15", seconds: "0")

        XCTAssertTrue(app.buttons["UI Counter Task"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["UI Cost Task"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["UI Income Task"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["UI Time Task"].waitForExistence(timeout: 2))
    }

    private func createCounterTask(name: String) {
        openAddTask()
        app.buttons["add-task-type-counter"].tap()
        app.buttons["add-task-frequency-daily"].tap()
        app.textFields["add-task-name-counter"].tap()
        app.textFields["add-task-name-counter"].typeText(name)
        app.buttons["add-task-save-top"].tap()
    }

    private func createCostTask(name: String, amount: String) {
        openAddTask()
        app.buttons["add-task-type-cost"].tap()
        app.buttons["add-task-frequency-daily"].tap()
        app.textFields["add-task-name-cost"].tap()
        app.textFields["add-task-name-cost"].typeText(name)
        replaceText(in: app.textFields["add-task-amount-cost"], with: amount)
        app.buttons["add-task-save-top"].tap()
    }

    private func createIncomeTask(name: String, amount: String) {
        openAddTask()
        app.buttons["add-task-type-income"].tap()
        app.buttons["add-task-frequency-daily"].tap()
        app.textFields["add-task-name-income"].tap()
        app.textFields["add-task-name-income"].typeText(name)
        replaceText(in: app.textFields["add-task-amount-income"], with: amount)
        app.buttons["add-task-save-top"].tap()
    }

    private func createTimeTask(name: String, hours: String, minutes: String, seconds: String) {
        openAddTask()
        app.buttons["add-task-type-time"].tap()
        app.buttons["add-task-frequency-daily"].tap()
        app.textFields["add-task-name-time"].tap()
        app.textFields["add-task-name-time"].typeText(name)
        replaceText(in: app.textFields["add-task-time-hours"], with: hours)
        replaceText(in: app.textFields["add-task-time-minutes"], with: minutes)
        replaceText(in: app.textFields["add-task-time-seconds"], with: seconds)
        app.buttons["add-task-save-top"].tap()
    }

    private func openAddTask() {
        let addTaskButton = app.buttons["day-view-add-task-button"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 5))
        addTaskButton.tap()
        XCTAssertTrue(app.scrollViews["add-task-screen"].waitForExistence(timeout: 5))
    }

    private func replaceText(in element: XCUIElement, with text: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 2))
        element.tap()

        if let currentValue = element.value as? String,
           !currentValue.isEmpty,
           currentValue != text {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteSequence)
        }

        element.typeText(text)
    }
}
