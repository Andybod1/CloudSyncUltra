# Definition of Done (DoD)

> A task is only DONE when ALL criteria are met

---

## Code Changes

- [ ] **Code compiles** - `xcodebuild build` succeeds without errors
- [ ] **Tests pass** - All existing tests pass
- [ ] **New tests added** - New functionality has test coverage
- [ ] **No warnings** - Build produces no new warnings
- [ ] **Linted** - Code follows project style guidelines

## Documentation

- [ ] **Code commented** - Complex logic has inline comments
- [ ] **Public API documented** - New public methods have doc comments
- [ ] **CHANGELOG updated** - Changes noted in CHANGELOG.md
- [ ] **README updated** - If user-facing behavior changed

## Git & GitHub

- [ ] **Atomic commit** - Single logical change per commit
- [ ] **Conventional commit** - Message follows format: `type(scope): description`
- [ ] **Issue linked** - Commit references issue number (e.g., `#42`)
- [ ] **Pushed** - Changes pushed to remote

## Review

- [ ] **Self-reviewed** - Author reviewed their own diff
- [ ] **Build verified** - App launches and works correctly
- [ ] **Edge cases checked** - Tested with unusual inputs

---

## Quick Reference

### Commit Message Format
```
type(scope): short description

Longer description if needed.

Closes #42
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `test` - Adding tests
- `refactor` - Code change that neither fixes bug nor adds feature
- `chore` - Maintenance tasks

### Scopes
- `ui` - Views, Components
- `engine` - RcloneManager, transfers
- `services` - Models, Managers
- `tests` - Test files

---

## Worker Completion Protocol

1. ✅ All DoD checkboxes verified
2. ✅ Task file updated with completion status
3. ✅ Commit pushed to git
4. ✅ Report completion to Strategic Partner

---

*Quality is not negotiable.*
