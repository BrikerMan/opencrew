---
name: bm.brainstorming
description: "Refine intent before taking action: use Socratic questioning to turn vague requirements into clear specs, present in chunks for user confirmation before proceeding. Use when user has a vague idea, fuzzy goal, or complex request that needs sharpening, 想做, 想要, 计划, 设计, 帮我做, 帮我想, brainstorm, idea, plan, spec, design. Applicable before writing articles, making decisions, planning, or writing code."
source: opencrew
version: "20260530.01"
---

# Skill: Brainstorming (Refine Intent Before Taking Action)

**Before writing code/articles or making decisions, first grind vague ideas into clear specs, have the user confirm each piece, then continue.** Target audience is non-technical; writing articles, planning, and product decisions all apply.

---

## When to Trigger

The user gives a **vague** or **open-ended** requirement, such as:

- "Help me write an X" → What is X? Who is it for? What's the goal?
- "I want to build a Y tool/product/event" → What problem does it solve? Target users? Scope?
- "Help me think about Z" → Think through what? What constraints exist?
- "Refactor/optimize/organize W" → What's unsatisfactory about the current state? What would ideal look like?

**Do NOT trigger when**: The user gives a clear, directly executable instruction ("Change the second paragraph of the README to XXX", "Install ffmpeg").

---

## Core Process

### Step 1: Identify Ambiguities (Do Not Start Immediately)

Read the user's input and list the **3-5 most critical uncertainties**. Priority:

1. **Goal**: What state should things be in after completion? What are the success criteria?
2. **Audience/Users**: Who will see/use this? Their background and expectations?
3. **Scope**: What must be included, what's optional, what's strictly excluded?
4. **Constraints**: Time, budget, technical, or style hard limits?
5. **Existing Materials**: What references, drafts, or related materials does the user have?

### Step 2: Socratic Questioning

**Ask only 1-2 most critical questions at a time.** Don't throw 10 questions at once — users will be annoyed.

Questioning principles:
- **Specific**: Don't ask "what style do you want", ask "do you want it like A or like B? Give an example"
- **Multiple choice**: Reduce cognitive load for the user
- **Based on guesses**: First guess an answer for the user to verify ("I understand you want X, is that right?")

Examples:

❌ Bad: "What kind of product do you want to build?"
✅ Good: "Is this tool for your own use, or for others? If for others, is it for colleagues or paying customers?"

❌ Bad: "What style should the article be?"
✅ Good: "Is this article meant to be a serious argument (like academic) or to attract attention (like social media)? I lean toward the latter, since you mentioned sharing it on social media."

### Step 3: Present Spec in Chunks (Critical)

**Don't present the entire long spec at once.** Show it to the user in chunks:

```
My understanding (please confirm or correct):

【Goal】
- Success criteria: XXX

【Audience】
- Primary: YYY
- Secondary: ZZZ

⏸️ Are these two parts correct? I'll confirm this first, then continue with scope and constraints.
```

User confirms → Continue to the next chunk. User corrects → Fix and re-confirm → Continue.

### Step 4: Finalize the Complete Spec

After all chunks are confirmed, write to `./working/brainstorm-{topic}.md` (intermediate artifact) or `./{topic}-spec.md` (final artifact):

```markdown
# Spec: {Topic}

## Goal
- Success criteria: ...

## Audience
- Primary: ...

## Scope
- Must have: ...
- Will not do: ...

## Constraints
- Time: ...
- Style: ...

## Existing Materials
- ...

## Next Steps
- [ ] ...
```

### Step 5: Clear Handoff

```
Spec has been saved to ./{topic}-spec.md. Confirm it's correct and I'll start working.
```

---

## Anti-Patterns (Don't Do These)

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| Start working immediately | Cost of going off track = full rework | Spec first, then execute |
| Ask 10 questions at once | User gets overwhelmed | 1-2 at a time, in chunks |
| Give open-ended questions | User doesn't know how to answer | Give specific options or guesses for user to confirm |
| Dump the entire spec at once | Too long, user won't read and verify each part | Present in chunks, pause at each |
| Only ask, never guess | Feels like an interrogation, user gets annoyed | First guess a version for the user to modify |
| Start working after user says "roughly" | Ambiguities remain unresolved | Key sticking points must be made explicit |

---

## Three Tiers of Depth

Choose based on requirement complexity:

| Tier | Applicable | Effort |
|---|---|---|
| **Light** | Simple requirement with only 1-2 ambiguities | Just ask 1 question, start working after getting the answer, don't write a spec file |
| **Standard** | Medium complexity, need to confirm goal + scope | Complete Steps 1-5, write spec to working/ |
| **Deep** | Large project, product, long-form content | Standard + competitive/reference research, write spec to root directory for archiving |

When unsure, proactively ask the user: "Do you want to quickly align, or create a complete spec?"

---

## Collaboration with Other Skills

- After completing spec, **before actually starting work**: invoke [bm.voice-of-user](../bm.voice-of-user/SKILL.md) to challenge from the user's perspective
- After completing execution: invoke [bm.verification](../bm.verification/SKILL.md) to self-verify whether the spec's success criteria are met
- Writing articles/reports: use `skilless.ai-writing` to execute after spec is finalized
- Research needs: use `skilless.ai-research` or [bm.research](../bm.research/SKILL.md) after spec is finalized

---

## File Locations

- Intermediate brainstorm drafts → `./working/brainstorm-{topic}.md`
- Final spec → `./{topic}-spec.md` (code project → `./docs/{topic}-spec.md`) or user-specified location
- Don't write to `/tmp/` or hidden directories

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.
