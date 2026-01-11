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
        // Calculate total size and file count, including folder contents
        var totalSize: Int64 = 0
        var totalFileCount = 0
        var hasFolder = false
        
        for file in files {
            if file.isDirectory {
                hasFolder = true
                // Calculate actual folder size and count files
                if from.type == .local {
                    let (size, fileCount) = getFolderSizeAndCount(path: file.path)
                    totalSize += size
                    totalFileCount += fileCount
                } else {
                    // For cloud folders, use the reported size (may be inaccurate)
                    // We can't accurately count files in cloud folders without fetching
                    totalSize += file.size
                    totalFileCount += 1 // Count the folder itself
                }
            } else {
                totalSize += file.size
                totalFileCount += 1
            }
        }
        
        let logPath = "/tmp/cloudsync_transfer_debug.log"
        let log = { (msg: String) in
            let timestamp = Date().description
            let line = "\(timestamp): [Transfer] \(msg)\n"
            if let data = line.data(using: .utf8) {
                let fileURL = URL(fileURLWithPath: logPath)
                if FileManager.default.fileExists(atPath: logPath) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    try? data.write(to: fileURL)
                }
            }
        }
        
        log("Starting transfer: \(files.count) files, \(totalSize) bytes")
        log("From: \(from.name) (\(from.type)) - \(fromPath)")
        log("To: \(to.name) (\(to.type)) - \(toPath)")
        log("Files to transfer:")
        for (i, file) in files.enumerated() {
            log("  [\(i+1)] \(file.name) - \(file.size) bytes")
        }
        
        transferProgress.start(itemCount: totalFileCount, totalSize: totalSize, sourceName: from.name, destName: to.name)
        
        // Create task for history
        let taskName = files.count == 1 ? files[0].name : "\(files.count) items"
        
        var task = tasksVM.createTask(
            name: taskName,
            type: .transfer,
            sourceRemote: from.name,
            sourcePath: fromPath,
            destinationRemote: to.name,
            destinationPath: toPath
        )
        task.totalFiles = totalFileCount
        task.totalBytes = totalSize
        task.startedAt = Date()
        task.state = .running
        
        // Mark if this is a folder transfer for better display
        if hasFolder {
            task.metadata = ["isFolder": "true"]
        }
        
        tasksVM.updateTask(task)
        
        Task {
            var successCount = 0
            var skipCount = 0
            var errorMessages: [String] = []
            
            log("Starting Task loop with \(files.count) files")
            
            for (index, file) in files.enumerated() {
                log("Processing file \(index + 1)/\(files.count): \(file.name)")
                
                do {
                    // Update which file we're on
                    await MainActor.run {
                        // Show our pre-calculated file count since rclone doesn't report it for folders
                        if file.isDirectory && totalFileCount > 1 {
                            transferProgress.sourceName = "Uploading \(totalFileCount) files: \(file.name)"
                        } else {
                            transferProgress.sourceName = "\(index + 1)/\(files.count): \(file.name)"
                        }
                    }
                    
                    // Determine source and destination paths
                    let sourcePath = file.path
                    let sourceRemote = from.type == .local ? "" : from.rcloneName
                    let destRemote = to.type == .local ? "" : to.rcloneName
                    var destPath = toPath.isEmpty ? "" : toPath
                    
                    log("File isDirectory: \(file.isDirectory), name: \(file.name), size: \(file.size)")
                    
                    // If transferring a directory, append the directory name to destination
                    // so it creates the folder at destination instead of copying contents into root
                    if file.isDirectory {
                        let folderName = (sourcePath as NSString).lastPathComponent
                        destPath = (destPath as NSString).appendingPathComponent(folderName)
                        log("Directory detected - adjusted dest path to: \(destPath)")
                    }
                    
                    log("Source: remote=\(sourceRemote), path=\(sourcePath)")
                    log("Dest: remote=\(destRemote), path=\(destPath)")
                    
                    // For direct copy between remotes or from local to remote
                    if from.type == .local {
                        // Source is local file system - use streaming upload with progress
                        log("Upload: local -> cloud")
                        let progressStream = try await RcloneManager.shared.uploadWithProgress(
                            localPath: sourcePath,
                            remoteName: destRemote.isEmpty ? "proton" : destRemote,
                            remotePath: destPath
                        )
                        
                        log("Got progress stream")
                        
                        for await progress in progressStream {
                            log("Progress: \(progress.percentage)% - \(progress.speed) - Files: \(progress.filesTransferred ?? 0)/\(progress.totalFiles ?? 0)")
                            await MainActor.run {
                                transferProgress.percentage = progress.percentage
                                transferProgress.speed = progress.speed
                                
                                // Update task progress
                                task.progress = progress.percentage / 100.0
                                task.speed = progress.speed
                                
                                // For folders, estimate files transferred based on percentage
                                if file.isDirectory && totalFileCount > 1 {
                                    let estimatedFilesTransferred = Int(Double(totalFileCount) * (progress.percentage / 100.0))
                                    task.filesTransferred = max(1, estimatedFilesTransferred) // At least 1
                                    // Update display
                                    transferProgress.sourceName = "\(task.filesTransferred)/\(totalFileCount): \(file.name)"
                                } else {
                                    // Use rclone's file count if available
                                    if let transferred = progress.filesTransferred {
                                        task.filesTransferred = transferred
                                    }
                                }
                                
                                // If rclone reports total bytes (for directories), use that
                                if let totalBytes = progress.totalBytes {
                                    if task.totalBytes != totalBytes {
                                        log("Updating totalBytes from \(task.totalBytes) to \(totalBytes)")
                                        task.totalBytes = totalBytes
                                    }
                                }
                                
                                // Calculate bytes transferred
                                if let bytesTransferred = progress.bytesTransferred {
                                    // Use rclone's reported bytes if available
                                    task.bytesTransferred = bytesTransferred
                                } else {
                                    // Fallback: calculate from file size and percentage
                                    let currentFileBytes = Int64(Double(file.size) * (progress.percentage / 100.0))
                                    let previousFilesBytes = files.prefix(index).reduce(Int64(0)) { $0 + $1.size }
                                    task.bytesTransferred = previousFilesBytes + currentFileBytes
                                }
                                
                                tasksVM.updateTask(task)
                            }
                        }
                        
                        log("Upload complete")
                        successCount += 1
                        
                        // Update file count after completion
                        await MainActor.run {
                            // For folders, set to total file count; for single files, increment
                            if file.isDirectory && totalFileCount > 1 {
                                task.filesTransferred = totalFileCount
                            } else {
                                task.filesTransferred = successCount
                            }
                            task.bytesTransferred = files.prefix(successCount).reduce(Int64(0)) { $0 + $1.size }
                            tasksVM.updateTask(task)
                        }
                    } else if to.type == .local {
                        // Destination is local file system
                        try await RcloneManager.shared.download(
                            remoteName: sourceRemote,
                            remotePath: sourcePath,
                            localPath: destPath
                        )
                        successCount += 1
                    } else {
                        // Both are cloud remotes - use rclone copy between remotes
                        let sourceSpec = "\(sourceRemote):\(sourcePath)"
                        let destSpec = "\(destRemote):\(destPath)"
                        
                        try await RcloneManager.shared.copyBetweenRemotes(
                            source: sourceSpec,
                            destination: destSpec
                        )
                        successCount += 1
                    }
                } catch {
                    let errStr = error.localizedDescription
                    if errStr.contains("already exists") || errStr.contains("already exist") {
                        skipCount += 1
                    } else {
                        errorMessages.append("\(file.name): \(errStr)")
                    }
                }
                
                // Update overall progress based on files completed
                let overallProgress = Double(successCount + skipCount + errorMessages.count) / Double(files.count) * 100
                await MainActor.run {
                    // Only update if we're between files (not during individual file progress)
                    if successCount + skipCount + errorMessages.count == index + 1 {
                        transferProgress.percentage = overallProgress
                    }
                }
            }
            
            await MainActor.run {
                // Update final task state
                task.completedAt = Date()
                
                // For folders, use the actual file count; otherwise use successCount
                if hasFolder {
                    task.filesTransferred = totalFileCount
                } else {
                    task.filesTransferred = successCount
                }
                
                task.bytesTransferred = totalSize
                task.progress = 1.0
                
                if errorMessages.isEmpty {
                    // Mark task as completed
                    task.state = .completed
                    tasksVM.updateTask(task)
                    tasksVM.moveToHistory(task)
                    
                    if skipCount > 0 {
                        transferProgress.complete(success: true, message: "\(successCount) transferred, \(skipCount) skipped (already exist)")
                    } else {
                        transferProgress.complete(success: true)
                    }
                } else {
                    // Mark task as failed
                    task.state = .failed
                    task.errorMessage = errorMessages.joined(separator: "; ")
                    tasksVM.updateTask(task)
                    tasksVM.moveToHistory(task)
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
}    // Helper function to calculate actual folder size
    private func getFolderSize(path: String) -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path),
                                                      includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                                                      options: [.skipsHiddenFiles]) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey]),
                  let isDirectory = resourceValues.isDirectory else {
                continue
            }
            
            if !isDirectory, let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    // Helper function to calculate folder size AND count files
    private func getFolderSizeAndCount(path: String) -> (size: Int64, fileCount: Int) {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        var fileCount = 0
        
        guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path),
                                                      includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
                                                      options: [.skipsHiddenFiles]) else {
            return (0, 0)
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey]),
                  let isDirectory = resourceValues.isDirectory else {
                continue
            }
            
            if !isDirectory {
                if let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
                fileCount += 1
            }
        }
        
        return (totalSize, fileCount)
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
                    HStack(spacing: 8) {
                        Text(progress.statusMessage).font(.caption).foregroundColor(.secondary)
                        if !progress.speed.isEmpty && progress.isTransferring {
                            Text("•").foregroundColor(.secondary)
                            Text(progress.speed).font(.caption).foregroundColor(.secondary)
                        }
                    }
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
    @State private var showingNewFolderDialog = false
    @State private var newFolderName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker(title, selection: $selectedRemote) {
                    Text("Select...").tag(nil as CloudRemote?)
                    ForEach(remotes) { remote in
                        Label(remote.name, systemImage: remote.displayIcon).tag(remote as CloudRemote?)
                    }
                }.frame(maxWidth: 200)
                
                Button {
                    showingNewFolderDialog = true
                    newFolderName = ""
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(.borderless)
                .help("Create new folder")
                .disabled(selectedRemote == nil)
                
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
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingNewFolderDialog) {
            NewFolderDialog(
                folderName: $newFolderName,
                isPresented: $showingNewFolderDialog,
                onCreate: { createFolder() }
            )
        }
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
    
    private func createFolder() {
        guard let remote = selectedRemote else { return }
        guard !newFolderName.isEmpty else { return }
        
        Task {
            do {
                let folderPath = (browser.currentPath as NSString).appendingPathComponent(newFolderName)
                
                if remote.type == .local {
                    // Create local folder
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
                } else {
                    // Create remote folder using rclone mkdir
                    try await RcloneManager.shared.createDirectory(
                        remoteName: remote.rcloneName,
                        path: folderPath
                    )
                }
                
                // Refresh the browser to show the new folder
                await MainActor.run {
                    browser.refresh()
                }
            } catch {
                await MainActor.run {
                    browser.error = "Failed to create folder: \(error.localizedDescription)"
                }
            }
        }
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

// MARK: - New Folder Dialog

struct NewFolderDialog: View {
    @Binding var folderName: String
    @Binding var isPresented: Bool
    let onCreate: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "folder.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create New Folder")
                        .font(.headline)
                    Text("Enter a name for the new folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            TextField("Folder name", text: $folderName)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onSubmit {
                    if !folderName.isEmpty {
                        onCreate()
                        isPresented = false
                    }
                }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Create") {
                    onCreate()
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(folderName.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    TransferView().environmentObject(RemotesViewModel.shared).environmentObject(TasksViewModel.shared).frame(width: 1000, height: 600)
}
