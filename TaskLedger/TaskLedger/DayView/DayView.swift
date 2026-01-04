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
            ZStackLayout(alignment: .bottomTrailing) {
                VStack {
                    if viewModel.tasks.isEmpty {
                        Spacer()
                        Text("Nothing To See Here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    } else {
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
                                            ForEach(0..<task.days.count, id: \.self) { idx in
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
    }
    
}

#Preview {
    DayView()
}
