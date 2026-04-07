import SwiftUI

// Superseded by DayViewTaskRow in DayView.swift. Kept to avoid Xcode project file changes.
@available(*, deprecated, renamed: "DayViewTaskRow")
struct DayViewTaskCell: View {
    @State var task: EventTask
    @State var currentDate: Date
    var markTask: (EventTask) -> Void
    
    var body: some View {
        DayViewTaskRow(task: task, currentDate: currentDate, onMark: markTask, onDelete: { _ in }, onSnooze: { _ in })
    }
}

