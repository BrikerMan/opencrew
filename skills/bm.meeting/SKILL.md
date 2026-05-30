---
name: bm.meeting
description: "Meeting processing: meeting minutes generation, subtitle/audio transcription, agenda management, action item tracking. Use when user has meeting notes, transcripts, subtitles to process, 会议, 纪要, 字幕, 录音, 议程, 行动项, meeting notes, transcript. Automatically extract key decisions and action items."
source: opencrew
version: "20260530.01"
---

# Skill: Meeting Processing

## Scope

Actionable process for meeting minutes extraction and Action Items tracking.

## File Locations

- **Final artifacts**: `./meetings/...` (code project → `./docs/meetings/...`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/meeting/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

---

## Creating Meeting Minutes from Scratch

### Step 1: Confirm Information

- Date (`YYYY-MM-DD`)
- Topic (short kebab-case)
- Attendees
- Associated project (if any)

### Step 2: Search if Already Exists

```
glob "./meetings/{date}-*.md"
```

### Step 3: Create from Template

Write to `./meetings/{YYYY-MM-DD}-{topic}.md`:

```markdown
---
type: meeting
date: 2026-05-16
attendees:
  - Zhang San
  - Li Si
project: "[[IPverse Project]]"
tags: [meeting]
---

# Meeting: IPverse Weekly Sync

## Agenda
1. This week's progress review
2. Next week's plan
3. Technical risk discussion

## Discussion Points

### This Week's Progress
- Frontend v2 development complete, entering testing
- API performance optimization complete, P99 reduced from 800ms to 200ms

### Technical Risks
- Third-party payment API maintenance this weekend, may affect launch

## Decisions
- Frontend v2 testing to be completed by next Wednesday
- Switch payment API to backup plan

## Action Items
- [ ] Complete frontend test cases — @Li Si — Due 2026-05-20
- [ ] Research payment API backup plan — @Zhang San — Due 2026-05-18
- [ ] Update project weekly report — @Zhang San — Due 2026-05-17

## Next Meeting
- Time: 2026-05-23
- Focus: Frontend test results, payment plan confirmation
```

## Extracting Minutes from Audio/Subtitles

### Step 1: Read Subtitle File

Subtitles are usually in `./working/transcripts/` or a user-specified path.

### Step 2: Extract Key Points

1. **Identify speakers** (if subtitles have speaker annotations)
2. **Skip pleasantries and repetition**, only extract:
   - Key discussion points ("I think...", "The issue is...")
   - Decisions ("Let's go with...", "We've decided to...")
   - Action Items ("Who will do...", "Before next week...")
3. **Group by topic**, not chronologically

### Step 3: Format the Output

Format using the meeting minutes template above. Pay special attention to:
- Each Action Item must have: specific task + owner + deadline
- Unclear Action Items should be marked `[needs confirmation]`
- Decisions should note who made the call

## Meeting Type Templates

### Weekly Sync

Fixed agenda:
1. Last week's progress review (check completion against last week's Action Items)
2. This week's plan
3. Risks/blockers
4. Action Items

### Review

Fixed agenda:
1. Review target and scope
2. Review criteria
3. Item-by-item review results
4. Improvement suggestions
5. Conclusion (PASS / CONDITIONAL PASS / FAIL)

### Report/Status Update

Fixed agenda:
1. Report topic
2. Current progress (data-driven)
3. Key metrics
4. Next steps
5. Support/resources needed

## Action Items Tracking

### Format Standard

```markdown
- [ ] Specific task — @Owner — Due YYYY-MM-DD
```

Each Action Item must:
- **Be specific**: Not "optimize performance", but "reduce P99 response time of /api/users to <500ms"
- **Have an owner**: `@Name`, not "everyone"
- **Have a deadline**: `YYYY-MM-DD`

### Follow-up Tracking

- At the start of the next meeting: Review completion of previous Action Items
- Incomplete Action Items: Note the reason, decide whether to extend or cancel
- Don't create new Action Items for "tracking completion of Action Items" (that's a process, not an action item)
