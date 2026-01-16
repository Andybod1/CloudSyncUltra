# CloudSync Ultra - Type Inventory

> **Reference for Workers** - These types exist and can be used.
> Run `./scripts/generate-type-inventory.sh` to refresh this list.

---

## Quick Lookup

Before using a type, verify it exists:
```bash
grep -r "struct TypeName" CloudSyncApp/
grep -r "class ClassName" CloudSyncApp/
```

---

## Models (CloudSyncApp/Models/)

```swift
enum CPUPriority: String, CaseIterable, Codable {
enum CheckFrequency: String, CaseIterable, Codable {
enum CloudProviderType: String, CaseIterable, Codable, Identifiable, Hashable {
enum HelpCategory: String, CaseIterable, Codable, Identifiable {
enum PerformanceProfile: String, CaseIterable {
enum PreviewError: LocalizedError {
enum PreviewOperation: String, Codable {
enum ScheduleFrequency: String, Codable, CaseIterable {
enum SubscriptionTier: String, Codable, CaseIterable {
enum TaskState: String, Codable {
enum TaskType: String, Codable, CaseIterable {
enum TransferError: Error, Equatable, Codable {
struct AppInfo: Codable, Hashable {
struct ChunkSizeConfig {
struct CloudRemote: Identifiable, Codable, Equatable, Hashable {
struct CrashReport: Identifiable, Codable, Hashable {
struct DeviceInfo: Codable, Hashable {
struct FileItem: Identifiable, Equatable, Hashable {
struct HelpTopic: Identifiable, Codable, Hashable {
struct PerformanceSettings: Codable, Equatable {
struct PreviewItem: Identifiable {
struct SyncSchedule: Identifiable, Codable, Equatable {
struct SyncTask: Identifiable, Codable {
struct TaskLog: Identifiable, Codable {
struct TransferPreview {
```

## ViewModels (CloudSyncApp/ViewModels/)

```swift
class FileBrowserViewModel: ObservableObject {
class OnboardingViewModel: ObservableObject {
class RemotesViewModel: ObservableObject {
class TasksViewModel: ObservableObject {
```

## Managers

```swift
class FileMonitor {
class HelpManager: ObservableObject {
class ICloudManager {
class KeychainManager {
class ProtonDriveManager: ObservableObject {
class RcloneManager {
class ScheduleManager: ObservableObject {
class StoreKitManager: ObservableObject {
class SyncManager: ObservableObject {
class TransferOptimizer {
struct CloudCredentials: Codable {
struct LargeFileDownloadResult {
struct MultiThreadDownloadConfig {
struct ProtonDriveCredentials: Codable {
struct RemoteEncryptionConfig: Codable {
struct RemoteFile: Codable {
struct SecurityManager {
struct SyncProgress {
```

## Main Views

```swift
struct AboutView: View {
struct AccountSettingsView: View {
struct ContentView: View {
struct DashboardView: View {
struct EncryptionSettingsView: View {
struct FileBrowserView: View {
struct GeneralSettingsView: View {
struct HistoryView: View {
struct PaywallView: View {
struct PerformanceSettingsView: View {
struct ProtonDriveSetupView: View {
struct QuickActionsView: View {
struct RemoteDetailView: View {
struct ScheduleRowView: View {
struct ScheduleSettingsView: View {
struct SchedulesView: View {
struct SettingsView: View {
struct SidebarView: View {
struct SubscriptionSettingsView: View {
struct SubscriptionView: View {
struct SyncSettingsView: View {
struct TasksView: View {
struct TransferView: View {
```

## SwiftUI Colors (use these, not custom)

```swift
Color.accentColor    // System blue (primary)
Color.green          // Success
Color.orange         // Warning
Color.red            // Error/destructive
Color.gray           // Secondary text
Color.primary        // Primary text (adapts to dark mode)
Color.secondary      // Secondary text (adapts to dark mode)
```

---

## Types That Require Coordination

These types exist but modifying them affects multiple workers:

| Type | Owner | Notes |
|------|-------|-------|
| `CloudRemote` | Shared | Core model, coordinate changes |
| `SyncTask` | Shared | Used by multiple views |
| `RcloneManager` | Dev-2 | Engine layer |
| `SyncManager` | Dev-3 | Service layer |

---

*Generated: 2026-01-16 08:17*
