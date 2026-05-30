---
name: bm.verification
description: "Self-verification before completion: before claiming done, must list checklist, run through it, and check results. Use before claiming a task is complete, finished, ready, done, 完成, 搞定, 做完, 跑通, ready, done, finish, complete. Prevents false completions, self-deception, and submitting broken deliverables."
source: opencrew
version: "20260530.01"
---

# Skill: Verification (Self-Verification Before Completion)

**Before claiming "done", the agent must run through verification itself, list evidence, not just say "I finished it" in words.**

Applicable to code, documentation, design, reports, configuration — any deliverable.

---

## Trigger Timing

**Mandatory trigger**: Before the agent is about to say any of the following —

- "I've completed X"
- "X is fixed"
- "It's ready, give it a try"
- "Done, written to Y"
- "All requirements are implemented"
- "Done"

**Do NOT trigger**:
- User explicitly says "that's fine for now, I'll review it myself"
- Intermediate artifacts, not claiming completion

---

## Three-Step Method

### Step 1: List the Checklist

Based on this task's goals, list **verifiable checklist items**. Each must be:
- **Objective**: Can be answered with evidence yes/no, not subjective judgment
- **Specific**: Not "feature works", but "running command X returns 0"
- **Actionable**: You (the agent) can verify it on the spot

Checklist examples:

**Writing code**:
- [ ] File written to expected path (verify with `ls` or reading the file)
- [ ] Syntax correct (lint / typecheck passes)
- [ ] Key behavior matches spec (run tests or manual invocation)
- [ ] Haven't broken other files (check scope with git diff)

**Writing documentation**:
- [ ] Length / structure meets requirements
- [ ] Facts are from source material, not fabricated
- [ ] Links / file paths are all accessible
- [ ] User's key points are all covered

**Fixing a bug**:
- [ ] Reproduction steps no longer trigger the issue
- [ ] No regression introduced (related tests pass)
- [ ] Root cause was fixed, not symptoms

**Configuration/Installation**:
- [ ] Config file is valid format (json/yaml parsing passes)
- [ ] Service/tool can start
- [ ] Verified with a minimal test case

### Step 2: Actually Run Through It

**Actually execute**, don't imagine. Common actions:

| Deliverable Type | Verification Action |
|---|---|
| Code | Run tests / lint / typecheck / actually invoke once |
| Script | Run once with sample input |
| Documentation | Read through once, check links and facts |
| Configuration | Have the target program load this config |
| Data/Report | Spot-check several entries |

Record **actual evidence** for each checklist item:
- Command exit codes and output snippets
- Actual file content snippets
- Screenshots / key log lines

### Step 3: Present the Verification Report

Format presented to the user:

```markdown
## Completion Report

**What was done**: One sentence describing what was done.

**Verification Results**:
- ✅ File written to ./output/report.md (138 lines)
- ✅ Markdown lint passed (0 errors)
- ✅ All links accessible (5/5)
- ⚠️ One item [needs confirmation]: X data field missing from original material, marked accordingly

**Evidence**:
\```
$ wc -l output/report.md
138 output/report.md

$ markdownlint output/report.md
(no output, passed)
\```

**Not Covered**:
- Didn't do Y because it's out of scope

**Suggested Next Steps**:
- You may want to check the ⚠️ item
```

---

## Anti-Patterns (Absolutely Do Not Do These)

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| "Should be fine" / "Theoretically no issues" | Haven't actually run it | Must run it |
| Ran once without errors and assumed OK | Didn't check output; could be silent failure | Check actual output against expectations |
| Self-assessed as correct and reported done | Subjective, unreliable | Give objective evidence |
| Lowered verification standards during verification | Self-deception | Verification standard = task standard |
| Reported "all done" but skipped some items | Misleading to the user | Explicitly mark skipped items with reasons |
| Hid failed items | User discovers them later, worse | Report failed items with ❌ clearly, give fix suggestions |

---

## Edge Cases

**When verification fails**:
- Don't stubbornly report "done"
- Report "partially done" or "not done", list failed items and your assessment (continue fixing / needs user decision)

**When unable to verify** (e.g., requires external environment):
- Explicitly say "I cannot locally verify X because Y"
- Give the user simple verification steps: "Please run `Z` and check if the output is `...`"

**When verification cost is too high** (e.g., requires production deployment):
- Fall back: Reproduce an equivalent scenario on staging / locally to verify
- Clearly mark the parts that cannot be verified

---

## Collaboration with Other Skills

- Task starting point used spec defined by [bm.brainstorming](../bm.brainstorming/SKILL.md) → Verification = checking against spec's success criteria
- Errors occur → Switch to [bm.systematic-troubleshooting](../bm.systematic-troubleshooting/SKILL.md) to troubleshoot root cause
- User perspective review → [bm.voice-of-user](../bm.voice-of-user/SKILL.md)

---

## File Locations

Verification evidence/logs → `./working/verification-{task}.log`, attach to report when needed.

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), document-type final artifacts go under `./docs/` in corresponding subdirectories. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.
