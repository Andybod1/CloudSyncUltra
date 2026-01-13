# Ticket Triage & Assignment Guide

> Strategic Partner uses this to evaluate and assign tickets

---

## Triage Process

When a new ticket arrives or during sprint planning:

```
1. Read ticket → Understand problem/goal
2. Categorize → Which domain?
3. Assess complexity → XS/S/M/L/XL
4. Assign → Core team OR Specialized agent
5. Create task → Write TASK_*.md file
6. Launch worker → With appropriate model
```

---

## Assignment Decision Tree

```
Is this implementation work?
├── YES → Core Team (Dev-1/2/3, QA, Dev-Ops)
└── NO → Is it analysis/strategy/review?
    ├── UX/design analysis? → UX-Designer
    ├── Product strategy/roadmap? → Product-Manager
    ├── Architecture decisions? → Architect
    ├── Security concerns? → Security-Auditor
    ├── Performance deep-dive? → Performance-Engineer
    └── Documentation needed? → Tech-Writer
```

---

## Core Team Assignments

| Domain | Worker | Assign When |
|--------|--------|-------------|
| Views, ViewModels, UI components | Dev-1 | Building/fixing UI |
| RcloneManager, transfers, engine | Dev-2 | Core sync logic |
| Models, *Manager.swift, services | Dev-3 | Data models, managers |
| Tests, test plans, validation | QA | Testing anything |
| Git, GitHub, docs, research | Dev-Ops | Infrastructure tasks |

---

## Specialized Agent Assignments

| Agent | Assign When | Example Tickets |
|-------|-------------|-----------------|
| **UX-Designer** | "feels clunky", "improve UX", "user flow", "design review" | #44 UI review |
| **Product-Manager** | "what to build", "prioritize", "roadmap", "strategy" | #45 Business logic |
| **Architect** | "refactor", "restructure", "scalability", "technical debt" | Architecture review |
| **Security-Auditor** | "security", "credentials", "encryption", "vulnerability" | Security audit |
| **Performance-Engineer** | "slow", "optimize", "benchmark", "profiling" | Deep perf analysis |
| **Tech-Writer** | "documentation", "guide", "README", "help text" | User docs |

---

## Trigger Keywords

Quick reference for assignment:

| Keywords in Ticket | Assign To |
|--------------------|-----------|
| view, button, layout, UI, screen | Dev-1 |
| sync, transfer, rclone, upload, download | Dev-2 |
| model, manager, service, data | Dev-3 |
| test, validate, verify, QA | QA |
| git, commit, docs, research, GitHub | Dev-Ops |
| UX, user experience, flow, design, intuitive | UX-Designer |
| strategy, priority, roadmap, feature, business | Product-Manager |
| architecture, refactor, structure, pattern | Architect |
| security, auth, token, credential, encrypt | Security-Auditor |
| performance, speed, slow, optimize, memory | Performance-Engineer |
| documentation, guide, help, README | Tech-Writer |

---

## Complexity → Model Selection

| Size | Time Est. | Core Team Model | Specialized Model |
|------|-----------|-----------------|-------------------|
| XS | < 30 min | Sonnet | Opus + /think |
| S | 30-60 min | Sonnet | Opus + /think |
| M | 1-2 hours | Opus | Opus + /think |
| L | 2-4 hours | Opus + /think | Opus + /think |
| XL | 4+ hours | Opus + /think | Opus + /think |

**Note:** All specialized agents ALWAYS use Opus + /think regardless of size.

---

## Hybrid Assignments

Some tickets need both analysis AND implementation:

**Example: "App feels slow"**
1. Performance-Engineer → Analyze and recommend (Phase 1)
2. Dev-2 → Implement optimizations (Phase 2)
3. QA → Verify improvements (Phase 3)

**Example: "Improve onboarding"**
1. UX-Designer → Analyze current flow, recommend changes (Phase 1)
2. Dev-1 → Implement UI changes (Phase 2)
3. QA → Test new flow (Phase 3)

---

## Quick Examples

| Ticket | Assignment | Reasoning |
|--------|------------|-----------|
| "Fix button alignment" | Dev-1 (Sonnet) | Simple UI fix |
| "Transfers failing" | Dev-2 (Opus) | Engine debugging |
| "Add new model field" | Dev-3 (Sonnet) | Model change |
| "Is our auth secure?" | Security-Auditor | Security review |
| "App feels clunky" | UX-Designer | UX analysis |
| "What should we build next?" | Product-Manager | Strategy |
| "Why is sync slow?" | Performance-Engineer | Deep analysis |
| "Need user guide" | Tech-Writer | Documentation |

---

## Post-Assignment Checklist

After assigning a ticket:

- [ ] Task file created: `.claude-team/tasks/TASK_{WORKER}.md`
- [ ] STATUS.md updated
- [ ] Worker launched with correct model
- [ ] Startup command provided/pasted

---

*This guide helps Strategic Partner make consistent assignment decisions*
