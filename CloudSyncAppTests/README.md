# Adding Unit Tests to CloudSync Ultra

## Test Files Created

The following test files have been created in `/Users/antti/Claude/CloudSyncAppTests/`:

1. **FileItemTests.swift** - Tests for FileItem model
   - Size formatting (bytes, KB, MB, GB)
   - Icon selection by file type
   - Date formatting
   - Equality

2. **CloudProviderTests.swift** - Tests for CloudProvider model
   - Display names
   - Icons
   - rclone names
   - OAuth requirements
   - CloudRemote creation

3. **SyncTaskTests.swift** - Tests for SyncTask model
   - Task types (sync, backup, transfer)
   - Task status
   - Task creation
   - Codable encoding/decoding

4. **FileBrowserViewModelTests.swift** - Tests for FileBrowserViewModel
   - Sorting (by name, size, date)
   - Filtering/search
   - Selection
   - Navigation

5. **TasksViewModelTests.swift** - Tests for TasksViewModel
   - Add/remove tasks
   - Filter by status
   - Filter by type
   - Update tasks

6. **RemotesViewModelTests.swift** - Tests for RemotesViewModel
   - Initial state
   - Configured remotes
   - Add/remove remotes
   - Selection

## How to Add Test Target in Xcode

1. Open **CloudSyncApp.xcodeproj** in Xcode

2. Go to **File → New → Target...**

3. Select **macOS → Test → Unit Testing Bundle**

4. Configure:
   - Product Name: `CloudSyncAppTests`
   - Team: Your team
   - Organization: Your org
   - Bundle Identifier: `com.yourorg.CloudSyncAppTests`
   - Language: Swift
   - Project: CloudSyncApp
   - Target to be Tested: CloudSyncApp

5. Click **Finish**

6. Delete the auto-generated test file in the new target

7. Drag the test files from `/Users/antti/Claude/CloudSyncAppTests/` into the CloudSyncAppTests group in Xcode

8. Make sure each file is added to the **CloudSyncAppTests** target

## Running Tests

- Press **⌘U** to run all tests
- Or go to **Product → Test**
- Or click the diamond icon next to any test function

## Test Coverage

To see code coverage:
1. **Product → Scheme → Edit Scheme...**
2. Select **Test** on the left
3. Check **Code Coverage**
4. Run tests with ⌘U
5. View coverage in **Report Navigator** (⌘9)
