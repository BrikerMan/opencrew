---
name: bm.review-checklist
description: "Code review checklist: structured code review process, quality gates, best practice checks. Use when user requests code review, PR review, quality check, 审查, review, 代码审查, PR检查. Covers security, performance, maintainability, test coverage dimensions."
source: opencrew
version: "20260521.01"
---

# Skill: Code Review Checklist

Checklist items and output format for multi-dimensional code review.

## File Locations

- **Final artifacts**: `./reviews/...` (code project → `./docs/reviews/...`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/review/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

---

## Review Process

### Step 1: Understand Context

The delegating party will tell you:
- What was changed (new feature / bug fix / refactor)
- Which files are involved
- What to focus on

If no context is given, infer from commit messages and diff summaries yourself.

### Step 2: Read the Code

1. Read the changed files, understand the intent of the changes
2. Read related context files (called functions, dependent modules)
3. Check consistency with existing project patterns

### Step 3: Check Each Dimension

## Dimension 1: Correctness

- [ ] Core logic matches expectations (against requirements/spec)
- [ ] Edge cases: null `null`/`undefined`/`None`, zero values `0`/`""`, negative numbers, extremely large values
- [ ] Types are correct (type inference vs. explicit annotations)
- [ ] Concurrency/race conditions: shared state, async operation ordering, lock scope
- [ ] Resource leaks: file handles, database connections, memory (especially those created in loops)
- [ ] Idempotency: is repeated calling safe

## Dimension 2: Security

- [ ] Input validation: are user inputs and external API return values trusted
- [ ] SQL injection: using parameterized queries, not string concatenation
- [ ] XSS: is user-generated content escaped
- [ ] CSRF: is there token verification
- [ ] Permission checks: does the current user have permission for this operation
- [ ] Sensitive data: passwords/tokens not logged or exposed in API responses
- [ ] Encryption: transport layer HTTPS, storage layer hash/encrypt

## Dimension 3: Performance

- [ ] N+1 queries: are there database calls inside loops
- [ ] Full data loading: is pagination/lazy loading/streaming needed
- [ ] Caching strategy: is hot data cached, is cache invalidation strategy reasonable
- [ ] Memory usage: handling of large arrays/lists (can streaming be used)
- [ ] Async vs sync: are I/O operations async

## Dimension 4: Maintainability

- [ ] Naming: do function names express intent (no comments needed to explain)
- [ ] Function length: consider splitting if over 30 lines
- [ ] Coupling: will changing A affect B
- [ ] Duplication: 3+ occurrences of the same logic → extract a shared function
- [ ] Magic numbers/strings: hardcoded constants → extract as named constants
- [ ] Over-abstraction: don't need an interface/strategy pattern with only 1 implementation

## Dimension 5: Consistency

- [ ] Code style consistent with the project (naming, formatting, structure)
- [ ] Error handling approach consistent (throw vs return error vs Result)
- [ ] Logging format consistent
- [ ] API design style consistent (RESTful, naming conventions)

## Dimension 6: Error Handling

- [ ] Exceptions properly caught (not empty `catch`/`except pass`)
- [ ] Error messages are meaningful (not just `"error"` or `"something went wrong"`)
- [ ] Reasonable degradation or rollback on failure
- [ ] Errors are traceable (with sufficient context: request ID, user ID, key parameters)

## Severity Levels

| Level | Meaning | Examples |
|------|------|------|
| 🔴 Must fix | Will cause bugs/security issues/data loss | SQL injection, null pointer, resource leak, permission bypass |
| 🟡 Should fix | Won't break things but should be addressed | N+1 queries, unclear naming, missing error handling, missing tests |
| 🟢 Optional | Nice to have | Minor code style tweaks, small maintainability improvements |

## Output Format

```markdown
## Review Conclusion
[PASS / PASS_WITH_NOTES / REQUEST_CHANGES]

## 🔴 Must Fix
- [Issue description] `file path:line number` — [Reason] → Suggested fix: [specific fix]

## 🟡 Should Fix
- [Issue description] `file path:line number` — [Reason]

## 🟢 Optional Improvements
- [Suggestion]

## Summary
[One or two sentence overall assessment]
```

## Review Principles

- If the code has no issues, don't force-find problems. PASS is PASS
- Every 🔴/🟡 must include the file path and line number
- Every issue should come with a specific fix, not just pointing out the problem
- Don't nitpick formatting (that's the linter's job)
- For unfamiliar domains, note "unsure about this part, suggest having someone familiar review it"
