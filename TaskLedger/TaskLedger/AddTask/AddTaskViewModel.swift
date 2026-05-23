import SwiftUI

class AddTaskViewModel: ObservableObject {
    
    @Published var inputTaskName: String = "" {
        didSet {
            updateDuplicateNameState()
        }
    }
    @Published private var daysSelected: Set<Weekdays> = []
    @Published var taskType: TaskType = .counter
    @Published var amount: Double = 0.0
    @Published var timeHours: Int = 0
    @Published var timeMinutes: Int = 0
    @Published var timeSeconds: Int = 0
    @Published var notes: String = ""
    @Published var selectedPage: Int = 0
    @Published var taskFrequency: TaskFrequencies = .weekly
    
    @Published var selectedDayOfMonth: Int = Calendar.current.component(.day, from: Date())
    @Published var selectedDate: Date = Date()
    
    @Published var notificationEnabled: Bool = false
    @Published var notificationTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @Published var notificationPermissionDenied: Bool = false
    
    @Published var saveAlert = false
    @Published var showHistorySheet = false
    @Published var taskTemplates: [EventTask] = []
    @Published private(set) var doesTaskNameAlreadyExist = false
    @Published private(set) var showsTemplateGroupingNotice = false
    private var templateGroupId: String?
    private var existingTaskNames = Set<String>()
    
    @DInjected(\.modelContext) private var modelContext
    @DInjected(\.notifications) private var notifications: NotificationService
    @DInjected(\.fetcher) private var fetcher: Fetcher
    @DInjected(\.analytics) private var analytics: AnalyticsService
    @DInjected(\.haptics) private var haptics: HapticFeedbackService
    
    var dayNames: [String] {
        Calendar.current.weekdaySymbols
    }
    
    func isDaySelected(_ day: Weekdays) -> Bool {
        daysSelected.contains(day)
    }
    
    func deselectDay(_ day: Weekdays) {
        daysSelected.remove(day)
    }
    
    func selectDay(_ day: Weekdays) {
        daysSelected.insert(day)
    }
    
    func toggleNotification() {
        if !notificationEnabled {
            notifications.requestAuthorization { [weak self] granted in
                if granted {
                    self?.notificationEnabled = true
                    guard let self else { return }
                    self.analytics.logNotificationEnabled(
                        timeOfDay: self.notificationTime,
                        frequency: self.taskFrequency
                    )
                } else {
                    self?.notificationPermissionDenied = true
                    self?.analytics.logNotificationDenied()
                }
            }
        } else {
            notificationEnabled = false
        }
    }
    
    var isFormValid: Bool {
        guard !trimmedTaskName(inputTaskName).isEmpty else { return false }
        guard !doesTaskNameAlreadyExist else { return false }

        if taskFrequency == .weekly {
            guard Weekdays.allCases.contains(where: { isDaySelected($0) }) else { return false }
        }

        if taskType == .cost || taskType == .income {
            guard amount > 0 else { return false }
        }

        return true
    }

    // MARK: - Task History / Templates

    var hasTemplates: Bool {
        !taskTemplates.isEmpty
    }

    var showsDuplicateNameWarning: Bool {
        doesTaskNameAlreadyExist && !trimmedTaskName(inputTaskName).isEmpty
    }

    func loadTemplates() {
        taskTemplates = fetcher.fetchUniqueTaskTemplates()
        existingTaskNames = fetcher.fetchExistingTaskNames()
        updateDuplicateNameState()
    }

    func applyTemplate(_ task: EventTask) {
        inputTaskName = task.name
        taskType = task.taskType
        templateGroupId = task.groupId
        showsTemplateGroupingNotice = true

        switch task.taskType {
        case .cost, .income:
            amount = task.amount
        case .time:
            let total = Int(task.amount)
            timeHours = total / 3600
            timeMinutes = (total % 3600) / 60
            timeSeconds = total % 60
        case .counter:
            break
        }

        haptics.trigger(.light)
    }

    @discardableResult
    func saveTask() -> Bool {
        existingTaskNames = fetcher.fetchExistingTaskNames()
        updateDuplicateNameState()

        guard currentValidationError == nil else {
            return false
        }

        // calculate amount base on time spend
        var customAmount: Double?
        if taskType == .time {
            customAmount = Double(timeHours * 3600 + timeMinutes * 60 + timeSeconds)
        }
        
        var fixedDate: Date? = nil
        var frequencyDays: [Weekdays] = []
        var repeatingPattern: RepeatingPattern? = nil
        
        switch taskFrequency {
        case .daily:
            frequencyDays = Weekdays.allCases
            repeatingPattern = .daily(weekdays: Weekdays.allCases)
            
        case .weekly:
            let selectedWeekdays = Array(daysSelected)
            frequencyDays = selectedWeekdays
            repeatingPattern = .daily(weekdays: selectedWeekdays)
            
        case .monthly:
            frequencyDays = []
            repeatingPattern = .monthly(day: selectedDayOfMonth)
            
        case .oneTime:
            fixedDate = selectedDate
            frequencyDays = []
            repeatingPattern = nil
        }
        
        let event = EventTask(
            timestamp: Date(),
            name: trimmedTaskName(inputTaskName),
            taskType: taskType,
            amount: customAmount ?? amount,
            taskFixedDate: fixedDate,
            repeatingPattern: repeatingPattern,
            days: frequencyDays,
            notes: notes,
            events: [],
            notificationEnabled: notificationEnabled,
            notificationTime: notificationEnabled ? notificationTime : nil,
            groupId: templateGroupId ?? UUID().uuidString
        )
        do {
            modelContext?.insert(event)
            try modelContext?.save()

            if notificationEnabled {
                notifications.scheduleTaskNotification(
                    taskId: event.id,
                    taskName: event.name,
                    time: notificationTime,
                    repeatingPattern: repeatingPattern,
                    fixedDate: fixedDate,
                    weekdays: frequencyDays
                )
            }
            analytics.logTaskCreated(taskType: taskType, frequency: taskFrequency)
            analytics.updateTotalTasksCount(fetcher.fetchActiveTaskCount())
            return true
        } catch {
            saveAlert.toggle()
            return false
        }
    }

    func trackValidationFailure() {
        guard let error = currentValidationError else { return }
        analytics.logValidationError(error)
    }

    func trackCreationCancelled() {
        analytics.logTaskCreationCancelled(stepReached: currentStepReached)
    }

    private var currentValidationError: TaskCreationValidationError? {
        if trimmedTaskName(inputTaskName).isEmpty {
            return .missingName
        }

        if doesTaskNameAlreadyExist {
            return .duplicateName
        }

        if (taskType == .cost || taskType == .income) && amount <= 0 {
            return .zeroAmount
        }

        if taskFrequency == .weekly && daysSelected.isEmpty {
            return .noDaysSelected
        }

        return nil
    }

    private var currentStepReached: TaskCreationStep {
        let currentDay = Calendar.current.component(.day, from: Date())
        let touchedFrequency = taskFrequency != .weekly
            || !daysSelected.isEmpty
            || selectedDayOfMonth != currentDay
            || !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
            || notificationEnabled

        if touchedFrequency {
            return .frequency
        }

        let touchedType = taskType != .counter
            || amount > 0
            || timeHours > 0
            || timeMinutes > 0
            || timeSeconds > 0

        if touchedType {
            return .type
        }

        return .name
    }

    private func updateDuplicateNameState() {
        let normalizedName = normalizedTaskName(inputTaskName)
        doesTaskNameAlreadyExist = !normalizedName.isEmpty && existingTaskNames.contains(normalizedName)
    }
}
