# Documentation Task: Create CONTRIBUTING.md

**Issue:** #92
**Sprint:** Next Sprint
**Priority:** Low
**Worker:** Tech Writer

---

## Objective

Create CONTRIBUTING.md with guidelines for contributors.

## File to Create

- `CONTRIBUTING.md` (project root)

## Tasks

### 1. Create CONTRIBUTING.md

```markdown
# Contributing to CloudSync Ultra

Thank you for your interest in contributing to CloudSync Ultra!

## Getting Started

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9+
- rclone installed (`brew install rclone`)

### Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/CloudSyncUltra.git`
3. Open `CloudSyncApp.xcodeproj` in Xcode
4. Build and run (⌘R)

## Code Style

### Swift Style Guide
- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Use descriptive variable names

### Formatting
- Run SwiftLint before committing (if configured)
- Ensure code builds without warnings
- Follow existing patterns in the codebase

### Naming Conventions
- Types: `PascalCase` (e.g., `CloudProvider`, `TransferManager`)
- Functions/variables: `camelCase` (e.g., `fetchRemotes`, `isConnected`)
- Constants: `camelCase` (e.g., `defaultTimeout`)
- Protocols: Descriptive nouns or `-able` suffix (e.g., `Transferable`)

## Making Changes

### Branch Naming
- Features: `feature/short-description`
- Bug fixes: `fix/issue-number-description`
- Documentation: `docs/what-changed`

### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Keep first line under 72 characters
- Reference issues when applicable: "Fix #123: Description"

Example:
```
Add multi-thread download support for large files

- Implement parallel chunk downloading
- Add provider capability detection
- Include unit tests for new functionality

Closes #72
```

## Pull Request Process

### Before Submitting
1. **Test your changes**: Run `./run_tests.sh`
2. **All tests must pass**: 743+ tests expected
3. **No build warnings**: Clean build required
4. **Update documentation** if needed

### PR Requirements
- Clear title describing the change
- Reference any related issues
- Include test coverage for new code
- Screenshots for UI changes

### Review Process
1. Submit PR against `main` branch
2. Wait for CI checks to pass
3. Address review feedback
4. Maintainer will merge when approved

## Testing

### Running Tests
```bash
# Run all tests
./run_tests.sh

# Run specific test file
xcodebuild test -project CloudSyncApp.xcodeproj \
  -scheme CloudSyncApp \
  -only-testing:CloudSyncAppTests/YourTestClass
```

### Writing Tests
- Place tests in `CloudSyncAppTests/`
- Follow existing test patterns
- Aim for meaningful coverage, not just line count
- Test edge cases and error conditions

## Reporting Issues

### Bug Reports
Include:
- macOS version
- App version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs (export from Help menu)

### Feature Requests
- Check existing issues first
- Describe the use case
- Suggest implementation if possible

## Code of Conduct

Be respectful and constructive. We're all here to build something great.

## Questions?

- Open a Discussion on GitHub
- Check existing documentation in `/docs`

---

Thank you for contributing! 🚀
```

### 2. Link from README

Add to README.md under a "Contributing" section:

```markdown
## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
```

## Verification

1. CONTRIBUTING.md exists in project root
2. Contains all required sections:
   - Getting Started
   - Code Style
   - Making Changes
   - Pull Request Process
   - Testing
   - Code of Conduct reference
3. Linked from README.md

## Output

Write completion report to: `/Users/antti/Claude/.claude-team/outputs/CONTRIBUTING_COMPLETE.md`

## Success Criteria

- [ ] CONTRIBUTING.md created
- [ ] Code style documented
- [ ] PR process documented
- [ ] Testing requirements documented
- [ ] Code of conduct referenced
- [ ] Linked from README
