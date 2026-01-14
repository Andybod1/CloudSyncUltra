# Architect Task: RcloneManager Refactor Plan

**Sprint:** Maximum Productivity
**Priority:** High
**Worker:** Architect (Opus)

---

## Objective

Create a detailed refactoring plan to split RcloneManager.swift (1,511 lines) into smaller, focused modules.

## Current State Analysis

```bash
# Count current file size
wc -l CloudSyncApp/RcloneManager.swift

# Identify sections
grep -n "// MARK:" CloudSyncApp/RcloneManager.swift
```

## Tasks

### 1. Analyze Current Structure

Identify logical groupings in RcloneManager.swift:
- Provider configuration methods (50+ providers)
- Transfer execution methods
- Remote management methods
- Progress parsing
- Error handling
- Multi-threading configuration

### 2. Propose Module Split

Create a refactoring plan document with proposed structure:

```
CloudSyncApp/
├── Rclone/
│   ├── RcloneCore.swift          # Core execution, process management
│   ├── RcloneProviders.swift     # All provider setup methods
│   ├── RcloneTransfers.swift     # Transfer operations (copy, sync, move)
│   ├── RcloneProgress.swift      # Progress parsing and streaming
│   └── RcloneConfig.swift        # Configuration management
└── RcloneManager.swift           # Facade that ties it all together
```

### 3. Document Dependencies

For each proposed module, document:
- Public interface (methods exposed)
- Dependencies on other modules
- Shared types needed

### 4. Migration Strategy

Propose step-by-step migration:
1. Extract protocols/interfaces first
2. Move methods one group at a time
3. Keep backward compatibility during transition
4. Update tests after each phase

### 5. Risk Assessment

Identify:
- Breaking changes for other parts of codebase
- Test coverage implications
- Integration points that need updating

## Deliverable

Write detailed plan to: `/Users/antti/Claude/.claude-team/outputs/RCLONE_REFACTOR_PLAN.md`

Include:

```markdown
# RcloneManager Refactor Plan

## Executive Summary
[1-2 paragraph overview]

## Current State
- File: RcloneManager.swift
- Lines: X
- Methods: X
- Provider configs: X

## Proposed Architecture

### Module 1: RcloneCore.swift (~200 lines)
**Purpose:** Core rclone process execution
**Methods:**
- execute(command:) async throws -> String
- executeWithProgress(command:) -> AsyncStream<String>
- cancelOperation(id:)
**Dependencies:** None

### Module 2: RcloneProviders.swift (~600 lines)
**Purpose:** Provider-specific configuration
**Methods:**
- setupGoogleDrive(...)
- setupDropbox(...)
- [all 50+ provider methods]
**Dependencies:** RcloneCore

[Continue for each module...]

## Migration Steps

### Phase 1: Extract Protocols (Day 1)
1. Create RcloneExecutable protocol
2. Create RcloneProviderConfigurable protocol
3. Have RcloneManager conform to both

### Phase 2: Extract RcloneCore (Day 2)
1. Move execution methods
2. Update RcloneManager to use RcloneCore
3. Run tests

[Continue...]

## Test Strategy
[How to ensure nothing breaks]

## Timeline
- Phase 1: X hours
- Phase 2: X hours
- Total: X hours

## Risks & Mitigations
[List each risk and mitigation]
```

## Success Criteria

- [ ] Complete analysis of current RcloneManager
- [ ] Proposed module structure with rationale
- [ ] Clear migration path
- [ ] Risk assessment
- [ ] Timeline estimate
- [ ] Plan document ready for review
