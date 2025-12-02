//
//  DayView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 03/10/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct DayView: View {
    
    @StateObject var viewModel: DayViewViewModel = DayViewViewModel(currentDate: Date())
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TaskListViewButton(showTasksListView: $viewModel.showTasksList)
                        .padding(.horizontal, 16)
                    Spacer()
                    CalendarButtonView(showCalendarView: $viewModel.showCalendar)
                        .padding(.horizontal, 16)
                }
                Spacer()
                HStack {
                    ButtonArrowLeft {
                        viewModel.previousDate()
                    }
                    Text(viewModel.dayString)
                        .tint(.black)
                        .font(.headline)
                    ButtonArrowRight {
                        viewModel.nextDate()
                    }
                }
                List {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            VStack(alignment: .leading, spacing: .spacingSmall) {
                                CheckButton(
                                    title: task.name,
                                    isChecked: task.isCheck(viewModel.currentDate),
                                    value: task) { tsk in
                                        viewModel.markTask(tsk)
                                    }
                                HStack {
                                    ForEach(0..<task.days.count) { idx in
                                        Text(DaysCalculator.dayName(from: task.days[idx]))
                                    }
                                    Spacer()
                                }
                            }
                            .tint(.black)
                            Spacer()
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchTasks()
                }
                Spacer()
                HStack {
                    Spacer()
                    AddTaskButton {
                        viewModel.showAddTaskView.toggle()
                    }
                    .padding(.trailing, 32)
                    .padding(.bottom, 16)
                }
                Spacer()
            }
            .navigationBarTitle("Title", displayMode: .inline)
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
        }
        .sheet(isPresented: $viewModel.showCalendar) {
            CalendarView(selectedDate: $viewModel.currentDate)
        }
    }
    
}

#Preview {
    DayView()
}
