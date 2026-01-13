# TASK: Set Up GitHub Actions for Project Board Auto-Add (#34)

## Worker: Dev-Ops
## Size: S
## Model: Opus (always for Dev-Ops)
## Ticket: #34

**Use extended thinking (`/think`) before implementing.**

---

## Problem

New GitHub issues are not automatically appearing on the CloudSync Ultra project board. Users must manually add each issue.

## Solution

Create a GitHub Actions workflow using `actions/add-to-project` to automatically add new issues to the project board.

## Implementation

### 1. Create Workflow File

Create `.github/workflows/add-to-project.yml`:

```yaml
name: Add issues to project

on:
  issues:
    types:
      - opened

jobs:
  add-to-project:
    name: Add issue to project
    runs-on: ubuntu-latest
    steps:
      - uses: actions/add-to-project@v1.0.2
        with:
          project-url: https://github.com/users/andybod1-lang/projects/1
          github-token: ${{ secrets.ADD_TO_PROJECT_PAT }}
```

### 2. Create Personal Access Token (PAT)

Andy needs to create a PAT with `project` scope:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create new token (classic) with `project` scope
3. Add as repository secret named `ADD_TO_PROJECT_PAT`

### 3. Document in README

Add note about automatic project board updates.

## Acceptance Criteria

- [ ] Workflow file created and committed
- [ ] Instructions for PAT creation documented
- [ ] Issue #34 closed with explanation that Andy needs to add the PAT secret

## Output

Write completion report to `/Users/antti/Claude/.claude-team/outputs/DEVOPS_COMPLETE.md`
