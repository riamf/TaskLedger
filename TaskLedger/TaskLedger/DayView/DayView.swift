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
        guard number < Calendar.current.shortWeekdaySymbols.count, number > 0 else {
            return ""
        }
        return Calendar.current.shortWeekdaySymbols[number]
    }
        
}

struct DayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var tasks: [Task]
    @State var filteredTasks: [Task] = []
    @ObservedObject var viewModel = DayViewViewModel(currentDate: Date())
    @State var showAddTaskView = false
    @State var showAlertView = false
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Spacer()
                Button {
                    
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
                                    VStack {
                                        Text(task.name)
                                            .padding(.horizontal, 4)
                                        HStack {
                                            ForEach(task.days, id: \.self) { day in
                                                Text(DaysCalculator.dayName(from: day))
                                                    .font(.caption)
                                                    .padding(4)
                                                
                                            }
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        
                                    } label: {
//                                        Image(systemName: "checkmark.circle")
                                        Image(systemName: "circle")
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
                            .padding(.trailing, 64)
                            .padding(.bottom, 64)
                        }
                    }
            }
            Spacer()
        }.sheet(isPresented: $showAddTaskView) {
            AddTaskView()
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
