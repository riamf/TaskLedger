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
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    if viewModel.tasks.isEmpty {
                        Spacer()
                        Text("Nothing To See Here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                    } else {
                        List {
                            ForEach(viewModel.tasks) { task in
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
                                    Button {
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)

                                    Button {
                                        // Snooze Logic
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
                            }
                        }
                        .refreshable {
                            viewModel.fetchTasks()
                        }
                    }
                }
            }
            .navigationBarTitle(viewModel.dayString, displayMode: .inline)
            .toolbar {
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
            
            HStack {
                Spacer()
                AddTaskButton {
                    viewModel.showAddTaskView.toggle()
                }
                .padding(.trailing, 44)
                .padding(.bottom, 32)
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
        .alert("Are you sure you want to delete?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let task = taskToDelete {
                    viewModel.deleteTask(task)
                }
            }
            Button("Cancel", role: .cancel) { }
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
