# ADR-002: Parallel Worker Development Model

## Status

Accepted

## Context

CloudSync Ultra development requires working across multiple domains:
- UI Layer (Views, ViewModels)
- Core Engine (RcloneManager, transfers)
- Services (Models, Managers)
- Testing (Unit tests, UI tests)
- Operations (Docs, CI/CD, releases)

Single-threaded development creates bottlenecks. Complex features touch multiple files, making sequential work slow.

## Decision

Adopt a parallel worker model with specialized Claude Code agents:

```
Strategic Partner (Coordinator)
├── Dev-1 (UI Layer)
├── Dev-2 (Core Engine)  
├── Dev-3 (Services)
├── QA (Testing)
└── Dev-Ops (Operations)
```

Each worker:
- Has clear file ownership to prevent conflicts
- Receives task files with specific instructions
- Works independently in separate Terminal sessions
- Commits with descriptive messages
- Reports completion through task file updates

## Consequences

### Positive

- 4-5x development speed through parallelization
- Clear separation of concerns
- Specialists develop deep domain expertise
- No merge conflicts with proper file ownership
- Scalable to more workers as needed

### Negative

- Coordination overhead for Strategic Partner
- Potential for miscommunication
- Workers may need context from other domains
- Integration testing required after parallel work

### Neutral

- Requires task file infrastructure
- Status tracking needed for visibility
- Workers don't persist memory between sessions

## Alternatives Considered

1. **Single Claude instance doing everything**
   - Rejected: Too slow, context limitations

2. **Feature branches per worker**
   - Rejected: Merge complexity, overkill for single-day sprints

3. **Microservices architecture**
   - Rejected: Over-engineering for macOS app

## References

- `.claude-team/tasks/TASK_*.md` - Task file templates
- `.claude-team/STATUS.md` - Worker status tracking
- `.claude-team/TRIAGE_GUIDE.md` - Task assignment decisions
