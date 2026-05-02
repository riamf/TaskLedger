import Foundation

final class OnboardingProgressStore: ObservableObject {
    private enum Keys {
        static let didCompleteAppIntroduction = "onboarding.didCompleteAppIntroduction"
        static let createdTaskCount = "onboarding.createdTaskCount"
        static let didCompleteDayViewSwipeHint = "onboarding.didCompleteDayViewSwipeHint"
    }

    let addTaskGoal: Int

    @Published private(set) var didCompleteAppIntroduction: Bool
    @Published private(set) var createdTaskCount: Int
    @Published private(set) var didCompleteDayViewSwipeHint: Bool

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard, addTaskGoal: Int = 3) {
        self.userDefaults = userDefaults
        self.addTaskGoal = addTaskGoal
        
        didCompleteAppIntroduction = userDefaults.bool(forKey: Keys.didCompleteAppIntroduction)
        createdTaskCount = min(userDefaults.integer(forKey: Keys.createdTaskCount), addTaskGoal)
        didCompleteDayViewSwipeHint = userDefaults.bool(forKey: Keys.didCompleteDayViewSwipeHint)
    }

    var shouldShowAppIntroduction: Bool {
        !didCompleteAppIntroduction
    }

    var shouldPulseAddTaskButton: Bool {
        createdTaskCount < addTaskGoal
    }

    var shouldShowDayViewSwipeHint: Bool {
        !didCompleteDayViewSwipeHint
    }

    func recordTaskCreated() {
        let updatedCount = min(createdTaskCount + 1, addTaskGoal)
        guard updatedCount != createdTaskCount else { return }

        createdTaskCount = updatedCount
        userDefaults.set(updatedCount, forKey: Keys.createdTaskCount)
    }

    func completeAppIntroduction() {
        guard !didCompleteAppIntroduction else { return }

        didCompleteAppIntroduction = true
        userDefaults.set(true, forKey: Keys.didCompleteAppIntroduction)
    }

    func completeDayViewSwipeHint() {
        guard !didCompleteDayViewSwipeHint else { return }

        didCompleteDayViewSwipeHint = true
        userDefaults.set(true, forKey: Keys.didCompleteDayViewSwipeHint)
    }
}
