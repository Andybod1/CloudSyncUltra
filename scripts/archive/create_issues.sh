#!/bin/bash
# Create GitHub Issues from INBOX.md tickets
# Usage: ./create_issues.sh

cd "$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}📋 Creating GitHub Issues${NC}"
echo "=============================="

# Critical Priority
echo -e "\n${GREEN}Creating Critical Priority Issues...${NC}"

gh issue create \
    --title "[Bug] Fix 11 failing unit tests" \
    --body "## Description
11 unit tests are failing (743 tests total, 11 failing with 0 unexpected).

## Tasks
- [ ] Run tests and capture specific failure output
- [ ] Identify root cause of each failure
- [ ] Fix failing tests
- [ ] Verify all 743 tests pass

## Acceptance Criteria
- All 743 tests pass
- Zero test failures" \
    --label "bug,priority:critical,component:tests"

# High Priority
echo -e "\n${GREEN}Creating High Priority Issues...${NC}"

gh issue create \
    --title "[Feature] Integrate UI test suite into Xcode project" \
    --body "## Description
73 UI tests exist in \`CloudSyncAppUITests_backup/\` but are not integrated into the Xcode project.

## Tasks
- [ ] Create CloudSyncAppUITests target in Xcode
- [ ] Move test files from backup folder
- [ ] Configure test scheme
- [ ] Verify all 73 UI tests run

## References
- QUALITY_ANALYSIS_REPORT.md
- UI_TEST_AUTOMATION_COMPLETE.md

## Acceptance Criteria
- UI test target exists in Xcode
- All 73 UI tests execute" \
    --label "enhancement,priority:high,component:tests"

gh issue create \
    --title "[Refactor] Split RcloneManager.swift (1,511 lines)" \
    --body "## Description
RcloneManager.swift is 1,511 lines and becoming monolithic. Split into smaller, focused files.

## Proposed Structure
- \`RcloneCore.swift\` - Core rclone execution
- \`ProviderConfigurator.swift\` - Provider setup methods
- \`TransferManager.swift\` - Transfer operations

## Tasks
- [ ] Extract provider setup methods to ProviderConfigurator
- [ ] Extract transfer logic to TransferManager
- [ ] Keep core execution in RcloneCore
- [ ] Update all imports/references
- [ ] Ensure tests still pass

## Acceptance Criteria
- Each file < 500 lines
- All existing tests pass
- No functionality changes" \
    --label "refactor,priority:high,component:engine"

gh issue create \
    --title "[Feature] Add CI/CD pipeline with GitHub Actions" \
    --body "## Description
Set up automated builds, test runs, and code coverage reporting.

## Tasks
- [ ] Create \`.github/workflows/test.yml\`
- [ ] Configure macOS runner
- [ ] Add build step
- [ ] Add test execution step
- [ ] Add code coverage reporting
- [ ] Add badge to README

## Example Workflow
\`\`\`yaml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: xcodebuild build -scheme CloudSyncApp
      - name: Test
        run: xcodebuild test -scheme CloudSyncApp
\`\`\`

## Acceptance Criteria
- Tests run on every push/PR
- Build status visible in GitHub" \
    --label "enhancement,priority:high,component:devops"

# Medium Priority
echo -e "\n${GREEN}Creating Medium Priority Issues...${NC}"

gh issue create \
    --title "[Feature] Add SwiftLint configuration" \
    --body "## Description
Add \`.swiftlint.yml\` for automated code style enforcement.

## Tasks
- [ ] Create .swiftlint.yml with project rules
- [ ] Run SwiftLint and fix violations
- [ ] Add to build phase (optional warning)
- [ ] Document coding standards

## Acceptance Criteria
- SwiftLint passes on all code
- Configuration documented" \
    --label "enhancement,priority:medium,component:devops"

gh issue create \
    --title "[Feature] Add accessibility support (VoiceOver)" \
    --body "## Description
Add accessibility support for users with disabilities.

## Tasks
- [ ] Add VoiceOver labels to all interactive elements
- [ ] Implement keyboard shortcuts for common actions
- [ ] Add Dynamic Type support for text scaling
- [ ] Add Reduce Motion support for animations
- [ ] Test with VoiceOver enabled

## References
- QUALITY_IMPROVEMENT_PLAN.md Phase 3

## Acceptance Criteria
- App is fully navigable with VoiceOver
- Keyboard shortcuts documented in Help menu" \
    --label "enhancement,priority:medium,component:ui,accessibility"

gh issue create \
    --title "[Feature] Implement OSLog logging" \
    --body "## Description
Replace print statements with Apple's unified logging system (OSLog).

## Tasks
- [ ] Create Logger extensions for categories
- [ ] Categories: Network, UI, Sync, FileOps
- [ ] Replace print() with appropriate log levels
- [ ] Ensure privacy-preserving logs
- [ ] Add performance metrics tracking

## Example
\`\`\`swift
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let network = Logger(subsystem: subsystem, category: \"network\")
    static let sync = Logger(subsystem: subsystem, category: \"sync\")
}
\`\`\`

## Acceptance Criteria
- No print() statements remain
- Logs visible in Console.app" \
    --label "enhancement,priority:medium,component:engine"

gh issue create \
    --title "[Feature] Pagination for large file lists (>1000 files)" \
    --body "## Description
Add lazy loading and pagination to prevent UI blocking with large directories.

## Tasks
- [ ] Implement lazy loading in FileBrowserView
- [ ] Add pagination (load 100 files at a time)
- [ ] Add loading indicator for more files
- [ ] Test with 10,000+ file directory
- [ ] Profile memory usage

## References
- QUALITY_ANALYSIS_REPORT.md Performance section

## Acceptance Criteria
- UI remains responsive with 10,000+ files
- Memory usage stays reasonable" \
    --label "enhancement,priority:medium,component:ui,performance"

gh issue create \
    --title "[Feature] User notifications for completed transfers" \
    --body "## Description
Add macOS notifications when transfers complete and progress in Dock icon.

## Tasks
- [ ] Request notification permissions
- [ ] Send notification on transfer complete
- [ ] Send notification on transfer error
- [ ] Add progress indicator in Dock icon
- [ ] Add optional sound effects
- [ ] Add preference to disable notifications

## Acceptance Criteria
- Notifications appear when app is in background
- Dock icon shows progress during transfers" \
    --label "enhancement,priority:medium,component:ui"

# Low Priority
echo -e "\n${GREEN}Creating Low Priority Issues...${NC}"

gh issue create \
    --title "[Docs] Add CHANGELOG.md" \
    --body "## Description
Create changelog to track version history.

## Tasks
- [ ] Create CHANGELOG.md
- [ ] Document v2.0.0 features
- [ ] Follow Keep a Changelog format
- [ ] Link from README

## Acceptance Criteria
- CHANGELOG.md exists with v2.0.0 entry" \
    --label "documentation,priority:low"

gh issue create \
    --title "[Docs] Add CONTRIBUTING.md" \
    --body "## Description
Create guidelines for contributors.

## Tasks
- [ ] Create CONTRIBUTING.md
- [ ] Document code style requirements
- [ ] Document PR process
- [ ] Document testing requirements
- [ ] Add code of conduct reference

## Acceptance Criteria
- CONTRIBUTING.md exists and is linked from README" \
    --label "documentation,priority:low"

gh issue create \
    --title "[Feature] Add Touch ID/biometric authentication" \
    --body "## Description
Add optional biometric authentication for sensitive operations.

## Tasks
- [ ] Add LocalAuthentication framework
- [ ] Add Touch ID prompt for encryption settings
- [ ] Add preference to enable/disable
- [ ] Graceful fallback for devices without Touch ID

## Acceptance Criteria
- Touch ID works on supported Macs
- Can be disabled in preferences" \
    --label "enhancement,priority:low,component:security"

gh issue create \
    --title "[Feature] Quick Look preview for cloud files" \
    --body "## Description
Add macOS Quick Look integration for previewing cloud files.

## Tasks
- [ ] Implement QLPreviewProvider
- [ ] Download file temporarily for preview
- [ ] Support common file types (images, PDFs, text)
- [ ] Clean up temp files after preview

## Acceptance Criteria
- Press Space to preview files in file browser" \
    --label "enhancement,priority:low,component:ui"

# QA
echo -e "\n${GREEN}Creating QA Issues...${NC}"

gh issue create \
    --title "[QA] Manual error handling verification" \
    --body "## Description
Execute manual test checklist for error handling.

## Test Checklist
### Error Detection
- [ ] Upload to full Google Drive → quota error shown
- [ ] Disconnect internet → connection error shown
- [ ] Revoke OAuth → auth error shown

### Error Display
- [ ] Error banner appears immediately
- [ ] Correct icon and color for severity
- [ ] Message is clear and actionable
- [ ] Auto-dismisses after 10s (non-critical)

### Task Error States
- [ ] Failed task shows red X in Tasks view
- [ ] Partial success shows orange triangle
- [ ] Error message displays in task card
- [ ] Retry button appears for retryable errors

### Error Propagation
- [ ] Transfer error → Progress stream → UI banner
- [ ] Transfer error → SyncTask → Tasks view
- [ ] Multiple errors stack properly

## References
- QA_FINAL_REPORT.md

## Acceptance Criteria
- All checklist items verified" \
    --label "testing,priority:medium,component:tests"

echo -e "\n${GREEN}✅ All issues created!${NC}"
echo "Run 'gh issue list' to see them."
