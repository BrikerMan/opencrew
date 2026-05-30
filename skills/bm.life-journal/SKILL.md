---
name: bm.life-journal
description: "Life journaling: diary, weekly reviews, monthly reflections, life event records, growth tracking. Use when user wants to write journal, diary, weekly review, monthly reflection, life events, milestones, 日记, 周报, 月报, 复盘, 回顾, 感恩, 反思. Three-part structure."
source: opencrew
version: "20260530.01"
---

# Skill: Life Journaling

## Scope

Narrative records for diaries, reflections, life memories, and growth tracking.

## File Locations

- **Final artifacts**: `./journal/...` (code project → `./docs/journal/...`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/journal/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

## Privacy and Write Confirmation

- Journals and life events are private content by default. Only persist when the user explicitly says "write journal/record/save/archive"; if just chatting or venting, default to not writing files.
- Before writing to `./journal/` for the first time, explain the path and content type to be saved, and get confirmation before writing.
- Don't write feelings, motivations, or facts that the user hasn't explicitly expressed as definitive records; mark uncertain content with `[needs confirmation]`.

---

## Diary Process

### Step 1: Check if Diary Already Exists

```
glob "./journal/daily/YYYY-MM-DD.md"
```

If it exists → Read and append content
If it doesn't exist → Create from template

### Step 2: Create Diary

Create from `./templates/Daily.md` (if available), write to `./journal/daily/YYYY-MM-DD.md`:

```markdown
---
type: daily
date: 2026-05-16
mood: 7
energy: 6
tags: [daily]
---

# 2026-05-16

## Gratitude
- Project launch went smoothly, great team collaboration
- Ran 5 km in the evening, felt good

## Record
- Morning: completed IPverse weekly meeting, confirmed next week's release plan
- Afternoon: code review, found a security issue in auth module (fixed)
- Evening: ran 5km, pace 5'30"

## Reflection
Productive day today, but forgot to take a break at noon and felt a bit tired around 3 PM.
Tomorrow I'll try taking a 15-minute rest at noon.

## Plan
- [ ] Write IPverse release checklist
- [ ] Reply to Chris's email
```

### Three-Part Structure (Use Flexibly)

| Section | Purpose | Required? |
|------|------|--------|
| **Gratitude** | Record 1-3 things to be grateful for | Recommended |
| **Record/Reflection** | What happened today, what was learned | Core |
| **Plan** | 1-3 most important things for tomorrow | Recommended |

Don't force every section to be filled. Writing three lines is better than writing nothing.

### Time Boundary Rules

- 12:00 AM - 3:59 AM → Assign to the **previous day's** diary
- From 4:00 AM onward → Assign to the **current day's** diary

## Weekly Review

### Step 1: Read This Week's Diaries

```
glob "./journal/daily/*.md"
```

Filter files within this week's date range.

### Step 2: Read Last Week's Weekly Review

```
glob "./journal/weekly/*.md"
```

### Step 3: Generate Weekly Review

Write to `./journal/weekly/YYYY-Wxx.md`:

```markdown
---
type: weekly
date: 2026-W18
tags: [weekly]
---

# Weekly Review 2026-W18

## This Week's Keywords
Launch, refactoring, running

## Highlights
- IPverse v2.1 successfully deployed to staging
- Ran 5 consecutive days, 30km total

## Challenges
- Auth module refactoring took 1 day longer than expected
  - Cause: insufficient test coverage
  - Takeaway: add tests before next refactoring

## Growth
- Learned to draw architecture diagrams with Mermaid
- Discovered that a 15-minute noon rest significantly improves afternoon efficiency

## Focus for Next Week
- IPverse production deployment
- Start notification module design

← [[2026-W17]] | [[2026-W19]] →
```

## Life Event Records

Important events (milestones, decisions, turning points) use standalone notes:

```markdown
---
type: note
date: 2026-05-16
tags: [milestone]
---

# IPverse v2.1 Launch

## What Happened
After 2 months of development, IPverse v2.1 was successfully deployed to production today.
First time using blue-green deployment, zero-downtime switchover.

## Feelings
Nervous but grounded. The team worked really well together, especially the QA test coverage which gave us confidence in the launch.

## What I Learned
- Blue-green deployment suits our scenario better than rolling updates
- Freezing feature branches 48 hours before launch was very effective

## Follow-up
- Monitor stability for 1 week
- Collect user feedback
```

### Events Go to Inbox First

Important but not yet organized → Place in `./inbox/` first
After organizing and confirming → Move to the appropriate directory or `./journal/`

## Growth Tracking

### Monthly Review

Do once at the beginning of each month:

```markdown
# Monthly Review 2026-05

## Skills
- [x] Mastered Mermaid diagrams
- [ ] Deep dive into k8s (in progress)
- [ ] Rust basics (not started)

## Habits
| Habit | Completion Rate | Trend |
|------|--------|------|
| Daily exercise | 80% | ↑ |
| Journaling | 90% | → |
| Meditation | 40% | ↓ |

## Key Events
- IPverse v2.1 launch
- Attended Bay Area AI Meetup

## Goals for Next Month
- [ ] Complete k8s learning path
- [ ] Improve meditation habit to 70%
```

## Principles

1. **Authentic > polished**: Record true feelings, don't embellish
2. **Brief > verbose**: A few lines are enough; don't create "journaling pressure"
3. **Consistent > perfect**: Writing three lines every day is more valuable than writing three pages once a week
4. **No judgment**: Don't morally judge yourself when recording feelings
5. **Prioritize change**: Record changes (state changes, decisions, milestones), not static information
