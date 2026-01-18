# Contributing to {{PROJECT_NAME}}

Thank you for your interest in contributing to {{PROJECT_NAME}}! We welcome contributions from the community and appreciate your help in making this project better.

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

- **macOS {{MIN_OS_VERSION}}** or later
- **Xcode {{XCODE_VERSION}}** or later
- **Swift {{SWIFT_VERSION}}+**
- **Dependencies**:
  ```bash
  {{DEPENDENCY_INSTALL_COMMAND}}
  ```
- **Git** - For cloning the repository

### Development Setup

1. **Fork the repository**

   Click the "Fork" button on the GitHub repository page to create your own copy.

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/{{PROJECT_DIR}}.git
   cd {{PROJECT_DIR}}
   ```

3. **Open the project in Xcode**
   ```bash
   open {{PROJECT_FILE}}
   ```

4. **Build and run**

   Press `Cmd+R` to build and run the application.

5. **Verify the setup**

   Run the test suite to ensure everything is working:
   ```bash
   {{TEST_COMMAND}}
   ```

### Project Structure

```
{{PROJECT_DIR}}/
├── {{SOURCE_DIR}}/
│   ├── {{APP_ENTRY_POINT}}    # App entry point
│   ├── Models/                 # Data models
│   ├── ViewModels/             # View logic and state
│   ├── Views/                  # SwiftUI views
│   ├── Managers/               # Business logic
│   └── Resources/              # Assets and configs
├── {{TEST_DIR}}/               # Unit and integration tests
└── docs/                       # Documentation
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
| Types (classes, structs, enums) | PascalCase | `DataModel`, `TransferManager` |
| Functions and methods | camelCase | `fetchData()`, `isConnected()` |
| Variables and properties | camelCase | `currentTask`, `itemCount` |
| Constants | camelCase | `defaultTimeout`, `maxRetryCount` |
| Protocols | Descriptive nouns or `-able`/`-ible` suffix | `Transferable`, `ServiceProvider` |
| Enum cases | camelCase | `optionOne`, `optionTwo` |

#### Code Organization

Within each file, organize code in the following order:

1. Type declaration
2. Properties (static, then instance)
3. Initializers
4. Lifecycle methods
5. Public methods
6. Private methods
7. Extensions and protocol conformance (use `// MARK: -` comments)

#### Documentation

- Add documentation comments (`///`) for all public APIs
- Use descriptive parameter and return value documentation
- Include usage examples for complex APIs

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
| New features | `feature/` | `feature/new-capability` |
| Bug fixes | `fix/` | `fix/issue-42-display-bug` |
| Documentation | `docs/` | `docs/update-readme` |
| Performance | `perf/` | `perf/optimize-loading` |
| Refactoring | `refactor/` | `refactor/split-manager` |
| Tests | `test/` | `test/add-unit-tests` |

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

### Keeping Your Fork Updated

Before starting new work, sync your fork with the upstream repository:

```bash
# Add upstream remote (one-time setup)
git remote add upstream {{GITHUB_URL}}.git

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
   {{TEST_COMMAND}}
   ```

   **Expected:** {{TEST_COUNT}}+ tests should pass

2. **Ensure clean build**

   Build the project and resolve any warnings:
   ```bash
   {{BUILD_COMMAND}}
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
2. **Description**: Include summary, related issues, screenshots for UI changes
3. **Test coverage**: New features must include tests
4. **Single responsibility**: Each PR should address one concern

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
{{TEST_COMMAND}}
```

### Writing Tests

#### Test Structure

```swift
import XCTest
@testable import {{SOURCE_DIR}}

final class MyTests: XCTestCase {

    // MARK: - Properties

    var sut: MyClass!  // System Under Test

    // MARK: - Setup/Teardown

    override func setUp() {
        super.setUp()
        sut = MyClass()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testExample() {
        // Given
        let input = "test"

        // When
        let result = sut.process(input)

        // Then
        XCTAssertEqual(result, expected)
    }
}
```

### Test Categories

| Category | Description | Location |
|----------|-------------|----------|
| Unit Tests | Test individual components in isolation | `{{TEST_DIR}}/` |
| Integration Tests | Test component interactions | `{{TEST_DIR}}/*IntegrationTests.swift` |
| UI Tests | Test user interface and workflows | `{{UI_TEST_DIR}}/` |

### Current Test Coverage

- **{{TEST_COUNT}}+ automated tests** across all layers
- **{{COVERAGE}}% overall coverage**

---

## Reporting Issues

### Bug Reports

When reporting a bug, please include:

1. **Environment** - OS version, app version
2. **Description** - Expected vs actual behavior, steps to reproduce
3. **Logs** - Relevant error messages or screenshots

### Feature Requests

Before submitting a feature request:

1. **Search existing issues** to avoid duplicates
2. **Check the roadmap** in CHANGELOG.md

When submitting:
1. **Describe the use case** - What problem does this solve?
2. **Propose a solution** - How should it work?
3. **Consider alternatives** - Are there other ways to achieve this?

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

Thank you for contributing to {{PROJECT_NAME}}!

---

*Last updated: {{DATE}}*
