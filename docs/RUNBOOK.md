# CloudSync Ultra Runbook

> Step-by-step guides for common operations

---

## Table of Contents

1. [Daily Development](#daily-development)
2. [Sprint Operations](#sprint-operations)
3. [Release Process](#release-process)
4. [Troubleshooting](#troubleshooting)
5. [Worker Management](#worker-management)

---

## Daily Development

### Build and Launch App

```bash
cd /Users/antti/Claude

# Build
xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Debug build 2>&1 | tail -10

# Launch
open ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*/Build/Products/Debug/CloudSyncApp.app
```

### Run Tests

```bash
# All tests
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' 2>&1 | grep -E "(Test Case|Executed|error:)"

# Specific test file
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -only-testing:CloudSyncAppTests/SyncManagerTests 2>&1 | tail -30

# Count tests
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp 2>&1 | grep "Executed" | tail -1
```

### Check Project Health

```bash
./scripts/dashboard.sh
```

---

## Sprint Operations

### Start New Sprint

1. Update STATUS.md with sprint goals
2. Create task files for each worker
3. Launch workers in parallel
4. Monitor progress via git log

### Launch Single Worker

```bash
# Open Terminal, navigate to project
cd /Users/antti/Claude

# Start Claude Code
claude

# Give prompt:
# "You are Dev-1, execute task from .claude-team/tasks/TASK_DEV1.md"
```

### Launch All Workers

Open 5 Terminal windows and run `claude` in each with appropriate role prompt.

### Monitor Worker Progress

```bash
# Check for new commits
git log --oneline -10

# Check uncommitted changes
git status --short

# Check specific worker's files
git diff CloudSyncApp/Views/  # Dev-1
git diff CloudSyncApp/RcloneManager.swift  # Dev-2
```

### Complete Sprint

1. Pull all changes
2. Run full test suite
3. Update VERSION.txt
4. Update CHANGELOG.md
5. Update CLAUDE_PROJECT_KNOWLEDGE.md
6. Commit and push
7. Archive task files

---

## Release Process

### Automated Release

```bash
./scripts/release.sh 2.0.22
```

This script:
1. Updates VERSION.txt
2. Updates all documentation versions
3. Runs version validation
4. Creates git tag
5. Pushes to GitHub

### Manual Release Steps

```bash
# 1. Update version
echo "2.0.22" > VERSION.txt

# 2. Update docs
./scripts/update-version.sh 2.0.22

# 3. Validate
./scripts/version-check.sh

# 4. Commit
git add -A
git commit -m "v2.0.22: Sprint description"

# 5. Tag
git tag -a v2.0.22 -m "Version 2.0.22"

# 6. Push
git push origin main --tags
```

---

## Troubleshooting

### Build Fails

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/CloudSyncApp-*

# Rebuild
xcodebuild clean build -project CloudSyncApp.xcodeproj -scheme CloudSyncApp
```

### Tests Fail

```bash
# Run specific failing test with verbose output
xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp \
  -only-testing:CloudSyncAppTests/FailingTestClass/testFailingMethod \
  2>&1 | tail -50
```

### Git Conflicts

```bash
# Check status
git status

# If workers created conflicts:
git stash  # Save local changes
git pull --rebase
git stash pop  # Restore changes
# Manually resolve conflicts
```

### Worker Not Responding

1. Check Terminal window for errors
2. If stuck, close Terminal and relaunch
3. Worker will read task file fresh

---

## Worker Management

### File Ownership Reference

| Worker | Files |
|--------|-------|
| Dev-1 | Views/*.swift, Components/*.swift |
| Dev-2 | RcloneManager.swift, TransferEngine/*.swift |
| Dev-3 | Models/*.swift, *Manager.swift (except Rclone) |
| QA | CloudSyncAppTests/*.swift |
| Dev-Ops | docs/*.md, scripts/*.sh |

### Prevent Conflicts

Before parallel sprint:
1. Identify all files each worker will touch
2. Ensure no overlap
3. If overlap exists, assign to single worker or sequence

### Worker Prompts Template

```
You are [WORKER], the [SPECIALTY] specialist.
Execute task from .claude-team/tasks/TASK_[WORKER].md
Use /think for planning.
Build, test, commit when done.
```

---

*Last Updated: 2026-01-15*
