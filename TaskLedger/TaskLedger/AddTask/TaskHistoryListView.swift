import SwiftUI

struct TaskHistoryListView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    let tasks: [EventTask]
    let onSelect: (EventTask) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            if tasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("history_title")
                .font(.headline)
            Spacer()
            Button("done_button_title") { dismiss() }
                .fontWeight(.semibold)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("history_empty_state")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var taskList: some View {
        List {
            ForEach(tasks) { task in
                Button {
                    onSelect(task)
                    dismiss()
                } label: {
                    TaskHistoryRow(task: task)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Row

private struct TaskHistoryRow: View {
    let task: EventTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.taskType.imageName)
                .foregroundStyle(task.taskType.color)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .font(.body)
                    .lineLimit(1)
                Text(task.taskType.taskName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}
