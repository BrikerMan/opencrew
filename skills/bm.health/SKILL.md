---
name: bm.health
description: "Personal health management: body metrics tracking, diet logging, exercise logging, sleep logging, trend analysis. Use when user wants to log or check weight, diet, exercise, sleep, body metrics, 体重, 饮食, 运动, 睡眠, 卡路里, 跑步, 健身."
source: opencrew
version: "20260521.01"
---

# Skill: Personal Health Management

## Scope

Data-driven management of body metrics, diet, exercise, and sleep. Emotions, stress, symptoms, and medications belong to `bm.wellness`.

## File Locations

- **Final artifacts**: `./health/...` (code project → `./docs/health/...`) (under cwd, visible directory, follow user conventions)
- **Intermediate artifacts**: `./working/health/`
- **Directory does not exist**: Create it proactively; follow user conventions if they exist
- **Always within cwd**: Don't write to `/tmp/`, `~/Desktop/`, `~/Downloads/`, or anywhere outside cwd (unless user explicitly specifies)

**Code Project Detection**: If code project markers exist under cwd (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `Gemfile`, `composer.json`, or `src/` + `.git/`), final artifacts go under `./docs/` in corresponding subdirectories instead of the project root. Intermediate artifacts in `./working/` remain unchanged. User-specified paths take priority.

## Privacy and Write Confirmation

- Health data is sensitive personal information. Only persist when the user explicitly says "record/save/write"; if just asking for advice, default to answering in conversation only.
- Before writing to `./health/` or journal frontmatter for the first time, explain which fields and paths will be saved, and get confirmation before writing.
- Don't write health data outside cwd, and don't fill in or guess data the user hasn't provided.

---

## Data Storage Path

All health data is written to the `./health/` directory.

If this directory does not exist, first search to confirm:

```
glob "./health/**"
```

If the current working directory has no Health structure, write health data to journal frontmatter.

### Path Mapping

| Data Type | File Path |
|---------|---------|
| Body metrics | `./health/body/metrics/YYYY-MM-DD.md` |
| Diet records | `./health/diet/YYYY-MM-DD.md` |
| Exercise records | `./health/exercise/YYYY-MM-DD.md` |
| Sleep records | `./health/sleep/YYYY-MM-DD.md` |

### Simplified Mode (No health Directory)

Write to journal frontmatter:

```yaml
---
type: daily
date: 2026-05-16
weight: 72.5           # kg
body_fat: 18            # %
sleep_hours: 7.5        # hours
sleep_quality: 4        # 1-5
exercise_type: running  # type
exercise_duration: 45   # minutes
---
```

## Recording Process

### Body Metrics

When the user provides weight/body fat data:

**Step 1**: Confirm the date (default is today)
**Step 2**: Search whether a record already exists for that day

```
glob "./health/body/metrics/YYYY-MM-DD.md"
```

**Step 3**: Create or update the record

```markdown
---
type: note
date: 2026-05-16
tags: [health, metrics]
---

# Body Metrics 2026-05-16

| Metric | Value |
|------|------|
| Weight | 72.5 kg |
| Body Fat | 18% |

## Notes
[If there are anomalies or user notes]
```

**Step 4**: Read the last 7 days of data and provide trend analysis

```
glob "./health/body/metrics/*.md"
```

### Diet Records

```markdown
---
type: note
date: 2026-05-16
tags: [health, diet]
---

# Diet 2026-05-16

| Meal | Content | Estimated Calories |
|------|------|---------|
| Breakfast | Eggs x2 + whole wheat bread + milk | ~450 kcal |
| Lunch | Chicken breast salad | ~350 kcal |
| Dinner | Beef noodles | ~650 kcal |

**Total calories**: ~1450 kcal

## Suggestions
Good protein intake (eggs + chicken breast + beef), but dinner carbs are on the high side.
Suggest reducing noodle portion at dinner and adding a serving of vegetables.
```

**After recording diet, always provide suggestions**:
1. Analyze nutritional composition (protein/carbs/vegetables/calories)
2. Point out issues
3. Give one specific improvement suggestion

### Exercise Records

```markdown
---
type: note
date: 2026-05-16
tags: [health, exercise]
---

# Exercise 2026-05-16

| Item | Details |
|------|------|
| Type | Running |
| Duration | 45 minutes |
| Distance | 6.2 km |
| Intensity | RPE 6/10 |
| Heart Rate | avg 145 bpm |

## Notes
Pace is 10s/km faster than last week, clear improvement.
```

### Sleep Records

```markdown
---
type: note
date: 2026-05-16
tags: [health, sleep]
---

# Sleep 2026-05-16

| Metric | Value |
|------|------|
| Bedtime | 23:30 |
| Wake time | 07:00 |
| Duration | 7.5 hours |
| Quality | 4/5 |

## Notes
Sufficient deep sleep, felt refreshed upon waking.
```

## Trend Analysis

When the user asks about health trends:

**Step 1**: Read data files from the last 7-30 days
**Step 2**: Summarize key metrics
**Step 3**: Calculate trends (increasing/decreasing/stable)

```markdown
## Weight Trend (Last 7 Days)

| Date | Weight | Change |
|------|------|------|
| 05-10 | 73.2 | — |
| 05-11 | 73.0 | -0.2 |
| 05-12 | 72.8 | -0.2 |
| 05-13 | 72.9 | +0.1 |
| 05-14 | 72.6 | -0.3 |
| 05-15 | 72.5 | -0.1 |
| 05-16 | 72.5 | 0.0 |

**Trend**: Steadily decreasing, 0.7 kg loss over 7 days. Healthy rate, keep it up.

**Note**: Daily fluctuations of ±0.3 kg are normal; the 7-day moving average is more accurate.
```

## Health Advice Principles

1. **Data-driven**: When records exist, analyze from data; when they don't, say "insufficient data, suggest tracking first"
2. **No medical diagnoses**: For abnormal metrics, suggest seeing a doctor; don't draw conclusions yourself
3. **Encourage sustainable habits**: Don't recommend extreme diets or excessive exercise
4. **Respect personal preferences**: Consider dietary preferences and exercise preferences
5. **Don't assume when data is missing**: Don't fabricate data to fill gaps
