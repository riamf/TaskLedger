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
  
  @StateObject var viewModel: DayViewViewModel
  
  init() {
    _viewModel = StateObject(wrappedValue: DayViewViewModel(currentDate: Date()))
  }
  
  var body: some View {
    VStack {
      HStack {
        TaskListViewButton(showTasksListView: viewModel.showTasksList)
          .padding(.horizontal, 16)
        Spacer()
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
          Text(task.name)
        }
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
    .sheet(isPresented: $viewModel.showTasksList) {
      TasksListView()
    }
    .sheet(isPresented: $viewModel.showAddTaskView) {
      AddTaskView()
    }
  }
  
}

#Preview {
  DayView()
}
