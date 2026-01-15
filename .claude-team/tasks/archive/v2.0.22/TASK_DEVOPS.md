# TASK: Update Project-Ops-Kit Template

## Ticket
**Type:** Operations / Template Update  
**Size:** M (1-2 hours)  
**Priority:** High

---

## Objective

Update `templates/project-ops-kit/` to be a proper reusable template for Claude-powered parallel development projects. Currently at v0.1.0, needs to become v1.0.0.

---

## Problems to Fix

1. **Missing Scripts** - `.claude-team/scripts/` is missing:
   - `auto_launch_workers.sh`
   - `launch_workers.sh`
   - `ticket.sh`

2. **Hardcoded Paths** - SPECIALIZED_AGENTS.md has `/Users/antti/Claude/` hardcoded
   - Replace with `{PROJECT_ROOT}` placeholder throughout

3. **CloudSync References** - Remove project-specific references:
   - SPECIALIZED_AGENTS.md mentions "CloudSync Ultra"
   - Make all references generic (e.g., "your project")

4. **Version Mismatch** - VERSION.txt shows 0.1.0 but README says "Version: 2.0"
   - Update to 1.0.0 as first proper release

5. **CLAUDE_PROJECT_KNOWLEDGE.md** - Needs to be a proper template
   - Should have placeholder sections, not CloudSync content

---

## Deliverables

### 1. Copy Missing Scripts
```bash
# Copy from live to template
cp /Users/antti/Claude/.claude-team/scripts/auto_launch_workers.sh \
   /Users/antti/Claude/templates/project-ops-kit/.claude-team/scripts/

cp /Users/antti/Claude/.claude-team/scripts/launch_workers.sh \
   /Users/antti/Claude/templates/project-ops-kit/.claude-team/scripts/

cp /Users/antti/Claude/.claude-team/scripts/ticket.sh \
   /Users/antti/Claude/templates/project-ops-kit/.claude-team/scripts/
```

### 2. Make Paths Generic
In all files under `templates/project-ops-kit/`:
- Replace `/Users/antti/Claude/` with `{PROJECT_ROOT}/`
- Replace `~/Claude/` with `{PROJECT_ROOT}/`

### 3. Remove CloudSync References
- Change "CloudSync Ultra" to "your project" or similar
- Make briefings generic (they should already be mostly generic)

### 4. Update Versions
- `VERSION.txt` → `1.0.0`
- `README.md` → Update version reference to 1.0.0
- Update any date references to current date

### 5. Create Template CLAUDE_PROJECT_KNOWLEDGE.md
Replace with a proper template structure:
```markdown
# {PROJECT_NAME} - Project Knowledge

## Purpose & Context
{Describe what your project does and why}

## Current State
{Current version, deployment status, active features}

## On the Horizon
{Upcoming priorities and future plans}

## Key Learnings & Principles
{Important lessons learned, core principles}

## Approach & Patterns
{Development methodology, workflows}

## Tools & Resources
{Tech stack, key dependencies, useful commands}

## Other Instructions
{Project-specific rules for Claude}
```

### 6. Update setup.sh
Ensure `scripts/setup.sh` properly:
- Replaces `{PROJECT_ROOT}` placeholders with actual paths
- Replaces `{PROJECT_NAME}` with user input
- Creates necessary directories

### 7. Git Commit
```bash
cd /Users/antti/Claude
git add templates/project-ops-kit/
git commit -m "chore(ops-kit): Update to v1.0.0

- Add missing scripts (auto_launch, launch_workers, ticket.sh)
- Make all paths generic with {PROJECT_ROOT} placeholder
- Remove CloudSync-specific references
- Create proper template CLAUDE_PROJECT_KNOWLEDGE.md
- Update setup.sh for proper initialization
- First proper release as reusable template"
git push
```

---

## Success Criteria

- [ ] All scripts from live `.claude-team/scripts/` present in template
- [ ] No hardcoded paths (grep for `/Users/antti` returns nothing)
- [ ] No CloudSync references (grep for `CloudSync` returns nothing)
- [ ] VERSION.txt = 1.0.0
- [ ] CLAUDE_PROJECT_KNOWLEDGE.md is a proper template with placeholders
- [ ] setup.sh handles placeholder replacement
- [ ] Changes committed and pushed to git

---

## Notes

- This is the operational template we've battle-tested on CloudSync Ultra
- Goal is to make it reusable for any Claude-powered project
- Keep the quality high - this could help many other developers

---

*Task created: 2025-01-15*
