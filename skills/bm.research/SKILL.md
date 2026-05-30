---
name: bm.research
description: "Research methodology: multi-source search, comparative analysis, solution research, fact-checking. Use when user needs to investigate, compare, analyze options, do deep research, 调研, 对比, 分析, 方案, 选型, 调查, 事实核查. Do NOT use for task completion verification; use bm.verification for 完成/搞定/跑通/done. Structured research process producing analysis reports with sources."
source: opencrew
version: "20260521.01"
---

# Skill: Research Methodology

Actionable process for multi-source information gathering, comparative analysis, and solution recommendations.

## 🔴 First Principle: Cite or It Didn't Happen

The core of research is not "information volume", it's "**every claim can be cited back to the original source**".

- Every conclusion / data point / recommendation in the report must have inline citations to specific sources (URLs or `[[sources/NN-slug]]`).
- No "as far as I know / generally speaking / it's commonly believed" — that's model prior, not research.
- Content from model memory rather than search must be marked `[model prior, unverified]`.
- Source files should preserve verbatim excerpts from the original text for user verification.
- Claims without findable sources → mark as `[unverified]` / `[inferred]`, don't disguise them as facts.

**A report with less than 100% citation coverage equals no research done.**

## File Locations

- **Final artifacts**: `./research/{topic}/REPORT.md` (code project → `./docs/research/{topic}/REPORT.md`)
- **Source files**: `sources/{NN}-{slug}.md` in the same directory
- **Search log**: `search-log.md` in the same directory
- **Intermediate artifacts**: `./working/research/{topic}/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

## Applicability Boundaries

- Simple factual Q&A: Can be answered directly without creating `./research/`.
- Multi-source comparison, recommendations, solution selection, fact-check reports: Use this skill; if orchestrated by Lead, prefer delegating to `researcher`.
- Pre-task-completion verification, testing, lint, checklists: Don't use this skill; use `bm.verification`.

---

## Search Strategy

1. **Multiple keywords for the same question**: Search 3-5 keyword groups from different angles
2. **Search in both Chinese and English**: Chinese for Zhihu/Juejin/CSDN, English for official docs/SO/Reddit/HN
3. **Three layers of information sources**:
   - Official documentation and GitHub READMEs (highest authority)
   - Community discussions (Stack Overflow / Reddit / tech blogs)
   - Real-world cases (GitHub Issues, production reports)
4. **Reverse search**: Search for problems and pitfalls
   - `xxx problems`, `xxx issues`, `xxx limitations`
   - `xxx vs yyy`, `xxx alternative`, `migrating from xxx to yyy`
   - `xxx production`, `xxx scale`, `xxx performance`

## Comparative Analysis Process

### Step 1: Define Comparison Dimensions

| Dimension | Description | Weight |
|------|------|------|
| Feature coverage | Can it do what's needed? What's missing? | High |
| Performance | Benchmark data, extreme scenario behavior (large data/high concurrency) | Depends on scenario |
| Ecosystem/Community | npm/PyPI downloads, GitHub stars, Issue response speed, plugin count | Medium |
| Learning curve | Documentation quality, API design intuitiveness, example richness | Medium |
| Maintenance status | Last commit time, release frequency, core team activity, open issues count | High |
| Best-fit scenarios | Best scenarios vs. not recommended scenarios | High |
| Migration cost | How much effort to migrate from current solution | Depends on scenario |

### Step 2: Fill in the Comparison Table Item by Item

```
| Dimension | Option A | Option B |
|------|--------|--------|
| Features | ... | ... |
| Performance | ... | ... |
| ... | ... | ... |
```

### Step 3: Give a Recommendation

**Don't list a menu for the user to choose.** Recommend one option and explain why. Format:

```
## Recommendation: Option A

Reasoning:
1. [Reason one]
2. [Reason two]

When to choose Option B instead:
- [Condition one]
- [Condition two]
```

## Feasibility Analysis Process

When verifying a specific solution, check this list:

- [ ] Are prerequisites met (runtime environment, dependency versions, team skills)
- [ ] What are the technical risks (known bugs, unresolved GitHub Issues)
- [ ] Known limitations (unsupported features, performance ceilings, platform restrictions)
- [ ] Are there production-verified cases (not just todo-list demos)
- [ ] Is the migration path clear (is there an official migration guide)

## Output Format

```markdown
## Conclusion
[One-sentence recommendation]

## Background
[Why this research was done, what problem it solves]

## Findings

### Option A: xxx
- Pros: ...
- Cons: ...
- Best-fit scenarios: ...
- Production cases: ...

### Option B: xxx
- Pros: ...
- Cons: ...
- Best-fit scenarios: ...

## Recommendation
[Which one to recommend + why + when to choose the other]

## Risks and Caveats
[Known pitfalls, migration costs, compatibility issues, time-sensitive information]
```

## Principles

- **Cite or didn't happen**: Every claim must have an inline source citation, otherwise don't deliver (see "First Principle" at top).
- **Don't pass off model priors as research**: No "as far as I know / generally / it's commonly believed" — either find the source or mark as `[model prior, unverified]`.
- **Give recommendations, not menus**: Recommend one option, don't say "either works, depends on the situation" — but every reason must have a citation.
- **Mark uncertainty**: When information is insufficient, explicitly mark `[unverified]` / `[inferred]` / `[disputed]`, don't disguise as fact.
- **Be pragmatic**: Focus on real-world usage experience, not just feature lists and benchmarks.
- **Timeliness**: Note publication dates of sources; information older than 1 year should have a caveat about potential obsolescence.
- **Depth first**: Default to L3 depth (multiple search rounds, multi-source verification); don't give "anyone could find this" answers.
