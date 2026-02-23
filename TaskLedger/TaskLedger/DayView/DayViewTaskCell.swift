import SwiftUI

struct DayViewTaskCell: View {
    @State var task: EventTask
    @State var currentDate: Date
    var markTask: (EventTask) -> Void
    
    var body: some View {
        HStack {
            TaskTypeCircleIcon(task: task)
            VStack(alignment: .leading, spacing: .spacingSmall) {
                CheckButton(
                    title: task.name,
                    isChecked: task.isCheck(currentDate),
                    value: task, action: markTask)
                HStack {
                    ForEach(0..<task.days.count, id: \.self) { idx in
                        Text(DaysCalculator.dayName(from: task.daysOrdered[idx].rawValue))
                    }
                    Spacer()
                }
            }
            .tint(.black)
        }
    }
}

