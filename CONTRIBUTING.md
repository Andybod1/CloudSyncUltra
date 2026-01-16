# Contributing to CloudSync Ultra

Thank you for your interest in contributing to CloudSync Ultra! We welcome contributions from the community and appreciate your help in making this project better.

This document provides guidelines for contributing to ensure a smooth collaboration process.

## Table of Contents

- [Getting Started](#getting-started)
- [Code Style](#code-style)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Reporting Issues](#reporting-issues)
- [Code of Conduct](#code-of-conduct)

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **macOS 13.0 (Ventura)** or later
- **Xcode 15.0** or later
- **Swift 5.9+**
- **rclone** - Install via Homebrew:
  ```bash
  brew install rclone
  ```
- **Git** - For cloning the repository

### Development Setup

1. **Fork the repository**

   Click the "Fork" button on the GitHub repository page to create your own copy.

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/CloudSyncUltra.git
   cd CloudSyncUltra
   ```

3. **Open the project in Xcode**
   ```bash
   open CloudSyncApp.xcodeproj
   ```

4. **Build and run**

   Press `Cmd+R` to build and run the application.

5. **Verify the setup**

   Run the test suite to ensure everything is working:
   ```bash
   xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS'
   ```

### Project Structure

```
CloudSyncUltra/
├── CloudSyncApp/
│   ├── CloudSyncAppApp.swift    # App entry point
│   ├── Models/                   # Data models
│   ├── ViewModels/               # View logic and state
│   ├── Views/                    # SwiftUI views
│   ├── Managers/                 # Business logic
│   └── Resources/                # Assets and configs
├── CloudSyncAppTests/            # Unit and integration tests
└── docs/                         # Documentation
```

---

## Code Style

We follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with a few project-specific conventions.

### Swift Style Guidelines

#### Indentation and Formatting

- Use **4 spaces** for indentation (no tabs)
- Maximum line length: **120 characters**
- Use blank lines to separate logical sections within functions
- Ensure code builds **without warnings**

#### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Types (classes, structs, enums) | PascalCase | `CloudProvider`, `TransferManager` |
| Functions and methods | camelCase | `fetchRemotes()`, `isConnected()` |
| Variables and properties | camelCase | `currentTask`, `fileCount` |
| Constants | camelCase | `defaultTimeout`, `maxRetryCount` |
| Protocols | Descriptive nouns or `-able`/`-ible` suffix | `Transferable`, `CloudServiceProvider` |
| Enum cases | camelCase | `googleDrive`, `oneDrive` |

#### Code Organization

Within each file, organize code in the following order:

1. Type declaration
2. Properties (static, then instance)
3. Initializers
4. Lifecycle methods
5. Public methods
6. Private methods
7. Extensions and protocol conformance (use `// MARK: -` comments)

Example:
```swift
// MARK: - CloudProvider

struct CloudProvider {
    // MARK: - Properties

    static let allProviders: [CloudProvider] = []

    let id: String
    let name: String
    private var isConnected = false

    // MARK: - Initialization

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    // MARK: - Public Methods

    func connect() async throws {
        // Implementation
    }

    // MARK: - Private Methods

    private func validateCredentials() -> Bool {
        // Implementation
    }
}

// MARK: - Equatable

extension CloudProvider: Equatable {
    static func == (lhs: CloudProvider, rhs: CloudProvider) -> Bool {
        lhs.id == rhs.id
    }
}
```

#### Documentation

- Add documentation comments (`///`) for all public APIs
- Use descriptive parameter and return value documentation
- Include usage examples for complex APIs

```swift
/// Transfers files between two cloud providers.
///
/// - Parameters:
///   - source: The source cloud provider and path
///   - destination: The destination cloud provider and path
///   - options: Transfer options including encryption settings
/// - Returns: A `TransferResult` containing the operation outcome
/// - Throws: `TransferError` if the operation fails
func transferFiles(
    from source: CloudPath,
    to destination: CloudPath,
    options: TransferOptions
) async throws -> TransferResult {
    // Implementation
}
```

#### SwiftUI Best Practices

- Extract complex views into separate files
- Use `@StateObject` for view-owned observable objects
- Use `@EnvironmentObject` for shared app state
- Prefer composition over inheritance
- Keep views focused and small (under 200 lines ideally)

---

## Making Changes

### Branch Naming

Use descriptive branch names with the following prefixes:

| Type | Prefix | Example |
|------|--------|---------|
| New features | `feature/` | `feature/icloud-integration` |
| Bug fixes | `fix/` | `fix/issue-42-progress-display` |
| Documentation | `docs/` | `docs/update-readme` |
| Performance | `perf/` | `perf/optimize-file-listing` |
| Refactoring | `refactor/` | `refactor/split-rclone-manager` |
| Tests | `test/` | `test/add-encryption-tests` |

### Commit Messages

Write clear, concise commit messages in present tense:

#### Format

```
<type>: Short summary (72 chars max)

Longer description explaining the change if needed.
- Bullet points for multiple items
- Reference issues when applicable

Closes #<issue-number>
```

#### Types

- `Add` - New feature or functionality
- `Fix` - Bug fix
- `Update` - Enhancement to existing feature
- `Remove` - Removing code or features
- `Refactor` - Code restructuring without behavior change
- `Docs` - Documentation changes
- `Test` - Adding or updating tests
- `Chore` - Maintenance tasks (dependencies, configs)

#### Examples

```
Add multi-thread download support for large files

- Implement parallel chunk downloading
- Add provider capability detection
- Include unit tests for new functionality

Closes #72
```

```
Fix progress display for cloud-to-cloud transfers

The progress bar was not updating during cloud-to-cloud
transfers due to missing stats flag in rclone command.

Fixes #21
```

### Keeping Your Fork Updated

Before starting new work, sync your fork with the upstream repository:

```bash
# Add upstream remote (one-time setup)
git remote add upstream https://github.com/andybod1-lang/CloudSyncUltra.git

# Fetch and merge upstream changes
git fetch upstream
git checkout main
git merge upstream/main

# Push to your fork
git push origin main
```

---

## Pull Request Process

### Before Submitting

1. **Run the test suite**
   ```bash
   xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS'
   ```

   **Expected:** 855+ tests should pass

2. **Ensure clean build**

   Build the project and resolve any warnings:
   ```bash
   xcodebuild -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -configuration Release build
   ```

   **Required:** No build warnings

3. **Test manually**

   Run the app and verify your changes work as expected.

4. **Update documentation**

   Update relevant documentation if your changes affect:
   - Public APIs
   - User-facing features
   - Configuration options
   - Installation steps

### PR Requirements

When submitting a pull request:

1. **Title**: Use a clear, descriptive title
   - Good: "Add bandwidth throttling controls to Settings"
   - Bad: "Fix bug" or "Update code"

2. **Description**: Include:
   - Summary of changes
   - Related issue numbers (e.g., "Closes #42")
   - Screenshots for UI changes
   - Testing notes

3. **Test coverage**:
   - New features must include tests
   - Bug fixes should include regression tests
   - Maintain or improve code coverage

4. **Single responsibility**:
   - Each PR should address one concern
   - Split large changes into smaller PRs

### PR Template

```markdown
## Summary

Brief description of what this PR does.

## Related Issues

Closes #<issue-number>

## Changes

- List of specific changes
- Another change

## Test Plan

- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] All existing tests pass

## Screenshots (if applicable)

<!-- Add screenshots for UI changes -->

## Checklist

- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] No build warnings
- [ ] Tests pass (855+ expected)
```

### Review Process

1. Submit your PR against the `main` branch
2. Automated CI checks will run
3. Wait for code review from maintainers
4. Address any feedback or requested changes
5. Once approved, a maintainer will merge your PR

---

## Testing

### Running Tests

#### Via Xcode

```bash
# Run all tests
Cmd+U

# Run specific test
Cmd+Ctrl+U (with cursor in test method)
```

#### Via Command Line

```bash
# Run all tests
xcodebuild test \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -destination 'platform=macOS'

# Run specific test file
xcodebuild test \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -only-testing:CloudSyncAppTests/FileItemTests

# Run specific test method
xcodebuild test \
  -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -only-testing:CloudSyncAppTests/FileItemTests/testFileItemCreation
```

### Writing Tests

#### Test File Location

Place test files in `CloudSyncAppTests/` following the naming convention:
- `<ClassName>Tests.swift` for unit tests
- `<Feature>IntegrationTests.swift` for integration tests

#### Test Structure

```swift
import XCTest
@testable import CloudSyncApp

final class CloudProviderTests: XCTestCase {

    // MARK: - Properties

    var sut: CloudProvider!  // System Under Test

    // MARK: - Setup/Teardown

    override func setUp() {
        super.setUp()
        sut = CloudProvider(id: "test", name: "Test Provider")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testProviderInitialization() {
        // Given
        let id = "google-drive"
        let name = "Google Drive"

        // When
        let provider = CloudProvider(id: id, name: name)

        // Then
        XCTAssertEqual(provider.id, id)
        XCTAssertEqual(provider.name, name)
    }

    func testConnectionThrowsWhenInvalidCredentials() async {
        // Given
        let provider = CloudProvider(id: "test", name: "Test")

        // When/Then
        do {
            try await provider.connect()
            XCTFail("Expected connection to throw")
        } catch {
            XCTAssertTrue(error is ConnectionError)
        }
    }
}
```

#### Test Best Practices

- **Naming**: Use descriptive test names that explain what is being tested
  - Good: `testTransferProgressUpdatesWhenFilesComplete()`
  - Bad: `testProgress()`

- **Arrange-Act-Assert**: Structure tests with clear Given/When/Then sections

- **Test one thing**: Each test should verify a single behavior

- **Test edge cases**: Include tests for:
  - Empty inputs
  - Boundary values
  - Error conditions
  - Invalid states

- **Avoid dependencies**: Tests should not depend on each other

- **Mock external services**: Use mocks for network and filesystem operations

### Test Categories

| Category | Description | Location |
|----------|-------------|----------|
| Unit Tests | Test individual components in isolation | `CloudSyncAppTests/` |
| Integration Tests | Test component interactions | `CloudSyncAppTests/*IntegrationTests.swift` |
| UI Tests | Test user interface and workflows | `CloudSyncAppUITests/` |

### Current Test Coverage

- **855+ automated tests** across all layers
- **88%+ coverage** for error handling
- **75% overall coverage**

See `CloudSyncAppTests/TEST_COVERAGE.md` for detailed test inventory.

---

## Reporting Issues

### Bug Reports

When reporting a bug, please include:

1. **Environment**
   - macOS version (e.g., macOS 14.2)
   - CloudSync Ultra version (e.g., v2.0.15)
   - rclone version (`rclone version`)

2. **Description**
   - What you expected to happen
   - What actually happened
   - Steps to reproduce

3. **Logs**
   - Export logs from Help menu if relevant
   - Console output for crashes

4. **Screenshots**
   - Include screenshots for UI-related issues

#### Bug Report Template

```markdown
## Environment

- macOS:
- CloudSync Ultra:
- rclone:

## Description

A clear description of the bug.

## Steps to Reproduce

1. Go to...
2. Click on...
3. Observe...

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Logs/Screenshots

<!-- Attach relevant logs or screenshots -->

## Additional Context

Any other relevant information.
```

### Feature Requests

Before submitting a feature request:

1. **Search existing issues** to avoid duplicates
2. **Check the roadmap** in CHANGELOG.md

When submitting a feature request:

1. **Describe the use case** - What problem does this solve?
2. **Propose a solution** - How should it work?
3. **Consider alternatives** - Are there other ways to achieve this?

#### Feature Request Template

```markdown
## Problem Statement

Describe the problem or need this feature addresses.

## Proposed Solution

Describe how you envision this feature working.

## Alternatives Considered

List any alternative solutions you've considered.

## Additional Context

Screenshots, mockups, or examples from other apps.
```

### Security Issues

For security vulnerabilities, please do NOT open a public issue. Instead:

1. Email the maintainers directly
2. Provide detailed information about the vulnerability
3. Allow time for a fix before public disclosure

---

## Code of Conduct

### Our Standards

We are committed to providing a welcoming and inclusive environment. Contributors are expected to:

- **Be respectful** - Treat everyone with dignity and respect
- **Be constructive** - Provide helpful feedback and accept constructive criticism
- **Be collaborative** - Work together toward shared goals
- **Be patient** - Remember that everyone has different experience levels
- **Be professional** - Keep discussions focused and productive

### Unacceptable Behavior

The following behaviors are not tolerated:

- Harassment, discrimination, or offensive comments
- Personal attacks or insults
- Trolling or inflammatory comments
- Publishing others' private information
- Any conduct inappropriate for a professional setting

### Enforcement

Instances of unacceptable behavior may be reported to the project maintainers. All complaints will be reviewed and investigated, resulting in a response appropriate to the circumstances.

---

## Getting Help

If you have questions or need help:

1. **Check existing documentation** in the `docs/` folder
2. **Search closed issues** for similar questions
3. **Open a Discussion** on GitHub for general questions
4. **Open an Issue** for bugs or feature requests

---

## Recognition

Contributors who make significant contributions will be recognized in:

- Release notes
- The project README
- The contributors list

Thank you for contributing to CloudSync Ultra!

---

*Last updated: January 2026*
