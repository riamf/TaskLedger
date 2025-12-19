import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.eventsDict.keys.sorted(by: { $0.name < $1.name }), id: \.self) { eventTask in
                VStack {
                    HStack {
                        Image(systemName: eventTask.taskType.imageName)
                        Text(eventTask.name)
                    }
                    let summary = viewModel.eventsDict[eventTask]
                    HStack {
                        Text(eventTask.taskType.taskName)
                        if eventTask.taskType == .counter, let counterSummary = summary?.counterSummary {
                            Text("\(counterSummary)")
                        } else if eventTask.taskType == .time, let timerSummary = summary?.amountSummary {
                            Text("\(timerSummary)")
                        } else if eventTask.taskType == .cost || eventTask.taskType == .income, let summary = summary?.amountSummary {
                            Text("\(summary)")
                        }
                            
                        
                    }
                        
                    
                }
            }
        }.refreshable {
            viewModel.fetchData()
        }.onAppear {
            viewModel.fetchData()
        }
    }
}
