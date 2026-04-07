import SwiftUI
import SwiftData

struct DayView: View {
    
    @ObservedObject var viewModel: DayViewViewModel
    @State private var taskToDelete: EventTask?
    @State private var showDeleteConfirmation = false
    @State private var taskToSnooze: EventTask?
    @State private var showSnoozeSheet = false
    @State private var snoozeDays = 1
    private let showAddButton: Bool

    @DInjected(\.haptics) var haptics
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: DayViewViewModel = .init(currentDate: Date()), showAddButton: Bool = true) {
        self.viewModel = viewModel
        self.showAddButton = showAddButton
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationBarTitle(viewModel.dayString, displayMode: .inline)
                .toolbar {
                    toolbarItems
                }
            
            if showAddButton {
                floatingActionButton
            }
        }
        .onAppear {
            viewModel.fetchTasks()
        }
        .sheet(isPresented: $viewModel.showTasksList) {
            TasksListView()
        }
        .sheet(isPresented: $viewModel.showAddTaskView) {
            AddTaskView {
                viewModel.fetchTasks()
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $viewModel.showCalendar) {
            CalendarView(selectedDate: $viewModel.currentDate)
        }
        .sheet(isPresented: $showSnoozeSheet) {
            SnoozeSheetView(snoozeDays: $snoozeDays) {
                if let task = taskToSnooze {
                    viewModel.snoozeTask(task, days: snoozeDays)
                }
                showSnoozeSheet = false
            } onCancel: {
                showSnoozeSheet = false
            }
            .presentationDetents([.medium])
        }
        .alert("day_view_delete_confirmation_title", isPresented: $showDeleteConfirmation) {
            deleteConfirmationButtons
        } message: {
            Text("day_view_delete_confirmation_message")
        }
        .alert("error_title", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("ok_button", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Subviews

    private var mainContent: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if viewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    tasksListView
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("nothing_to_see_here")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private var tasksListView: some View {
        List {
            ForEach(viewModel.tasks) { task in
                DayViewTaskRow(task: task, currentDate: viewModel.currentDate) { taskToMark in
                    haptics.trigger(.medium)
                    viewModel.markTask(taskToMark)
                } onDelete: { taskToArchive in
                    taskToDelete = taskToArchive
                    showDeleteConfirmation = true
                } onSnooze: { taskToDelay in
                    taskToSnooze = taskToDelay
                    snoozeDays = 1
                    showSnoozeSheet = true
                }
            }
        }
        .refreshable {
            viewModel.fetchTasks()
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if showAddButton {
            ToolbarItem(placement: .navigationBarLeading) {
                ButtonArrowLeft {
                    viewModel.previousDate()
                }
                .buttonStyle(.plain)
                .background(Color.clear)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                ButtonArrowRight {
                    viewModel.nextDate()
                }
                .buttonStyle(.plain)
                .background(Color.clear)
            }
        } else {
            ToolbarItem(placement: .confirmationAction) {
                Button("done_button_title") {
                    dismiss()
                }
            }
        }
    }
    
    private var floatingActionButton: some View {
        HStack {
            Spacer()
            AddTaskButton {
                viewModel.showAddTaskView.toggle()
            }
            .padding(.trailing, 44)
            .padding(.bottom, 32)
        }
    }
    
    @ViewBuilder
    private var deleteConfirmationButtons: some View {
        Button("delete_task_schedule_button", role: .destructive) {
            if let task = taskToDelete {
                viewModel.archiveTask(task)
            }
        }
        Button("delete_task_history_button", role: .destructive) {
            if let task = taskToDelete {
                viewModel.deleteTask(task)
            }
        }
        Button("cancel_button_title", role: .cancel) { }
    }
}

// MARK: - SnoozeSheetView

private struct SnoozeSheetView: View {
    @Binding var snoozeDays: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("snooze_task_title")
                .font(.headline)
            
            Text("snooze_days_prompt")
                .font(.subheadline)
            
            Picker("Days", selection: $snoozeDays) {
                ForEach(1...30, id: \.self) { day in
                    Text("\(day) \(day == 1 ? String(localized: "snooze_day_singular") : String(localized: "snooze_day_plural"))").tag(day)
                }
            }
            .pickerStyle(.wheel)
            
            HStack {
                Button("cancel_button_title", role: .cancel) {
                    onCancel()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("snooze_button_title") {
                    onConfirm()
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - DayViewTaskRow

struct DayViewTaskRow: View {
    let task: EventTask
    let currentDate: Date
    let onMark: (EventTask) -> Void
    let onDelete: (EventTask) -> Void
    let onSnooze: (EventTask) -> Void

    var body: some View {
        HStack {
            TaskTypeCircleIcon(task: task)
            VStack(alignment: .leading, spacing: .spacingSmall) {
                CheckButton(
                    title: task.name,
                    isChecked: task.isCheck(currentDate),
                    value: task, action: onMark)
                TaskPatternLabel(task: task)
            }.padding(.horizontal, .spacingSmall)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onDelete(task)
            } label: {
                Label("delete_action_title", systemImage: "trash")
            }
            .tint(.red)

            Button {
                onSnooze(task)
            } label: {
                Label("snooze_button_title", systemImage: "clock")
            }
            .tint(.orange)
        }
    }
}

// MARK: - TaskPatternLabel

struct TaskPatternLabel: View {
    let task: EventTask

    var body: some View {
        HStack {
            patternText
            Spacer()
        }
    }

    @ViewBuilder
    private var patternText: some View {
        if let pattern = task.repeatingPattern {
            switch pattern {
            case .daily(let weekdays):
                if weekdays.count == 7 {
                    Text("every_day_label")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text(weekdays.sorted { $0.rawValue < $1.rawValue }
                        .map { String($0.stringName.prefix(3)) }
                        .joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            case .monthly(let day):
                Text(String(format: String(localized: "every_month_pattern"), day, daySuffix(for: day)))
                    .font(.caption)
                    .foregroundColor(.gray)
            case .yearly(let day, let month):
                Text(String(format: String(localized: "every_year_pattern"), day, daySuffix(for: day), monthName(month)))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        } else if let fixedDate = task.taskFixedDate {
            Text(fixedDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)
        } else if !task.days.isEmpty {
            ForEach(task.daysOrdered) { weekday in
                Text(DaysCalculator.dayName(from: weekday.rawValue))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31: return String(localized: "day_suffix_st")
        case 2, 22: return String(localized: "day_suffix_nd")
        case 3, 23: return String(localized: "day_suffix_rd")
        default: return String(localized: "day_suffix_th")
        }
    }

    private func monthName(_ month: Int) -> String {
        switch month {
        case 1: return String(localized: "month_january")
        case 2: return String(localized: "month_february")
        case 3: return String(localized: "month_march")
        case 4: return String(localized: "month_april")
        case 5: return String(localized: "month_may")
        case 6: return String(localized: "month_june")
        case 7: return String(localized: "month_july")
        case 8: return String(localized: "month_august")
        case 9: return String(localized: "month_september")
        case 10: return String(localized: "month_october")
        case 11: return String(localized: "month_november")
        case 12: return String(localized: "month_december")
        default: return ""
        }
    }
}

#if DEBUG

#Preview {
    let vm = DayViewViewModel(
        currentDate: Date(),
        tasks: [EventTask.example(), EventTask.example()]
    )
    return DayView(viewModel: vm)
        .modelContainer(previewContainer)
}

#endif

