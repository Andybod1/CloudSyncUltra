//
//  FileBrowserView.swift
//  CloudSyncApp
//
//  Full-page file browser for a single remote
//  Styled to match onboarding experience with AppTheme design tokens
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
            .background(AppTheme.windowBackground)
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
        
        // Pagination Controls (only when lazy loading is disabled)
        if !browser.isLoading && !browser.useLazyLoading && browser.files.count > browser.pageSize {
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
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: "eye.slash")
                .foregroundColor(AppTheme.warningColor)

            Text("Viewing raw encrypted data")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.warningColor)

            Text("*")
                .foregroundColor(AppTheme.textSecondary)

            Text("Enable encryption toggle to see decrypted filenames")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)

            Spacer()

            Button("Enable Encryption") {
                encryptionEnabled = true
            }
            .font(AppTheme.captionFont)
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityLabel("Enable Encryption")
            .accessibilityHint("Enables encryption to protect your files")
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.vertical, AppTheme.spacingXS)
        .background(AppTheme.warningColor.opacity(0.1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Raw encrypted data warning. Enable decryption to see readable filenames.")
    }
    
    // MARK: - Pagination Bar

    private var paginationBar: some View {
        HStack(spacing: AppTheme.spacingM) {
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
                HStack(spacing: AppTheme.spacingXS) {
                    Text("\(browser.pageSize) per page")
                    Image(systemName: "chevron.down")
                }
                .font(AppTheme.captionFont)
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
            .accessibilityLabel("First Page")
            .accessibilityHint("Jump to the first page of files")

            // Previous page button
            Button {
                browser.previousPage()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!browser.canGoToPreviousPage)
            .help("Previous page")
            .keyboardShortcut("[", modifiers: [.command])
            .accessibilityLabel("Previous Page")
            .accessibilityHint("Go to the previous page of files")

            // Page indicator with jump capability
            HStack(spacing: AppTheme.spacingXS) {
                Text("Page")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)

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
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, AppTheme.spacingS)
            .padding(.vertical, AppTheme.spacingXS)
            .background(AppTheme.controlBackground.opacity(0.5))
            .cornerRadius(AppTheme.cornerRadiusSmall)

            // Next page button
            Button {
                browser.nextPage()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!browser.canGoToNextPage)
            .help("Next page")
            .keyboardShortcut("]", modifiers: [.command])
            .accessibilityLabel("Next Page")
            .accessibilityHint("Go to the next page of files")

            // Last page button
            Button {
                browser.lastPage()
            } label: {
                Image(systemName: "chevron.right.2")
            }
            .disabled(!browser.canGoToNextPage)
            .help("Last page")
            .accessibilityLabel("Last Page")
            .accessibilityHint("Jump to the last page of files")

            Divider()
                .frame(height: 16)

            // Page info
            Text(browser.pageInfo)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.vertical, AppTheme.spacingS)
        .background(AppTheme.controlBackground.opacity(0.5))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pagination: Page \(browser.currentPage) of \(browser.totalPages)")
    }

    // MARK: - Not Connected View

    private var notConnectedView: some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            // Icon with circular background (matching onboarding)
            ZStack {
                Circle()
                    .fill(remote.displayColor.opacity(AppTheme.iconBackgroundOpacity))
                    .frame(width: AppTheme.iconContainerLarge * 1.5, height: AppTheme.iconContainerLarge * 1.5)

                Image(systemName: remote.displayIcon)
                    .font(.system(size: 48))
                    .foregroundColor(remote.displayColor)
            }

            Text(remote.name)
                .font(AppTheme.title2Font)

            Text("Not Connected")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.warningColor)

            Text("Connect your \(remote.type.displayName) account to browse files")
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Connect Now") {
                showConnectSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel("Connect Now")
            .accessibilityHint("Opens setup to connect your cloud storage account")

            Spacer()
        }
        .padding(AppTheme.spacing)
    }
    
    // MARK: - Toolbar

    private var browserToolbar: some View {
        HStack(spacing: AppTheme.spacingM) {
            HStack(spacing: AppTheme.spacingXS) {
                Button {
                    browser.navigateUp()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(browser.currentPath.isEmpty && remote.type != .local)
                .accessibilityLabel("Go Back")
                .accessibilityHint("Navigate to parent folder")
                .keyboardShortcut(.leftArrow, modifiers: .command)

                Button {
                    browser.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh")
                .accessibilityHint("Refreshes the current folder contents")
                .keyboardShortcut("r", modifiers: .command)
            }

            Divider()
                .frame(height: 20)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.textSecondary)
                TextField("Search...", text: $browser.searchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: browser.searchQuery) {
                        // Reset pagination and lazy loading when searching
                        browser.onSearchQueryChanged()
                    }
                    .accessibilityLabel("Search Files")
                    .accessibilityHint("Type to filter files in the current folder")

                if !browser.searchQuery.isEmpty {
                    Button {
                        browser.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.spacingXS)
            .background(AppTheme.controlBackground)
            .cornerRadius(AppTheme.cornerRadiusSmall)
            .frame(maxWidth: 300)
            
            Spacer()

            HStack(spacing: AppTheme.spacingS) {
                Button {
                    showNewFolderSheet = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .help("New Folder")
                .accessibilityLabel("New Folder")
                .accessibilityHint("Creates a new folder in the current location")
                .keyboardShortcut("n", modifiers: [.command, .shift])

                Button {
                    uploadFiles()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Upload")
                .accessibilityLabel("Upload Files")
                .accessibilityHint("Opens a file picker to select files for upload")
                .keyboardShortcut("u", modifiers: .command)

                Button {
                    downloadSelectedFiles()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .disabled(browser.selectedFiles.isEmpty)
                .help("Download")
                .accessibilityLabel("Download Selected")
                .accessibilityHint("Downloads selected files to your computer")
                .keyboardShortcut("d", modifiers: .command)

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
                .accessibilityLabel("Delete Selected")
                .accessibilityHint("Deletes selected files permanently")
                .keyboardShortcut(.delete, modifiers: .command)
            }

            Divider()
                .frame(height: 20)

            VStack(spacing: AppTheme.spacingXS) {
                Button {
                    browser.viewMode = .list
                } label: {
                    Image(systemName: "list.bullet")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.bordered)
                .background(browser.viewMode == .list ? AppTheme.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(AppTheme.cornerRadiusSmall)
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
                .background(browser.viewMode == .grid ? AppTheme.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(AppTheme.cornerRadiusSmall)
                .accessibilityLabel("Grid View")
                .accessibilityHint("Display files as a grid")
                .accessibilityValue(browser.viewMode == .grid ? "Selected" : "")
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("View Mode")
        }
        .padding(AppTheme.spacing)
    }
    
    // MARK: - Encryption Toggle

    private var encryptionToggle: some View {
        HStack(spacing: AppTheme.spacingXS) {
            // Lock icon with color based on state
            Image(systemName: encryptionEnabled ? "lock.fill" : "lock.open")
                .foregroundColor(encryptionEnabled ? AppTheme.encryptionColor : (isViewingRawEncrypted ? AppTheme.warningColor : AppTheme.textSecondary))

            Toggle(isOn: $encryptionEnabled) {
                Text("Encrypt")
                    .font(AppTheme.captionFont)
            }
            .toggleStyle(.switch)
            .controlSize(.small)
            .accessibilityLabel("Encryption")
            .accessibilityValue(encryptionEnabled ? "Enabled" : "Disabled")
            .accessibilityHint("Toggle to enable or disable end-to-end encryption")

            // Configuration button (gear icon)
            if EncryptionManager.shared.isEncryptionConfigured(for: remote.rcloneName) {
                Button {
                    showEncryptionModal = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(AppTheme.captionFont)
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.textSecondary)
                .help("Encryption settings")
            }
        }
        .padding(.horizontal, AppTheme.spacingS)
        .padding(.vertical, AppTheme.spacingXS)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(encryptionEnabled ? AppTheme.encryptionColor.opacity(0.1) : (isViewingRawEncrypted ? AppTheme.warningColor.opacity(0.1) : Color.clear))
        )
        .help(encryptionEnabled ? "Encryption ON - files encrypted on upload, decrypted on view" : "Encryption OFF - viewing raw encrypted data")
    }
    
    // MARK: - Content Views

    private var loadingView: some View {
        VStack(spacing: AppTheme.spacing) {
            Spacer()

            if isUploading {
                // Enhanced upload progress bar (similar to TransferView)
                uploadProgressBar
            } else {
                // Show generic spinner with circular background (matching onboarding)
                ZStack {
                    Circle()
                        .fill(AppTheme.accentColor.opacity(AppTheme.iconBackgroundOpacity))
                        .frame(width: AppTheme.iconContainerMedium, height: AppTheme.iconContainerMedium)
                    ProgressView()
                }
                Text(isDownloading ? "Downloading..." : (isDeleting ? "Deleting..." : "Loading..."))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()
        }
    }
    
    private var uploadProgressBar: some View {
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
                HStack(spacing: AppTheme.spacingXS) {
                    Text("Uploading to \(remote.name)")
                        .font(AppTheme.subheadlineFont)

                    if encryptionEnabled {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(AppTheme.encryptionColor)
                    }
                }

                HStack(spacing: AppTheme.spacingXS) {
                    if uploadTotalFiles > 1 {
                        Text("\(uploadFileIndex)/\(uploadTotalFiles)")
                    }
                    if !uploadCurrentFile.isEmpty {
                        Text(uploadCurrentFile)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Text("*")
                    Text("\(Int(uploadProgress))%")
                        .foregroundColor(AppTheme.accentColor)
                    if !uploadSpeed.isEmpty {
                        Text("*")
                        Text(uploadSpeed)
                    }
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // View in Tasks button
            Button {
                NotificationCenter.default.post(name: .navigateToTasks, object: nil)
            } label: {
                Text("View in Tasks")
                    .font(AppTheme.captionFont)
            }
            .buttonStyle(SecondaryButtonStyle())

            // Cancel button
            Button {
                cancelUpload()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .help("Cancel upload")
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.vertical, AppTheme.spacingM)
        .background(AppTheme.accentColor.opacity(0.08))
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, AppTheme.spacing)
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
        VStack(spacing: AppTheme.spacing) {
            Spacer()

            // Icon with circular background (matching onboarding)
            ZStack {
                Circle()
                    .fill(AppTheme.errorColor.opacity(AppTheme.iconBackgroundOpacity))
                    .frame(width: AppTheme.iconContainerLarge * 1.5, height: AppTheme.iconContainerLarge * 1.5)

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.errorColor)
            }

            Text("Error Loading Files")
                .font(AppTheme.headlineFont)

            Text(error)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                browser.refresh()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel("Retry")
            .accessibilityHint("Try loading the files again")

            Spacer()
        }
        .padding(AppTheme.spacing)
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.spacing) {
            Spacer()

            // Icon with circular background (matching onboarding)
            ZStack {
                Circle()
                    .fill(AppTheme.textSecondary.opacity(AppTheme.iconBackgroundOpacity))
                    .frame(width: AppTheme.iconContainerLarge * 1.5, height: AppTheme.iconContainerLarge * 1.5)

                Image(systemName: "folder")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.5))
            }

            Text("Empty Folder")
                .font(AppTheme.headlineFont)

            Text("This folder doesn't contain any files")
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: AppTheme.spacing) {
                Button("New Folder") {
                    showNewFolderSheet = true
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityLabel("New Folder")
                .accessibilityHint("Creates a new folder in the current location")

                Button("Upload Files") {
                    uploadFiles()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityLabel("Upload Files")
                .accessibilityHint("Opens a file picker to select files for upload")
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header row
                HStack(spacing: 0) {
                    Text("Name")
                        .fontWeight(.medium)
                        .frame(minWidth: 200, alignment: .leading)
                    Spacer()
                    Text("Size")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .trailing)
                    Text("Modified")
                        .fontWeight(.medium)
                        .frame(width: 150, alignment: .trailing)
                        .padding(.trailing, AppTheme.spacingS)
                }
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingXS)
                .background(AppTheme.controlBackground.opacity(0.5))

                Divider()

                // File rows with lazy loading
                ForEach(browser.lazyScrollFiles) { file in
                    FileListRow(
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
                    .onAppear {
                        // Trigger lazy loading when approaching end of list
                        browser.loadMoreIfNeeded(currentFile: file)
                    }

                    Divider()
                        .padding(.leading, 40)
                }

                // Loading indicator for infinite scroll
                if browser.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more files...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                    .padding(AppTheme.spacing)
                }

                // Load more button (optional fallback)
                if browser.hasMoreFilesToLoad && !browser.isLoadingMore {
                    HStack {
                        Spacer()
                        Button {
                            browser.loadMoreFiles()
                        } label: {
                            HStack(spacing: AppTheme.spacingXS) {
                                Image(systemName: "arrow.down.circle")
                                Text("Load More (\(browser.totalFileCount - browser.displayedFileCount) remaining)")
                            }
                            .font(AppTheme.captionFont)
                        }
                        .buttonStyle(.link)
                        Spacer()
                    }
                    .padding(AppTheme.spacing)
                }
            }
        }
        .contextMenu {
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
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 120), spacing: AppTheme.spacing)
            ], spacing: AppTheme.spacing) {
                ForEach(browser.lazyScrollFiles) { file in
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
                    .onAppear {
                        // Trigger lazy loading when approaching end of grid
                        browser.loadMoreIfNeeded(currentFile: file)
                    }
                }
            }
            .padding(AppTheme.spacing)

            // Loading indicator for infinite scroll
            if browser.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more files...")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
                .padding(AppTheme.spacing)
            }

            // Load more button (optional fallback)
            if browser.hasMoreFilesToLoad && !browser.isLoadingMore {
                HStack {
                    Spacer()
                    Button {
                        browser.loadMoreFiles()
                    } label: {
                        HStack(spacing: AppTheme.spacingXS) {
                            Image(systemName: "arrow.down.circle")
                            Text("Load More (\(browser.totalFileCount - browser.displayedFileCount) remaining)")
                        }
                        .font(AppTheme.captionFont)
                    }
                    .buttonStyle(.link)
                    Spacer()
                }
                .padding(.bottom, AppTheme.spacing)
            }
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
            HStack(spacing: AppTheme.spacingXS) {
                Image(systemName: remote.displayIcon)
                    .foregroundColor(remote.displayColor)
                Text(remote.name)
            }
            .font(AppTheme.captionFont)

            // Encryption status in status bar (only for cloud remotes, not local storage)
            if remote.type != .local {
                if encryptionEnabled {
                    HStack(spacing: AppTheme.spacingXS) {
                        Image(systemName: "lock.fill")
                        Text("Encrypted")
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.encryptionColor)
                } else if isViewingRawEncrypted {
                    HStack(spacing: AppTheme.spacingXS) {
                        Image(systemName: "eye.slash")
                        Text("Raw View")
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.warningColor)
                }
            }

            Divider()
                .frame(height: 12)

            // Show displayed vs total count for lazy loading
            if browser.useLazyLoading && browser.totalFileCount > browser.displayedFileCount {
                Text("\(browser.displayedFileCount) of \(browser.totalFileCount) items")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                Text("\(browser.files.count) items")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }

            if !browser.selectedFiles.isEmpty {
                Text(" | \(browser.selectedFiles.count) selected")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            // Selection controls for pagination
            if browser.isPaginationEnabled && browser.files.count > browser.pageSize {
                HStack(spacing: AppTheme.spacingS) {
                    Button("Select Page") {
                        browser.selectAll()
                    }
                    .buttonStyle(.borderless)
                    .font(AppTheme.captionFont)
                    .help("Select all items on current page")

                    Button("Select All (\(browser.files.count))") {
                        browser.selectAllInDirectory()
                    }
                    .buttonStyle(.borderless)
                    .font(AppTheme.captionFont)
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
                HStack(spacing: AppTheme.spacingXS) {
                    Text("Sort: \(browser.sortOrder.rawValue)")
                    Image(systemName: "chevron.down")
                }
                .font(AppTheme.captionFont)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.horizontal, AppTheme.spacing)
        .padding(.vertical, AppTheme.spacingS)
        .background(AppTheme.controlBackground)
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
        
        // Use secure debug logging instead of world-readable /tmp
        let log = SecurityManager.createSecureDebugLogger(filename: "upload_debug.log") ?? { msg in
            print("[Upload Debug] \(msg)")
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

// MARK: - List Row Item (for LazyVStack)

struct FileListRow: View {
    let file: FileItem
    let isSelected: Bool
    var showEncryptedIndicator: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: file.icon)
                    .foregroundColor(file.isDirectory ? .accentColor : .secondary)
                    .frame(width: 20)

                Text(file.name)
                    .lineLimit(1)

                // Show encrypted indicator for gibberish-looking names
                if showEncryptedIndicator {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .frame(minWidth: 200, alignment: .leading)

            Spacer()

            Text(file.formattedSize)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .trailing)

            Text(file.formattedDate)
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .trailing)
                .padding(.trailing, 8)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(file.name), \(file.isDirectory ? "folder" : file.formattedSize)")
        .accessibilityHint(file.isDirectory ? "Double-tap to open folder" : "Double-tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(file.name), \(file.isDirectory ? "folder" : file.formattedSize)")
        .accessibilityHint(file.isDirectory ? "Double-tap to open folder" : "Double-tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
