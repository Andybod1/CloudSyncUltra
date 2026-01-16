# Test Plan: Sprint Tickets #80, #72, #52

> **Created:** 2026-01-14
> **Author:** QA Specialist
> **Sprint Focus:** Onboarding, Multi-Threading, Help System
> **Project:** CloudSync Ultra (macOS SwiftUI)

---

## Table of Contents

1. [Overview](#overview)
2. [Ticket #80 - Onboarding Infrastructure + Welcome Screen](#ticket-80---onboarding-infrastructure--welcome-screen)
3. [Ticket #72 - Multi-Threaded Large File Downloads](#ticket-72---multi-threaded-large-file-downloads)
4. [Ticket #52 - Help System](#ticket-52---help-system)
5. [Test Priority Matrix](#test-priority-matrix)
6. [Edge Cases Summary](#edge-cases-summary)
7. [Error Scenarios](#error-scenarios)

---

## Overview

This test plan covers three sprint tickets focusing on user experience improvements:

| Ticket | Component | Priority | Size | Dependencies |
|--------|-----------|----------|------|--------------|
| **#80** | OnboardingManager + Welcome UI | Critical | M | None |
| **#72** | Multi-Thread Downloads | High | M | TransferOptimizer (#70) |
| **#52** | HelpTopic + HelpManager | High | M | None |

**Test Location:** `CloudSyncAppTests/`

**Existing Related Files:**
- `CloudSyncApp/ViewModels/OnboardingManager.swift`
- `CloudSyncApp/Models/HelpTopic.swift`
- `CloudSyncApp/Models/HelpCategory.swift`
- `CloudSyncApp/RcloneManager.swift` (TransferOptimizer)
- `CloudSyncAppTests/TransferOptimizerTests.swift`

---

## Ticket #80 - Onboarding Infrastructure + Welcome Screen

### 1. OnboardingManager State Persistence Tests

**Test File:** `OnboardingManagerTests.swift`

#### TC-80.1: First Launch Detection

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.1.1 | `testFirstLaunchShowsOnboarding` - Fresh install (no UserDefaults) shows onboarding | **P0** | Unit |
| TC-80.1.2 | `testSubsequentLaunchHidesOnboarding` - After completion, onboarding is hidden | **P0** | Unit |
| TC-80.1.3 | `testHasCompletedOnboardingDefaultsFalse` - Default value is false for new users | **P1** | Unit |

**Test Steps for TC-80.1.1:**
```
Given: UserDefaults has no "hasCompletedOnboarding" key
When: OnboardingManager is initialized
Then: shouldShowOnboarding == true
And: hasCompletedOnboarding == false
```

**Test Steps for TC-80.1.2:**
```
Given: hasCompletedOnboarding == true in UserDefaults
When: OnboardingManager is initialized
Then: shouldShowOnboarding == false
```

#### TC-80.2: State Persistence

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.2.1 | `testCompletionStatePersistsAcrossInstances` - Singleton maintains state | **P0** | Unit |
| TC-80.2.2 | `testCompletionStatePersistsToUserDefaults` - State saved to UserDefaults | **P0** | Unit |
| TC-80.2.3 | `testAppStorageKeyIsCorrect` - Uses "hasCompletedOnboarding" key | **P1** | Unit |

**Test Steps for TC-80.2.2:**
```
Given: OnboardingManager with hasCompletedOnboarding == false
When: completeOnboarding() is called
Then: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") == true
And: shouldShowOnboarding == false
```

#### TC-80.3: Step Navigation

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.3.1 | `testNextStepAdvancesFromWelcome` - nextStep() moves forward | **P0** | Unit |
| TC-80.3.2 | `testPreviousStepDoesNothingOnFirstStep` - previousStep() on first step is no-op | **P1** | Unit |
| TC-80.3.3 | `testGoToStepJumpsToSpecificStep` - goToStep() navigates directly | **P1** | Unit |
| TC-80.3.4 | `testNextStepOnLastStepCompletesOnboarding` - Final step triggers completion | **P0** | Unit |
| TC-80.3.5 | `testProgressCalculation` - progress returns correct percentage | **P2** | Unit |

**Test Steps for TC-80.3.4:**
```
Given: OnboardingManager at last step (isLastStep == true)
When: nextStep() is called
Then: hasCompletedOnboarding == true
And: shouldShowOnboarding == false
And: Notification.onboardingCompleted is posted
```

#### TC-80.4: Reset Onboarding Functionality

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.4.1 | `testResetOnboardingClearsCompletion` - resetOnboarding() sets hasCompletedOnboarding to false | **P0** | Unit |
| TC-80.4.2 | `testResetOnboardingResetsToWelcomeStep` - currentStep becomes .welcome | **P0** | Unit |
| TC-80.4.3 | `testResetOnboardingShowsOnboarding` - shouldShowOnboarding becomes true | **P0** | Unit |
| TC-80.4.4 | `testResetOnboardingPostsNotification` - Notification.onboardingReset is posted | **P1** | Unit |

**Test Steps for TC-80.4.1:**
```
Given: OnboardingManager with hasCompletedOnboarding == true
When: resetOnboarding() is called
Then: hasCompletedOnboarding == false
And: currentStep == .welcome
And: shouldShowOnboarding == true
```

#### TC-80.5: Skip Onboarding

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.5.1 | `testSkipOnboardingCompletesFlow` - skipOnboarding() marks as complete | **P0** | Unit |
| TC-80.5.2 | `testSkipOnboardingFromAnyStep` - Can skip from any step | **P1** | Unit |

#### TC-80.6: Notification Integration

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.6.1 | `testOnboardingCompletedNotificationPosted` - Notification fires on completion | **P1** | Unit |
| TC-80.6.2 | `testOnboardingResetNotificationPosted` - Notification fires on reset | **P1** | Unit |

### 2. Welcome Screen UI Tests

**Test File:** `OnboardingUITests.swift` (UI Tests)

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-80.7.1 | `testWelcomeScreenAppearsOnFirstLaunch` - Welcome screen visible | **P0** | UI |
| TC-80.7.2 | `testWelcomeScreenHasGetStartedButton` - CTA button exists | **P0** | UI |
| TC-80.7.3 | `testWelcomeScreenHasSkipButton` - Skip option available | **P1** | UI |
| TC-80.7.4 | `testGetStartedButtonNavigatesForward` - Button advances flow | **P0** | UI |
| TC-80.7.5 | `testWelcomeScreenAccessibility` - VoiceOver labels present | **P2** | UI |

---

## Ticket #72 - Multi-Threaded Large File Downloads

### 1. Thread Count Configuration Tests

**Test File:** `MultiThreadDownloadTests.swift`

#### TC-72.1: Default Thread Count

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.1.1 | `testDefaultMultiThreadStreamsIs8` - Default streams count is 8 | **P0** | Unit |
| TC-72.1.2 | `testMultiThreadStreamsConfigurable` - Can change thread count | **P1** | Unit |
| TC-72.1.3 | `testMultiThreadStreamsBounds` - Thread count has min/max bounds | **P1** | Unit |

**Test Steps for TC-72.1.1:**
```
Given: TransferOptimizer.optimize() called for large download
When: fileCount == 1 AND totalBytes > 100MB AND isDownload == true
Then: config.multiThreadStreams == 8
And: config.multiThread == true
```

### 2. Size Threshold Logic Tests

#### TC-72.2: Multi-Thread Activation Threshold

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.2.1 | `testMultiThreadEnabledForLargeFiles` - Files >100MB enable multi-threading | **P0** | Unit |
| TC-72.2.2 | `testMultiThreadDisabledForSmallFiles` - Files <100MB use single thread | **P0** | Unit |
| TC-72.2.3 | `testMultiThreadThresholdExactly100MB` - Boundary case at threshold | **P1** | Unit |
| TC-72.2.4 | `testMultiThreadDisabledForMultipleFiles` - Multiple files use parallel transfers instead | **P1** | Unit |

**Test Steps for TC-72.2.1:**
```
Given: TransferOptimizer.optimize() called
When: fileCount == 1
And: totalBytes == 500_000_000 (500MB)
And: isDownload == true
Then: config.multiThread == true
And: config.multiThreadStreams == 8
```

**Test Steps for TC-72.2.2:**
```
Given: TransferOptimizer.optimize() called
When: fileCount == 1
And: totalBytes == 10_000_000 (10MB)
And: isDownload == true
Then: config.multiThread == false
And: config.multiThreadStreams == 0
```

#### TC-72.3: Multi-Thread Cutoff Configuration

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.3.1 | `testBuildArgsIncludesMultiThreadCutoff` - Args include --multi-thread-cutoff | **P1** | Unit |
| TC-72.3.2 | `testMultiThreadCutoffValue` - Cutoff is set to 100M | **P1** | Unit |

### 3. Provider Capability Detection Tests

#### TC-72.4: Provider Support

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.4.1 | `testGoogleDriveSupportsMultiThread` - Google Drive enables multi-thread | **P0** | Unit |
| TC-72.4.2 | `testDropboxSupportsMultiThread` - Dropbox enables multi-thread | **P1** | Unit |
| TC-72.4.3 | `testS3SupportsMultiThread` - S3 enables multi-thread | **P1** | Unit |
| TC-72.4.4 | `testOneDriveSupportsMultiThread` - OneDrive enables multi-thread | **P1** | Unit |
| TC-72.4.5 | `testLocalStorageDisablesMultiThread` - Local storage doesn't need multi-thread | **P2** | Unit |

### 4. Fallback to Single-Thread Tests

#### TC-72.5: Upload Fallback

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.5.1 | `testMultiThreadDisabledForUpload` - Uploads always single-threaded | **P0** | Unit |
| TC-72.5.2 | `testLargeUploadStillSingleThread` - Even large uploads are single-threaded | **P1** | Unit |

**Test Steps for TC-72.5.1:**
```
Given: TransferOptimizer.optimize() called
When: isDownload == false (upload)
And: totalBytes == 500_000_000 (500MB)
Then: config.multiThread == false
And: config.multiThreadStreams == 0
```

#### TC-72.6: Directory Transfer Fallback

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.6.1 | `testMultiThreadDisabledForDirectories` - Directory downloads use parallel transfers | **P1** | Unit |
| TC-72.6.2 | `testParallelTransfersForMultipleFiles` - Multiple files use --transfers instead | **P1** | Unit |

### 5. BuildArgs Output Tests

#### TC-72.7: Argument Generation

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-72.7.1 | `testBuildArgsWithMultiThreadEnabled` - Includes --multi-thread-streams flag | **P0** | Unit |
| TC-72.7.2 | `testBuildArgsWithMultiThreadDisabled` - No multi-thread flags when disabled | **P0** | Unit |
| TC-72.7.3 | `testBuildArgsFormat` - Arguments are correctly formatted for rclone | **P1** | Unit |

**Test Steps for TC-72.7.1:**
```
Given: TransferConfig with multiThread == true, multiThreadStreams == 8
When: TransferOptimizer.buildArgs(from: config)
Then: args contains "--multi-thread-streams"
And: args contains "8"
And: args contains "--multi-thread-cutoff"
And: args contains "100M"
```

---

## Ticket #52 - Help System

### 1. HelpTopic Model Tests

**Test File:** `HelpTopicTests.swift`

#### TC-52.1: Encoding/Decoding

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.1.1 | `testHelpTopicEncodesToJSON` - Model encodes to JSON correctly | **P0** | Unit |
| TC-52.1.2 | `testHelpTopicDecodesFromJSON` - Model decodes from JSON correctly | **P0** | Unit |
| TC-52.1.3 | `testHelpTopicRoundTrip` - Encode then decode produces identical object | **P0** | Unit |
| TC-52.1.4 | `testHelpTopicOptionalRelatedTopicsEncode` - relatedTopicIds encodes as null when nil | **P1** | Unit |
| TC-52.1.5 | `testHelpTopicArrayEncoding` - Array of topics encodes correctly | **P1** | Unit |

**Test Steps for TC-52.1.3:**
```
Given: HelpTopic with all fields populated
When: Encoded to JSON then decoded back
Then: Original and decoded topics are equal
And: All fields match (id, title, content, category, keywords, sortOrder, relatedTopicIds)
```

#### TC-52.2: Initialization

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.2.1 | `testHelpTopicDefaultValues` - Default initializer provides sensible defaults | **P1** | Unit |
| TC-52.2.2 | `testHelpTopicUUIDGeneration` - Each topic gets unique UUID | **P1** | Unit |
| TC-52.2.3 | `testHelpTopicFullInitialization` - All parameters accepted | **P0** | Unit |

### 2. Search Functionality Tests

#### TC-52.3: Basic Search

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.3.1 | `testSearchMatchesTitle` - Query matching title returns true | **P0** | Unit |
| TC-52.3.2 | `testSearchMatchesContent` - Query matching content returns true | **P0** | Unit |
| TC-52.3.3 | `testSearchMatchesKeyword` - Query matching keyword returns true | **P0** | Unit |
| TC-52.3.4 | `testSearchNoMatch` - Non-matching query returns false | **P0** | Unit |
| TC-52.3.5 | `testSearchCaseInsensitive` - Search is case-insensitive | **P0** | Unit |

**Test Steps for TC-52.3.1:**
```
Given: HelpTopic with title "Getting Started Guide"
When: matches(query: "getting started")
Then: returns true
```

**Test Steps for TC-52.3.5:**
```
Given: HelpTopic with title "Sync Files"
When: matches(query: "SYNC") OR matches(query: "sync") OR matches(query: "SyNc")
Then: All return true
```

#### TC-52.4: Partial Match Search

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.4.1 | `testSearchPartialTitleMatch` - Partial title match works | **P1** | Unit |
| TC-52.4.2 | `testSearchPartialKeywordMatch` - Partial keyword match works | **P1** | Unit |
| TC-52.4.3 | `testSearchSingleCharacter` - Single character search works | **P2** | Unit |

### 3. Category Filtering Tests

**Test File:** `HelpCategoryTests.swift`

#### TC-52.5: HelpCategory Tests

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.5.1 | `testAllCategoriesExist` - All 6 categories defined | **P0** | Unit |
| TC-52.5.2 | `testCategoryDisplayNames` - Each category has display name | **P0** | Unit |
| TC-52.5.3 | `testCategoryIconNames` - Each category has icon | **P1** | Unit |
| TC-52.5.4 | `testCategorySortOrder` - Categories sorted correctly | **P1** | Unit |
| TC-52.5.5 | `testCategoryEncodeDecode` - Category encodes/decodes properly | **P0** | Unit |

**Test Steps for TC-52.5.1:**
```
Given: HelpCategory enum
When: Checking allCases
Then: Contains: gettingStarted, providers, syncing, troubleshooting, security, advanced
And: count == 6
```

#### TC-52.6: Filtering by Category

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.6.1 | `testFilterTopicsByCategory` - Returns only matching category | **P0** | Unit |
| TC-52.6.2 | `testFilterEmptyCategoryReturnsEmpty` - Empty category returns [] | **P1** | Unit |
| TC-52.6.3 | `testFilterMultipleCategories` - Can filter by multiple categories | **P2** | Unit |

### 4. Keyword Matching Tests

#### TC-52.7: Keyword Search

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.7.1 | `testKeywordExactMatch` - Exact keyword match found | **P0** | Unit |
| TC-52.7.2 | `testKeywordPartialMatch` - Partial keyword match found | **P1** | Unit |
| TC-52.7.3 | `testMultipleKeywordsAnyMatch` - Any matching keyword is found | **P1** | Unit |
| TC-52.7.4 | `testEmptyKeywordsArray` - Empty keywords array handled | **P1** | Unit |

### 5. Relevance Scoring Tests

#### TC-52.8: Search Ranking

| ID | Test Case | Priority | Type |
|----|-----------|----------|------|
| TC-52.8.1 | `testTitleMatchHigherThanContent` - Title match scores higher | **P0** | Unit |
| TC-52.8.2 | `testExactTitleMatchHighest` - Exact title match gets bonus | **P1** | Unit |
| TC-52.8.3 | `testKeywordMatchMediumScore` - Keyword match between title and content | **P1** | Unit |
| TC-52.8.4 | `testContentMatchLowestScore` - Content match scores lowest | **P1** | Unit |
| TC-52.8.5 | `testNoMatchZeroScore` - Non-match returns 0 | **P1** | Unit |

**Test Steps for TC-52.8.1:**
```
Given: Two HelpTopics:
  - Topic A: title contains "sync", content does not
  - Topic B: title does not contain "sync", content does
When: relevanceScore(for: "sync") called on both
Then: Topic A score > Topic B score
```

---

## Test Priority Matrix

### Priority Definitions

| Priority | Definition | When to Run |
|----------|------------|-------------|
| **P0** | Critical path - Must pass for feature to work | Every commit |
| **P1** | Important - Core functionality | Every PR |
| **P2** | Nice to have - Edge cases, polish | Release candidate |

### Summary by Ticket

#### Ticket #80 - Onboarding (14 tests)
| Priority | Count | Test IDs |
|----------|-------|----------|
| P0 | 9 | TC-80.1.1, TC-80.1.2, TC-80.2.1, TC-80.2.2, TC-80.3.1, TC-80.3.4, TC-80.4.1, TC-80.4.2, TC-80.4.3 |
| P1 | 8 | TC-80.1.3, TC-80.2.3, TC-80.3.2, TC-80.3.3, TC-80.4.4, TC-80.5.2, TC-80.6.1, TC-80.6.2 |
| P2 | 2 | TC-80.3.5, TC-80.7.5 |

#### Ticket #72 - Multi-Threading (17 tests)
| Priority | Count | Test IDs |
|----------|-------|----------|
| P0 | 7 | TC-72.1.1, TC-72.2.1, TC-72.2.2, TC-72.4.1, TC-72.5.1, TC-72.7.1, TC-72.7.2 |
| P1 | 8 | TC-72.1.2, TC-72.1.3, TC-72.2.3, TC-72.2.4, TC-72.3.1, TC-72.3.2, TC-72.4.2-4, TC-72.5.2, TC-72.6.1, TC-72.6.2, TC-72.7.3 |
| P2 | 2 | TC-72.4.5 |

#### Ticket #52 - Help System (24 tests)
| Priority | Count | Test IDs |
|----------|-------|----------|
| P0 | 12 | TC-52.1.1-3, TC-52.2.3, TC-52.3.1-5, TC-52.5.1, TC-52.5.2, TC-52.5.5, TC-52.6.1, TC-52.7.1, TC-52.8.1 |
| P1 | 10 | TC-52.1.4-5, TC-52.2.1-2, TC-52.4.1-2, TC-52.5.3-4, TC-52.6.2, TC-52.7.2-4, TC-52.8.2-5 |
| P2 | 2 | TC-52.4.3, TC-52.6.3 |

---

## Edge Cases Summary

### Ticket #80 - Onboarding

| Edge Case | Test Coverage | Risk |
|-----------|---------------|------|
| App killed during onboarding | TC-80.2.2 (persistence) | Medium |
| Multiple rapid nextStep() calls | Needs test | Low |
| Reset while transitioning | Needs test | Low |
| UserDefaults corruption | Needs test | Low |
| First launch on upgrade (existing user) | Needs test | **High** |

### Ticket #72 - Multi-Threading

| Edge Case | Test Coverage | Risk |
|-----------|---------------|------|
| File exactly 100MB (boundary) | TC-72.2.3 | Medium |
| 0 byte file | Needs test | Low |
| Very large file (>10GB) | Needs test | Medium |
| Network interruption mid-download | Needs integration test | **High** |
| Unsupported provider | Implicit in tests | Medium |
| Concurrent multi-threaded downloads | Needs test | Medium |

### Ticket #52 - Help System

| Edge Case | Test Coverage | Risk |
|-----------|---------------|------|
| Empty search query | Needs test | Low |
| Search query with special chars | Needs test | Medium |
| Unicode in keywords/content | Needs test | Low |
| Very long content (>10000 chars) | Needs test | Low |
| Circular related topics | Needs test | Low |
| Nil vs empty keywords array | TC-52.7.4 | Low |

---

## Error Scenarios

### Ticket #80 - Onboarding

| Error Scenario | Expected Behavior | Test Required |
|----------------|-------------------|---------------|
| UserDefaults write fails | Should not crash, log error | P2 |
| Notification observer deallocated | Weak reference prevents crash | P2 |
| Invalid step index | Should clamp to valid range | P1 |

### Ticket #72 - Multi-Threading

| Error Scenario | Expected Behavior | Test Required |
|----------------|-------------------|---------------|
| rclone not installed | Graceful error, not crash | P0 |
| Thread count exceeds system limit | Should cap at safe maximum | P1 |
| Disk full during download | Proper error propagation | P1 |
| Server rejects multi-thread | Fallback to single-thread | P0 |
| Timeout on chunk download | Retry logic or error | P1 |

### Ticket #52 - Help System

| Error Scenario | Expected Behavior | Test Required |
|----------------|-------------------|---------------|
| Invalid JSON for decode | Should throw, not crash | P0 |
| Missing required field in JSON | Should throw with message | P0 |
| Search on empty topics array | Return empty, not crash | P1 |
| Nil relatedTopicIds lookup | Handle gracefully | P1 |

---

## Recommended Test File Structure

```
CloudSyncAppTests/
├── OnboardingManagerTests.swift          # TC-80.1 through TC-80.6
├── HelpTopicTests.swift                  # TC-52.1 through TC-52.4, TC-52.7, TC-52.8
├── HelpCategoryTests.swift               # TC-52.5, TC-52.6
├── MultiThreadDownloadTests.swift        # TC-72.1 through TC-72.7
│
└── (existing)
    └── TransferOptimizerTests.swift      # Already has some #72 coverage
```

---

## Test Data Requirements

### Ticket #80
- Clean UserDefaults state (use setUp/tearDown)
- Mock NotificationCenter observers

### Ticket #72
- Sample file sizes: 10MB, 100MB, 500MB, 1GB, 10GB (mocked)
- Provider names: "googledrive", "dropbox", "s3", "onedrive", "proton"

### Ticket #52
- Sample HelpTopic JSON fixtures
- Topics in each category
- Topics with various keyword counts (0, 1, 5, 10)
- Topics with relatedTopicIds (nil, empty, populated)

---

## Execution Plan

### Phase 1: Unit Tests (Day 1)
1. Implement P0 tests for all three tickets
2. Run and verify passing

### Phase 2: Edge Cases (Day 2)
1. Implement P1 tests
2. Add identified edge case tests

### Phase 3: UI Tests (Day 3)
1. Implement TC-80.7.x UI tests
2. Integration testing for help system

### Phase 4: Polish (Day 4)
1. P2 tests
2. Code coverage review
3. Documentation

---

*Test Plan Created by QA Specialist*
*Ready for implementation approval*
