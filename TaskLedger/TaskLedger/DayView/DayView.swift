import Foundation
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
            snoozeSheetView
                .presentationDetents([.medium])
        }
        .alert("day_view_delete_confirmation_title", isPresented: $showDeleteConfirmation) {
            deleteConfirmationButtons
        } message: {
            Text("day_view_delete_confirmation_message")
        }
    }
    
    // MARK: - Subviews
    
    private var snoozeSheetView: some View {
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
                    showSnoozeSheet = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("snooze_button_title") {
                    if let task = taskToSnooze {
                        viewModel.snoozeTask(task, days: snoozeDays)
                    }
                    showSnoozeSheet = false
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            .padding()
        }
        .padding()
    }

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
                taskRow(for: task)
            }
        }
        .refreshable {
            viewModel.fetchTasks()
        }
    }
    
    private func taskRow(for task: EventTask) -> some View {
        HStack {
            TaskTypeCircleIcon(task: task)
            VStack(alignment: .leading, spacing: .spacingSmall) {
                CheckButton(
                    title: task.name,
                    isChecked: task.isCheck(viewModel.currentDate),
                    value: task, action: { task in
                        haptics.trigger(.medium)
                        viewModel.markTask(task)
                    })
                HStack {
                    if let pattern = task.repeatingPattern {
                        switch pattern {
                        case .daily(let weekdays):
                            if weekdays.count == 7 {
                                Text("every_day_label")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Text(weekdays.sorted { $0.rawValue < $1.rawValue }.map { String($0.stringName.prefix(3)) }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        case .monthly(let day):
                            Text(String(format: String(localized: "every_month_pattern"), day, daySuffix(for: day)))
                                .font(.caption)
                                .foregroundColor(.gray)
                        case .yearly(let day, let month):
                            Text(String(format: String(localized: "every_year_pattern"), day, daySuffix(for: day), Month(rawValue: month)?.name ?? ""))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else if let fixedDate = task.taskFixedDate {
                        Text(fixedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if !task.days.isEmpty {
                        // Fallback for legacy tasks
                        ForEach(0..<task.days.count, id: \.self) { idx in
                            Text(DaysCalculator.dayName(from: task.daysOrdered[idx].rawValue))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            }.padding(.horizontal, .spacingSmall)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(for: task)
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
    
    private enum Month: Int {
        case january = 1, february, march, april, may, june, july, august, september, october, november, december
        
        var name: String {
            switch self {
            case .january: return String(localized: "month_january")
            case .february: return String(localized: "month_february")
            case .march: return String(localized: "month_march")
            case .april: return String(localized: "month_april")
            case .may: return String(localized: "month_may")
            case .june: return String(localized: "month_june")
            case .july: return String(localized: "month_july")
            case .august: return String(localized: "month_august")
            case .september: return String(localized: "month_september")
            case .october: return String(localized: "month_october")
            case .november: return String(localized: "month_november")
            case .december: return String(localized: "month_december")
            }
        }
    }

    @ViewBuilder
    private func swipeActions(for task: EventTask) -> some View {
        Button {
            taskToDelete = task
            showDeleteConfirmation = true
        } label: {
            Label("delete_action_title", systemImage: "trash")
        }
        .tint(.red)
        
        Button {
            taskToSnooze = task
            snoozeDays = 1
            showSnoozeSheet = true
        } label: {
            Label("snooze_button_title", systemImage: "clock")
        }
        .tint(.orange)
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
