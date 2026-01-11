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
    @State private var downloadError: String?
    @State private var showDeleteError = false
    @State private var showDownloadError = false
    @State private var showRenameSheet = false
    @State private var renameFile: FileItem?
    @State private var newFileName = ""
    @State private var isRenaming = false
    @State private var renameError: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if !remote.isConfigured {
                notConnectedView
            } else {
                browserToolbar
                
                Divider()
                
                BreadcrumbBar(
                    components: browser.pathComponents,
                    onNavigate: { browser.navigateTo($0) }
                )
                
                Divider()
                
                if browser.isLoading || isDeleting || isDownloading || isUploading {
                    loadingView
                } else if let error = browser.error {
                    errorView(error)
                } else if browser.files.isEmpty {
                    emptyView
                } else {
                    fileContent
                }
                
                Divider()
                
                statusBar
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle(remote.name)
        .task(id: remote.id) {
            if remote.isConfigured {
                browser.setRemote(remote)
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
        .alert("Download Error", isPresented: $showDownloadError) {
            Button("OK") {
                downloadError = nil
            }
        } message: {
            Text(downloadError ?? "Unknown error")
        }
        .sheet(isPresented: $showNewFolderSheet) {
            NewFolderSheet(browser: browser, remote: remote)
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
            
            Picker("View", selection: $browser.viewMode) {
                Image(systemName: "list.bullet").tag(FileBrowserViewModel.ViewMode.list)
                Image(systemName: "square.grid.2x2").tag(FileBrowserViewModel.ViewMode.grid)
            }
            .pickerStyle(.segmented)
            .frame(width: 80)
        }
        .padding()
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            if isUploading && uploadProgress > 0 {
                // Show upload progress
                VStack(spacing: 12) {
                    ProgressView(value: uploadProgress, total: 100)
                        .frame(width: 200)
                    
                    Text("Uploading... \(Int(uploadProgress))%")
                        .foregroundColor(.secondary)
                    
                    if !uploadSpeed.isEmpty {
                        Text(uploadSpeed)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                // Show generic spinner
                ProgressView()
                Text(isUploading ? "Uploading..." : (isDownloading ? "Downloading..." : (isDeleting ? "Deleting..." : "Loading...")))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
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
        Table(browser.filteredFiles, selection: $browser.selectedFiles) {
            TableColumn("Name") { file in
                HStack(spacing: 8) {
                    Image(systemName: file.icon)
                        .foregroundColor(file.isDirectory ? .accentColor : .secondary)
                        .frame(width: 20)
                    
                    Text(file.name)
                        .lineLimit(1)
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
                ForEach(browser.filteredFiles) { file in
                    FileGridItem(
                        file: file,
                        isSelected: browser.selectedFiles.contains(file.id)
                    )
                    .onTapGesture {
                        browser.toggleSelection(file)
                    }
                    .onTapGesture(count: 2) {
                        browser.navigateToFile(file)
                    }
                }
            }
            .padding()
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
            
            if remote.isEncrypted {
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                    Text("Encrypted")
                }
                .font(.caption)
                .foregroundColor(.green)
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
                    for file in filesToDownload {
                        if remote.type == .local {
                            // Local copy
                            let destPath = url.appendingPathComponent(file.name).path
                            try FileManager.default.copyItem(atPath: file.path, toPath: destPath)
                        } else {
                            // Cloud download via rclone
                            try await RcloneManager.shared.download(
                                remoteName: remote.rcloneName,
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
        
        panel.begin { response in
            guard response == .OK, !panel.urls.isEmpty else { return }
            
            Task { @MainActor in
                isUploading = true
                uploadProgress = 0
                uploadSpeed = ""
                
                do {
                    for url in panel.urls {
                        if remote.type == .local {
                            // Local copy
                            let destPath = (browser.currentPath as NSString).appendingPathComponent(url.lastPathComponent)
                            try FileManager.default.copyItem(atPath: url.path, toPath: destPath)
                        } else {
                            // Cloud upload via rclone with progress
                            let progressStream = try await RcloneManager.shared.uploadWithProgress(
                                localPath: url.path,
                                remoteName: remote.rcloneName,
                                remotePath: browser.currentPath
                            )
                            
                            for await progress in progressStream {
                                await MainActor.run {
                                    uploadProgress = progress.percentage
                                    uploadSpeed = progress.speed
                                    print("UI Update: \(progress.percentage)% - \(progress.speed)")
                                }
                            }
                        }
                    }
                    
                    isUploading = false
                    uploadProgress = 0
                    uploadSpeed = ""
                    browser.refresh()
                } catch {
                    isUploading = false
                    uploadProgress = 0
                    uploadSpeed = ""
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
                for file in filesToDelete {
                    if remote.type == .local {
                        try FileManager.default.removeItem(atPath: file.path)
                    } else {
                        if file.isDirectory {
                            try await RcloneManager.shared.deleteFolder(
                                remoteName: remote.rcloneName,
                                path: file.path
                            )
                        } else {
                            try await RcloneManager.shared.deleteFile(
                                remoteName: remote.rcloneName,
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
                // Calculate the new path
                let parentPath = (file.path as NSString).deletingLastPathComponent
                let newPath = parentPath.isEmpty ? newFileName : "\(parentPath)/\(newFileName)"
                
                try await RcloneManager.shared.renameFile(
                    remoteName: remote.rcloneName,
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
}

// MARK: - Grid Item

struct FileGridItem: View {
    let file: FileItem
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                    .frame(width: 80, height: 80)
                
                Image(systemName: file.icon)
                    .font(.system(size: 32))
                    .foregroundColor(file.isDirectory ? .accentColor : .secondary)
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

#Preview {
    FileBrowserView(
        remote: CloudRemote(name: "Local", type: .local, isConfigured: true, path: NSHomeDirectory())
    )
    .environmentObject(RemotesViewModel.shared)
    .frame(width: 900, height: 600)
}
