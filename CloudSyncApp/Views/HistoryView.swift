//
//  HistoryView.swift
//  CloudSyncApp
//
//  Task history and activity log
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var tasksVM: TasksViewModel
    @State private var searchText = ""
    @State private var filterState: TaskState?
    @State private var selectedTask: SyncTask?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            historyHeader
            
            Divider()
            
            if filteredHistory.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("History")
        .sheet(item: $selectedTask) { task in
            TaskDetailSheet(task: task)
        }
    }
    
    private var historyHeader: some View {
        HStack(spacing: 16) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search history...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .frame(maxWidth: 300)
            
            // Filter
            Picker("Filter", selection: $filterState) {
                Text("All").tag(nil as TaskState?)
                Divider()
                Text("Completed").tag(TaskState.completed as TaskState?)
                Text("Failed").tag(TaskState.failed as TaskState?)
                Text("Cancelled").tag(TaskState.cancelled as TaskState?)
            }
            .frame(width: 150)
            
            Spacer()
            
            // Clear History
            Button {
                tasksVM.clearHistory()
            } label: {
                Label("Clear History", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .disabled(tasksVM.taskHistory.isEmpty)
        }
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Completed tasks will appear here")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var historyList: some View {
        List {
            ForEach(groupedHistory, id: \.0) { date, tasks in
                Section(header: Text(formatDate(date))) {
                    ForEach(tasks) { task in
                        HistoryRow(task: task)
                            .onTapGesture {
                                selectedTask = task
                            }
                    }
                }
            }
        }
        .listStyle(.inset)
    }
    
    private var filteredHistory: [SyncTask] {
        tasksVM.taskHistory.filter { task in
            let matchesSearch = searchText.isEmpty ||
                task.name.localizedCaseInsensitiveContains(searchText) ||
                task.sourceRemote.localizedCaseInsensitiveContains(searchText) ||
                task.destinationRemote.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = filterState == nil || task.state == filterState
            
            return matchesSearch && matchesFilter
        }
    }
    
    private var groupedHistory: [(Date, [SyncTask])] {
        let grouped = Dictionary(grouping: filteredHistory) { task in
            Calendar.current.startOfDay(for: task.completedAt ?? task.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct HistoryRow: View {
    let task: SyncTask
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
            }
            
            // Task Info
            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Text(task.sourceRemote)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(task.destinationRemote)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 2) {
                Text(task.formattedBytesTransferred)
                    .font(.caption)
                
                // Show average speed for completed transfers
                if task.state == .completed && task.bytesTransferred > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "speedometer")
                            .font(.caption2)
                        Text(task.averageSpeed)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if let date = task.completedAt {
                    Text(date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Duration
            Text(task.formattedDuration)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private var statusColor: Color {
        switch task.state {
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        default: return .blue
        }
    }
    
    private var statusIcon: String {
        switch task.state {
        case .completed: return "checkmark"
        case .failed: return "xmark"
        case .cancelled: return "minus"
        default: return "arrow.triangle.2.circlepath"
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(TasksViewModel.shared)
        .frame(width: 800, height: 600)
}
