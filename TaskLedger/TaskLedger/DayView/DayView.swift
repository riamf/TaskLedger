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
        .alert("Are you sure you want to delete?", isPresented: $showDeleteConfirmation) {
            deleteConfirmationButtons
        } message: {
            Text("You can delete only future schedule or delete task completely with history.")
        }
    }
    
    // MARK: - Subviews
    
    private var snoozeSheetView: some View {
        VStack(spacing: 20) {
            Text("Snooze Task")
                .font(.headline)
            
            Text("Snooze for how many days?")
                .font(.subheadline)
            
            Picker("Days", selection: $snoozeDays) {
                ForEach(1...30, id: \.self) { day in
                    Text("\(day) \(day == 1 ? "day" : "days")").tag(day)
                }
            }
            .pickerStyle(.wheel)
            
            HStack {
                Button("Cancel", role: .cancel) {
                    showSnoozeSheet = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Snooze") {
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
            Text("Nothing To See Here")
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
                                Text("Every day")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Text(weekdays.sorted { $0.rawValue < $1.rawValue }.map { String($0.stringName.prefix(3)) }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        case .monthly(let day):
                            Text("Every \(day)\(daySuffix(for: day)) of month")
                                .font(.caption)
                                .foregroundColor(.gray)
                        case .yearly(let day, let month):
                            Text("Every \(day)\(daySuffix(for: day)) of \(Month(rawValue: month)?.name ?? "")")
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
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    private enum Month: Int {
        case january = 1, february, march, april, may, june, july, august, september, october, november, december
        
        var name: String {
            switch self {
            case .january: return "January"
            case .february: return "February"
            case .march: return "March"
            case .april: return "April"
            case .may: return "May"
            case .june: return "June"
            case .july: return "July"
            case .august: return "August"
            case .september: return "September"
            case .october: return "October"
            case .november: return "November"
            case .december: return "December"
            }
        }
    }

    @ViewBuilder
    private func swipeActions(for task: EventTask) -> some View {
        Button {
            taskToDelete = task
            showDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
        
        Button {
            taskToSnooze = task
            snoozeDays = 1
            showSnoozeSheet = true
        } label: {
            Label("Snooze", systemImage: "clock")
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
                Button("Done") {
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
        Button("Delete task schedule", role: .destructive) {
            if let task = taskToDelete {
                viewModel.archiveTask(task)
            }
        }
        Button("Delete task & history", role: .destructive) {
            if let task = taskToDelete {
                viewModel.deleteTask(task)
            }
        }
        Button("Cancel", role: .cancel) { }
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
