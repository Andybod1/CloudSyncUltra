# CloudSync Ultra 2.0 - Development Guide

Technical documentation for developers working on CloudSync Ultra v2.0.32.

## Architecture Overview

### Component Hierarchy (v2.0.32)

```
CloudSyncAppApp (App Entry)
    │
    ├── WindowGroup (Main Window)
    │   └── MainWindow
    │       ├── NavigationSplitView
    │       │   ├── SidebarView
    │       │   │   ├── Navigation Items
    │       │   │   ├── Cloud Remotes List
    │       │   │   └── Local Storage List
    │       │   │
    │       │   └── Detail Views
    │       │       ├── DashboardView
    │       │       ├── TransferView (Dual-Pane)
    │       │       ├── SchedulesView
    │       │       ├── TasksView
    │       │       ├── HistoryView
    │       │       └── FileBrowserView
    │       │
    │       ├── QuickActionsView (Cmd+Shift+N overlay)
    │       │
    │       └── Environment Objects
    │           ├── SyncManager
    │           ├── RemotesViewModel
    │           ├── TasksViewModel
    │           ├── ScheduleManager
    │           └── StoreKitManager (NEW v2.0.32)
    │
    ├── OnboardingView (First launch)
    │   └── 4-Step Interactive Wizard
    │       ├── WelcomeStepView
    │       ├── AddProviderStepView → "Connect a Provider Now" button
    │       ├── FirstSyncStepView → "Try a Sync Now" button
    │       └── CompleteStepView
    │
    ├── Wizards (NEW v2.0.32)
    │   ├── ProviderConnectionWizardView
    │   ├── ScheduleWizardView
    │   └── TransferWizardView
    │
    ├── Subscription Views (NEW v2.0.32)
    │   ├── PaywallView
    │   └── SubscriptionView
    │
    ├── Settings Scene
    │   └── SettingsView (Tabs)
    │       ├── GeneralSettingsView
    │       ├── AccountSettingsView
    │       ├── SecuritySettingsView
    │       ├── PerformanceSettingsView
    │       ├── SyncSettingsView
    │       └── AboutView
    │
    └── AppDelegate
        └── StatusBarController
            └── Menu Bar UI
```

### Data Flow

```
User Action → SwiftUI View → ViewModel → Manager → rclone → Cloud Provider
                                         ↓
                                  TransferOptimizer
                                    (v2.0.32)
                                         ↓
                              Provider-specific tuning
                                         │
User Notification ← UI Update ← Published State ← Progress ←──┘
```

### MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS                               │
│  MainWindow │ DashboardView │ TransferView │ TasksView     │
│  QuickActionsView │ OnboardingView │ SchedulesView         │
│  PaywallView │ SubscriptionView │ Wizards/*                │
└──────────────────────────┬──────────────────────────────────┘
                           │ @EnvironmentObject
┌──────────────────────────▼──────────────────────────────────┐
│                      VIEW MODELS                            │
│  RemotesViewModel │ TasksViewModel │ FileBrowserViewModel  │
│  OnboardingViewModel │ ScheduleManager                     │
│  @Published properties for reactive UI updates             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                       MANAGERS                              │
│  SyncManager │ RcloneManager │ EncryptionManager           │
│  TransferOptimizer │ CrashReportingManager                 │
│  NotificationManager │ ErrorNotificationManager            │
│  StoreKitManager │ SecurityManager │ FeedbackManager (NEW) │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                        MODELS                               │
│  CloudProvider │ CloudRemote │ SyncTask │ FileItem         │
│  TransferError │ TransferPreview │ ChunkSizeConfig         │
│  SyncSchedule │ CrashReport │ OnboardingState              │
│  SubscriptionTier │ FeatureGate (NEW v2.0.32)              │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Models

#### CloudProvider.swift
Defines 42+ supported cloud services:

```swift
enum CloudProviderType: String, CaseIterable, Codable {
    // Major providers
    case protonDrive = "protondrive"
    case googleDrive = "drive"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    case amazonS3 = "s3"
    case mega = "mega"
    case box = "box"
    case pcloud = "pcloud"
    case icloudDrive = "iclouddrive"
    case backblazeB2 = "b2"
    case googleCloudStorage = "gcs"

    // ... 31 more providers

    var displayName: String { ... }
    var iconName: String { ... }      // SF Symbol
    var brandColor: Color { ... }     // Provider brand color
    var rcloneType: String { ... }    // rclone config type
    var authType: AuthType { ... }    // OAuth, password, API key
}

struct CloudRemote: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CloudProviderType
    var isConfigured: Bool
    var path: String
    var isEncrypted: Bool
    var sortOrder: Int               // User-customizable order
    var accountName: String?         // Email/username display
}
```

#### SubscriptionTier.swift (NEW v2.0.32)
StoreKit 2 subscription management:

```swift
enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "free"
    case pro = "pro"
    case team = "team"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .team: return "Team"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .pro: return "$9.99/mo"
        case .team: return "$19.99/user"
        }
    }

    var maxRemotes: Int {
        switch self {
        case .free: return 3
        case .pro, .team: return .max
        }
    }

    var maxScheduledTasks: Int {
        switch self {
        case .free: return 1
        case .pro, .team: return .max
        }
    }
}

struct FeatureGate {
    static func canAddRemote(currentCount: Int, tier: SubscriptionTier) -> Bool
    static func canCreateSchedule(currentCount: Int, tier: SubscriptionTier) -> Bool
    static func requiresUpgrade(for feature: Feature, tier: SubscriptionTier) -> Bool
}
```

#### TransferError.swift
Comprehensive error handling system:

```swift
struct TransferError: Error, Identifiable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let recoverySuggestion: String?
    let isRetryable: Bool
    let underlyingError: String?

    enum ErrorType {
        case quotaExceeded
        case authenticationFailed
        case networkTimeout
        case fileNotFound
        case permissionDenied
        case checksumMismatch
        case rateLimited
        // ... 20+ error types
    }

    static func parse(from output: String) -> TransferError?
}
```

#### TransferPreview.swift
Dry-run preview model:

```swift
struct TransferPreview: Codable {
    let totalFiles: Int
    let totalSize: Int64
    let newFiles: Int
    let modifiedFiles: Int
    let deletedFiles: Int
    let operations: [Operation]

    struct Operation: Identifiable {
        let id = UUID()
        let type: OperationType // new, update, delete
        let path: String
        let size: Int64?
    }
}
```

#### ChunkSizeConfig.swift
Provider-specific optimization:

```swift
struct ChunkSizeConfig {
    let provider: CloudProviderType
    let chunkSize: String
    let transfers: Int
    let checkers: Int

    static let configurations: [CloudProviderType: ChunkSizeConfig] = [
        .googleDrive: ChunkSizeConfig(
            provider: .googleDrive,
            chunkSize: "128M",
            transfers: 8,
            checkers: 16
        ),
        .dropbox: ChunkSizeConfig(
            provider: .dropbox,
            chunkSize: "150M",
            transfers: 4,
            checkers: 8
        ),
        // ... configurations for all providers
    ]
}
```

#### SyncSchedule.swift
Schedule model for automated syncing:

```swift
struct SyncSchedule: Identifiable, Codable {
    let id: UUID
    var name: String
    var sourceRemote: CloudRemote
    var sourcePath: String
    var destinationRemote: CloudRemote
    var destinationPath: String
    var frequency: ScheduleFrequency
    var isEnabled: Bool
    var lastRun: Date?
    var nextRun: Date?

    enum ScheduleFrequency: String, Codable, CaseIterable {
        case hourly, daily, weekly, custom
    }
}
```

### 2. ViewModels

#### RemotesViewModel.swift
Enhanced with sorting and account names:

```swift
@MainActor
class RemotesViewModel: ObservableObject {
    static let shared = RemotesViewModel()

    @Published var remotes: [CloudRemote] = []
    @Published var selectedRemote: CloudRemote?

    func loadRemotes()
    func saveRemotes()
    func addRemote(_ remote)
    func removeRemote(_ remote)
    func updateRemote(_ remote)
    func moveRemote(from: IndexSet, to: Int) // Drag reordering

    // Feature gating (v2.0.32)
    func canAddRemote() -> Bool {
        FeatureGate.canAddRemote(
            currentCount: remotes.count,
            tier: StoreKitManager.shared.currentTier
        )
    }

    var configuredRemotes: [CloudRemote] {
        remotes.filter { $0.isConfigured }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
```

#### OnboardingViewModel.swift
First-run experience state with interactive actions:

```swift
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var isComplete = false
    @Published var selectedProvider: CloudProviderType?

    // Persistent state for interactive onboarding (v2.0.32)
    @AppStorage("onboarding_hasConnectedProvider") var hasConnectedProvider = false
    @AppStorage("onboarding_hasCompletedFirstSync") var hasCompletedFirstSync = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    func nextStep()
    func previousStep()
    func skipOnboarding()
    func completeOnboarding()

    // Called when user completes provider connection wizard
    func providerConnected() {
        hasConnectedProvider = true
    }

    // Called when user completes first sync via wizard
    func firstSyncCompleted() {
        hasCompletedFirstSync = true
    }
}
```

#### ScheduleManager.swift
Manages scheduled sync execution:

```swift
@MainActor
class ScheduleManager: ObservableObject {
    static let shared = ScheduleManager()

    @Published var schedules: [SyncSchedule] = []
    @Published var activeTimers: [UUID: Timer] = [:]
    @Published var nextScheduledSync: Date?

    func createSchedule(...) -> SyncSchedule
    func updateSchedule(_ schedule: SyncSchedule)
    func deleteSchedule(_ schedule: SyncSchedule)
    func runScheduleNow(_ schedule: SyncSchedule) async
    func startScheduleTimers()
    func stopScheduleTimers()

    // Feature gating (v2.0.32)
    func canCreateSchedule() -> Bool {
        FeatureGate.canCreateSchedule(
            currentCount: schedules.count,
            tier: StoreKitManager.shared.currentTier
        )
    }
}
```

### 3. Views

#### Wizards (NEW v2.0.32)

##### ProviderConnectionWizardView.swift
Guided cloud provider setup:

```swift
struct ProviderConnectionWizardView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProviderConnectionViewModel()

    enum Step: Int, CaseIterable {
        case selectProvider
        case nameRemote
        case authenticate
        case testConnection
        case complete
    }

    @State private var currentStep: Step = .selectProvider

    var body: some View {
        VStack {
            // Progress indicator
            WizardProgressView(
                steps: Step.allCases.count,
                current: currentStep.rawValue
            )

            // Step content
            switch currentStep {
            case .selectProvider:
                ProviderGridView(selection: $viewModel.selectedProvider)
            case .nameRemote:
                RemoteNameView(name: $viewModel.remoteName)
            case .authenticate:
                AuthenticationView(provider: viewModel.selectedProvider)
            case .testConnection:
                ConnectionTestView(viewModel: viewModel)
            case .complete:
                CompletionView()
            }

            // Navigation buttons
            WizardNavigationButtons(
                canGoBack: currentStep != .selectProvider,
                canGoNext: viewModel.canProceed(from: currentStep),
                onBack: { currentStep = Step(rawValue: currentStep.rawValue - 1)! },
                onNext: { advanceStep() }
            )
        }
    }
}
```

##### ScheduleWizardView.swift
Easy schedule configuration:

```swift
struct ScheduleWizardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleManager: ScheduleManager

    @State private var name = ""
    @State private var sourceRemote: CloudRemote?
    @State private var destinationRemote: CloudRemote?
    @State private var frequency: ScheduleFrequency = .daily
    @State private var time = Date()

    var body: some View {
        Form {
            Section("Schedule Name") {
                TextField("Daily Backup", text: $name)
            }

            Section("Source") {
                RemotePicker(selection: $sourceRemote)
                PathPicker(remote: sourceRemote)
            }

            Section("Destination") {
                RemotePicker(selection: $destinationRemote)
                PathPicker(remote: destinationRemote)
            }

            Section("Frequency") {
                Picker("Run", selection: $frequency) {
                    ForEach(ScheduleFrequency.allCases) { freq in
                        Text(freq.displayName).tag(freq)
                    }
                }
                DatePicker("At", selection: $time, displayedComponents: .hourAndMinute)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") { createSchedule() }
                    .disabled(!isValid)
            }
        }
    }
}
```

##### TransferWizardView.swift
Step-by-step transfer with preview:

```swift
struct TransferWizardView: View {
    @Environment(\.dismiss) var dismiss

    enum Step { case source, destination, files, preview, transfer }
    @State private var currentStep: Step = .source

    @State private var sourceRemote: CloudRemote?
    @State private var destinationRemote: CloudRemote?
    @State private var selectedFiles: [FileItem] = []
    @State private var preview: TransferPreview?

    var body: some View {
        VStack {
            switch currentStep {
            case .source:
                RemoteAndPathSelector(
                    title: "Select Source",
                    selection: $sourceRemote
                )
            case .destination:
                RemoteAndPathSelector(
                    title: "Select Destination",
                    selection: $destinationRemote
                )
            case .files:
                FileSelector(
                    remote: sourceRemote,
                    selection: $selectedFiles
                )
            case .preview:
                TransferPreviewView(preview: preview)
            case .transfer:
                TransferProgressView()
            }
        }
    }
}
```

#### PaywallView.swift (NEW v2.0.32)
Subscription upgrade UI:

```swift
struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeKit: StoreKitManager

    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Upgrade to Pro")
                .font(.largeTitle.bold())

            // Feature comparison
            FeatureComparisonTable()

            // Pricing cards
            HStack(spacing: 16) {
                PricingCard(tier: .pro, isSelected: true)
                PricingCard(tier: .team, isSelected: false)
            }

            // Purchase button
            Button("Subscribe to Pro - $9.99/month") {
                Task { await storeKit.purchase(.pro) }
            }
            .buttonStyle(.borderedProminent)

            // Restore purchases
            Button("Restore Purchases") {
                Task { await storeKit.restorePurchases() }
            }
            .buttonStyle(.link)
        }
        .padding()
    }
}
```

#### QuickActionsView.swift
Keyboard-driven productivity menu:

```swift
struct QuickActionsView: View {
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @Binding var isShowing: Bool

    let actions = [
        QuickAction(title: "Add Cloud Service", icon: "plus.circle"),
        QuickAction(title: "Quick Transfer", icon: "arrow.right.circle"),
        QuickAction(title: "New Folder", icon: "folder.badge.plus"),
        QuickAction(title: "Schedule Sync", icon: "calendar.badge.clock"),
        QuickAction(title: "View Recent Transfers", icon: "clock.arrow.circlepath")
    ]

    var body: some View {
        VStack(spacing: 0) {
            SearchField(text: $searchText)

            ScrollView {
                ForEach(filteredActions) { action in
                    QuickActionRow(action: action, ...)
                }
            }
        }
        .onKeyPress(.downArrow) { ... }
        .onKeyPress(.upArrow) { ... }
        .onKeyPress(.return) { ... }
    }
}
```

#### OnboardingView.swift
4-step interactive wizard for new users:

```swift
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            ProgressIndicator(currentStep: viewModel.currentStep)

            TabView(selection: $viewModel.currentStep) {
                WelcomeStepView()
                    .tag(0)
                AddProviderStepView(viewModel: viewModel)
                    .tag(1)
                FirstSyncStepView(viewModel: viewModel)
                    .tag(2)
                CompleteStepView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            NavigationButtons(viewModel: viewModel)
        }
    }
}

// Interactive step with wizard integration
struct AddProviderStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingWizard = false

    var body: some View {
        VStack {
            Text("Connect Your First Cloud")
                .font(.title)

            Button("Connect a Provider Now") {
                showingWizard = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.hasConnectedProvider)

            if viewModel.hasConnectedProvider {
                Label("Provider Connected!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .sheet(isPresented: $showingWizard) {
            ProviderConnectionWizardView()
                .onDisappear {
                    // Check if a provider was added
                    if RemotesViewModel.shared.remotes.count > 0 {
                        viewModel.providerConnected()
                    }
                }
        }
    }
}
```

### 4. Core Managers

#### StoreKitManager.swift (NEW v2.0.32)
StoreKit 2 subscription management:

```swift
@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var currentTier: SubscriptionTier = .free
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.cloudsync.pro.monthly",
                "com.cloudsync.pro.yearly",
                "com.cloudsync.team.monthly"
            ])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ tier: SubscriptionTier) async throws {
        guard let product = products.first(where: { $0.id.contains(tier.rawValue) }) else {
            throw StoreError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            currentTier = tier
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                updateTier(from: transaction)
            }
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updateTier(from: transaction)
                    await transaction.finish()
                }
            }
        }
    }
}
```

#### SecurityManager.swift (NEW v2.0.32)
Security hardening and path sanitization:

```swift
class SecurityManager {
    static let shared = SecurityManager()

    /// Sanitize file paths to prevent path traversal attacks
    func sanitizePath(_ path: String) -> String {
        var sanitized = path

        // Remove path traversal attempts
        sanitized = sanitized.replacingOccurrences(of: "../", with: "")
        sanitized = sanitized.replacingOccurrences(of: "..\\", with: "")

        // Remove null bytes
        sanitized = sanitized.replacingOccurrences(of: "\0", with: "")

        // Normalize path
        sanitized = (sanitized as NSString).standardizingPath

        return sanitized
    }

    /// Validate that a path is within allowed boundaries
    func isPathAllowed(_ path: String, within allowedRoot: String) -> Bool {
        let resolvedPath = (path as NSString).standardizingPath
        let resolvedRoot = (allowedRoot as NSString).standardizingPath
        return resolvedPath.hasPrefix(resolvedRoot)
    }

    /// Secure file permissions for sensitive files
    func setSecurePermissions(for url: URL) throws {
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],  // Owner read/write only
            ofItemAtPath: url.path
        )
    }

    /// Scrub sensitive data from crash logs
    func scrubSensitiveData(_ text: String) -> String {
        var scrubbed = text

        // Scrub passwords
        scrubbed = scrubbed.replacingOccurrences(
            of: #"password[\"']?\s*[:=]\s*[\"']?[^\"'\s]+"#,
            with: "password=<REDACTED>",
            options: .regularExpression
        )

        // Scrub API keys
        scrubbed = scrubbed.replacingOccurrences(
            of: #"(api[_-]?key|secret|token)[\"']?\s*[:=]\s*[\"']?[A-Za-z0-9+/=]+"#,
            with: "$1=<REDACTED>",
            options: .regularExpression
        )

        return scrubbed
    }
}
```

#### FeedbackManager.swift (NEW v2.0.32)
In-app feedback system:

```swift
@MainActor
class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()

    @Published var isSubmitting = false
    @Published var lastError: String?

    struct Feedback {
        let type: FeedbackType
        let title: String
        let description: String
        let includeSystemInfo: Bool
        let includeLogs: Bool
    }

    enum FeedbackType: String, CaseIterable {
        case bug = "bug"
        case feature = "enhancement"
        case question = "question"

        var label: String {
            switch self {
            case .bug: return "Bug Report"
            case .feature: return "Feature Request"
            case .question: return "Question"
            }
        }
    }

    func submit(_ feedback: Feedback) async throws {
        isSubmitting = true
        defer { isSubmitting = false }

        var body = feedback.description

        if feedback.includeSystemInfo {
            body += "\n\n---\n**System Info:**\n"
            body += "- macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)\n"
            body += "- App Version: \(Bundle.main.appVersion)\n"
            body += "- Subscription: \(StoreKitManager.shared.currentTier.displayName)\n"
        }

        // Create GitHub issue via API or open URL
        let issueURL = createGitHubIssueURL(
            title: feedback.title,
            body: body,
            labels: [feedback.type.rawValue]
        )

        NSWorkspace.shared.open(issueURL)
    }
}
```

#### RcloneManager.swift
Enhanced with optimization and preview:

```swift
class RcloneManager {
    private let optimizer = TransferOptimizer()
    private let security = SecurityManager.shared

    func sync(localPath:remotePath:mode:encrypted:) async throws -> AsyncStream<SyncProgress>
    func listRemoteFiles(remotePath:encrypted:) async throws -> [RemoteFile]
    func copyFiles(source:destination:files:preview:) async throws -> TransferResult
    func previewTransfer(source:destination:) async throws -> TransferPreview

    // Provider-aware optimization
    private func buildTransferArgs(for provider: CloudProviderType?) -> [String] {
        var args = optimizer.buildArgs(parallelism: nil, provider: provider)

        if let config = ChunkSizeConfig.configurations[provider] {
            args.append("--drive-chunk-size=\(config.chunkSize)")
        }

        return args
    }

    // Enhanced error parsing
    func parseError(from output: String, exitCode: Int32) -> TransferError? {
        TransferError.parse(from: output) ??
        TransferError.fromExitCode(exitCode)
    }

    // Secure path handling (v2.0.32)
    private func validatePath(_ path: String) throws {
        let sanitized = security.sanitizePath(path)
        guard sanitized == path else {
            throw TransferError(type: .permissionDenied, message: "Invalid path")
        }
    }
}
```

#### CrashReportingManager.swift
Privacy-first crash handling:

```swift
class CrashReportingManager {
    static let shared = CrashReportingManager()
    private let security = SecurityManager.shared

    private let crashReportsURL: URL
    private var signalSources: [DispatchSourceSignal] = []

    func setup() {
        setupExceptionHandling()
        setupSignalHandlers()
    }

    private func setupExceptionHandling() {
        NSSetUncaughtExceptionHandler { exception in
            self.handleException(exception)
        }
    }

    private func setupSignalHandlers() {
        let signals = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE]

        for sig in signals {
            let source = DispatchSource.makeSignalSource(signal: sig)
            source.setEventHandler {
                self.handleSignal(sig)
            }
            source.resume()
            signalSources.append(source)
        }
    }

    private func saveCrashReport(_ report: CrashReport) {
        // Scrub sensitive data before saving
        var scrubbedReport = report
        scrubbedReport.stackTrace = security.scrubSensitiveData(report.stackTrace)

        // Save with secure permissions
        let url = crashReportsURL.appendingPathComponent("\(report.id).json")
        try? security.setSecurePermissions(for: url)
    }

    func getCrashReports() -> [CrashReport] {
        // Load from local storage only
    }
}
```

## State Management

### Global State (Singletons)
```swift
SyncManager.shared              // Sync operations
RemotesViewModel.shared         // Cloud connections
TasksViewModel.shared           // Job queue
ScheduleManager.shared          // Scheduled syncs
StoreKitManager.shared          // Subscriptions (NEW)
SecurityManager.shared          // Security utils (NEW)
FeedbackManager.shared          // User feedback (NEW)
ErrorNotificationManager.shared // Error banners
CrashReportingManager.shared    // Crash reports
```

### Local State (Views)
```swift
@State private var showingQuickActions = false
@State private var showingPaywall = false
@State private var selectedFiles: Set<UUID> = []
@State private var transferPreview: TransferPreview?
@StateObject private var onboardingVM = OnboardingViewModel()
```

### Environment Objects
```swift
.environmentObject(syncManager)
.environmentObject(remotesVM)
.environmentObject(tasksVM)
.environmentObject(scheduleManager)
.environmentObject(storeKitManager)
.environmentObject(errorManager)
```

### Data Persistence
```swift
// UserDefaults keys
"cloudRemotes"       // [CloudRemote] JSON
"syncTasks"          // [SyncTask] JSON
"syncSchedules"      // [SyncSchedule] JSON
"hasCompletedOnboarding" // Bool
"onboarding_hasConnectedProvider" // Bool (NEW)
"onboarding_hasCompletedFirstSync" // Bool (NEW)
"use24HourTime"      // Bool
"uploadBandwidthLimit" // Double (MB/s)
"downloadBandwidthLimit" // Double (MB/s)

// Keychain (secure storage)
"subscriptionReceipt" // StoreKit receipt data
```

## Testing Infrastructure

### 855 Automated Tests (v2.0.32)

#### Test Categories
- **Models** (150+ tests)
  - CloudProviderTests.swift - 42 provider configurations
  - TransferErrorTests.swift - 48 error parsing tests
  - ChunkSizeTests.swift - 25 optimization tests
  - TransferPreviewTests.swift - 25 preview tests
  - SubscriptionTierTests.swift - 15 tier tests (NEW)

- **ViewModels** (200+ tests)
  - RemotesViewModelTests.swift - Remote management
  - TasksViewModelTests.swift - Task queue logic
  - OnboardingViewModelTests.swift - 35 onboarding tests
  - ScheduleManagerTests.swift - 32 schedule tests

- **Managers** (250+ tests)
  - RcloneManagerTests.swift - Core sync engine
  - TransferOptimizerTests.swift - Performance tuning
  - CrashReportingTests.swift - 27 crash handling tests
  - ErrorNotificationTests.swift - Error display logic
  - StoreKitManagerTests.swift - 20 subscription tests (NEW)
  - SecurityManagerTests.swift - 15 security tests (NEW)

- **Integration** (100+ tests)
  - End-to-end transfer workflows
  - Provider authentication flows
  - Schedule execution tests
  - Error recovery scenarios
  - Feature gating tests (NEW)

- **UI Tests** (69 tests)
  - OnboardingUITests.swift
  - TransferUITests.swift
  - QuickActionsUITests.swift
  - ErrorHandlingUITests.swift
  - WizardUITests.swift (NEW)
  - PaywallUITests.swift (NEW)

### StoreKit Testing Configuration (NEW v2.0.32)

```swift
// StoreKit Configuration file for testing
// CloudSyncApp/StoreKitTest.storekit
{
    "products": [
        {
            "id": "com.cloudsync.pro.monthly",
            "type": "autoRenewable",
            "price": 9.99
        },
        {
            "id": "com.cloudsync.pro.yearly",
            "type": "autoRenewable",
            "price": 99.99
        },
        {
            "id": "com.cloudsync.team.monthly",
            "type": "autoRenewable",
            "price": 19.99
        }
    ]
}
```

### CI/CD Pipeline

#### GitHub Actions (.github/workflows/ci.yml)
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.app
    - name: Build
      run: xcodebuild build -scheme CloudSyncApp -destination 'platform=macOS'
    - name: Test
      run: xcodebuild test -scheme CloudSyncApp -destination 'platform=macOS'
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

### Pre-commit Hooks

#### scripts/pre-commit
```bash
#!/bin/bash
# Pre-commit hook for CloudSync Ultra

echo "Running pre-commit checks..."

# 1. Swift syntax check
echo "Checking Swift syntax..."
find . -name "*.swift" -exec swiftc -parse {} \; || exit 1

# 2. Build check
echo "Building project..."
xcodebuild build -scheme CloudSyncApp -quiet || exit 1

# 3. Version consistency
echo "Checking version consistency..."
./scripts/version-check.sh || exit 1

# 4. Check for debug artifacts
echo "Checking for debug artifacts..."
if grep -r "print(" --include="*.swift" CloudSyncApp/; then
    echo "Warning: Found print() statements"
fi

# 5. Update test count
./scripts/record-test-count.sh

echo "Pre-commit checks passed!"
```

## Adding Features

### Adding a New Cloud Provider

1. **Add to CloudProviderType enum:**
```swift
case myprovider = "myprovider"

var displayName: String {
    case .myprovider: return "My Provider"
}

var iconName: String {
    case .myprovider: return "cloud.fill"
}

var brandColor: Color {
    case .myprovider: return Color(hex: "0082C9")
}
```

2. **Add chunk size configuration:**
```swift
// In ChunkSizeConfig.swift
.myprovider: ChunkSizeConfig(
    provider: .myprovider,
    chunkSize: "64M",
    transfers: 4,
    checkers: 8
)
```

3. **Add authentication UI:**
```swift
// In AccountSettingsView.swift
case .myprovider:
    MyProviderConfigView(remote: remote)
```

4. **Add tests:**
```swift
// In CloudProviderTests.swift
func testMyProviderConfiguration() {
    let provider = CloudProviderType.myprovider
    XCTAssertEqual(provider.displayName, "My Provider")
    XCTAssertEqual(provider.rcloneType, "myprovider")
}
```

### Adding a New Feature

1. **Create feature branch:**
```bash
git checkout -b feature/my-feature
```

2. **Add model if needed:**
```swift
// Models/MyFeature.swift
struct MyFeature: Identifiable, Codable {
    let id: UUID
    // ... properties
}
```

3. **Add ViewModel:**
```swift
// ViewModels/MyFeatureViewModel.swift
@MainActor
class MyFeatureViewModel: ObservableObject {
    @Published var items: [MyFeature] = []
    // ... logic
}
```

4. **Add View:**
```swift
// Views/MyFeatureView.swift
struct MyFeatureView: View {
    @StateObject private var viewModel = MyFeatureViewModel()

    var body: some View {
        // ... UI
    }
}
```

5. **Add tests:**
```swift
// Tests/MyFeatureTests.swift
class MyFeatureTests: XCTestCase {
    func testMyFeature() {
        // ... tests
    }
}
```

6. **Update test count:**
```bash
./scripts/record-test-count.sh
```

## Keyboard Navigation (v2.0.32)

### Global Shortcuts
| Shortcut | Action | Handler |
|----------|--------|---------|
| `⌘N` | Add new provider | MainWindow.swift |
| `⌘,` | Open Settings | AppDelegate.swift |
| `⌘⇧N` | Quick Actions menu | MainWindow.swift |
| `⌘1-9` | Switch sidebar sections | SidebarView.swift |

### File Browser Shortcuts
| Shortcut | Action | Handler |
|----------|--------|---------|
| `↑/↓` | Navigate files | FileBrowserView.swift |
| `⏎` | Open folder / Select file | FileBrowserView.swift |
| `⌘↑` | Go to parent folder | FileBrowserView.swift |
| `Space` | Quick Look preview | FileBrowserView.swift |
| `⌘A` | Select all | FileBrowserView.swift |
| `⌘⇧A` | Deselect all | FileBrowserView.swift |
| `Delete` | Delete selected | FileBrowserView.swift |

### Implementation Pattern
```swift
struct FileBrowserView: View {
    @FocusState private var isFocused: Bool
    @State private var selectedIndex: Int = 0

    var body: some View {
        List(selection: $selection) { ... }
            .focused($isFocused)
            .onKeyPress(.upArrow) {
                moveSelection(by: -1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                moveSelection(by: 1)
                return .handled
            }
            .onKeyPress(.return) {
                openSelected()
                return .handled
            }
    }
}
```

## Build & Deployment

### Debug Build
```bash
xcodebuild -scheme CloudSyncApp -configuration Debug build
```

### Release Build
```bash
xcodebuild -scheme CloudSyncApp -configuration Release \
    -archivePath CloudSyncApp.xcarchive archive

xcodebuild -exportArchive \
    -archivePath CloudSyncApp.xcarchive \
    -exportPath Release \
    -exportOptionsPlist ExportOptions.plist
```

### Version Management
```bash
# Update version
./scripts/update-version.sh 2.0.32

# Create release
./scripts/release.sh 2.0.32
```

---

**Development Guide Version**: 2.0.32
**Last Updated**: January 2026
**Architecture**: MVVM + SwiftUI
**Tests**: 855 automated tests
