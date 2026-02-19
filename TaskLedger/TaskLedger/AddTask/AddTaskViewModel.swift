import SwiftUI

class AddTaskViewModel: ObservableObject {
    
    @Published var inputTaskName: String = ""
    @Published private var daysSelected: [String] = []
    @Published var taskType: TaskType = .counter
    @Published var amount: Double = 0.0
    @Published var timeHours: Int = 0
    @Published var timeMinutes: Int = 0
    @Published var timeSeconds: Int = 0
    @Published var notes: String = ""
    @Published var selectedPage: Int = 0
    @Published var taskFrequency: TaskFrequencies = .weekly
    
    @Published var selectedDayOfMonth: Int = 1
    @Published var selectedDate: Date = Date()
    
    @Published var saveAlert = false
    
    @DInjected(\.modelContext) private var modelContext
    
    var dayNames: [String] {
        Calendar.current.weekdaySymbols
    }
    
    func isDaySelected(_ day: Weekdays) -> Bool {
        daysSelected.contains { str in
            str == day.stringName
        }
    }
    
    func deselectDay(_ day: Weekdays) {
        daysSelected.removeAll { dayName in
            day.stringName == dayName
        }
    }
    
    func selectDay(_ day: Weekdays) {
        daysSelected.append(day.stringName)
    }
    
    
    func saveTask() {
        // calculate amount base on time spend
        var customAmount: Double?
        if taskType == .time {
            customAmount = Double(timeHours * 3600 + timeMinutes * 60 + timeSeconds)
        }
        
        var fixedDate: Date? = nil
        var frequencyDays: [Int] = []
        var repeatingPattern: RepeatingPattern? = nil
        
        switch taskFrequency {
        case .daily:
            // Daily means every day (Mon-Sun)
            // Assuming 'days' stores 1-7 for weekdays. If empty, maybe interpreted as daily?
            // Or we explicitly fill 1...7
            frequencyDays = Array(1...7)
            repeatingPattern = .daily(weekdays: Weekdays.allCases)
            
        case .weekly:
            frequencyDays = daysSelected.compactMap { DaysCalculator.dayNumberForName($0) }
            // Map string names back to Weekdays enum for repeatingPattern if needed
            let selectedWeekdays = daysSelected.compactMap { name in
                Weekdays.allCases.first(where: { $0.stringName == name })
            }
            repeatingPattern = .daily(weekdays: selectedWeekdays)
            
        case .monthly:
            // Monthly recurrence
            // Assuming we store day of month in 'repeatingPattern'
            frequencyDays = [] // Clear days as it's not weekly
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
