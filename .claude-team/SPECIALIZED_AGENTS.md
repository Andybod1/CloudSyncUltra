# Specialized Agents System

## Overview

Beyond the core dev team, CloudSync Ultra can leverage specialized agents for focused expertise.

---

## Agent Roster

### Core Team (Always Available)
| Agent | Domain | Model Rule |
|-------|--------|------------|
| Dev-1 | UI (Views, ViewModels) | Sonnet XS/S, Opus M/L/XL |
| Dev-2 | Engine (RcloneManager) | Sonnet XS/S, Opus M/L/XL |
| Dev-3 | Services (Models, Managers) | Sonnet XS/S, Opus M/L/XL |
| QA | Testing | Always Opus |
| Dev-Ops | Git, GitHub, Docs, Research | Always Opus |

### Specialized Agents (On-Demand)
| Agent | Domain | Model | Use Case |
|-------|--------|-------|----------|
| **UX-Designer** | UI/UX Analysis | Opus + /think | Design review, user flow improvements |
| **Product-Manager** | Strategy & Requirements | Opus + /think | Feature prioritization, business logic |
| **Architect** | System Design | Opus + /think | Architecture decisions, refactoring |
| **Security-Auditor** | Security Review | Opus + /think | Vulnerability analysis, best practices |
| **Performance-Engineer** | Optimization | Opus + /think | Deep performance analysis |
| **Tech-Writer** | Documentation | Opus + /think | User guides, API docs, README |

**All specialized agents use Opus with extended thinking (`/think`) for thorough analysis.**

---

## Launch Commands

```bash
# Core team
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-1 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-2 opus
~/Claude/.claude-team/scripts/launch_single_worker.sh dev-3 sonnet
~/Claude/.claude-team/scripts/launch_single_worker.sh qa opus
~/Claude/.claude-team/scripts/launch_single_worker.sh devops opus

# Specialized agents
~/Claude/.claude-team/scripts/launch_single_worker.sh ux-designer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh product-manager opus
~/Claude/.claude-team/scripts/launch_single_worker.sh architect opus
~/Claude/.claude-team/scripts/launch_single_worker.sh security-auditor opus
~/Claude/.claude-team/scripts/launch_single_worker.sh performance-engineer opus
~/Claude/.claude-team/scripts/launch_single_worker.sh tech-writer sonnet
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

---

## File Locations

| Type | Location |
|------|----------|
| Briefings | `.claude-team/templates/{AGENT}_BRIEFING.md` |
| Tasks | `.claude-team/tasks/TASK_{AGENT}.md` |
| Outputs | `.claude-team/outputs/{AGENT}_COMPLETE.md` |

---

*System designed for extensibility - add new agents as needed*
