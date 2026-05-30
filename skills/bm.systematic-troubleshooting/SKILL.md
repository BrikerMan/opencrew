---
name: bm.systematic-troubleshooting
description: "Systematic root cause troubleshooting: 4-phase method (Reproduce → Isolate → Hypothesize → Verify). Use when something is broken, wrong, slow, weird, unexpected, intermittent, 出错, 报错, bug, 问题, 不对, 慢, 卡, 怪, 排查, 定位, debug, troubleshoot. Applicable to code bugs, product anomalies, process errors, data issues — any scenario where 'things are not happening as expected'."
source: opencrew
version: "20260521.01"
---

# Skill: Systematic Troubleshooting

**First reproduce, then isolate, then hypothesize, finally verify. Never rely on guessing.** Applicable to all scenarios where "things are not happening as expected".

Not just code bugs — product process anomalies, data mismatches, device malfunctions, operations not responding, processes stuck — all apply.

---

## Core Principles

1. **Evidence before hypotheses**: Don't start fixing without reproducing
2. **Narrow the scope, don't broaden it**: Each step should make the problem boundary clearer
3. **Hypotheses must be falsifiable**: Can be verified with a single yes/no action
4. **Change the minimum**: Only manipulate one variable at a time
5. **Must verify after fixing**: Otherwise you may have just masked the issue

---

## 4-Phase Method

### Phase 1: Reproduce

**Goal**: Make the problem appear in a controlled, stable, minimal-step manner.

**Key actions**:
- Find the minimal reproduction steps (remove all non-essential steps)
- Record environmental differences: when it occurs vs. when it doesn't
- Cannot stably reproduce: Record frequency and conditions, don't skip

**Problem classification** (determines next-step strategy):

| Type | Characteristics | Difficulty |
|---|---|---|
| Always reproducible | Occurs every time | Low |
| Condition-triggered | Only occurs with specific input/state/time | Medium |
| Intermittent | Occurs sometimes, no pattern | High (first try to make it condition-triggered) |
| One-time | Happened once and never again | Highest (first collect evidence, wait for recurrence) |

**Anti-patterns**:
- ❌ Start modifying code without reproducing → You won't know if the fix worked
- ❌ Reproduce once and think it's handled → Intermittent issues need multiple confirmations

### Phase 2: Isolate

**Goal**: Compress the boundary of "where the problem is" from large to small.

**Methods**:

| Method | Operation | Applicable When |
|---|---|---|
| **Bisect** | Cut in half and see which side has the problem | Don't know which segment it's in |
| **Swap** | Change data/environment/device/account | Suspect environment |
| **Revert** | Go back to a known-good version | It was working before |
| **Minimize** | Strip down to minimal reproduction | Complex systems |
| **Timeline** | git bisect / review history | Regression issues |

**Ask "Why" 5 Times**:
- Surface: Error thrown
- Why the error? → Function returned None
- Why None? → Database query returned nothing
- Why nothing? → Field name was misspelled
- Why misspelled? → Schema was changed last week without syncing
- **Root cause**: Change management process missing

Fix the deepest layer you can fix, not the surface layer.

### Phase 3: Hypothesize

**Goal**: Based on evidence, list 2-3 most likely root causes, each verifiable.

**Criteria for a good hypothesis**:
- ✅ **Specific**: "`port` field in `config.json` is string `'8080'` instead of number `8080`"
- ✅ **Falsifiable**: Running one action tells you if it's right or wrong
- ❌ "Might be a configuration issue" — too vague
- ❌ "Probably a caching problem" — no evidence

**List hypotheses ordered by probability**:

```
Hypothesis 1 (most likely): A broke B
  - Verification: Run X and check Y
  - Evidence source: Error message mentions A

Hypothesis 2: Environment difference
  - Verification: Reproduce on staging
  - Evidence source: Works locally, doesn't work in production

Hypothesis 3 (fallback): Third-party dependency
  - Verification: Check dependency versions
  - Evidence source: Recently upgraded
```

### Phase 4: Verify

**Goal**: Confirm whether the hypothesis is correct, then confirm whether the fix is effective.

**Two-step verification**:

1. **Verify root cause**: Use Phase 3's verification action to confirm the hypothesis
   - Hypothesis wrong → Return to Phase 3, try next hypothesis
   - Hypothesis correct → Proceed to fix

2. **Verify fix**:
   - Change the minimum code / configuration / steps
   - **Run Phase 1's reproduction steps again** — must no longer trigger the problem
   - Run related tests / adjacent scenarios — no new issues introduced
   - Use [bm.verification](../bm.verification/SKILL.md) to provide a completion report

---

## Output Format

Document the troubleshooting process for user follow-up / future retrospectives:

```markdown
# Troubleshooting Record: {Problem}

## Symptoms
- {One-sentence description}
- Reproduction steps:
  1. ...
  2. ...

## Environment
- {OS / version / configuration}

## Troubleshooting Timeline

### Phase 1: Reproduce ✅
- Successfully reproduced, always reproducible
- Minimal steps: ...

### Phase 2: Isolate
- Bisected X, problem is in module Y
- 5 Whys: ... → Root cause guess: ...

### Phase 3: Hypothesize
1. ❌ A: Ruled out after verification (evidence: ...)
2. ✅ B: Confirmed (evidence: ...)

### Phase 4: Verify
- Fixed ...
- Reproduction steps no longer trigger the issue ✅
- Adjacent tests passed ✅

## Root Cause
{One sentence}

## Fix
{What was changed, why it was changed this way}

## Prevention
- {Process/checklist item}
```

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| Blindly changing things and hoping | If it works you don't know why; if it fails you waste time | Reproduce first + hypothesize |
| Skip reproduction and guess directly | Hypotheses lack evidence, direction may be completely wrong | Stably reproduce first |
| Change 5 things at once | Don't know which one worked | One variable at a time |
| Fix it and move on once it works | Just masking the issue, may recur | Fix root cause, not symptoms |
| Look only at the outermost error | Outermost is the entry point, not the root cause | Read stack traces from inside out |
| Don't check existing issues | Might be a known problem | Search GitHub Issues / historical troubleshooting records first |
| Don't verify after fixing | Might not be fixed or may have introduced new issues | Run reproduction steps + adjacent tests |

---

## Non-Code Scenario Examples

**Scenario: User says "one of my files is missing"**
1. Reproduce: Ask the user which file specifically, when they noticed, when they last saw it
2. Isolate: Was it actually deleted or just can't be found? Trash/recent files/git log?
3. Hypothesize: Accidental deletion / renamed / sync issue / path changed
4. Verify: Each hypothesis corresponds to a search action

**Scenario: No one showed up to the meeting**
1. Reproduce: Who came to the previous few meetings?
2. Isolate: Is this one unusual or has it always been like this? Who sent the invitations?
3. Hypothesize: Invitations didn't reach people / time conflicts / topic wasn't compelling / no one felt they should attend
4. Verify: Spot-check a few people and ask

---

## File Locations

- Troubleshooting records → `./working/troubleshoot-{topic}.md`
- Root cause summaries for important issues → Archive to `./postmortems/{date}-{topic}.md` (code project → `./docs/postmortems/{date}-{topic}.md`)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.
