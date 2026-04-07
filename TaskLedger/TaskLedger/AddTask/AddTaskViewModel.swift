import SwiftUI

class AddTaskViewModel: ObservableObject {
    
    @Published var inputTaskName: String = ""
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
    
    @Published var saveAlert = false
    
    @DInjected(\.modelContext) private var modelContext
    
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
    
    
    var isFormValid: Bool {
        guard !inputTaskName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }

        if taskFrequency == .weekly {
            guard Weekdays.allCases.contains(where: { isDaySelected($0) }) else { return false }
        }

        if taskType == .cost || taskType == .income {
            guard amount > 0 else { return false }
        }

        return true
    }

    func saveTask() {
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
            name: inputTaskName,
            taskType: taskType,
            amount: customAmount ?? amount,
            taskFixedDate: fixedDate,
            repeatingPattern: repeatingPattern,
            days: frequencyDays,
            notes: notes,
            events: []
        )
        do {
            modelContext?.insert(event)
            try modelContext?.save()
        } catch {
            saveAlert.toggle()
        }
    }
}
