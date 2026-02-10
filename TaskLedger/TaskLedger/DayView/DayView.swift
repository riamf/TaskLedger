import Foundation
import SwiftUI
import SwiftData

struct DayView: View {
    
    @ObservedObject var viewModel: DayViewViewModel
    @State private var taskToDelete: EventTask?
    @State private var showDeleteConfirmation = false
    
    init(viewModel: DayViewViewModel = .init(currentDate: Date())) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationBarTitle(viewModel.dayString, displayMode: .inline)
                .toolbar {
                    toolbarItems
                }
            
            floatingActionButton
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
        .alert("Are you sure you want to delete?", isPresented: $showDeleteConfirmation) {
            deleteConfirmationButtons
        } message: {
            Text("You can delete only future schedule or delete task completely with history.")
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
                    value: task, action: viewModel.markTask)
                HStack {
                    ForEach(0..<task.days.count, id: \.self) { idx in
                        Text(DaysCalculator.dayName(from: task.days.sorted()[idx]))
                    }
                    Spacer()
                }
            }
            .tint(.black)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            swipeActions(for: task)
        }
    }
    
    @ViewBuilder
    private func swipeActions(for task: EventTask) -> some View {
        Button(role: .destructive) {
            taskToDelete = task
            showDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
        
        Button {
            viewModel.snoozeTask(task)
        } label: {
            Label("Snooze", systemImage: "clock")
        }
        .tint(.orange)
        
        Button {
            // Edit Logic
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
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
