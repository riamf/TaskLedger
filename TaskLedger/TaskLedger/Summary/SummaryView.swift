import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.eventsDict.isEmpty {
                    Text("No events for this month.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.eventsDict.keys.sorted(by: { $0.name < $1.name }), id: \.self) { eventTask in
                            VStack {
                                HStack {
                                    Image(systemName: eventTask.taskType.imageName)
                                    Text(eventTask.name)
                                    let summary = viewModel.eventsDict[eventTask]
                                    HStack {
                                        Spacer()
                                        if eventTask.taskType == .counter, let counterSummary = summary?.counterSummary {
                                            Text("\(counterSummary)")
                                        } else if eventTask.taskType == .time, let timerSummary = summary?.amountSummary {
                                            Text("\(timerSummary)")
                                        } else if eventTask.taskType == .cost || eventTask.taskType == .income, let summary = summary?.amountSummary {
                                            Text(MoneyFormatter.formatter.string(from: NSNumber(value: summary)) ?? "\(summary)")
                                        }
                                    }
                                }.padding(.leading, 0)
                            }
                        }
                    }
                    .refreshable {
                        viewModel.fetchData()
                    }
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .navigationBarTitle(viewModel.currentMonthDateString, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ButtonArrowLeft {
                        viewModel.previousMonth()
                    }
                    .buttonStyle(.plain)
                    .background(Color.clear)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ButtonArrowRight {
                        viewModel.nextMonth()
                    }
                }
            }
        }
    }
}

#Preview {
    SummaryView()
}
