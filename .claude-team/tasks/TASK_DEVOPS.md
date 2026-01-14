# DevOps Task: CI/CD Pipeline with GitHub Actions

**Sprint:** Maximum Productivity
**Priority:** High
**Worker:** DevOps

---

## Objective

Create GitHub Actions workflow for automated testing on every push and pull request.

## Files to Create

- `.github/workflows/test.yml`
- `.github/workflows/build.yml` (optional - for release builds)

## Tasks

### 1. Create Test Workflow

Create `.github/workflows/test.yml`:

```yaml
name: Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Run Tests
    runs-on: macos-14

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode version
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Build
        run: |
          xcodebuild build \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -destination 'platform=macOS' \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO

      - name: Run Tests
        run: |
          xcodebuild test \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -destination 'platform=macOS' \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            | xcpretty --report junit

      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: build/reports/junit.xml

  lint:
    name: SwiftLint
    runs-on: macos-14

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run SwiftLint
        run: |
          if which swiftlint >/dev/null; then
            swiftlint lint --reporter github-actions-logging
          else
            echo "SwiftLint not installed, skipping"
          fi
```

### 2. Create Build Status Badge

Add to README.md after the title:

```markdown
![Tests](https://github.com/andybod1-lang/CloudSyncUltra/actions/workflows/test.yml/badge.svg)
```

### 3. Create Branch Protection Rules (Documentation)

Document recommended settings for Andy to configure:

```markdown
## Branch Protection (Recommended)

For `main` branch:
- [x] Require status checks to pass before merging
- [x] Require branches to be up to date before merging
- [x] Required status checks: "Run Tests"
- [x] Require pull request reviews before merging
```

### 4. Optional: Release Build Workflow

Create `.github/workflows/release.yml` for tagged releases:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    name: Build Release
    runs-on: macos-14

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build Archive
        run: |
          xcodebuild archive \
            -project CloudSyncApp.xcodeproj \
            -scheme CloudSyncApp \
            -archivePath build/CloudSyncApp.xcarchive \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO

      - name: Export App
        run: |
          xcodebuild -exportArchive \
            -archivePath build/CloudSyncApp.xcarchive \
            -exportPath build/export \
            -exportOptionsPlist ExportOptions.plist

      - name: Create DMG
        run: |
          hdiutil create -volname "CloudSync Ultra" \
            -srcfolder build/export/CloudSyncApp.app \
            -ov -format UDZO \
            build/CloudSyncUltra-${{ github.ref_name }}.dmg

      - name: Upload Release Asset
        uses: actions/upload-artifact@v4
        with:
          name: CloudSyncUltra-${{ github.ref_name }}
          path: build/CloudSyncUltra-*.dmg
```

## Verification

1. Commit workflow files
2. Push to GitHub
3. Check Actions tab for workflow runs
4. Verify tests execute and pass
5. Verify badge displays correctly

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/DEVOPS_COMPLETE.md`

Include:
- Workflow files created
- Badge markdown
- Any issues encountered

## Success Criteria

- [ ] test.yml workflow created
- [ ] Workflow triggers on push/PR
- [ ] Tests run successfully in CI
- [ ] Badge added to README
- [ ] Documentation for branch protection
