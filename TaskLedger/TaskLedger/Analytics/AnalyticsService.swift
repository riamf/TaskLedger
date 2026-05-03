import FirebaseAnalytics
import FirebaseCore
import Foundation

/// Abstraction over app analytics so views and view models emit tracked events through DI.
protocol AnalyticsService {
    /// Configures Firebase Analytics and logs the current app locale at launch.
    func configure()
    /// Tracks successful task creation with the selected task type and frequency.
    func logTaskCreated(taskType: TaskType, frequency: TaskFrequencies)
    /// Tracks dismissal of the add-task flow before saving, including the furthest completed step.
    func logTaskCreationCancelled(stepReached: TaskCreationStep)
    /// Tracks a blocked save attempt, capturing which validation rule prevented creation.
    func logValidationError(_ errorType: TaskCreationValidationError)
    /// Tracks marking a task done or undone from the Day View.
    func logTaskToggle(task: EventTask, isNowDone: Bool)
    /// Tracks completion of cost, income, and time tasks with their quantitative payload.
    func logFinancialCompletion(for task: EventTask)
    /// Tracks navigation between days, including whether it came from arrows or the calendar picker.
    func logDayNavigation(method: DayNavigationMethod, direction: DayNavigationDirection)
    /// Tracks pull-to-refresh usage for the supported list-based screens.
    func logListRefreshed(view: AnalyticsViewName)
    /// Tracks deferring a task by a chosen number of days.
    func logTaskSnoozed(days: Int)
    /// Tracks moving a task schedule into the archive while preserving its history.
    func logTaskArchived(taskType: TaskType)
    /// Tracks permanent task deletion together with its task type.
    func logTaskFullyDeleted(taskType: TaskType)
    /// Tracks opening the summary tab for a specific month.
    func logViewSummaryTab(month: Date)
    /// Tracks opening a task's heatmap details from the summary screen.
    func logHeatmapDrillDown(taskType: TaskType)
    /// Tracks tapping a heatmap day and whether that date has recorded activity.
    func logHeatmapDayTap(hasActivity: Bool)
    /// Tracks enabling reminders with the chosen time of day and task frequency.
    func logNotificationEnabled(timeOfDay: Date, frequency: TaskFrequencies)
    /// Tracks the system notification permission prompt being denied.
    func logNotificationDenied()
    /// Updates the analytics user property used to segment users by active task count.
    func updateTotalTasksCount(_ count: Int)
}

final class FirebaseAnalyticsService: AnalyticsService {
    func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        logAppLocale()
    }

    func logTaskCreated(taskType: TaskType, frequency: TaskFrequencies) {
        logEvent(
            "task_created",
            parameters: [
                "task_type": taskType.analyticsLabel,
                "frequency": frequency.analyticsLabel
            ]
        )
    }

    func logTaskCreationCancelled(stepReached: TaskCreationStep) {
        logEvent(
            "task_creation_cancelled",
            parameters: ["step_reached": stepReached.analyticsLabel]
        )
    }

    func logValidationError(_ errorType: TaskCreationValidationError) {
        logEvent(
            "validation_error",
            parameters: ["error_type": errorType.analyticsLabel]
        )
    }

    func logTaskToggle(task: EventTask, isNowDone: Bool) {
        logEvent(
            "task_toggle",
            parameters: [
                "task_type": task.taskType.analyticsLabel,
                "new_status": isNowDone ? "Done" : "Undone"
            ]
        )
    }

    func logFinancialCompletion(for task: EventTask) {
        switch task.taskType {
        case .cost:
            logEvent(
                "expense_logged",
                parameters: [
                    "amount": NSNumber(value: task.amount),
                    "task_name": task.name
                ]
            )
        case .income:
            logEvent(
                "income_logged",
                parameters: [
                    "amount": NSNumber(value: task.amount),
                    "task_name": task.name
                ]
            )
        case .time:
            let durationMinutes = Int((task.amount / 60).rounded())
            logEvent(
                "time_tracked",
                parameters: [
                    "duration_minutes": NSNumber(value: durationMinutes),
                    "task_name": task.name
                ]
            )
        case .counter:
            break
        }
    }

    func logDayNavigation(method: DayNavigationMethod, direction: DayNavigationDirection) {
        logEvent(
            "day_navigation",
            parameters: [
                "method": method.analyticsLabel,
                "direction": direction.analyticsLabel
            ]
        )
    }

    func logListRefreshed(view: AnalyticsViewName) {
        logEvent(
            "list_refreshed",
            parameters: ["view": view.analyticsLabel]
        )
    }

    func logTaskSnoozed(days: Int) {
        logEvent(
            "task_snoozed",
            parameters: ["days_snoozed": NSNumber(value: days)]
        )
    }

    func logTaskArchived(taskType: TaskType) {
        logEvent(
            "task_archived",
            parameters: ["task_type": taskType.analyticsLabel]
        )
    }

    func logTaskFullyDeleted(taskType: TaskType) {
        logEvent(
            "task_fully_deleted",
            parameters: ["task_type": taskType.analyticsLabel]
        )
    }

    func logViewSummaryTab(month: Date) {
        logEvent(
            "view_summary_tab",
            parameters: ["month_year": month.analyticsMonthYear]
        )
    }

    func logHeatmapDrillDown(taskType: TaskType) {
        logEvent(
            "heatmap_drill_down",
            parameters: ["task_type": taskType.analyticsLabel]
        )
    }

    func logHeatmapDayTap(hasActivity: Bool) {
        logEvent(
            "heatmap_day_tap",
            parameters: ["has_activity": hasActivity ? "True" : "False"]
        )
    }

    func logNotificationEnabled(timeOfDay: Date, frequency: TaskFrequencies) {
        logEvent(
            "notification_enabled",
            parameters: [
                "time_of_day": timeOfDay.analyticsTimeOfDay,
                "frequency": frequency.analyticsLabel
            ]
        )
    }

    func logNotificationDenied() {
        logEvent("notification_denied")
    }

    func updateTotalTasksCount(_ count: Int) {
        Analytics.setUserProperty(String(count), forName: "total_tasks_count")
    }

    private func logAppLocale() {
        let localeIdentifier = Locale.current.language.languageCode?.identifier
            ?? Locale.current.identifier
        logEvent(
            "app_locale_set",
            parameters: ["language": localeIdentifier.uppercased()]
        )
    }

    private func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

enum TaskCreationStep {
    case name
    case type
    case frequency

    var analyticsLabel: String {
        switch self {
        case .name: return "Name"
        case .type: return "Type"
        case .frequency: return "Frequency"
        }
    }
}

enum TaskCreationValidationError {
    case missingName
    case zeroAmount
    case noDaysSelected

    var analyticsLabel: String {
        switch self {
        case .missingName: return "Missing Name"
        case .zeroAmount: return "Zero Amount"
        case .noDaysSelected: return "No Days Selected"
        }
    }
}

enum DayNavigationMethod {
    case arrow
    case calendarPicker

    var analyticsLabel: String {
        switch self {
        case .arrow: return "Arrow"
        case .calendarPicker: return "Calendar Picker"
        }
    }
}

enum DayNavigationDirection {
    case previous
    case next

    var analyticsLabel: String {
        switch self {
        case .previous: return "Prev"
        case .next: return "Next"
        }
    }
}

enum AnalyticsViewName {
    case dayView
    case summary

    var analyticsLabel: String {
        switch self {
        case .dayView: return "DayView"
        case .summary: return "Summary"
        }
    }
}

private extension TaskType {
    var analyticsLabel: String {
        switch self {
        case .counter: return "Counter"
        case .cost: return "Cost"
        case .income: return "Income"
        case .time: return "Time"
        }
    }
}

private extension TaskFrequencies {
    var analyticsLabel: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .oneTime: return "One-Time"
        }
    }
}

private extension Date {
    var analyticsMonthYear: String {
        Self.analyticsMonthYearFormatter.string(from: self)
    }

    var analyticsTimeOfDay: String {
        Self.analyticsTimeFormatter.string(from: self)
    }

    private static let analyticsMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    private static let analyticsTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
