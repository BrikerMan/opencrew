---
name: bm.project-mgmt
description: "Project management: project creation, task management, progress tracking, risk assessment, weekly report generation. Use when user needs to manage projects, tasks, milestones, risks, timelines, 项目, 任务, 进度, 风险, 里程碑, 排期, project, task, sprint. Data stored in current working directory, organized by directory."
source: opencrew
version: "20260530.01"
---

# Skill: Project Management

## Scope

Project tracking, weekly report generation, risk early warning, task decomposition.

## File Locations

- **Final artifacts**: `./projects/...` (code project → `./docs/projects/...`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/project/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

---

## Project Tracking

### Milestone Management

Define 3-7 milestones per project. Each milestone:

```markdown
## Milestones

| Name | Deliverable | Deadline | Status |
|------|--------|---------|------|
| M1: Infrastructure | API framework + DB schema | 2026-06-01 | ✅ done |
| M2: Core Features | User registration/login/CRUD | 2026-06-15 | 🟡 at-risk |
| M3: Launch | Deployment + monitoring | 2026-07-01 | ⬜ pending |
```

**Status lights**:
- ✅ done — Completed
- 🟢 on-track — Progressing normally
- 🟡 at-risk — At risk of delay
- 🔴 delayed — Already delayed

### Progress Assessment

- Use completed milestones / total milestones = rough percentage
- **Update once per week**, not daily
- Watch trends: two consecutive weeks at-risk = intervention needed

## Weekly Report Generation

### Personal Weekly Report

Personal life/growth weekly reports are handled by `bm.life-journal` and written to `./journal/weekly/`. This skill only handles project/work weekly reports; if the user says "life weekly review/personal reflection", switch to `bm.life-journal`.

### Project Weekly Report

Write to `./projects/{Project}/mgmt/weekly-updates/YYYY-Wxx.md`:

```markdown
---
type: project-weekly
date: 2026-W18
project: ProjectName
tags: [project, weekly]
---

# ProjectName Weekly Report 2026-W18

## Status Light: 🟢 on-track

## Last Week ✅
- ✅ Completed auth module refactoring ([[T-0015-auth-refactor]])
- ✅ Deployed v2.1 to staging

## This Week 🎯
- [ ] Production deployment of v2.1
- [ ] Start notification module

## Risks/Blockers
- Staging environment intermittent timeouts, need ops investigation

← [[2026-W17]] | [[2026-W19]] →
```

**Weekly report continuity**:
- Read the previous issue before creating, review last week's plan item by item
- Use `← last week | next week →` links to form a timeline

## Risk Management

### Risk Identification Checklist

- **Technical risks**: New technology, complex integrations, performance bottlenecks, single points of dependency
- **Resource risks**: Personnel changes, compressed timelines, skill gaps
- **Requirements risks**: Requirement changes, misunderstanding, priority shifts
- **External risks**: Third-party services, policy changes, market competition

### Assessment Matrix

| Probability \ Impact | Low Impact | Medium Impact | High Impact |
|-------------|--------|--------|--------|
| High probability | 🟡 Monitor | 🟠 Actively mitigate | 🔴 Prioritize |
| Medium probability | 🟢 Accept | 🟡 Monitor | 🟠 Actively mitigate |
| Low probability | ⬜ Ignore | 🟢 Accept | 🟡 Monitor |

### Risk Record Format

```markdown
| Risk Description | Probability | Impact | Mitigation | Owner | Status |
|---------|------|------|---------|--------|------|
| DB performance bottleneck | Medium | High | Add caching + read-write separation | Coder | Monitoring |
```

## Task Decomposition

### Principles

- Each task should be completable in 1-2 days (if longer, break it down further)
- Have clear "done" criteria (not "in progress", but "delivered xxx")
- Dependencies clearly marked
- Clear priorities

### Decomposition Process

1. Write out the final deliverable
2. Work backward to identify required steps
3. If any step takes more than 2 days, break it down further
4. Mark dependencies between steps (which can run in parallel)
5. Set priorities

### Priority

| Value | Meaning | How to Handle |
|---|------|---------|
| P0 | Urgent, not doing it blocks others | Handle immediately, can interrupt current work |
| P1 | Important, must do soon | Schedule in current iteration |
| P2 | Normal, do when time allows | Put in backlog, review periodically |
