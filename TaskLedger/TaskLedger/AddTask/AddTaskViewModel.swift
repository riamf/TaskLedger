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
    
    @Published var saveAlert = false
    
    var dayNames: [String] {
        Calendar.current.weekdaySymbols
    }
    
    
}
