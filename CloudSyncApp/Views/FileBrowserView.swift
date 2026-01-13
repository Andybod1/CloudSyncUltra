//
//  FileBrowserView.swift
//  CloudSyncApp
//
//  Full-page file browser for a single remote
//

import SwiftUI
import AppKit

struct FileBrowserView: View {
    let remote: CloudRemote
    @EnvironmentObject var remotesVM: RemotesViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @StateObject private var browser = FileBrowserViewModel()
    @State private var showNewFolderSheet = false
    @State private var showDeleteConfirm = false
    @State private var showConnectSheet = false
    @State private var isDeleting = false
    @State private var deleteError: String?
    @State private var isDownloading = false
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var uploadSpeed: String = ""
    @State private var uploadCurrentFile: String = ""
    @State private var uploadFileIndex: Int = 0
    @State private var uploadTotalFiles: Int = 0
    @State private var currentUploadTask: SyncTask?
    @State private var downloadError: String?
    @State private var showDeleteError = false
    @State private var showDownloadError = false
    @State private var showRenameSheet = false
    @State private var renameFile: FileItem?
    @State private var newFileName = ""
    @State private var isRenaming = false
    @State private var renameError: String?
    @State private var showPageSizeMenu = false
    @State private var jumpToPageString = ""
    
    // MARK: - Encryption State
    /// When true: uploads are encrypted, view shows decrypted content (transparent encryption)
    /// When false: view shows raw encrypted content (gibberish filenames)
    @State private var encryptionEnabled = false
    @State private var showEncryptionModal = false
    
    // The actual remote being used for operations (may be encrypted version)
    @State private var activeRemote: CloudRemote?
    
    // Track if we're viewing raw encrypted data (only applies to cloud remotes)
    private var isViewingRawEncrypted: Bool {
        remote.type != .local && !encryptionEnabled && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName)
    }
    
    var body: some View {
        mainContent
            .background(Color(NSColor.windowBackgroundColor))
            .navigationTitle(remote.name)
            .task(id: remote.id) {
                await initializeEncryptionState()
            }
            .onChange(of: encryptionEnabled) { _, isEnabled in
                handleEncryptionToggle(isEnabled)
            }
            .modifier(AlertsModifier(
                showDeleteConfirm: $showDeleteConfirm,
                showDeleteError: $showDeleteError,
                showDownloadError: $showDownloadError,
                selectedCount: browser.selectedFiles.count,
                deleteError: deleteError,
                downloadError: downloadError,
                onDeleteConfirm: deleteSelectedFiles,
                onDeleteErrorDismiss: { deleteError = nil },
                onDownloadErrorDismiss: { downloadError = nil }
            ))
            .modifier(SheetsModifier(
                showNewFolderSheet: $showNewFolderSheet,
                showConnectSheet: $showConnectSheet,
                showRenameSheet: $showRenameSheet,
                showEncryptionModal: $showEncryptionModal,
                browser: browser,
                remote: remote,
                activeRemote: activeRemote,
                renameFile: renameFile,
                newFileName: $newFileName,
                isRenaming: $isRenaming,
                renameError: $renameError,
                performRename: performRename,
                configureEncryption: configureEncryption
            ))
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if !remote.isConfigured {
                notConnectedView
            } else {
                connectedContent
            }
        }
    }
    
    @ViewBuilder
    private var connectedContent: some View {
        browserToolbar
        
        Divider()
        
        // Show encryption status banner when viewing raw encrypted data
        if isViewingRawEncrypted {
            rawEncryptionBanner
        }
        
        BreadcrumbBar(
            components: browser.pathComponents,
            onNavigate: { browser.navigateTo($0) }
        )
        
        Divider()
        
        contentArea
        
        // Pagination Controls
        if !browser.isLoading && browser.files.count > browser.pageSize {
            Divider()
            paginationBar
        }
        
        // Running task indicator (same as Tasks view)
        if let task = runningTaskForRemote {
            Divider()
            RunningTaskIndicator(task: task) {
                tasksVM.cancelTask(task)
            }
        }
        
        Divider()
        
        statusBar
    }
    
    /// Get running task that involves this remote
    private var runningTaskForRemote: SyncTask? {
        tasksVM.tasks.first { task in
            task.state == .running && 
            (task.destinationRemote.lowercased() == remote.name.lowercased() ||
             task.sourceRemote.lowercased() == remote.name.lowercased())
        }
    }
    
    @ViewBuilder
    private var contentArea: some View {
        if browser.isLoading || isDeleting || isDownloading {
            loadingView
        } else if let error = browser.error {
            errorView(error)
        } else if browser.files.isEmpty {
            emptyView
        } else {
            fileContent
        }
    }
    
    // MARK: - Encryption Banner
    
    private var rawEncryptionBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "eye.slash")
                .foregroundColor(.orange)
            
            Text("Viewing raw encrypted data")
                .font(.caption)
                .foregroundColor(.orange)
            
            Text("•")
                .foregroundColor(.secondary)
            
            Text("Enable encryption toggle to see decrypted filenames")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Enable Decryption") {
                encryptionEnabled = true
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
    }
    
    // MARK: - Pagination Bar
    
    private var paginationBar: some View {
        HStack(spacing: 12) {
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
                    Text("\(browser.pageSize) per page")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
            }
            .menuStyle(.borderlessButton)
            .help("Items per page")
            
            Divider()
                .frame(height: 16)
            
            // First page button
            Button {
                browser.firstPage()
            } label: {
                Image(systemName: "chevron.left.2")
            }
            .disabled(!browser.canGoToPreviousPage)
            .help("First page")
            
            // Previous page button
            Button {
                browser.previousPage()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!browser.canGoToPreviousPage)
            .help("Previous page")
            .keyboardShortcut("[", modifiers: [.command])
            
            // Page indicator with jump capability
            HStack(spacing: 4) {
                Text("Page")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    TextField("", text: $jumpToPageString, prompt: Text("\(browser.currentPage)"))
                        .textFieldStyle(.plain)
                        .frame(width: 30)
                        .multilineTextAlignment(.center)
                        .font(.caption.monospacedDigit())
                        .onSubmit {
                            if let page = Int(jumpToPageString), page >= 1, page <= browser.totalPages {
                                browser.goToPage(page)
                            }
                            jumpToPageString = ""
                        }
                    
                    if jumpToPageString.isEmpty {
                        Text("\(browser.currentPage)")
                            .font(.caption.monospacedDigit())
                            .frame(width: 30)
                    }
                }
                
                Text("of \(browser.totalPages)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(4)
            
            // Next page button
            Button {
                browser.nextPage()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!browser.canGoToNextPage)
            .help("Next page")
            .keyboardShortcut("]", modifiers: [.command])
            
            // Last page button
            Button {
                browser.lastPage()
            } label: {
                Image(systemName: "chevron.right.2")
            }
            .disabled(!browser.canGoToNextPage)
            .help("Last page")
            
            Divider()
                .frame(height: 16)
            
            // Page info
            Text(browser.pageInfo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Not Connected View
    
    private var notConnectedView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(remote.displayColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: remote.displayIcon)
                    .font(.system(size: 48))
                    .foregroundColor(remote.displayColor)
            }
            
            Text(remote.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Not Connected")
                .font(.headline)
                .foregroundColor(.orange)
            
            Text("Connect your \(remote.type.displayName) account to browse files")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Connect Now") {
                showConnectSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Toolbar
    
    private var browserToolbar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Button {
                    browser.navigateUp()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(browser.currentPath.isEmpty && remote.type != .local)
                
                Button {
                    browser.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            
            Divider()
                .frame(height: 20)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search...", text: $browser.searchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: browser.searchQuery) {
                        // Reset to first page when searching
                        browser.currentPage = 1
                    }
                
                if !browser.searchQuery.isEmpty {
                    Button {
                        browser.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .frame(maxWidth: 300)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    showNewFolderSheet = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .help("New Folder")
                
                Button {
                    uploadFiles()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Upload")
                
                Button {
                    downloadSelectedFiles()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .disabled(browser.selectedFiles.isEmpty)
                .help("Download")
                
                // Only show encryption controls for cloud remotes, not local storage
                if remote.type != .local {
                    Divider()
                        .frame(height: 20)
                    
                    // Encryption toggle with enhanced visuals
                    encryptionToggle
                }
                
                Divider()
                    .frame(height: 20)
                
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(browser.selectedFiles.isEmpty)
                .help("Delete")
            }
            
            Divider()
                .frame(height: 20)
            
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
                
                Button {
                    browser.viewMode = .grid
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.bordered)
                .background(browser.viewMode == .grid ? Color.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(6)
            }
        }
        .padding()
    }
    
    // MARK: - Encryption Toggle
    
    private var encryptionToggle: some View {
        HStack(spacing: 6) {
            // Lock icon with color based on state
            Image(systemName: encryptionEnabled ? "lock.fill" : "lock.open")
                .foregroundColor(encryptionEnabled ? .green : (isViewingRawEncrypted ? .orange : .secondary))
            
            Toggle(isOn: $encryptionEnabled) {
                Text("Encrypt")
                    .font(.caption)
            }
            .toggleStyle(.switch)
            .controlSize(.small)
            
            // Configuration button (gear icon)
            if EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
                Button {
                    showEncryptionModal = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help("Encryption settings")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(encryptionEnabled ? Color.green.opacity(0.1) : (isViewingRawEncrypted ? Color.orange.opacity(0.1) : Color.clear))
        )
        .help(encryptionEnabled ? "Encryption ON - files encrypted on upload, decrypted on view" : "Encryption OFF - viewing raw encrypted data")
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            if isUploading {
                // Enhanced upload progress bar (similar to TransferView)
                uploadProgressBar
            } else {
                // Show generic spinner
                ProgressView()
                Text(isDownloading ? "Downloading..." : (isDeleting ? "Deleting..." : "Loading..."))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var uploadProgressBar: some View {
        HStack(spacing: 12) {
            // Spinning indicator
            ProgressView()
                .scaleEffect(0.8)
            
            // Status text
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Uploading to \(remote.name)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if encryptionEnabled {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                HStack(spacing: 6) {
                    if uploadTotalFiles > 1 {
                        Text("\(uploadFileIndex)/\(uploadTotalFiles)")
                    }
                    if !uploadCurrentFile.isEmpty {
                        Text(uploadCurrentFile)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Text("•")
                    Text("\(Int(uploadProgress))%")
                        .foregroundColor(.accentColor)
                    if !uploadSpeed.isEmpty {
                        Text("•")
                        Text(uploadSpeed)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // View in Tasks button
            Button {
                NotificationCenter.default.post(name: .navigateToTasks, object: nil)
            } label: {
                Text("View in Tasks")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            
            // Cancel button
            Button {
                cancelUpload()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Cancel upload")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.accentColor.opacity(0.08))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func cancelUpload() {
        RcloneManager.shared.stopCurrentSync()
        
        // Cancel the task in TasksViewModel
        if var task = currentUploadTask {
            task.state = .cancelled
            task.completedAt = Date()
            tasksVM.updateTask(task)
            tasksVM.moveToHistory(task)
        }
        
        isUploading = false
        uploadProgress = 0
        uploadSpeed = ""
        uploadCurrentFile = ""
        uploadFileIndex = 0
        uploadTotalFiles = 0
        currentUploadTask = nil
    }
    
    private var uploadStatusColor: Color {
        if uploadProgress >= 100 {
            return .green
        }
        return encryptionEnabled ? .green : .accentColor
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error Loading Files")
                .font(.headline)
            
            Text(error)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                browser.refresh()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Empty Folder")
                .font(.headline)
            
            Text("This folder doesn't contain any files")
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button("New Folder") {
                    showNewFolderSheet = true
                }
                .buttonStyle(.bordered)
                
                Button("Upload Files") {
                    uploadFiles()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var fileContent: some View {
        switch browser.viewMode {
        case .list:
            listView
        case .grid:
            gridView
        }
    }
    
    private var listView: some View {
        Table(browser.paginatedFiles, selection: $browser.selectedFiles) {
            TableColumn("Name") { file in
                HStack(spacing: 8) {
                    Image(systemName: file.icon)
                        .foregroundColor(file.isDirectory ? .accentColor : .secondary)
                        .frame(width: 20)
                    
                    Text(file.name)
                        .lineLimit(1)
                    
                    // Show encrypted indicator for gibberish-looking names
                    if isViewingRawEncrypted && looksEncrypted(file.name) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .width(min: 200)
            
            TableColumn("Size") { file in
                Text(file.formattedSize)
                    .foregroundColor(.secondary)
            }
            .width(80)
            
            TableColumn("Modified") { file in
                Text(file.formattedDate)
                    .foregroundColor(.secondary)
            }
            .width(150)
        }
        .tableStyle(.inset)
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
                            newFileName = file.name
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
                    showNewFolderSheet = true
                }
                Button("Upload Files") {
                    uploadFiles()
                }
                Divider()
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
    }
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
            ], spacing: 16) {
                ForEach(browser.paginatedFiles) { file in
                    FileGridItem(
                        file: file,
                        isSelected: browser.selectedFiles.contains(file.id),
                        showEncryptedIndicator: isViewingRawEncrypted && looksEncrypted(file.name)
                    )
                    .onTapGesture {
                        browser.toggleSelection(file)
                    }
                    .onTapGesture(count: 2) {
                        browser.navigateToFile(file)
                    }
                    .contextMenu {
                        Button("Open") {
                            browser.navigateToFile(file)
                        }
                        Divider()
                        Button("Rename") {
                            renameFile = file
                            newFileName = file.name
                            showRenameSheet = true
                        }
                        Button("Download") {
                            browser.selectedFiles.removeAll()
                            browser.selectedFiles.insert(file.id)
                            downloadSelectedFiles()
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            browser.selectedFiles.removeAll()
                            browser.selectedFiles.insert(file.id)
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .padding()
        }
        .contextMenu {
            // Context menu for empty space in grid view
            Button("New Folder") {
                showNewFolderSheet = true
            }
            Button("Upload Files") {
                uploadFiles()
            }
            Divider()
            Button("Refresh") {
                browser.refresh()
            }
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBar: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: remote.displayIcon)
                    .foregroundColor(remote.displayColor)
                Text(remote.name)
            }
            .font(.caption)
            
            // Encryption status in status bar (only for cloud remotes, not local storage)
            if remote.type != .local {
                if encryptionEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                        Text("Encrypted")
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                } else if isViewingRawEncrypted {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.slash")
                        Text("Raw View")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
            
            Divider()
                .frame(height: 12)
            
            Text("\(browser.files.count) items")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !browser.selectedFiles.isEmpty {
                Text("• \(browser.selectedFiles.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Selection controls for pagination
            if browser.isPaginationEnabled && browser.files.count > browser.pageSize {
                HStack(spacing: 8) {
                    Button("Select Page") {
                        browser.selectAll()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .help("Select all items on current page")
                    
                    Button("Select All (\(browser.files.count))") {
                        browser.selectAllInDirectory()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .help("Select all items in directory")
                }
                
                Divider()
                    .frame(height: 12)
            }
            
            Menu {
                ForEach(FileBrowserViewModel.SortOrder.allCases, id: \.self) { order in
                    Button {
                        browser.sortOrder = order
                        browser.sortFiles()
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if browser.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Sort: \(browser.sortOrder.rawValue)")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Helper Functions
    
    /// Check if a filename looks like it's encrypted (base64-like gibberish)
    private func looksEncrypted(_ name: String) -> Bool {
        // Encrypted filenames from rclone crypt are typically long base64-like strings
        let baseName = (name as NSString).deletingPathExtension
        guard baseName.count > 20 else { return false }
        
        // Check if it contains mostly alphanumeric and looks like base64
        let alphanumericCount = baseName.filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }.count
        return Double(alphanumericCount) / Double(baseName.count) > 0.9
    }
    
    // MARK: - Encryption State Management
    
    private func initializeEncryptionState() async {
        guard remote.isConfigured else { return }
        
        // Check if encryption is enabled for this remote
        let isEnabled = EncryptionManager.shared.isEncryptionEnabled(for: remote.rcloneName)
        encryptionEnabled = isEnabled
        
        // Set the active remote based on encryption state
        updateActiveRemote(encryptionEnabled: isEnabled)
        
        // Load files with the correct remote
        browser.setRemote(activeRemote ?? remote)
    }
    
    private func handleEncryptionToggle(_ isEnabled: Bool) {
        // If enabling encryption but not configured, show setup modal
        if isEnabled && !EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
            showEncryptionModal = true
            // Reset to false until configured
            encryptionEnabled = false
            return
        }
        
        // Update the active remote
        updateActiveRemote(encryptionEnabled: isEnabled)
        
        // Save the encryption state for this remote
        EncryptionManager.shared.setEncryptionEnabled(isEnabled, for: remote.rcloneName)
        
        // Refresh the browser with the new remote
        if let newRemote = activeRemote {
            browser.setRemote(newRemote)
        }
    }
    
    private func updateActiveRemote(encryptionEnabled: Bool) {
        if encryptionEnabled && EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
            // Use the crypt remote (shows decrypted view)
            let cryptRemoteName = EncryptionManager.shared.getCryptRemoteName(for: remote.rcloneName)
            activeRemote = CloudRemote(
                name: remote.name,
                type: remote.type,
                isConfigured: true,
                path: "",
                isEncrypted: true,
                customRcloneName: cryptRemoteName
            )
        } else {
            // Use the base remote (shows raw encrypted data if encryption was configured)
            activeRemote = remote
        }
    }
    
    // MARK: - Actions
    
    private func downloadSelectedFiles() {
        let filesToDownload = browser.files.filter { browser.selectedFiles.contains($0.id) }
        guard !filesToDownload.isEmpty else { return }
        
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
                isDownloading = true
                
                do {
                    let targetRemote = activeRemote ?? remote
                    
                    for file in filesToDownload {
                        if remote.type == .local {
                            // Local copy
                            let destPath = url.appendingPathComponent(file.name).path
                            try FileManager.default.copyItem(atPath: file.path, toPath: destPath)
                        } else {
                            // Cloud download via rclone
                            try await RcloneManager.shared.download(
                                remoteName: targetRemote.rcloneName,
                                remotePath: file.path,
                                localPath: url.path
                            )
                        }
                    }
                    
                    isDownloading = false
                    browser.selectedFiles.removeAll()
                    
                    // Open Finder at download location
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                } catch {
                    isDownloading = false
                    downloadError = error.localizedDescription
                    showDownloadError = true
                }
            }
        }
    }
    
    private func uploadFiles() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.message = "Choose files to upload"
        panel.prompt = "Upload"
        
        let logPath = "/tmp/cloudsync_upload_debug.log"
        let log = { (msg: String) in
            let timestamp = Date().description
            let line = "\(timestamp): \(msg)\n"
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
        
        log("Opening file picker for upload")
        
        panel.begin { response in
            log("File picker response: \(response.rawValue)")
            guard response == .OK, !panel.urls.isEmpty else { 
                log("File picker cancelled or no files selected")
                return 
            }
            
            log("Selected \(panel.urls.count) files for upload")
            
            Task { @MainActor in
                isUploading = true
                uploadProgress = 0
                uploadSpeed = ""
                uploadTotalFiles = panel.urls.count
                uploadFileIndex = 0
                
                log("Starting upload task, isUploading=true, encryptionEnabled=\(encryptionEnabled)")
                
                // Create a task in TasksViewModel
                let taskName = panel.urls.count == 1 ? panel.urls[0].lastPathComponent : "\(panel.urls.count) items"
                var task = tasksVM.createTask(
                    name: taskName,
                    type: .transfer,
                    sourceRemote: "Local",
                    sourcePath: panel.urls[0].deletingLastPathComponent().path,
                    destinationRemote: remote.name,
                    destinationPath: browser.currentPath
                )
                task.totalFiles = panel.urls.count
                task.startedAt = Date()
                task.state = .running
                task.encryptDestination = encryptionEnabled
                tasksVM.updateTask(task)
                currentUploadTask = task
                
                do {
                    // Use the active remote (encrypted or regular)
                    let targetRemote = activeRemote ?? remote
                    log("Target remote: \(targetRemote.rcloneName)")
                    
                    for (index, url) in panel.urls.enumerated() {
                        uploadFileIndex = index + 1
                        uploadCurrentFile = url.lastPathComponent
                        uploadProgress = 0
                        
                        // Update task progress
                        task.filesTransferred = index
                        tasksVM.updateTask(task)
                        
                        log("Processing file \(uploadFileIndex)/\(uploadTotalFiles): \(url.path)")
                        
                        // Check if this is a directory
                        var isDirectory: ObjCBool = false
                        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                        
                        log("Is directory: \(isDirectory.boolValue)")
                        
                        if remote.type == .local {
                            // Local copy
                            let destPath = (browser.currentPath as NSString).appendingPathComponent(url.lastPathComponent)
                            try FileManager.default.copyItem(atPath: url.path, toPath: destPath)
                        } else {
                            // Cloud upload via rclone with progress
                            // For directories, append folder name to destination to preserve structure
                            var destPath = browser.currentPath
                            if isDirectory.boolValue {
                                destPath = (destPath as NSString).appendingPathComponent(url.lastPathComponent)
                                log("Directory detected - uploading to: \(destPath)")
                            }
                            
                            log("Starting cloud upload to \(targetRemote.rcloneName):\(destPath)")
                            
                            let progressStream = try await RcloneManager.shared.uploadWithProgress(
                                localPath: url.path,
                                remoteName: targetRemote.rcloneName,
                                remotePath: destPath
                            )
                            
                            log("Got progress stream, starting iteration")
                            
                            for try await progress in progressStream {
                                let speedStr = String(format: "%.2f MB/s", progress.speed)
                                log("Progress update: \(progress.percentage)% - \(speedStr)")
                                uploadProgress = progress.percentage
                                uploadSpeed = speedStr
                                
                                // Update task progress
                                task.progress = Double(index) / Double(panel.urls.count) + (progress.percentage / 100.0) / Double(panel.urls.count)
                                task.speed = speedStr
                                tasksVM.updateTask(task)
                            }
                            
                            log("Progress stream completed")
                        }
                    }
                    
                    // Mark task complete
                    task.state = .completed
                    task.completedAt = Date()
                    task.progress = 1.0
                    task.filesTransferred = panel.urls.count
                    tasksVM.updateTask(task)
                    tasksVM.moveToHistory(task)
                    
                    isUploading = false
                    uploadProgress = 0
                    uploadSpeed = ""
                    uploadCurrentFile = ""
                    uploadFileIndex = 0
                    uploadTotalFiles = 0
                    currentUploadTask = nil
                    browser.refresh()
                } catch {
                    // Mark task failed
                    task.state = .failed
                    task.completedAt = Date()
                    task.errorMessage = error.localizedDescription
                    tasksVM.updateTask(task)
                    tasksVM.moveToHistory(task)
                    
                    isUploading = false
                    uploadProgress = 0
                    uploadSpeed = ""
                    uploadCurrentFile = ""
                    uploadFileIndex = 0
                    uploadTotalFiles = 0
                    currentUploadTask = nil
                    downloadError = error.localizedDescription
                    showDownloadError = true
                }
            }
        }
    }
    
    private func deleteSelectedFiles() {
        let filesToDelete = browser.files.filter { browser.selectedFiles.contains($0.id) }
        guard !filesToDelete.isEmpty else { return }
        
        isDeleting = true
        
        Task {
            do {
                let targetRemote = activeRemote ?? remote
                
                for file in filesToDelete {
                    if remote.type == .local {
                        try FileManager.default.removeItem(atPath: file.path)
                    } else {
                        if file.isDirectory {
                            try await RcloneManager.shared.deleteFolder(
                                remoteName: targetRemote.rcloneName,
                                path: file.path
                            )
                        } else {
                            try await RcloneManager.shared.deleteFile(
                                remoteName: targetRemote.rcloneName,
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
        guard let file = renameFile, !newFileName.isEmpty, newFileName != file.name else {
            showRenameSheet = false
            return
        }
        
        isRenaming = true
        
        Task {
            do {
                let targetRemote = activeRemote ?? remote
                
                // Calculate the new path
                let parentPath = (file.path as NSString).deletingLastPathComponent
                let newPath = parentPath.isEmpty ? newFileName : "\(parentPath)/\(newFileName)"
                
                try await RcloneManager.shared.renameFile(
                    remoteName: targetRemote.rcloneName,
                    oldPath: file.path,
                    newPath: newPath
                )
                
                await MainActor.run {
                    isRenaming = false
                    showRenameSheet = false
                    renameFile = nil
                    newFileName = ""
                    browser.refresh()
                }
            } catch {
                await MainActor.run {
                    isRenaming = false
                    renameError = error.localizedDescription
                }
            }
        }
    }
    
    private func configureEncryption(config: EncryptionConfig) async {
        do {
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
                // Now that encryption is configured, enable it
                encryptionEnabled = true
                EncryptionManager.shared.setEncryptionEnabled(true, for: remoteName)
                updateActiveRemote(encryptionEnabled: true)
                browser.setRemote(activeRemote ?? remote)
            }
        } catch {
            await MainActor.run {
                encryptionEnabled = false
            }
            print("[FileBrowserView] Encryption setup failed: \(error)")
        }
    }
}

// MARK: - Grid Item

struct FileGridItem: View {
    let file: FileItem
    let isSelected: Bool
    var showEncryptedIndicator: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                    .frame(width: 80, height: 80)
                
                Image(systemName: file.icon)
                    .font(.system(size: 32))
                    .foregroundColor(file.isDirectory ? .accentColor : .secondary)
                
                // Encrypted indicator overlay
                if showEncryptedIndicator {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(4)
                                .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                    .frame(width: 80, height: 80)
                    .padding(4)
                }
            }
            
            Text(file.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - New Folder Sheet

struct NewFolderSheet: View {
    @ObservedObject var browser: FileBrowserViewModel
    let remote: CloudRemote
    @Environment(\.dismiss) private var dismiss
    @State private var folderName = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Folder")
                .font(.headline)
            
            TextField("Folder Name", text: $folderName)
                .textFieldStyle(.roundedBorder)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                if isCreating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                Button("Create") {
                    createFolder()
                }
                .buttonStyle(.borderedProminent)
                .disabled(folderName.isEmpty || isCreating)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    private func createFolder() {
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                let newPath: String
                if browser.currentPath.isEmpty {
                    newPath = folderName
                } else {
                    newPath = (browser.currentPath as NSString).appendingPathComponent(folderName)
                }
                
                if remote.type == .local {
                    try FileManager.default.createDirectory(
                        atPath: newPath,
                        withIntermediateDirectories: true
                    )
                } else {
                    try await RcloneManager.shared.createFolder(
                        remoteName: remote.rcloneName,
                        path: newPath
                    )
                }
                
                await MainActor.run {
                    dismiss()
                    browser.refresh()
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Rename File Sheet

struct RenameFileSheet: View {
    let file: FileItem?
    @Binding var newName: String
    @Binding var isRenaming: Bool
    @Binding var error: String?
    let onRename: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: file?.isDirectory == true ? "folder.fill" : "doc.fill")
                    .foregroundColor(.accentColor)
                    .font(.title2)
                Text("Rename")
                    .font(.headline)
            }
            
            TextField("New name", text: $newName)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if !isRenaming && !newName.isEmpty {
                        onRename()
                    }
                }
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Rename") {
                    onRename()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newName.isEmpty || newName == file?.name || isRenaming)
                .keyboardShortcut(.return)
            }
            
            if isRenaming {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - View Modifiers for Type Checking

private struct AlertsModifier: ViewModifier {
    @Binding var showDeleteConfirm: Bool
    @Binding var showDeleteError: Bool
    @Binding var showDownloadError: Bool
    let selectedCount: Int
    let deleteError: String?
    let downloadError: String?
    let onDeleteConfirm: () -> Void
    let onDeleteErrorDismiss: () -> Void
    let onDownloadErrorDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Delete Files?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDeleteConfirm()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedCount) item(s)? This cannot be undone.")
            }
            .alert("Delete Error", isPresented: $showDeleteError) {
                Button("OK") {
                    onDeleteErrorDismiss()
                }
            } message: {
                Text(deleteError ?? "Unknown error")
            }
            .alert("Download Error", isPresented: $showDownloadError) {
                Button("OK") {
                    onDownloadErrorDismiss()
                }
            } message: {
                Text(downloadError ?? "Unknown error")
            }
    }
}

private struct SheetsModifier: ViewModifier {
    @Binding var showNewFolderSheet: Bool
    @Binding var showConnectSheet: Bool
    @Binding var showRenameSheet: Bool
    @Binding var showEncryptionModal: Bool
    let browser: FileBrowserViewModel
    let remote: CloudRemote
    let activeRemote: CloudRemote?
    let renameFile: FileItem?
    @Binding var newFileName: String
    @Binding var isRenaming: Bool
    @Binding var renameError: String?
    let performRename: () -> Void
    let configureEncryption: (EncryptionConfig) async -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showNewFolderSheet) {
                NewFolderSheet(browser: browser, remote: activeRemote ?? remote)
            }
            .sheet(isPresented: $showConnectSheet) {
                ConnectRemoteSheet(remote: remote)
            }
            .sheet(isPresented: $showRenameSheet) {
                RenameFileSheet(
                    file: renameFile,
                    newName: $newFileName,
                    isRenaming: $isRenaming,
                    error: $renameError,
                    onRename: { performRename() },
                    onCancel: { showRenameSheet = false }
                )
            }
            .sheet(isPresented: $showEncryptionModal) {
                EncryptionModal { config in
                    Task {
                        await configureEncryption(config)
                    }
                }
            }
    }
}

#Preview {
    FileBrowserView(
        remote: CloudRemote(name: "Local", type: .local, isConfigured: true, path: NSHomeDirectory())
    )
    .environmentObject(RemotesViewModel.shared)
    .frame(width: 900, height: 600)
}
