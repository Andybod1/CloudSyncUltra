# Project Runbook

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

### Build Project

```bash
cd /path/to/project

# Build command (customize for your project)
# Examples:
# npm run build
# cargo build
# xcodebuild build
# go build
```

### Run Tests

```bash
# All tests
# npm test
# cargo test
# xcodebuild test

# Specific test
# npm test -- --grep "pattern"
```

### Check Project Health

```bash
./scripts/dashboard.sh
```

### Build API Documentation

```bash
# Build and open documentation
./scripts/build-docs.sh --open

# For Xcode projects: Product → Build Documentation (⌃⇧⌘D)
# Then view: Window → Developer Documentation
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
cd /path/to/project
claude

# Give prompt:
# "You are Dev-1, execute task from .claude-team/tasks/TASK_DEV1.md"
```

### Monitor Worker Progress

```bash
# Check for new commits
git log --oneline -10

# Check uncommitted changes
git status --short
```

### Complete Sprint

1. Pull all changes
2. Run full test suite
3. Update VERSION.txt
4. Update CHANGELOG.md
5. Commit and push
6. Archive task files

---

## Release Process

### Automated Release

```bash
./scripts/release.sh X.Y.Z
```

### Manual Release Steps

```bash
# 1. Update version
echo "X.Y.Z" > VERSION.txt

# 2. Update docs
./scripts/update-version.sh X.Y.Z

# 3. Validate
./scripts/version-check.sh

# 4. Commit
git add -A
git commit -m "vX.Y.Z: Release description"

# 5. Tag
git tag -a vX.Y.Z -m "Version X.Y.Z"

# 6. Push
git push origin main --tags
```

---

## Troubleshooting

### Build Fails

```bash
# Clean build artifacts
rm -rf build/ dist/ node_modules/

# Reinstall dependencies
npm install  # or equivalent

# Rebuild
npm run build
```

### Tests Fail

```bash
# Run specific failing test with verbose output
npm test -- --verbose --grep "failing test"
```

### Git Conflicts

```bash
git status
git stash
git pull --rebase
git stash pop
# Manually resolve conflicts
```

---

## Worker Management

### File Ownership Reference

| Worker | Files |
|--------|-------|
| Dev-1 | UI components, views |
| Dev-2 | Core engine, business logic |
| Dev-3 | Models, services |
| QA | Test files |
| Dev-Ops | Docs, scripts, CI/CD |

### Prevent Conflicts

Before parallel sprint:
1. Identify all files each worker will touch
2. Ensure no overlap
3. If overlap exists, assign to single worker

### Worker Prompts Template

```
You are [WORKER], the [SPECIALTY] specialist.
Execute task from .claude-team/tasks/TASK_[WORKER].md
Use /think for planning.
Build, test, commit when done.
```

---

*Customize this runbook for your project's specific needs.*
