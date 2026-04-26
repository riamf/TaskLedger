import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.eventsDict.isEmpty {
                    if viewModel.showsSampleSummary {
                        SummarySampleListView()
                    } else {
                        Text("no_events_for_month")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.sortedTasks, id: \.self) { eventTask in
                            NavigationLink {
                                SummaryDetailsView(
                                    eventSummary: viewModel.eventsDict[eventTask]!,
                                    visibleMonth: viewModel.currentMonthDate
                                )
                            } label: {
                                SummaryRowContent(
                                    title: Text(eventTask.name),
                                    summary: Text(eventTask.summaryShortText(viewModel.eventsDict[eventTask]))
                                ) {
                                    TaskTypeCircleIcon(task: eventTask)
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

private struct SummarySampleListView: View {
    private struct SampleItem: Identifiable {
        let id = UUID()
        let taskType: TaskType
        let titleKey: LocalizedStringKey
        let summaryKey: LocalizedStringKey
        let opacity: Double
    }

    private let sampleItems: [SampleItem] = [
        SampleItem(
            taskType: .time,
            titleKey: "summary_sample_task_focus_name",
            summaryKey: "summary_sample_task_focus_value",
            opacity: 0.34
        ),
        SampleItem(
            taskType: .counter,
            titleKey: "summary_sample_task_habit_name",
            summaryKey: "summary_sample_task_habit_value",
            opacity: 0.24
        ),
        SampleItem(
            taskType: .income,
            titleKey: "summary_sample_task_income_name",
            summaryKey: "summary_sample_task_income_value",
            opacity: 0.42
        )
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("summary_sample_badge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            VStack(spacing: 8) {
                Text("summary_sample_headline")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("summary_sample_body")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            List {
                ForEach(sampleItems) { item in
                    SummaryRowContent(title: Text(item.titleKey), summary: Text(item.summaryKey)) {
                        TaskTypeCircleIcon(
                            taskType: item.taskType,
                            iconColor: item.taskType.color.opacity(min(item.opacity + 0.4, 1)),
                            strokeOpacity: min(item.opacity + 0.2, 0.8),
                            lineWidth: 4
                        )
                    }
                    .allowsHitTesting(false)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .frame(height: 220)
        }
    }
}

private struct SummaryRowContent<Leading: View, Summary: View>: View {
    let title: Text
    let summary: Summary
    let leading: Leading

    init(
        title: Text,
        summary: Summary,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.summary = summary
        self.leading = leading()
    }

    var body: some View {
        VStack {
            HStack {
                leading
                title
                HStack {
                    Spacer()
                    summary
                }
            }
            .padding(.leading, 0)
        }
    }
}

#Preview {
    SummaryView()
}
