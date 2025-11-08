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
    
    @Published var saveAlert = false
    
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
    
}
