import SwiftUI

struct CrashReportViewer: View {
    @State private var selectedReport: CrashReport?
    @State private var reports: [CrashReport] = []
    @State private var showDeleteConfirmation = false
    @State private var reportToDelete: CrashReport?

    var body: some View {
        HSplitView {
            // Report list
            List(selection: $selectedReport) {
                ForEach(reports) { report in
                    CrashReportRow(report: report)
                        .tag(report)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200, maxWidth: 300)
            .onAppear {
                loadReports()
            }

            // Report detail
            if let report = selectedReport {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Crash Report")
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text(report.summary)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                Button {
                                    exportReport(report)
                                } label: {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)

                                Button {
                                    reportToDelete = report
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .foregroundColor(.red)
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()

                        Divider()

                        // Report content
                        Text(report.formattedDescription)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .padding()
                    }
                }
                .frame(minWidth: 400)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("Select a crash report")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 700, minHeight: 500)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button {
                    clearAllReports()
                } label: {
                    Label("Clear All", systemImage: "trash")
                }
                .disabled(reports.isEmpty)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    exportAllReports()
                } label: {
                    Label("Export All", systemImage: "square.and.arrow.up")
                }
                .disabled(reports.isEmpty)
            }
        }
        .alert("Delete Crash Report?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let report = reportToDelete {
                    deleteReport(report)
                }
            }
            Button("Cancel", role: .cancel) {
                reportToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func loadReports() {
        reports = CrashReportingManager.shared.getAllCrashReports()
    }

    private func exportReport(_ report: CrashReport) {
        let panel = NSSavePanel()
        panel.title = "Export Crash Report"
        panel.nameFieldStringValue = "crash_report_\(ISO8601DateFormatter().string(from: report.date)).txt"
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            do {
                try report.formattedDescription.write(to: url, atomically: true, encoding: .utf8)
                NSWorkspace.shared.activateFileViewerSelecting([url])
            } catch {
                print("Failed to export report: \(error)")
            }
        }
    }

    private func exportAllReports() {
        do {
            let exportURL = try CrashReportingManager.shared.exportLogs()

            let panel = NSSavePanel()
            panel.title = "Export All Crash Reports"
            panel.nameFieldStringValue = exportURL.lastPathComponent
            panel.allowedContentTypes = [.zip]
            panel.canCreateDirectories = true

            panel.begin { response in
                guard response == .OK, let url = panel.url else {
                    try? FileManager.default.removeItem(at: exportURL)
                    return
                }

                do {
                    try FileManager.default.moveItem(at: exportURL, to: url)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } catch {
                    print("Failed to export reports: \(error)")
                    try? FileManager.default.removeItem(at: exportURL)
                }
            }
        } catch {
            print("Failed to prepare export: \(error)")
        }
    }

    private func deleteReport(_ report: CrashReport) {
        CrashReportingManager.shared.deleteCrashReport(report)
        loadReports()
        if selectedReport?.id == report.id {
            selectedReport = nil
        }
        reportToDelete = nil
    }

    private func clearAllReports() {
        CrashReportingManager.shared.clearLogs()
        loadReports()
        selectedReport = nil
    }
}

struct CrashReportRow: View {
    let report: CrashReport

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: report.type == .exception ? "exclamationmark.circle.fill" : "bolt.circle.fill")
                    .foregroundColor(report.type == .exception ? .orange : .red)

                Text(report.type.rawValue)
                    .fontWeight(.medium)

                Spacer()
            }

            Text(formatDate(report.date))
                .font(.caption)
                .foregroundColor(.secondary)

            if let reason = report.reason {
                Text(reason)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CrashReportViewer()
}
