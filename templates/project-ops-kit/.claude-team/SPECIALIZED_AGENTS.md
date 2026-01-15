# Specialized Agents System

## Overview

Beyond the core dev team, your project can leverage specialized agents for focused expertise.

**Triage Guide:** See `TRIAGE_GUIDE.md` for assignment decision tree and examples.

---

## Agent Roster

### Core Team (Always Available)
| Agent | Domain | Model Rule |
|-------|--------|------------|
| Dev-1 | UI (Views, ViewModels) | Sonnet XS/S, Opus M/L/XL |
| Dev-2 | Engine (Core Business Logic) | Sonnet XS/S, Opus M/L/XL |
| Dev-3 | Services (Models, Managers) | Sonnet XS/S, Opus M/L/XL |
| QA | Testing | Always Opus + /think |
| Dev-Ops | Git, GitHub, Docs, Research | Always Opus + /think |

### Specialized Agents (On-Demand)
| Agent | Domain | Model | Use Case |
|-------|--------|-------|----------|
| **UX-Designer** | UI/UX Analysis | Opus + /think hard | Design review, user flow improvements |
| **Product-Manager** | Strategy & Requirements | Opus + /think hard | Feature prioritization, business logic |
| **Architect** | System Design | Opus + /think hard | Architecture decisions, refactoring |
| **Security-Auditor** | Security Review | Opus + /think hard | Vulnerability analysis, best practices |
| **Performance-Engineer** | Optimization | Opus + /think hard | Deep performance analysis |
| **Tech-Writer** | Documentation | Opus + /think hard | User guides, API docs, README |
| **Brand-Designer** | Brand & Visual Identity | Opus + /think hard | Brand audit, visual assets, style guides |
| **QA-Automation** | Test Automation | Opus + /think hard | UI tests, CI/CD, coverage analysis |
| **Marketing-Strategist** | Growth & Marketing | Opus + /think hard | ASO, campaigns, positioning |

**All specialized agents use Opus with `/think hard` for deep, thorough analysis.**

---

## Launch Commands

```bash
# Core team (run from project root)
./.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
./.claude-team/scripts/launch_single_worker.sh dev-2 opus
./.claude-team/scripts/launch_single_worker.sh dev-3 sonnet
./.claude-team/scripts/launch_single_worker.sh qa opus
./.claude-team/scripts/launch_single_worker.sh devops opus

# Specialized agents
./.claude-team/scripts/launch_single_worker.sh ux-designer opus
./.claude-team/scripts/launch_single_worker.sh product-manager opus
./.claude-team/scripts/launch_single_worker.sh architect opus
./.claude-team/scripts/launch_single_worker.sh security-auditor opus
./.claude-team/scripts/launch_single_worker.sh performance-eng opus
./.claude-team/scripts/launch_single_worker.sh tech-writer opus
./.claude-team/scripts/launch_single_worker.sh brand-designer opus
./.claude-team/scripts/launch_single_worker.sh qa-automation opus
./.claude-team/scripts/launch_single_worker.sh marketing-strategist opus
```

---

## Startup Commands (Paste into Claude Code)

> **Note:** Replace `{PROJECT_ROOT}` with your actual project path

### Core Team
```
Dev-1: Read {PROJECT_ROOT}/.claude-team/templates/DEV1_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV1.md. Update STATUS.md as you work.

Dev-2: Read {PROJECT_ROOT}/.claude-team/templates/DEV2_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV2.md. Update STATUS.md as you work.

Dev-3: Read {PROJECT_ROOT}/.claude-team/templates/DEV3_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEV3.md. Update STATUS.md as you work.

QA: Read {PROJECT_ROOT}/.claude-team/templates/QA_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_QA.md. Update STATUS.md as you work.

Dev-Ops: Read {PROJECT_ROOT}/.claude-team/templates/DEVOPS_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_DEVOPS.md. Update STATUS.md as you work.
```

### Specialized Agents
```
UX-Designer: Read {PROJECT_ROOT}/.claude-team/templates/UX_DESIGNER_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_UX_DESIGNER.md. Update STATUS.md as you work.

Product-Manager: Read {PROJECT_ROOT}/.claude-team/templates/PRODUCT_MANAGER_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_PRODUCT_MANAGER.md. Update STATUS.md as you work.

Architect: Read {PROJECT_ROOT}/.claude-team/templates/ARCHITECT_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_ARCHITECT.md. Update STATUS.md as you work.

Security-Auditor: Read {PROJECT_ROOT}/.claude-team/templates/SECURITY_AUDITOR_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_SECURITY_AUDITOR.md. Update STATUS.md as you work.

Performance-Engineer: Read {PROJECT_ROOT}/.claude-team/templates/PERFORMANCE_ENGINEER_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_PERFORMANCE_ENGINEER.md. Update STATUS.md as you work.

Tech-Writer: Read {PROJECT_ROOT}/.claude-team/templates/TECH_WRITER_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_TECH_WRITER.md. Update STATUS.md as you work.

Brand-Designer: Read {PROJECT_ROOT}/.claude-team/templates/BRAND_DESIGNER_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_BRAND_DESIGNER.md. Update STATUS.md as you work.

QA-Automation: Read {PROJECT_ROOT}/.claude-team/templates/QA_AUTOMATION_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_QA_AUTOMATION.md. Update STATUS.md as you work.

Marketing-Strategist: Read {PROJECT_ROOT}/.claude-team/templates/MARKETING_STRATEGIST_BRIEFING.md then read and execute {PROJECT_ROOT}/.claude-team/tasks/TASK_MARKETING_STRATEGIST.md. Update STATUS.md as you work.
```

---

## When to Use Specialized Agents

| Situation | Agent |
|-----------|-------|
| "App feels clunky" or "improve UX" | UX-Designer |
| "What should we build next?" | Product-Manager |
| "Is this the right architecture?" | Architect |
| "Is this secure?" | Security-Auditor |
| "Why is X slow?" | Performance-Engineer |
| "Need better docs" | Tech-Writer |
| "Brand looks inconsistent" or "need visual identity" | Brand-Designer |
| "Need automated UI tests" or "improve test coverage" | QA-Automation |
| "How do we grow users?" or "App Store optimization" | Marketing-Strategist |

---

## File Locations

| Type | Location |
|------|----------|
| Briefings | `.claude-team/templates/{AGENT}_BRIEFING.md` |
| Tasks | `.claude-team/tasks/TASK_{AGENT}.md` |
| Outputs | `.claude-team/outputs/{AGENT}_COMPLETE.md` |

---

*System designed for extensibility - add new agents as needed*
