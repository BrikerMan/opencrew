---
name: bm.skill-improvement
description: "Skill 自我优化：评估现有 skill 质量、发现问题、提出改进方案、迭代更新。Use when user wants to improve, update, optimize skills, 优化 skill, 改进 skill, 更新 skill, skill 质量. 由 butler agent 调用。"
source: opencrew
version: "20260521.01"
---

# Skill: Skill 自我优化

## 作用域

分析 skill 使用情况，生成改进建议，用户确认后执行优化。

## 文件落点

- **最终产物**：`./reports/skill-suggestions/{skill}-{date}.md`（cwd 下，可见目录，跟随用户惯例）
- **中间产物**：`./working/skill-improvement/`
- **变更日志**：`./working/skill-improvement/changelog.md`
- **目录不存在**：主动创建；用户已有惯例则跟随
- **永远在 cwd 内**：不写 `/tmp/`、`~/Desktop/`、`~/Downloads/` 等 cwd 之外位置（用户明确指定除外）

---

## 原则

1. **不自动修改任何 skill 文件**。所有改动必须用户确认
2. **每次只改一个 skill**。不要一次改多个
3. **改前备份**。记录原始内容和改动理由
4. **可回滚**。每次改动记录版本号，可以恢复

---

## 优化流程

### Step 1：收集使用数据

从以下来源推断 skill 使用情况：

1. `./reports/butler-*.md` 和 `./reports/skill-suggestions/*.md` — 之前的复盘与建议
2. 近期对话上下文 — 用户反馈了什么问题
3. `./working/skill-improvement/changelog.md` — 已确认执行过的 skill 变更
4. 相关产物目录 — 哪些 skill 对应的输出质量如何

### Step 2：评估每个 Skill

对每个 skill 按 3 个维度打分：

| 维度 | 评分标准 |
|------|---------|
| **清晰度** | Agent 按照指令执行时，是否经常偏离？偏离说明指令不够清晰 |
| **完整性** | 是否经常遇到指令没覆盖的场景？ |
| **实用性** | 实际使用中哪些部分是多余的？哪些缺失？ |

### Step 3：生成优化报告

```markdown
## Skill 优化报告

### 评估结果

| Skill | 清晰度 | 完整性 | 实用性 | 优先级 |
|-------|--------|--------|--------|--------|
| research | 8/10 | 7/10 | 9/10 | 低 |
| meeting | 6/10 | 5/10 | 8/10 | 高 |
| health | 9/10 | 8/10 | 9/10 | 无需改 |

### 需要优化的 Skill

#### 1. bm.meeting/SKILL.md（优先级：高）

**问题**：
- 字幕提取步骤不够具体，Agent 不知道如何处理无 speaker 标注的情况
- 缺少"多语言会议"的处理说明

**建议改动**：
1. 在"字幕提取"部分增加无 speaker 标注的处理流程
2. 增加"多语言会议"小节

**改动内容**：
[具体要改的文字，old → new]
```

### Step 4：用户确认

把报告交给用户，等确认后再改。

### Step 5：执行改动

用户确认后：
1. 记录改动前内容到 `./working/skill-improvement/changelog.md`
2. 修改 skill 文件
3. 在 changelog 中记录改动摘要和回滚信息

---

## 变更日志格式

在 `./working/skill-improvement/changelog.md` 中维护：

```markdown
## Skill 变更日志

| 日期 | Skill | 改动摘要 | 原因 |
|------|-------|---------|------|
| 2026-05-16 | bm.meeting | 增加无 speaker 字幕处理流程 | 字幕提取经常偏离 |
| 2026-05-16 | bm.project-mgmt | 增加项目目录创建流程 | 首次创建时不确定步骤 |
```

---

## 优化模式

### 用户主动触发

```
用户 → Lead: "帮我优化一下 meeting skill"
Lead → Butler: 执行 skill-improvement 流程
Butler → 输出优化报告
Lead → 交给用户确认
```

### Butler 定期复盘时触发

在复盘报告的"建议优化"部分输出。不自动执行，等用户确认。

---

## 注意事项

- 不要为了改而改。用得好的 skill 不要动
- 每次改动最小化。只改有问题的部分，不顺手"完善"其他部分
- 改动理由必须来自实际使用中的问题，不是理论上的"可以更好"
- 如果 skill 刚改过不到 7 天，不要再次建议改动（给改动时间验证）
