//
//  TransferView.swift
//  CloudSyncApp
//
//  Dual-pane file transfer interface with drag & drop
//  Styled to match onboarding experience with AppTheme design tokens
//

import SwiftUI
import UniformTypeIdentifiers

struct TransferView: View {
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @EnvironmentObject var transferState: TransferViewState

    @StateObject private var sourceBrowser = FileBrowserViewModel()
    @StateObject private var destBrowser = FileBrowserViewModel()
    @StateObject private var transferProgress = TransferProgressModel()
    @StateObject private var errorManager = ErrorNotificationManager()

    @State private var dragSourceIsLeft = true
    @State private var isDragging = false
    @State private var encryptLeftToRight = false
    @State private var encryptRightToLeft = false
    @State private var showingTransferWizard = false

    // Performance settings
    @AppStorage("showQuickToggle") private var showQuickToggle = true
    @AppStorage("performanceProfile") private var sessionProfile = PerformanceProfile.balanced

    // Computed properties for the selected remotes based on transferState
    private var selectedSourceRemote: CloudRemote? {
        guard let id = transferState.sourceRemoteId else { return nil }
        return remotesVM.remotes.first { $0.id == id }
    }

    private var selectedDestRemote: CloudRemote? {
        guard let id = transferState.destRemoteId else { return nil }
        return remotesVM.remotes.first { $0.id == id }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            transferToolbar
            Divider()

            // Error banner stack at top
            if !errorManager.activeErrors.isEmpty {
                ScrollView {
                    ErrorBannerStack(
                        errorManager: errorManager,
                        onRetry: { notification in
                            handleRetry(notification)
                        }
                    )
                    .padding()
                }
                .frame(maxHeight: 300)
                Divider()
            }

            // Minimal transfer indicator - just shows something is happening
            if transferProgress.isTransferring {
                TransferActiveIndicator(progress: transferProgress) {
                    cancelTransfer()
                } onViewTasks: {
                    NotificationCenter.default.post(name: .navigateToTasks, object: nil)
                }
                Divider()
            }
            
            HStack(spacing: 0) {
                TransferFileBrowserPane(
                    title: "Source",
                    browser: sourceBrowser,
                    selectedRemote: Binding(
                        get: { selectedSourceRemote },
                        set: { transferState.sourceRemoteId = $0?.id }
                    ),
                    remotes: remotesVM.configuredRemotes,
                    isLeftPane: true,
                    dragSourceIsLeft: $dragSourceIsLeft,
                    isDragging: $isDragging,
                    encryptTransfers: $encryptLeftToRight,
                    onDropReceived: { transferFromRightToLeft() }
                )

                transferControls

                TransferFileBrowserPane(
                    title: "Destination",
                    browser: destBrowser,
                    selectedRemote: Binding(
                        get: { selectedDestRemote },
                        set: { transferState.destRemoteId = $0?.id }
                    ),
                    remotes: remotesVM.configuredRemotes,
                    isLeftPane: false,
                    dragSourceIsLeft: $dragSourceIsLeft,
                    isDragging: $isDragging,
                    encryptTransfers: $encryptRightToLeft,
                    onDropReceived: { transferFromLeftToRight() }
                )
            }
        }
        .background(AppTheme.windowBackground)
        .navigationTitle("Transfer")
        .onChange(of: transferState.sourceRemoteId) { _, _ in
            if let remote = selectedSourceRemote {
                // Initialize encryption state for this remote
                let isEncrypted = EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)
                encryptLeftToRight = isEncrypted
                
                // Set the correct remote (crypt or base) based on encryption state
                if isEncrypted && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
                    let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: remote.rcloneName)
                    let cryptRemote = CloudRemote(
                        name: remote.name,
                        type: remote.type,
                        isConfigured: true,
                        path: "",
                        isEncrypted: true,
                        customRcloneName: cryptRemoteName
                    )
                    sourceBrowser.setRemote(cryptRemote)
                } else {
                    sourceBrowser.setRemote(remote)
                }
            }
        }
        .onChange(of: transferState.destRemoteId) { _, _ in
            if let remote = selectedDestRemote {
                // Initialize encryption state for this remote
                let isEncrypted = EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)
                encryptRightToLeft = isEncrypted
                
                // Set the correct remote (crypt or base) based on encryption state
                if isEncrypted && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
                    let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: remote.rcloneName)
                    let cryptRemote = CloudRemote(
                        name: remote.name,
                        type: remote.type,
                        isConfigured: true,
                        path: "",
                        isEncrypted: true,
                        customRcloneName: cryptRemoteName
                    )
                    destBrowser.setRemote(cryptRemote)
                } else {
                    destBrowser.setRemote(remote)
                }
            }
        }
        .sheet(isPresented: $showingTransferWizard) {
            TransferWizardView()
                .environmentObject(remotesVM)
                .environmentObject(tasksVM)
                .environmentObject(transferState)
        }
    }

    private var transferToolbar: some View {
        HStack(spacing: AppTheme.spacing) {
            Picker("Mode", selection: $transferState.transferMode) {
                ForEach(TaskType.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            .disabled(transferProgress.isTransferring)
            .accessibilityLabel("Transfer Mode")
            .accessibilityHint("Select the type of transfer operation")

            // Performance quick toggle
            if showQuickToggle {
                Divider().frame(height: 20)

                HStack(spacing: AppTheme.spacingXS) {
                    Image(systemName: "speedometer")
                        .foregroundColor(AppTheme.textSecondary)

                    Picker("Performance", selection: $sessionProfile) {
                        Text("Conservative").tag(PerformanceProfile.conservative)
                        Text("Balanced").tag(PerformanceProfile.balanced)
                        Text("Performance").tag(PerformanceProfile.performance)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    .disabled(transferProgress.isTransferring)
                    .accessibilityLabel("Performance Profile")
                    .accessibilityHint("Session-only performance setting for transfers")
                }
            }

            Spacer()

            // Transfer Wizard button
            Button { showingTransferWizard = true } label: {
                Label("New Transfer", systemImage: "wand.and.stars")
            }
            .disabled(transferProgress.isTransferring)
            .accessibilityLabel("New Transfer Wizard")
            .accessibilityHint("Opens a guided wizard to set up a new file transfer")

            Button { sourceBrowser.refresh(); destBrowser.refresh() } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(transferProgress.isTransferring)
            .accessibilityLabel("Refresh")
            .accessibilityHint("Refreshes both source and destination file lists")
            .keyboardShortcut("r", modifiers: .command)

            Divider().frame(height: 20)

            Text("\(sourceBrowser.selectedFiles.count + destBrowser.selectedFiles.count) selected")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
                .accessibilityLabel("\(sourceBrowser.selectedFiles.count + destBrowser.selectedFiles.count) files selected")
        }
        .padding(AppTheme.spacing)
    }
    
    private var transferControls: some View {
        VStack(spacing: AppTheme.spacing) {
            Spacer()

            Button { transferFromLeftToRight() } label: {
                Image(systemName: "chevron.right.2").font(.title2)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(sourceBrowser.selectedFiles.isEmpty || selectedDestRemote == nil || transferProgress.isTransferring)
            .accessibilityLabel("Transfer to Right")
            .accessibilityHint("Transfers selected files from source to destination")
            .keyboardShortcut(.rightArrow, modifiers: [.command, .shift])

            Button {
                let tempId = transferState.sourceRemoteId
                transferState.sourceRemoteId = transferState.destRemoteId
                transferState.destRemoteId = tempId
            } label: {
                Image(systemName: "arrow.left.arrow.right").font(.caption)
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(transferProgress.isTransferring)
            .accessibilityLabel("Swap Panes")
            .accessibilityHint("Swaps source and destination locations")

            Button { transferFromRightToLeft() } label: {
                Image(systemName: "chevron.left.2").font(.title2)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(destBrowser.selectedFiles.isEmpty || selectedSourceRemote == nil || transferProgress.isTransferring)
            .accessibilityLabel("Transfer to Left")
            .accessibilityHint("Transfers selected files from destination to source")
            .keyboardShortcut(.leftArrow, modifiers: [.command, .shift])

            Spacer()

            if transferProgress.isTransferring {
                Button { transferProgress.cancel() } label: {
                    Label("Cancel", systemImage: "xmark.circle").font(AppTheme.captionFont)
                }
                .buttonStyle(.bordered).tint(.red)
                .accessibilityLabel("Cancel Transfer")
                .accessibilityHint("Cancels the current transfer operation")
                .keyboardShortcut(.escape)
            } else {
                // Hint text below buttons
                VStack(spacing: 4) {
                    Image(systemName: "hand.draw")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Drag files\nbetween panes")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()
        }
        .frame(width: 80)
        .padding(.vertical, AppTheme.spacing)
    }
    
    private func transferFromLeftToRight() {
        guard let srcRemote = selectedSourceRemote, let dstRemote = selectedDestRemote else { return }
        guard !sourceBrowser.selectedFiles.isEmpty else { return }
        let items = sourceBrowser.files.filter { sourceBrowser.selectedFiles.contains($0.id) }
        
        // Get effective remotes based on encryption state
        let effectiveSrc = getEffectiveRemote(srcRemote, encrypted: encryptLeftToRight)
        let effectiveDst = getEffectiveRemote(dstRemote, encrypted: encryptRightToLeft)
        
        startTransfer(files: items, from: effectiveSrc, fromPath: sourceBrowser.currentPath,
                      to: effectiveDst, toPath: destBrowser.currentPath, srcBrowser: sourceBrowser, dstBrowser: destBrowser)
    }
    
    private func transferFromRightToLeft() {
        guard let srcRemote = selectedDestRemote, let dstRemote = selectedSourceRemote else { return }
        guard !destBrowser.selectedFiles.isEmpty else { return }
        let items = destBrowser.files.filter { destBrowser.selectedFiles.contains($0.id) }
        
        // Get effective remotes based on encryption state
        let effectiveSrc = getEffectiveRemote(srcRemote, encrypted: encryptRightToLeft)
        let effectiveDst = getEffectiveRemote(dstRemote, encrypted: encryptLeftToRight)
        
        startTransfer(files: items, from: effectiveSrc, fromPath: destBrowser.currentPath,
                      to: effectiveDst, toPath: sourceBrowser.currentPath, srcBrowser: destBrowser, dstBrowser: sourceBrowser)
    }
    
    /// Get the effective remote (crypt or base) based on encryption state
    private func getEffectiveRemote(_ remote: CloudRemote, encrypted: Bool) -> CloudRemote {
        if encrypted && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
            let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: remote.rcloneName)
            return CloudRemote(
                name: remote.name,
                type: remote.type,
                isConfigured: true,
                path: "",
                isEncrypted: true,
                customRcloneName: cryptRemoteName
            )
        }
        return remote
    }
    
    private func cancelTransfer() {
        RcloneManager.shared.stopCurrentSync()
        transferProgress.cancel()
    }

    private func handleRetry(_ notification: ErrorNotification) {
        errorManager.dismiss(notification.id)

        // For basic retry functionality
        Task {
            do {
                // Re-attempt the transfer that failed
                // (This will be enhanced when TransferError integration is complete)
                print("🔄 Retrying operation after error: \(notification.message)")

                // Demo: Show a success message after "retry"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.errorManager.show(
                        "Retry completed successfully",
                        context: notification.context,
                        isCritical: false,
                        isRetryable: false
                    )
                }
            } catch {
                print("❌ Retry failed: \(error)")
                errorManager.show(
                    "Retry failed: \(error.localizedDescription)",
                    context: notification.context,
                    isCritical: true,
                    isRetryable: false
                )
            }
        }
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
        
        // Use secure debug logging instead of world-readable /tmp
        let log = SecurityManager.createSecureDebugLogger(filename: "transfer_debug.log") ?? { msg in
            print("[Transfer Debug] \(msg)")
        }
        
        log("Starting transfer: \(files.count) files, \(totalSize) bytes")
        log("From: \(from.name) (\(from.type)) - \(fromPath)")
        log("To: \(to.name) (\(to.type)) - \(toPath)")
        log("Files to transfer:")
        for (i, file) in files.enumerated() {
            log("  [\(i+1)] \(file.name) - \(file.size) bytes")
        }
        
        // Check if encryption is enabled on either side
        let isEncrypted = from.isEncrypted || to.isEncrypted

        // Calculate max parallel transfers based on providers
        // Use the more conservative limit between source and destination
        let sourceParallelism = from.type.defaultParallelism.transfers
        let destParallelism = to.type.defaultParallelism.transfers
        let maxTransfers = min(sourceParallelism, destParallelism)

        transferProgress.start(itemCount: totalFileCount, totalSize: totalSize, sourceName: from.name, destName: to.name, encrypted: isEncrypted, maxTransfers: maxTransfers)
        
        // Show tip for many small files
        if totalFileCount > 50 {
            let estimatedMinutes = max(1, totalFileCount / 30)  // Rough estimate: 30 files per minute
            transferProgress.statusMessage = "Uploading \(totalFileCount) files (est. \(estimatedMinutes)-\(estimatedMinutes + 1) min). Tip: Zip folders with many small files for faster transfers."
        }
        
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
                    // Use effectiveRemoteName to get crypt remote when encryption is enabled
                    let sourceRemote = from.type == .local ? "" : from.effectiveRemoteName
                    let destRemote = to.type == .local ? "" : to.effectiveRemoteName
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
                        
                        for try await progress in progressStream {
                            log("Progress: \(progress.percentage)% - \(progress.speed) - Files: \(progress.filesTransferred)/\(progress.totalFiles)")
                            await MainActor.run {
                                transferProgress.percentage = progress.percentage
                                transferProgress.speed = progress.speed  // Raw speed string from rclone

                                // Update Dock badge with progress percentage
                                NotificationManager.shared.updateDockProgress(progress.percentage / 100.0)

                                // Update task progress
                                task.progress = progress.percentage / 100.0
                                task.speed = progress.speed  // Raw speed string from rclone
                                
                                // For folders, estimate files transferred based on percentage
                                if file.isDirectory && totalFileCount > 1 {
                                    let estimatedFilesTransferred = Int(Double(totalFileCount) * (progress.percentage / 100.0))
                                    task.filesTransferred = max(1, estimatedFilesTransferred) // At least 1
                                    // Update display
                                    transferProgress.sourceName = "\(task.filesTransferred)/\(totalFileCount): \(file.name)"
                                } else {
                                    // Use rclone's file count
                                    task.filesTransferred = progress.filesTransferred
                                }
                                
                                // If rclone reports total bytes (for directories), use that
                                if progress.totalBytes > 0 {
                                    if task.totalBytes != progress.totalBytes {
                                        log("Updating totalBytes from \(task.totalBytes) to \(progress.totalBytes)")
                                        task.totalBytes = progress.totalBytes
                                    }
                                }
                                
                                // Calculate bytes transferred
                                if progress.bytesTransferred > 0 {
                                    // Use rclone's reported bytes
                                    task.bytesTransferred = progress.bytesTransferred
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
                        log("Cloud to cloud transfer")
                        
                        if file.isDirectory {
                            // For directories, use rclone copy (not copyto)
                            // This copies the entire directory structure
                            let sourceSpec = "\(sourceRemote):\(sourcePath)"
                            let destSpec = "\(destRemote):\(destPath)"
                            
                            log("Cloud-to-cloud folder: \(sourceSpec) -> \(destSpec)")
                            
                            // Use regular copy for directories
                            try await RcloneManager.shared.copy(
                                source: sourceSpec,
                                destination: destSpec
                            )
                        } else {
                            // For files, use copyto for exact destination
                            // If destination path is empty, use just the filename
                            let fileName = (sourcePath as NSString).lastPathComponent
                            let finalDestPath = destPath.isEmpty ? fileName : (destPath as NSString).appendingPathComponent(fileName)
                            
                            let sourceSpec = "\(sourceRemote):\(sourcePath)"
                            let destSpec = "\(destRemote):\(finalDestPath)"
                            
                            log("Cloud-to-cloud file: \(sourceSpec) -> \(destSpec)")
                            
                            try await RcloneManager.shared.copyBetweenRemotes(
                                source: sourceSpec,
                                destination: destSpec
                            )
                        }
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

                // Clear Dock progress badge
                NotificationManager.shared.clearDockProgress()

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

                    // Send notification for successful transfer
                    if files.count == 1 {
                        // Single file transfer
                        NotificationManager.shared.sendTransferComplete(
                            fileName: files[0].name,
                            destination: to.name,
                            fileSize: files[0].size
                        )
                    } else {
                        // Batch transfer
                        NotificationManager.shared.sendBatchComplete(
                            count: successCount,
                            destination: to.name,
                            totalSize: totalSize,
                            failedCount: 0
                        )
                    }
                } else {
                    // Mark task as failed
                    task.state = .failed
                    task.errorMessage = errorMessages.joined(separator: "; ")
                    tasksVM.updateTask(task)
                    tasksVM.moveToHistory(task)
                    transferProgress.complete(success: false, error: errorMessages.first)

                    // Send notification for failed transfer
                    if files.count == 1 {
                        // Single file error
                        NotificationManager.shared.sendTransferError(
                            fileName: files[0].name,
                            error: errorMessages.first ?? "Transfer failed",
                            isRetryable: true
                        )
                    } else {
                        // Batch transfer with errors
                        NotificationManager.shared.sendBatchComplete(
                            count: successCount,
                            destination: to.name,
                            totalSize: totalSize,
                            failedCount: errorMessages.count
                        )
                    }
                }
                srcBrowser.deselectAll()
                dstBrowser.refresh()
            }
        }
    }
    
    // Helper function to calculate actual folder size
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
    @Published var isEncrypted = false
    @Published var maxParallelTransfers = 4
    
    func start(itemCount: Int, totalSize: Int64, sourceName: String, destName: String, encrypted: Bool = false, maxTransfers: Int = 4) {
        isTransferring = true; percentage = 0; speed = ""; self.itemCount = itemCount
        self.totalSize = totalSize; transferredSize = 0; self.sourceName = sourceName
        self.destName = destName; statusMessage = "Transferring..."; isCancelled = false
        isCompleted = false; hasError = false; errorMessage = nil; isEncrypted = encrypted
        maxParallelTransfers = maxTransfers
    }
    
    func complete(success: Bool, error: String? = nil, message: String? = nil) {
        isCompleted = true; hasError = !success; errorMessage = error
        if success {
            percentage = 100
            statusMessage = message ?? "Transfer complete!"
        } else if isCancelled { statusMessage = "Transfer cancelled" } else {
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
    @EnvironmentObject var tasksVM: TasksViewModel
    var onCancel: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.spacingS) {
            HStack(spacing: AppTheme.spacing) {
                // Status icon with circular background (matching onboarding)
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(AppTheme.iconBackgroundOpacity))
                        .frame(width: AppTheme.iconContainerSmall, height: AppTheme.iconContainerSmall)
                    if progress.isCompleted {
                        Image(systemName: progress.hasError ? "xmark" : "checkmark")
                            .foregroundColor(statusColor)
                    } else {
                        ProgressView().scaleEffect(0.8)
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    HStack(spacing: AppTheme.spacingS) {
                        Text(progress.sourceName).fontWeight(.medium)
                        Image(systemName: "arrow.right")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)
                        Text(progress.destName).fontWeight(.medium)

                        // Transfer counter
                        let activeTransfers = tasksVM.runningTasksCount
                        let maxTransfers = progress.maxParallelTransfers
                        Text("•")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(AppTheme.captionFont)
                        Text("\(activeTransfers)/\(maxTransfers) transfers")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)

                        // Encryption badge
                        if progress.isEncrypted {
                            HStack(spacing: 3) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                                Text("E2E Encrypted")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(AppTheme.encryptionColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.encryptionColor.opacity(0.15))
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                        }
                    }
                    .font(AppTheme.subheadlineFont)

                    HStack(spacing: AppTheme.spacingS) {
                        Text(progress.statusMessage)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)
                        if !progress.speed.isEmpty && progress.isTransferring {
                            Text("*")
                                .foregroundColor(AppTheme.textSecondary)
                            Text(progress.speed)
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }

                Spacer()

                Text("\(Int(progress.percentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)

                // Cancel button
                if progress.isTransferring && !progress.isCompleted {
                    Button {
                        onCancel?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.textSecondary.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Cancel transfer")
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                        .fill(AppTheme.textSecondary.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                        .fill(statusColor)
                        .frame(width: geo.size.width * CGFloat(progress.percentage / 100), height: 8)
                        .animation(AppTheme.easeInOut, value: progress.percentage)
                }
            }
            .frame(height: 8)
        }
        .padding(AppTheme.spacing)
        .background(statusColor.opacity(0.05))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Transfer Progress: \(Int(progress.percentage)) percent, \(progress.sourceName) to \(progress.destName)")
        .accessibilityValue(progress.statusMessage)
    }

    private var statusColor: Color {
        if progress.hasError { return AppTheme.errorColor }
        if progress.isCancelled { return AppTheme.warningColor }
        if progress.isCompleted { return AppTheme.successColor }
        return AppTheme.accentColor
    }
}

// MARK: - Transfer Active Indicator (Minimal)

struct TransferActiveIndicator: View {
    @ObservedObject var progress: TransferProgressModel
    @EnvironmentObject var tasksVM: TasksViewModel
    var onCancel: (() -> Void)?
    var onViewTasks: (() -> Void)?

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            // Spinning indicator with circular background (matching onboarding)
            ZStack {
                Circle()
                    .fill(AppTheme.accentColor.opacity(AppTheme.iconBackgroundOpacity))
                    .frame(width: AppTheme.iconContainerSmall, height: AppTheme.iconContainerSmall)
                ProgressView()
                    .scaleEffect(0.8)
            }

            // Status text
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text("\(progress.sourceName) -> \(progress.destName)")
                    .font(AppTheme.subheadlineFont)
                    .lineLimit(1)

                HStack(spacing: AppTheme.spacingXS) {
                    Text("\(Int(progress.percentage))%")
                        .foregroundColor(AppTheme.accentColor)
                    if !progress.speed.isEmpty {
                        Text("*")
                            .foregroundColor(AppTheme.textSecondary)
                        Text(progress.speed)
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    // Transfer counter (X/Y transfers)
                    let activeTransfers = tasksVM.runningTasksCount
                    let maxTransfers = progress.maxParallelTransfers
                    Text("*")
                        .foregroundColor(AppTheme.textSecondary)
                    Text("\(activeTransfers)/\(maxTransfers) transfers")
                        .foregroundColor(AppTheme.textSecondary)

                    if progress.isEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(AppTheme.encryptionColor)
                    }
                }
                .font(AppTheme.captionFont)
            }

            Spacer()

            // View in Tasks button
            Button {
                onViewTasks?()
            } label: {
                Text("View in Tasks")
                    .font(AppTheme.captionFont)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityLabel("View in Tasks")
            .accessibilityHint("Opens the tasks view to see detailed progress")

            // Cancel button
            Button {
                onCancel?()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .help("Cancel transfer")
            .accessibilityLabel("Cancel Transfer")
            .accessibilityHint("Cancels the current transfer operation")
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.vertical, AppTheme.spacingS)
        .background(AppTheme.accentColor.opacity(0.08))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Transfer in progress: \(Int(progress.percentage)) percent complete")
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
    @Binding var encryptTransfers: Bool
    let onDropReceived: () -> Void
    
    @State private var isDropTarget = false
    @State private var showingNewFolderDialog = false
    @State private var newFolderName = ""
    @State private var showRenameSheet = false
    @State private var renameFile: FileItem?
    @State private var renameNewName = ""
    @State private var showDeleteConfirm = false
    @State private var showDeleteError = false
    @State private var deleteError: String?
    @State private var isDeleting = false
    @State private var showEncryptionModal = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker(title, selection: $selectedRemote) {
                    Text("Select...").tag(nil as CloudRemote?)
                    ForEach(remotes) { remote in
                        Label(remote.name, systemImage: remote.displayIcon).tag(remote as CloudRemote?)
                    }
                }.frame(maxWidth: 200)
                .accessibilityLabel("\(title) Location")
                .accessibilityHint("Select the \(title.lowercased()) cloud storage")

                Button {
                    showingNewFolderDialog = true
                    newFolderName = ""
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(.borderless)
                .help("Create new folder")
                .disabled(selectedRemote == nil)
                .accessibilityLabel("New Folder")
                .accessibilityHint("Creates a new folder in the current location")
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Spacer()
                
                // Encryption toggle (only for cloud remotes, not local storage)
                if let remote = selectedRemote, remote.type != .local {
                    Toggle(isOn: $encryptTransfers) {
                        HStack(spacing: 4) {
                            Image(systemName: encryptTransfers ? "lock.fill" : "lock.open")
                                .foregroundColor(encryptTransfers ? .green : .secondary)
                                .font(.caption)
                            Text("Encrypt")
                                .font(.caption)
                        }
                    }
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .help("Encrypt transfers with E2E encryption")
                    .accessibilityLabel("Encryption")
                    .accessibilityValue(encryptTransfers ? "Enabled" : "Disabled")
                    .accessibilityHint("Toggle to enable or disable end-to-end encryption for transfers")
                    .onChange(of: encryptTransfers) { _, isEnabled in
                        guard let remote = selectedRemote else { return }
                        let remoteName = remote.rcloneName
                        
                        if isEnabled && !EncryptionManager.shared.isEncryptionConfigured(for: remoteName) {
                            showEncryptionModal = true
                            encryptTransfers = false  // Reset until configured
                        } else {
                            // Save encryption state for this remote
                            EncryptionManager.shared.setEncryptionEnabled(isEnabled, for: remoteName)
                            // Refresh the browser
                            updateBrowserRemote()
                        }
                    }
                    
                    Divider().frame(height: 20)
                }
                
                VStack(spacing: 4) {
                    Button {
                        browser.viewMode = .list
                    } label: {
                        Image(systemName: "list.bullet")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.bordered)
                    .background(browser.viewMode == .list ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                    .accessibilityLabel("List View")
                    .accessibilityHint("Display files as a list")
                    .accessibilityValue(browser.viewMode == .list ? "Selected" : "")

                    Button {
                        browser.viewMode = .grid
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.bordered)
                    .background(browser.viewMode == .grid ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                    .accessibilityLabel("Grid View")
                    .accessibilityHint("Display files as a grid")
                    .accessibilityValue(browser.viewMode == .grid ? "Selected" : "")
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("View Mode")
            }
            .padding(AppTheme.spacingS)
            .background(AppTheme.controlBackground)
            
            Divider()
            BreadcrumbBar(components: browser.pathComponents, onNavigate: { browser.navigateTo($0) })
            Divider()
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(AppTheme.textSecondary)
                TextField("Search files...", text: $browser.searchQuery).textFieldStyle(.plain)
                    .accessibilityLabel("Search Files")
                    .accessibilityHint("Type to filter files in the current folder")
            }
            .padding(AppTheme.spacingS)
            .background(Color(NSColor.textBackgroundColor))
            
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
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(AppTheme.accentColor, lineWidth: 3)
                        .background(AppTheme.accentColor.opacity(0.1))
                        .padding(AppTheme.spacingXS)
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
        .sheet(isPresented: $showRenameSheet) {
            if let file = renameFile {
                RenameFileSheet(
                    file: file,
                    newName: $renameNewName,
                    isRenaming: .constant(false),
                    error: .constant(nil),
                    onRename: { performRename() },
                    onCancel: { showRenameSheet = false }
                )
            }
        }
        .alert("Delete Files?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteSelectedFiles()
            }
        } message: {
            Text("Are you sure you want to delete \(browser.selectedFiles.count) item(s)? This cannot be undone.")
        }
        .alert("Delete Error", isPresented: $showDeleteError) {
            Button("OK") {
                deleteError = nil
            }
        } message: {
            Text(deleteError ?? "Unknown error")
        }
        .sheet(isPresented: $showEncryptionModal) {
            EncryptionModal { config in
                Task {
                    await configurePaneEncryption(config: config)
                }
            }
        }
    }
    
    private var fileListView: some View {
        VStack(spacing: 0) {
            List(selection: $browser.selectedFiles) {
                ForEach(browser.paginatedFiles) { file in
                    TransferFileRow(file: file, isSelected: browser.selectedFiles.contains(file.id), browser: browser,
                                   isLeftPane: isLeftPane, dragSourceIsLeft: $dragSourceIsLeft, isDragging: $isDragging).tag(file.id)
                }
            }
            .listStyle(.plain)
            .contextMenu(forSelectionType: UUID.self) { selection in
            if !selection.isEmpty {
                Button("Open") {
                    if let file = browser.files.first(where: { selection.contains($0.id) }) {
                        browser.navigateToFile(file)
                    }
                }
                Divider()
                if selection.count == 1 {
                    Button("Rename") {
                        if let file = browser.files.first(where: { selection.contains($0.id) }) {
                            renameFile = file
                            renameNewName = file.name
                            showRenameSheet = true
                        }
                    }
                }
                Button("Download") {
                    downloadSelectedFiles()
                }
                Divider()
                Button("Delete", role: .destructive) {
                    showDeleteConfirm = true
                }
            } else {
                // Context menu for empty space
                Button("New Folder") {
                    showingNewFolderDialog = true
                    newFolderName = ""
                }
                Button("Refresh") {
                    browser.refresh()
                }
            }
        } primaryAction: { selection in
            if let fileId = selection.first,
               let file = browser.files.first(where: { $0.id == fileId }) {
                browser.navigateToFile(file)
            }
        }
            
            // Pagination Controls
            if !browser.isLoading && browser.files.count > browser.pageSize {
                Divider()
                paginationBar
            }
        }
    }
    
    // MARK: - Pagination Bar
    
    private var paginationBar: some View {
        HStack(spacing: 8) {
            // Page size selector
            Menu {
                ForEach([50, 100, 200, 500], id: \.self) { size in
                    Button {
                        browser.pageSize = size
                    } label: {
                        HStack {
                            Text("\(size) items")
                            if browser.pageSize == size {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                Button {
                    browser.isPaginationEnabled.toggle()
                } label: {
                    HStack {
                        Text("Show All")
                        if !browser.isPaginationEnabled {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("\(browser.pageSize)")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
            }
            .menuStyle(.borderlessButton)
            .help("Items per page")
            
            Divider().frame(height: 12)
            
            // Previous page button
            Button {
                browser.previousPage()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!browser.canGoToPreviousPage)
            .buttonStyle(.borderless)
            .font(.caption)
            
            // Page indicator
            Text("Page \(browser.currentPage) of \(browser.totalPages)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Next page button
            Button {
                browser.nextPage()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!browser.canGoToNextPage)
            .buttonStyle(.borderless)
            .font(.caption)
            
            Divider().frame(height: 12)
            
            // Page info
            Text(browser.pageInfo)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, AppTheme.spacingS)
        .padding(.vertical, AppTheme.spacingXS)
        .background(AppTheme.controlBackground.opacity(0.5))
    }

    private var statusBar: some View {
        HStack {
            Text("\(browser.files.count) items")
            if !browser.selectedFiles.isEmpty { Text("* \(browser.selectedFiles.count) selected") }
            Spacer()
        }
        .font(AppTheme.captionFont)
        .foregroundColor(AppTheme.textSecondary)
        .padding(AppTheme.spacingS)
        .background(AppTheme.controlBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(browser.files.count) items\(browser.selectedFiles.isEmpty ? "" : ", \(browser.selectedFiles.count) selected")")
    }
    
    private func createFolder() {
        guard let remote = selectedRemote else { return }
        guard !newFolderName.isEmpty else { return }
        
        // Get effective remote name based on encryption state
        let effectiveRemoteName = getEffectiveRemoteName()
        
        Task {
            do {
                let folderPath = (browser.currentPath as NSString).appendingPathComponent(newFolderName)
                
                if remote.type == .local {
                    // Create local folder
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true)
                } else {
                    // Create remote folder using rclone mkdir
                    try await RcloneManager.shared.createDirectory(
                        remoteName: effectiveRemoteName,
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
    
    /// Get the effective remote name based on encryption state
    private func getEffectiveRemoteName() -> String {
        guard let remote = selectedRemote else { return "proton" }
        if encryptTransfers && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
            return EncryptionManager.shared.getCryptRemoteName(for: remote.rcloneName)
        }
        return remote.rcloneName
    }
    
    private func downloadSelectedFiles() {
        guard let remote = selectedRemote else { return }
        let filesToDownload = browser.files.filter { browser.selectedFiles.contains($0.id) }
        guard !filesToDownload.isEmpty else { return }
        
        // Get effective remote name based on encryption state
        let effectiveRemoteName = getEffectiveRemoteName()
        
        // Show save panel
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose download location"
        panel.prompt = "Download Here"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            Task { @MainActor in
                for file in filesToDownload {
                    do {
                        if remote.type == .local {
                            // Local copy
                            let destPath = url.appendingPathComponent(file.name).path
                            try FileManager.default.copyItem(atPath: file.path, toPath: destPath)
                        } else {
                            // Cloud download via rclone - use effective remote
                            try await RcloneManager.shared.download(
                                remoteName: effectiveRemoteName,
                                remotePath: file.path,
                                localPath: url.path
                            )
                        }
                    } catch {
                        deleteError = error.localizedDescription
                        showDeleteError = true
                        return
                    }
                }
                
                browser.selectedFiles.removeAll()
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
            }
        }
    }
    
    private func deleteSelectedFiles() {
        guard let remote = selectedRemote else { return }
        let filesToDelete = browser.files.filter { browser.selectedFiles.contains($0.id) }
        guard !filesToDelete.isEmpty else { return }
        
        // Get effective remote name based on encryption state
        let effectiveRemoteName = getEffectiveRemoteName()
        
        isDeleting = true
        
        Task {
            do {
                for file in filesToDelete {
                    if remote.type == .local {
                        try FileManager.default.removeItem(atPath: file.path)
                    } else {
                        if file.isDirectory {
                            try await RcloneManager.shared.deleteFolder(
                                remoteName: effectiveRemoteName,
                                path: file.path
                            )
                        } else {
                            try await RcloneManager.shared.deleteFile(
                                remoteName: effectiveRemoteName,
                                path: file.path
                            )
                        }
                    }
                }
                
                await MainActor.run {
                    isDeleting = false
                    browser.selectedFiles.removeAll()
                    browser.refresh()
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    deleteError = error.localizedDescription
                    showDeleteError = true
                }
            }
        }
    }
    
    private func performRename() {
        guard let remote = selectedRemote, let file = renameFile else { return }
        guard !renameNewName.isEmpty, renameNewName != file.name else {
            showRenameSheet = false
            return
        }
        
        // Get effective remote name based on encryption state
        let effectiveRemoteName = getEffectiveRemoteName()
        
        Task {
            do {
                let parentPath = (file.path as NSString).deletingLastPathComponent
                let newPath = parentPath.isEmpty ? renameNewName : "\(parentPath)/\(renameNewName)"
                
                if remote.type == .local {
                    let oldURL = URL(fileURLWithPath: file.path)
                    let newURL = URL(fileURLWithPath: newPath)
                    try FileManager.default.moveItem(at: oldURL, to: newURL)
                } else {
                    try await RcloneManager.shared.renameFile(
                        remoteName: effectiveRemoteName,
                        oldPath: file.path,
                        newPath: newPath
                    )
                }
                
                await MainActor.run {
                    showRenameSheet = false
                    renameFile = nil
                    renameNewName = ""
                    browser.refresh()
                }
            } catch {
                await MainActor.run {
                    deleteError = error.localizedDescription
                    showDeleteError = true
                }
            }
        }
    }
    
    private func configurePaneEncryption(config: EncryptionConfig) async {
        do {
            // Use the selected remote for this pane
            guard let remote = selectedRemote else {
                return
            }
            
            let remoteName = remote.rcloneName
            let salt = EncryptionManager.shared.generateSecureSalt()
            
            // Create the encryption config for this remote
            let remoteConfig = RemoteEncryptionConfig(
                password: config.password,
                salt: salt,
                encryptFilenames: config.encryptFilenames,
                encryptFolders: config.encryptFolders
            )
            
            // Setup crypt remote using the new per-remote method
            try await RcloneManager.shared.setupCryptRemote(
                for: remoteName,
                config: remoteConfig
            )
            
            await MainActor.run {
                encryptTransfers = true
                EncryptionManager.shared.setEncryptionEnabled(true, for: remoteName)
                updateBrowserRemote()
            }
        } catch {
            await MainActor.run {
                encryptTransfers = false
            }
            print("[TransferPane] Encryption setup failed: \(error)")
        }
    }
    
    /// Update the browser to use the correct remote (base or crypt) based on encryption state
    private func updateBrowserRemote() {
        guard let remote = selectedRemote else { return }
        let remoteName = remote.rcloneName
        
        if encryptTransfers && EncryptionManager.shared.isEncryptionConfigured(for: remoteName) {
            // Use the crypt remote
            let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: remoteName)
            let cryptRemote = CloudRemote(
                name: remote.name,
                type: remote.type,
                isConfigured: true,
                path: "",
                isEncrypted: true,
                customRcloneName: cryptRemoteName
            )
            browser.setRemote(cryptRemote)
        } else {
            // Use the base remote
            browser.setRemote(remote)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(file.name), \(file.isDirectory ? "folder" : file.formattedSize)")
        .accessibilityHint(file.isDirectory ? "Double-tap to open folder" : "Double-tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Breadcrumb & FileRow

struct BreadcrumbBar: View {
    let components: [(name: String, path: String)]
    let onNavigate: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingXS) {
                ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Button { onNavigate(component.path) } label: {
                        Text(component.name)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(index == components.count - 1 ? AppTheme.textPrimary : AppTheme.accentColor)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(component.name)
                    .accessibilityHint("Navigate to \(component.name)")
                }
            }
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, AppTheme.spacingXS)
        }
        .background(AppTheme.controlBackground.opacity(0.5))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Breadcrumb navigation, current path: \(components.map { $0.name }.joined(separator: ", "))")
    }
}

struct FileRow: View {
    let file: FileItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: file.icon)
                .foregroundColor(file.isDirectory ? AppTheme.accentColor : AppTheme.textSecondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(file.name).lineLimit(1)
                if !file.isDirectory {
                    Text(file.formattedSize)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            Spacer()
            Text(file.formattedDate)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, AppTheme.spacingXS)
        .padding(.horizontal, AppTheme.spacingS)
        .background(isSelected ? AppTheme.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(AppTheme.cornerRadiusSmall)
        .contentShape(Rectangle())
    }
}

// MARK: - New Folder Dialog

struct NewFolderDialog: View {
    @Binding var folderName: String
    @Binding var isPresented: Bool
    let onCreate: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            HStack {
                // Icon with circular background (matching onboarding)
                ZStack {
                    Circle()
                        .fill(AppTheme.accentColor.opacity(AppTheme.iconBackgroundOpacity))
                        .frame(width: AppTheme.iconContainerLarge, height: AppTheme.iconContainerLarge)

                    Image(systemName: "folder.badge.plus")
                        .font(.title)
                        .foregroundColor(AppTheme.accentColor)
                }

                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text("Create New Folder")
                        .font(AppTheme.headlineFont)
                    Text("Enter a name for the new folder")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Create New Folder dialog")

            TextField("Folder name", text: $folderName)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onSubmit {
                    if !folderName.isEmpty {
                        onCreate()
                        isPresented = false
                    }
                }
                .accessibilityLabel("Folder name")
                .accessibilityHint("Enter a name for the new folder")

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(SecondaryButtonStyle())
                .keyboardShortcut(.cancelAction)
                .accessibilityLabel("Cancel")
                .accessibilityHint("Closes the dialog without creating a folder")

                Spacer()

                Button("Create") {
                    onCreate()
                    isPresented = false
                }
                .buttonStyle(PrimaryButtonStyle())
                .keyboardShortcut(.defaultAction)
                .disabled(folderName.isEmpty)
                .accessibilityLabel("Create Folder")
                .accessibilityHint("Creates the new folder with the entered name")
            }
        }
        .padding(AppTheme.spacingXL)
        .frame(width: 400)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    TransferView().environmentObject(RemotesViewModel.shared).environmentObject(TasksViewModel.shared).frame(width: 1000, height: 600)
}
