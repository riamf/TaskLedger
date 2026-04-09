import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.eventsDict.isEmpty {
                    Text("no_events_for_month")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.sortedTasks, id: \.self) { eventTask in
                            NavigationLink {
                                SummaryDetailsView(
                                    eventSummary: viewModel.eventsDict[eventTask]!,
                                    visibleMonth: viewModel.currentMonthDate
                                )
                            } label: {
                                VStack {
                                    HStack {
                                        TaskTypeCircleIcon(task: eventTask)
                                        Text(eventTask.name)
                                        let summary = viewModel.eventsDict[eventTask]
                                        HStack {
                                            Spacer()
                                            Text(eventTask.summaryShortText(summary))
                                        }
                                    }.padding(.leading, 0)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
