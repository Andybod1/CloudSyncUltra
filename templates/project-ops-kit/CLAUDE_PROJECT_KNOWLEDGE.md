# Project Knowledge Template

> **Instructions:** Fill in each section with your project's specific details. This file serves as the primary context for Claude workers.

---

## Purpose & Context

<!-- Describe your project's mission, main objectives, and the problem it solves -->

**Project:** [Your Project Name]
**Description:** [What does this project do?]
**Tech Stack:** [Languages, frameworks, tools]
**Target Audience:** [Who uses this?]

### Key Stakeholders
- Project Lead: [Name/Role]
- Development Team: [Worker roles and domains]

---

## Current State

<!-- Document where the project is right now -->

**Version:** See VERSION.txt
**Status:** [Development/Beta/Production]

### Recent Achievements
- [List recent milestones]
- [Important features completed]

### Known Issues
- [Active bugs or limitations]
- [Technical debt items]

---

## On the Horizon

<!-- What's coming next? -->

### Near-term Priorities
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]

### Future Considerations
- [Long-term goals]
- [Potential features]

---

## Key Learnings & Principles

<!-- Wisdom gained from building this project -->

### Technical Decisions
- [Why certain technologies were chosen]
- [Patterns that work well]

### What We've Learned
- [Important discoveries]
- [Lessons from mistakes]

### Principles We Follow
- [Code quality standards]
- [Testing requirements]
- [Documentation practices]

---

## Approach & Patterns

<!-- How we work on this project -->

### Development Workflow
- **Branching:** [Git strategy]
- **Testing:** [Required coverage, types]
- **Code Review:** [Process]
- **Deployment:** [How releases work]

### Sprint Methodology
- [Sprint duration]
- [Planning process]
- [Definition of Done]

### Communication
- [How workers coordinate]
- [Status update frequency]
- [Documentation requirements]

---

## Tools & Resources

### Development Environment
- **IDE:** [e.g., VS Code, Xcode]
- **Build System:** [e.g., npm, cargo, xcodebuild]
- **Package Manager:** [e.g., npm, pip, homebrew]

### Key Dependencies
- [Critical libraries]
- [External services]

### Documentation Locations
- `README.md` - Project overview
- `CONTRIBUTING.md` - Contribution guidelines
- `docs/` - Detailed documentation

### Useful Commands
```bash
# Build
[your build command]

# Test
[your test command]

# Run
[your run command]
```

---

### ⚠️ MANDATORY: Post-Sprint Documentation

> **🔒 PROTECTED SECTION** - Do NOT skip these steps when completing any sprint or major milestone

**🚀 AUTOMATED OPTION:** Run `./scripts/release.sh X.X.X` to execute all steps automatically!

**After EVERY sprint, complete ALL steps:**

#### 0. Check Project Health FIRST
```bash
# Run project dashboard/health check (customize this)
./scripts/dashboard.sh  # OR your health check command
```
- [ ] Review health score - should be 80%+
- [ ] Check for any ⚡ NEEDS ATTENTION alerts
- [ ] Note any issues to address

#### 1. Verify Build & Tests
```bash
# Run all tests (customize for your project)
npm test  # OR: pytest, go test, cargo test, etc.

# Build and verify
npm run build  # OR: make build, cargo build, etc.

# Launch/smoke test if applicable
npm start  # OR your launch command
```
- [ ] All tests pass
- [ ] Build completes successfully
- [ ] Application launches and works

#### 2. Update Version (use scripts!)
```bash
# Update all docs to new version automatically:
./scripts/update-version.sh X.X.X

# Verify all docs match VERSION.txt:
./scripts/version-check.sh
```
- [ ] VERSION.txt updated
- [ ] All docs updated via script
- [ ] version-check.sh passes ✅

#### 3. Update Documentation Files

| File | What to Update |
|------|----------------|
| `CHANGELOG.md` | New version entry with features/fixes |
| `STATUS.md` | Version, completed items, test count, worker status |
| `RECOVERY.md` | Version, current state, test count, open issues |
| `CLAUDE_PROJECT_KNOWLEDGE.md` | Version, test count, current state |

#### 4. GitHub Housekeeping
```bash
# Close completed issues
gh issue close <number> -c "Completed in vX.X.X"

# Verify issue states
gh issue list
```
- [ ] All completed issues closed
- [ ] Labels updated (remove `in-progress`, add `done` if applicable)

#### 5. Clean Up Sprint Files
- [ ] Archive or clear `.claude-team/tasks/TASK_*.md` files
- [ ] Organize `.claude-team/outputs/*_COMPLETE.md` reports
- [ ] Update GitHub Project Board (move cards to Done)

#### 6. Commit, Tag & Push
```bash
cd {PROJECT_ROOT}
git add -A
git commit -m "docs: Update documentation to vX.X.X"
git tag vX.X.X
git push --tags origin main
```
- [ ] Changes committed
- [ ] Version tagged
- [ ] Pushed to GitHub

#### 7. Reflect on Operational Excellence
```bash
# Check final health score
./scripts/dashboard.sh  # OR your health check
```
- [ ] Health maintained or improved
- [ ] Document any lessons learned
- [ ] Update process improvements

---

## Other Instructions

<!-- Special instructions for Claude workers -->

- [Specific coding conventions]
- [Required steps after changes]
- [Things to always/never do]

---

*Last Updated: [Date]*
*Maintained by: Strategic Partner*
