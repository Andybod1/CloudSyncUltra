//
//  TasksViewModel.swift
//  CloudSyncApp
//
//  Manages sync tasks and job queue
//

import Foundation
import Combine

@MainActor
class TasksViewModel: ObservableObject {
    static let shared = TasksViewModel()
    
    @Published var tasks: [SyncTask] = []
    @Published var activeTasks: [SyncTask] = []
    @Published var taskHistory: [SyncTask] = []
    @Published var logs: [TaskLog] = []
    @Published var selectedTask: SyncTask?
    
    private let storageKey = "syncTasks"
    private let historyKey = "taskHistory"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadTasks()
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([SyncTask].self, from: data) {
            tasks = saved
        }
        
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let saved = try? JSONDecoder().decode([SyncTask].self, from: data) {
            taskHistory = saved
        }
        
        activeTasks = tasks.filter { $0.state == .running || $0.state == .pending }
    }
    
    func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func saveHistory() {
        // Keep last 100 tasks
        let trimmed = Array(taskHistory.prefix(100))
        if let data = try? JSONEncoder().encode(trimmed) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    func createTask(
        name: String,
        type: TaskType,
        sourceRemote: String,
        sourcePath: String,
        destinationRemote: String,
        destinationPath: String
    ) -> SyncTask {
        let task = SyncTask(
            name: name,
            type: type,
            sourceRemote: sourceRemote,
            sourcePath: sourcePath,
            destinationRemote: destinationRemote,
            destinationPath: destinationPath
        )
        tasks.append(task)
        saveTasks()
        return task
    }
    
    func startTask(_ task: SyncTask) async {
        guard var updatedTask = tasks.first(where: { $0.id == task.id }) else { return }
        
        updatedTask.state = .running
        updatedTask.startedAt = Date()
        updateTask(updatedTask)
        
        // Log encryption status
        if task.hasEncryption {
            addLog(taskId: task.id, level: .info, message: "🔐 E2E encryption enabled")
            if task.encryptSource {
                addLog(taskId: task.id, level: .info, message: "Source: decrypting from \(task.effectiveSourceRemote)")
            }
            if task.encryptDestination {
                addLog(taskId: task.id, level: .info, message: "Destination: encrypting to \(task.effectiveDestinationRemote)")
            }
        }
        
        addLog(taskId: task.id, level: .info, message: "Task started")
        
        // Use effective remote names (crypt or base) based on encryption settings
        let sourceRemote = task.effectiveSourceRemote
        let destRemote = task.effectiveDestinationRemote
        
        // Execute sync via RcloneManager
        do {
            let progressStream = try await RcloneManager.shared.syncBetweenRemotes(
                sourceRemote: sourceRemote,
                sourcePath: task.sourcePath,
                destRemote: destRemote,
                destPath: task.destinationPath,
                mode: task.type == .sync ? .biDirectional : .oneWay
            )
            
            for await progress in progressStream {
                updatedTask.progress = progress.percentage / 100
                updatedTask.speed = String(format: "%.2f MB/s", progress.speed)
                updatedTask.filesTransferred = progress.filesTransferred
                updatedTask.totalFiles = progress.totalFiles
                updateTask(updatedTask)
            }
            
            updatedTask.state = .completed
            updatedTask.completedAt = Date()
            updatedTask.progress = 1.0
            
            if task.hasEncryption {
                addLog(taskId: task.id, level: .info, message: "🔐 Task completed with encryption")
            } else {
                addLog(taskId: task.id, level: .info, message: "Task completed successfully")
            }
            
        } catch {
            updatedTask.state = .failed
            updatedTask.completedAt = Date()
            updatedTask.errorMessage = error.localizedDescription
            addLog(taskId: task.id, level: .error, message: error.localizedDescription)
        }
        
        updateTask(updatedTask)
        moveToHistory(updatedTask)
    }
    
    func pauseTask(_ task: SyncTask) {
        guard var updatedTask = tasks.first(where: { $0.id == task.id }) else { return }
        updatedTask.state = .paused
        updateTask(updatedTask)
        RcloneManager.shared.stopCurrentSync()
        addLog(taskId: task.id, level: .info, message: "Task paused")
    }
    
    func cancelTask(_ task: SyncTask) {
        guard var updatedTask = tasks.first(where: { $0.id == task.id }) else { return }
        updatedTask.state = .cancelled
        updatedTask.completedAt = Date()
        updateTask(updatedTask)
        RcloneManager.shared.stopCurrentSync()
        addLog(taskId: task.id, level: .warning, message: "Task cancelled")
        moveToHistory(updatedTask)
    }
    
    func deleteTask(_ task: SyncTask) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTask(_ task: SyncTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            objectWillChange.send()  // Force UI update
            saveTasks()
        }
        activeTasks = tasks.filter { $0.state == .running || $0.state == .pending }
    }
    
    func moveToHistory(_ task: SyncTask) {
        taskHistory.insert(task, at: 0)
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        saveHistory()
    }
    
    func addLog(taskId: UUID, level: TaskLog.LogLevel, message: String) {
        let log = TaskLog(taskId: taskId, level: level, message: message)
        logs.append(log)
    }
    
    func logsForTask(_ taskId: UUID) -> [TaskLog] {
        logs.filter { $0.taskId == taskId }
    }
    
    func clearHistory() {
        taskHistory.removeAll()
        saveHistory()
    }
    
    var runningTasksCount: Int {
        tasks.filter { $0.state == .running }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { $0.state == .pending }.count
    }
}
