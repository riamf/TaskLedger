//
//  DayView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 03/10/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct DaysCalculator {
    private static let dayFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        return df
    }()
    
    static let compDateFormatter = {
       let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    static func todayNumber() -> Int {
         let dayName = dayFormatter.string(from: Date())
        return Calendar.current.weekdaySymbols.firstIndex(of: dayName) ?? -1
    }
    
    static func dayName(from number: Int) -> String {
        guard number < Calendar.current.shortWeekdaySymbols.count, number >= 0 else {
            return ""
        }
        return Calendar.current.shortWeekdaySymbols[number]
    }
        
}

struct DayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var tasks: [EventTask]
    @State var filteredTasks: [EventTask] = []
    @ObservedObject var viewModel = DayViewViewModel(currentDate: Date())
    @State var showAddTaskView = false
    @State var showAlertView = false
    @State var showCalendarView = false
    @State var showTasksListView = false
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    showTasksListView.toggle()
                } label: {
                    Image(systemName: "list.bullet")
                        .tint(.black)
                }.padding(.horizontal, 16)
                Spacer()
                Button {
                    showCalendarView.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .tint(.black)
                }
                .padding(.horizontal, 16)
            }
            Text("Tasks for Today")
                .font(.title)
            Text(viewModel.dayString)
            ZStack {
                if tasks.isEmpty {
                    Text("No tasks for today")
                        .foregroundStyle(.gray)
                } else {
                    List {
                        ForEach(tasks, id: \.id) { task in
                            if task.days.contains(DaysCalculator.todayNumber()) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.name)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                        HStack {
                                            ForEach(task.days, id: \.self) { day in
                                                Text(DaysCalculator.dayName(from: day))
                                                    .font(.caption)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                    Spacer()
                                    Button {
                                        if task.isExistingToday {
                                            do {
                                                task.removeTodayEvent()
                                                try modelContext.save()
                                            } catch {
                                                showAlertView.toggle()
                                                task.addTodayEvent()
                                            }
                                        } else {
                                            do {
                                                task.addTodayEvent()
                                                try modelContext.save()
                                            } catch {
                                                task.removeTodayEvent()
                                                showAlertView.toggle()
                                            }
                                        }
                                        
                                    } label: {
                                        if task.isExistingToday {
                                            Image(systemName: "checkmark.circle")
                                                .tint(.black)
                                        } else {
                                            Image(systemName: "circle")
                                                .tint(.black)
                                        }
                                    }
                                }
                            }
                        }.onDelete { indexSet in
                            indexSet.forEach { index in
                                let task = tasks[index]
                                modelContext.delete(task)
                                do {
                                    try modelContext.save()
                                } catch {
                                    showAlertView.toggle()
                                }
                            }
                        }
                    }
                    .refreshable {
                        
                    }
                }
                VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showAddTaskView.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .clipShape(Circle())
                            .tint(.white)
                            .background(Circle().fill(.blue).frame(width: 56, height: 56))
                            .padding(.trailing, 32)
                            .padding(.bottom, 32)
                        }
                    }
            }
            Spacer()
        }.sheet(isPresented: $showAddTaskView) {
            AddTaskView()
        }
        .sheet(isPresented: $showTasksListView) {
            TasksListView()
        }
        .sheet(isPresented: $showCalendarView) {
            CalendarView()
        }
        .alert(isPresented: $showAlertView) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to delete task. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
