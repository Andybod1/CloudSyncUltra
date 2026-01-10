//
//  TransferView.swift
//  CloudSyncApp
//
//  Dual-pane file transfer interface with drag & drop
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferView: View {
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    
    @StateObject private var sourceBrowser = FileBrowserViewModel()
    @StateObject private var destBrowser = FileBrowserViewModel()
    @StateObject private var transferProgress = TransferProgressModel()
    
    @State private var selectedSourceRemote: CloudRemote?
    @State private var selectedDestRemote: CloudRemote?
    @State private var transferMode: TaskType = .transfer
    @State private var dragSourceIsLeft = true
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            transferToolbar
            Divider()
            
            if transferProgress.isTransferring {
                TransferProgressBar(progress: transferProgress)
                Divider()
            }
            
            HStack(spacing: 0) {
                TransferFileBrowserPane(
                    title: "Source",
                    browser: sourceBrowser,
                    selectedRemote: $selectedSourceRemote,
                    remotes: remotesVM.configuredRemotes,
                    isLeftPane: true,
                    dragSourceIsLeft: $dragSourceIsLeft,
                    isDragging: $isDragging,
                    onDropReceived: { transferFromRightToLeft() }
                )
                
                transferControls
                
                TransferFileBrowserPane(
                    title: "Destination",
                    browser: destBrowser,
                    selectedRemote: $selectedDestRemote,
                    remotes: remotesVM.configuredRemotes,
                    isLeftPane: false,
                    dragSourceIsLeft: $dragSourceIsLeft,
                    isDragging: $isDragging,
                    onDropReceived: { transferFromLeftToRight() }
                )
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("Transfer")
        .onChange(of: selectedSourceRemote) { _, newValue in
            if let remote = newValue { sourceBrowser.setRemote(remote) }
        }
        .onChange(of: selectedDestRemote) { _, newValue in
            if let remote = newValue { destBrowser.setRemote(remote) }
        }
    }
    
    private var transferToolbar: some View {
        HStack(spacing: 16) {
            Picker("Mode", selection: $transferMode) {
                ForEach(TaskType.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            .disabled(transferProgress.isTransferring)
            
            Spacer()
            
            if !transferProgress.isTransferring {
                HStack(spacing: 4) {
                    Image(systemName: "hand.draw").foregroundColor(.secondary)
                    Text("Drag files between panes to transfer").font(.caption).foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button { sourceBrowser.refresh(); destBrowser.refresh() } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(transferProgress.isTransferring)
            
            Divider().frame(height: 20)
            
            Text("\(sourceBrowser.selectedFiles.count + destBrowser.selectedFiles.count) selected")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var transferControls: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Button { transferFromLeftToRight() } label: {
                Image(systemName: "chevron.right.2").font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .disabled(sourceBrowser.selectedFiles.isEmpty || selectedDestRemote == nil || transferProgress.isTransferring)
            
            Button { swap(&selectedSourceRemote, &selectedDestRemote) } label: {
                Image(systemName: "arrow.left.arrow.right").font(.caption)
            }
            .buttonStyle(.bordered)
            .disabled(transferProgress.isTransferring)
            
            Button { transferFromRightToLeft() } label: {
                Image(systemName: "chevron.left.2").font(.title2)
            }
            .buttonStyle(.borderedProminent)
            .disabled(destBrowser.selectedFiles.isEmpty || selectedSourceRemote == nil || transferProgress.isTransferring)
            
            Spacer()
            
            if transferProgress.isTransferring {
                Button { transferProgress.cancel() } label: {
                    Label("Cancel", systemImage: "xmark.circle").font(.caption)
                }
                .buttonStyle(.bordered).tint(.red)
            }
            
            Spacer()
        }
        .frame(width: 80)
        .padding(.vertical)
    }
    
    private func transferFromLeftToRight() {
        guard let srcRemote = selectedSourceRemote, let dstRemote = selectedDestRemote else { return }
        guard !sourceBrowser.selectedFiles.isEmpty else { return }
        let items = sourceBrowser.files.filter { sourceBrowser.selectedFiles.contains($0.id) }
        startTransfer(files: items, from: srcRemote, fromPath: sourceBrowser.currentPath, 
                      to: dstRemote, toPath: destBrowser.currentPath, srcBrowser: sourceBrowser, dstBrowser: destBrowser)
    }
    
    private func transferFromRightToLeft() {
        guard let srcRemote = selectedDestRemote, let dstRemote = selectedSourceRemote else { return }
        guard !destBrowser.selectedFiles.isEmpty else { return }
        let items = destBrowser.files.filter { destBrowser.selectedFiles.contains($0.id) }
        startTransfer(files: items, from: srcRemote, fromPath: destBrowser.currentPath,
                      to: dstRemote, toPath: sourceBrowser.currentPath, srcBrowser: destBrowser, dstBrowser: sourceBrowser)
    }
    
    private func startTransfer(files: [FileItem], from: CloudRemote, fromPath: String, 
                               to: CloudRemote, toPath: String, srcBrowser: FileBrowserViewModel, dstBrowser: FileBrowserViewModel) {
        let totalSize = files.reduce(0) { $0 + $1.size }
        transferProgress.start(itemCount: files.count, totalSize: totalSize, sourceName: from.name, destName: to.name)
        
        Task {
            var successCount = 0
            var skipCount = 0
            var errorMessages: [String] = []
            
            for file in files {
                do {
                    let tempDir = NSTemporaryDirectory()
                    try await RcloneManager.shared.download(remoteName: from.rcloneName, remotePath: file.path, localPath: tempDir)
                    let tempFile = (tempDir as NSString).appendingPathComponent(file.name)
                    
                    do {
                        try await RcloneManager.shared.upload(localPath: tempFile, remoteName: to.rcloneName, remotePath: toPath)
                        successCount += 1
                    } catch {
                        let errStr = error.localizedDescription
                        if errStr.contains("already exists") {
                            skipCount += 1  // File exists, count as skipped
                        } else {
                            errorMessages.append("\(file.name): \(errStr)")
                        }
                    }
                    
                    try? FileManager.default.removeItem(atPath: tempFile)
                } catch {
                    errorMessages.append("\(file.name): \(error.localizedDescription)")
                }
            }
            
            await MainActor.run {
                if errorMessages.isEmpty {
                    if skipCount > 0 {
                        transferProgress.complete(success: true, message: "\(successCount) transferred, \(skipCount) skipped (already exist)")
                    } else {
                        transferProgress.complete(success: true)
                    }
                } else {
                    transferProgress.complete(success: false, error: errorMessages.first)
                }
                srcBrowser.deselectAll()
                dstBrowser.refresh()
            }
        }
    }
}

// MARK: - Transfer Progress Model

@MainActor
class TransferProgressModel: ObservableObject {
    @Published var isTransferring = false
    @Published var percentage: Double = 0
    @Published var speed: String = ""
    @Published var itemCount: Int = 0
    @Published var totalSize: Int64 = 0
    @Published var transferredSize: Int64 = 0
    @Published var sourceName: String = ""
    @Published var destName: String = ""
    @Published var statusMessage: String = ""
    @Published var isCancelled = false
    @Published var isCompleted = false
    @Published var hasError = false
    @Published var errorMessage: String?
    
    func start(itemCount: Int, totalSize: Int64, sourceName: String, destName: String) {
        isTransferring = true; percentage = 0; speed = ""; self.itemCount = itemCount
        self.totalSize = totalSize; transferredSize = 0; self.sourceName = sourceName
        self.destName = destName; statusMessage = "Transferring..."; isCancelled = false
        isCompleted = false; hasError = false; errorMessage = nil
    }
    
    func complete(success: Bool, error: String? = nil, message: String? = nil) {
        isCompleted = true; hasError = !success; errorMessage = error
        if success { 
            percentage = 100
            statusMessage = message ?? "Transfer complete!"
        }
        else if isCancelled { statusMessage = "Transfer cancelled" }
        else { 
            // Clean up error message - remove raw API details
            if let err = error {
                if err.contains("already exists") {
                    statusMessage = "Some files already exist at destination"
                } else if err.contains("not found") {
                    statusMessage = "File or folder not found"
                } else if err.contains("permission") || err.contains("denied") {
                    statusMessage = "Permission denied"
                } else {
                    // Show only first line of error
                    statusMessage = String(err.split(separator: "\n").first ?? "Transfer failed")
                }
            } else {
                statusMessage = "Transfer failed"
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self.isTransferring = false }
    }
    
    func cancel() { isCancelled = true; statusMessage = "Cancelling..." }
}

// MARK: - Transfer Progress Bar

struct TransferProgressBar: View {
    @ObservedObject var progress: TransferProgressModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(statusColor.opacity(0.15)).frame(width: 40, height: 40)
                    if progress.isCompleted {
                        Image(systemName: progress.hasError ? "xmark" : "checkmark").foregroundColor(statusColor)
                    } else { ProgressView().scaleEffect(0.8) }
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(progress.sourceName).fontWeight(.medium)
                        Image(systemName: "arrow.right").font(.caption).foregroundColor(.secondary)
                        Text(progress.destName).fontWeight(.medium)
                    }.font(.subheadline)
                    Text(progress.statusMessage).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("\(Int(progress.percentage))%").font(.title2).fontWeight(.bold).foregroundColor(statusColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.2)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(statusColor)
                        .frame(width: geo.size.width * CGFloat(progress.percentage / 100), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress.percentage)
                }
            }.frame(height: 8)
        }
        .padding()
        .background(statusColor.opacity(0.05))
    }
    
    private var statusColor: Color {
        if progress.hasError { return .red }
        if progress.isCancelled { return .orange }
        if progress.isCompleted { return .green }
        return .accentColor
    }
}

// MARK: - Transfer File Browser Pane

struct TransferFileBrowserPane: View {
    let title: String
    @ObservedObject var browser: FileBrowserViewModel
    @Binding var selectedRemote: CloudRemote?
    let remotes: [CloudRemote]
    let isLeftPane: Bool
    @Binding var dragSourceIsLeft: Bool
    @Binding var isDragging: Bool
    let onDropReceived: () -> Void
    
    @State private var isDropTarget = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker(title, selection: $selectedRemote) {
                    Text("Select...").tag(nil as CloudRemote?)
                    ForEach(remotes) { remote in
                        Label(remote.name, systemImage: remote.displayIcon).tag(remote as CloudRemote?)
                    }
                }.frame(maxWidth: 200)
                Spacer()
                Picker("View", selection: $browser.viewMode) {
                    Image(systemName: "list.bullet").tag(FileBrowserViewModel.ViewMode.list)
                    Image(systemName: "square.grid.2x2").tag(FileBrowserViewModel.ViewMode.grid)
                }.pickerStyle(.segmented).frame(width: 80)
            }
            .padding(8).background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            BreadcrumbBar(components: browser.pathComponents, onNavigate: { browser.navigateTo($0) })
            Divider()
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search files...", text: $browser.searchQuery).textFieldStyle(.plain)
            }.padding(8).background(Color(NSColor.textBackgroundColor))
            
            Divider()
            
            ZStack {
                if browser.isLoading {
                    VStack { Spacer(); ProgressView("Loading..."); Spacer() }
                } else if let error = browser.error {
                    VStack { Spacer(); Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundColor(.red)
                        Text(error).foregroundColor(.secondary); Spacer() }
                } else if browser.files.isEmpty {
                    VStack { Spacer(); Image(systemName: "folder").font(.largeTitle).foregroundColor(.secondary)
                        Text("Empty folder").foregroundColor(.secondary); Text("Drop files here").font(.caption).foregroundColor(.secondary); Spacer() }
                } else { fileListView }
                
                if isDropTarget && isDragging && dragSourceIsLeft != isLeftPane {
                    RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 3)
                        .background(Color.accentColor.opacity(0.1)).padding(4)
                }
            }
            .onDrop(of: [UTType.text], isTargeted: $isDropTarget) { _ in
                if isDragging && dragSourceIsLeft != isLeftPane {
                    onDropReceived(); isDragging = false; return true
                }
                return false
            }
            
            Divider()
            statusBar
        }.frame(maxWidth: .infinity)
    }
    
    private var fileListView: some View {
        List(selection: $browser.selectedFiles) {
            ForEach(browser.filteredFiles) { file in
                TransferFileRow(file: file, isSelected: browser.selectedFiles.contains(file.id), browser: browser,
                               isLeftPane: isLeftPane, dragSourceIsLeft: $dragSourceIsLeft, isDragging: $isDragging).tag(file.id)
            }
        }.listStyle(.plain)
    }
    
    private var statusBar: some View {
        HStack {
            Text("\(browser.files.count) items")
            if !browser.selectedFiles.isEmpty { Text("• \(browser.selectedFiles.count) selected") }
            Spacer()
        }.font(.caption).foregroundColor(.secondary).padding(8).background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Transfer File Row

struct TransferFileRow: View {
    let file: FileItem
    let isSelected: Bool
    @ObservedObject var browser: FileBrowserViewModel
    let isLeftPane: Bool
    @Binding var dragSourceIsLeft: Bool
    @Binding var isDragging: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.icon).foregroundColor(file.isDirectory ? .accentColor : .secondary).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).lineLimit(1)
                if !file.isDirectory { Text(file.formattedSize).font(.caption).foregroundColor(.secondary) }
            }
            Spacer()
            Text(file.formattedDate).font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 4).padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4).contentShape(Rectangle())
        .onTapGesture(count: 2) { browser.navigateToFile(file) }
        .onTapGesture(count: 1) { browser.toggleSelection(file) }
        .onDrag {
            dragSourceIsLeft = isLeftPane; isDragging = true
            if !browser.selectedFiles.contains(file.id) { browser.selectedFiles = [file.id] }
            return NSItemProvider(object: file.name as NSString)
        }
    }
}

// MARK: - Breadcrumb & FileRow

struct BreadcrumbBar: View {
    let components: [(name: String, path: String)]
    let onNavigate: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                    if index > 0 { Image(systemName: "chevron.right").font(.caption2).foregroundColor(.secondary) }
                    Button { onNavigate(component.path) } label: {
                        Text(component.name).font(.caption).foregroundColor(index == components.count - 1 ? .primary : .accentColor)
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 8).padding(.vertical, 6)
        }.background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

struct FileRow: View {
    let file: FileItem; let isSelected: Bool
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.icon).foregroundColor(file.isDirectory ? .accentColor : .secondary).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name).lineLimit(1)
                if !file.isDirectory { Text(file.formattedSize).font(.caption).foregroundColor(.secondary) }
            }
            Spacer()
            Text(file.formattedDate).font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 4).padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4).contentShape(Rectangle())
    }
}

#Preview {
    TransferView().environmentObject(RemotesViewModel.shared).environmentObject(TasksViewModel.shared).frame(width: 1000, height: 600)
}
