---
name: bm.skill-improvement
description: "Skill self-improvement and creation: evaluate existing skill quality, identify issues, propose improvements, iterate updates. Can also create new skills — brainstorm to refine requirements before creation. Use when user wants to improve, update, optimize, create skills, 优化 skill, 改进 skill, 更新 skill, 创建 skill, 新建 skill, skill 质量. Called by butler agent."
source: opencrew
version: "20260530.01"
---

# Skill: Skill Self-Improvement and Creation

## Scope

Two core capabilities:
1. **Optimize**: Analyze existing skill usage, generate improvement suggestions, execute after user confirmation
2. **Create**: Create new skills — must brainstorm to refine requirements before creation

## File Locations

- **Final artifacts**: `./reports/skill-suggestions/{skill}-{date}.md` (code project → `./docs/reports/skill-suggestions/{skill}-{date}.md`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/skill-improvement/`
- **Change log**: `./working/skill-improvement/changelog.md`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

---

## Principles

1. **Never auto-modify any skill file**. All changes require user confirmation
2. **Only modify one skill at a time**. Don't change multiple at once
3. **Back up before modifying**. Record original content and reason for change
4. **Rollback capable**. Record version number for each change; can be reverted

---

## Optimization Process

### Step 1: Collect Usage Data

Infer skill usage from the following sources:

1. `./reports/butler-*.md` and `./reports/skill-suggestions/*.md` — previous retrospectives and suggestions
2. Recent conversation context — what issues the user reported
3. `./working/skill-improvement/changelog.md` — confirmed and executed skill changes
4. Related artifact directories — quality of each skill's corresponding output

### Step 2: Evaluate Each Skill

Score each skill on 3 dimensions:

| Dimension | Scoring Criteria |
|------|---------|
| **Clarity** | When the agent follows the instructions, does it often deviate? Deviation indicates unclear instructions |
| **Completeness** | Are there frequent scenarios not covered by the instructions? |
| **Practicality** | Which parts are redundant in practice? Which are missing? |

### Step 3: Generate Optimization Report

```markdown
## Skill Optimization Report

### Evaluation Results

| Skill | Clarity | Completeness | Practicality | Priority |
|-------|--------|--------|--------|--------|
| research | 8/10 | 7/10 | 9/10 | Low |
| meeting | 6/10 | 5/10 | 8/10 | High |
| health | 9/10 | 8/10 | 9/10 | No changes needed |

### Skills Needing Optimization

#### 1. bm.meeting/SKILL.md (Priority: High)

**Issues**:
- Subtitle extraction steps are not specific enough; the agent doesn't know how to handle cases without speaker annotations
- Missing handling instructions for "multilingual meetings"

**Suggested Changes**:
1. Add processing flow for subtitles without speaker annotations in the "subtitle extraction" section
2. Add a "multilingual meetings" subsection

**Change Content**:
[Specific text to change, old → new]
```

### Step 4: User Confirmation

Present the report to the user and wait for confirmation before making changes.

### Step 5: Execute Changes

After user confirmation:
1. Record pre-change content to `./working/skill-improvement/changelog.md`
2. Modify the skill file
3. Record change summary and rollback info in the changelog

---

## Change Log Format

Maintain in `./working/skill-improvement/changelog.md`:

```markdown
## Skill Change Log

| Date | Skill | Change Summary | Reason |
|------|-------|---------|------|
| 2026-05-16 | bm.meeting | Added subtitle processing flow without speaker annotations | Subtitle extraction frequently deviates |
| 2026-05-16 | bm.project-mgmt | Added project directory creation flow | Uncertain steps during first creation |
```

---

## Optimization Modes

### User-Triggered

```
User → Lead: "Help me optimize the meeting skill"
Lead → Butler: Execute skill-improvement process
Butler → Output optimization report
Lead → Present to user for confirmation
```

### Butler Periodic Retrospective Trigger

Output in the "suggested optimizations" section of the retrospective report. Don't auto-execute; wait for user confirmation.

---

## Creation Process (New Skill)

Follow this process when the user says "create a skill" or "make a new skill".

### Step 0: Brainstorm First (Mandatory)

**Never skip this step.** Load `bm.brainstorming`, use Socratic questioning to clarify:

1. **What problem does it solve**: What should this skill make the agent do? Which scenarios does it address?
2. **Who uses it**: Which agent will load it? Lead? Coder? All?
3. **Input/output**: What are the trigger conditions? What files/formats does it produce?
4. **Boundaries**: What's outside this skill's scope? When should it not trigger?
5. **Relationship to existing skills**: Does it overlap with existing skills? Should it be merged or split?

Organize the brainstorm results into a skill spec, **present in chunks for user confirmation**. Only proceed to creation after user confirmation.

### Step 1: Determine Name and Location

- **Naming**: Follow project conventions (e.g., `bm.{name}` or `skilless.ai-{name}`)
- **Location**: `./skills/{name}/SKILL.md` (project-level) or `~/.agents/skills/{name}/SKILL.md` (global)
- **Prefer project-level** (travels with the project, customizable), unless the user explicitly wants global sharing

### Step 2: Generate SKILL.md

Every SKILL.md must include:

```markdown
---
name: {name}
description: "{One-sentence description + trigger keywords}"
source: opencrew
version: "{date}.01"
---

# Skill: {Title}

## Scope
{What this skill covers, what it doesn't}

## File Locations
{Where artifacts are written}

---

## Principles
{3-5 core principles}

---

## Core Process
{Step-by-step execution process}

---

## Notes
{Edge cases, common pitfalls}
```

### Step 3: User Confirmation

Show the complete SKILL.md content to the user for confirmation:
- Do the trigger keywords in the description cover the user's expected scenarios
- Is the process complete
- Are the principles reasonable

### Step 4: Create the File

After user confirmation:
1. Create directory `./skills/{name}/`
2. Write SKILL.md
3. Record creation in `./working/skill-improvement/changelog.md`

### Step 5: Register

Remind the user (or Lead) to add a reference to the new skill in the corresponding agent's Skills table.

---

## Notes

- Don't change for the sake of changing. Well-functioning skills should not be touched
- Minimize each change. Only fix the problematic parts; don't "improve" other parts along the way
- Change reasons must come from real-world usage problems, not theoretical "could be better"
- If a skill was changed less than 7 days ago, don't suggest changes again (give the change time to be validated)
