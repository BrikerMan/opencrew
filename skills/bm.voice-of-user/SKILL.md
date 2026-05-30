---
name: bm.voice-of-user
description: "Challenge product/spec/feature from user perspective: play different personas walking through flows, list friction points, give improvement suggestions in user language (not technical jargon). Use when designing or reviewing a product, feature, spec, UI, UX, flow, copy, 产品, 设计, 评审, 用户体验, UX, 易用性, 流程, 文案, review feature, design review, user perspective. Fills the 'user perspective' gap."
source: opencrew
version: "20260521.01"
---

# Skill: Voice of User (User Perspective Review)

**Stand on the user's side** to scrutinize products/features/specs/copy/flows. This is not a technical review — it's about putting yourself in the shoes of a "real user" to discover problems and give feedback.

---

## Applicable Scenarios

- Reviewing a feature design / spec / PRD
- Reviewing UI / flows / copy
- Deciding whether to add a feature (first check from user perspective if it's worth it)
- Improving an existing product's experience
- Checking if product intro / Landing Page can resonate with users

**Not applicable**: Technical quality review (use [bm.review-checklist](../bm.review-checklist/SKILL.md)), bug troubleshooting (use [bm.systematic-troubleshooting](../bm.systematic-troubleshooting/SKILL.md)).

---

## Core Principles

1. **Not the designer's perspective, but the user's**. Designers know the context and the "why"; users don't know and don't care.
2. **User language**: Don't say "trade-off", "P0", "MVP"; say "good enough", "hassle-free", "annoying".
3. **Specific scenarios**: Don't say "the experience here is bad"; say "as a first-time user, when I see X, I think Y".
4. **Truly blocking issues vs. nice-to-haves**: Rank them; don't lump everything together.

---

## Workflow

### Step 1: Clarify the Review Target

Read the spec / look at screenshots / listen to user's verbal description. If information is incomplete, ask:
- Who is this for? (**Most critical**)
- In what context will users encounter this? (mobile/desktop, busy/idle, new user/veteran)
- What user problem does it solve?

### Step 2: Select Personas (At Least 3)

Don't review with only one "ideal user". Run at least 3 personas:

| Persona | Characteristics | Focus |
|---|---|---|
| **Novice / First Time** | Doesn't know what this is or how to use it | Can they understand at first glance; will they bounce in the first 60 seconds |
| **Impatient / Busy** | No time to read instructions, wants to finish quickly | How many steps to complete; are there unnecessary steps |
| **Power User / Veteran** | Familiar with similar products, has comparisons | Is high-frequency operation fast; are there shortcuts |
| **Non-technical Person** | Elderly, non-tech professions | Can they understand the terminology; can they recover from errors |
| **Accessibility User** | Visually impaired, motor impaired, keyboard-only users | Can they complete the flow with keyboard; is color contrast sufficient |

If the task background includes specific target user personas, add them or substitute.

### Step 3: Walk Through the Flow for Each Persona

Describe from the user's perspective: **"I am XXX, I open X, I see Y, I want Z, I do W, the result is..."**

Record:
- **See**: Interface/text/buttons
- **Think**: Inner questions, expectations, misunderstandings
- **Do**: Actions
- **Result**: Whether it matches expectations; if not, where they got stuck

**Focus on catching**:
- Which step is most likely to cause abandonment / exit
- Which phrase/term confuses the user
- Which button makes the user unsure whether to click it
- How many steps to complete the core purpose (more = worse)

### Step 4: List Friction Points + Rank Them

```markdown
## Friction Points (By Severity)

### 🔴 Blocking (User Will Abandon)
- **Novice landing on homepage for the first time**: Sees "configure vault path" and doesn't know what it means, might just close the app
  - Suggested copy: "Tell me which folder your notes are in" + a "Let me choose" button

### 🟡 Annoying (Can Complete But Frustrating)
- **Power user**: Need to click 4 times every time to add a task, can we make it one click?
  - Suggestion: Add `Cmd+N` keyboard shortcut

### 🟢 Nice to Have
- Colors could be more harmonious
```

### Step 5: Suggestions Must Include Alternatives

Don't just say "this doesn't work"; provide at least one specific alternative:

❌ "This button copy is bad"
✅ "Change 'Confirm Submit' to 'Send It Like This' — more conversational, easier for novices to click"

❌ "The flow is too long"
✅ "Merge steps 2 and 3 into one form, from 5 steps → 3 steps"

---

## Classic Follow-up Question Checklist

Ask yourself each time (not all need to be used):

**Entry / First Impression**
- How does the user know this feature exists?
- Can they understand what it does at first glance?
- Can they articulate the value within 30 seconds?

**Task Path**
- How many steps to complete the core goal?
- Are there unnecessary intermediate steps?
- Which steps require user input? How much mental effort does the input take?

**Error Tolerance**
- Can the user go back if they make a mistake?
- Can the user understand error messages?
- Are there confirmations for destructive/irreversible actions?

**Waiting / Feedback**
- Is there a progress indicator for slow operations?
- Is there clear feedback upon completion?
- When it fails, does the user know what to do next?

**Leaving / Returning**
- Can the user find their previous state when they come back?
- After using it, would they want to recommend it to a friend? Why?

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| Vague "experience is bad" | Not actionable | Specific to "which persona, sees what, thinks what, stuck where" |
| Only criticizing without solutions | Designer can't act on it | At least 1 alternative per issue |
| Using product manager jargon | Users don't think like that | User language |
| Dumping 30 issues at once | No focus, can't fix them all | Rank as blocking/annoying/nice-to-have, fix blocking first |
| Representing users with "I think" | You are not the user | Review per persona explicitly, note which persona's perspective |
| Ending after review | No re-review after changes | Walk through persona flow again after fixes to verify |

---

## Output Template

```markdown
# Voice of User Review: {Target}

**Review Target**: {spec / feature / screenshot / flow}
**Target Users**: {Personas}
**Core Goal**: {What users want to achieve with this}

## Personas

1. **{P1 Name}**: {One-sentence background}
2. **{P2 Name}**: {One-sentence background}
3. **{P3 Name}**: {One-sentence background}

## Flow Walkthrough

### {P1} Perspective
> I am X, I open Y, I see Z...

- ✅ Smooth parts
- ⚠️ Friction point 1
- ❌ Blocking point

### {P2} Perspective
...

## Friction Points Summary

### 🔴 Blocking
- ... (Suggestion: ...)

### 🟡 Annoying
- ... (Suggestion: ...)

### 🟢 Nice to Have
- ...

## Overall Assessment

**Worth doing?**: {Judgment on core goal}
**Top priority fixes**: {1-3 things}
```

---

## Collaboration with Other Skills

- Before design: [bm.brainstorming](../bm.brainstorming/SKILL.md) has already finalized the spec → run voice-of-user review here
- After changes: Run voice-of-user again → then use [bm.verification](../bm.verification/SKILL.md) for self-verification
- Writing product copy / Landing Page: After draft is done, use voice-of-user to check if new users can be engaged within 30 seconds

---

## File Locations

- **Intermediate artifacts**: `./working/voice-of-user-{topic}.md`
- **Final artifacts**: `./reviews/{topic}-uxreview.md` (code project → `./docs/reviews/{topic}-uxreview.md`) (when user requests formal review/archiving)
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.
