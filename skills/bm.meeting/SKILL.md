---
name: bm.meeting
description: "会议处理：会议纪要生成、字幕/录音转文字、议程管理、行动项追踪。Use when user has meeting notes, transcripts, subtitles to process, 会议, 纪要, 字幕, 录音, 议程, 行动项, meeting notes, transcript. 自动提取关键决策和待办。"
source: opencrew
version: "20260521.01"
---

# Skill: 会议处理

## 作用域

会议纪要提取、Action Items 跟踪的可执行流程。

## 文件落点

- **最终产物**：`./meetings/...`（cwd 下，可见目录，跟随用户惯例）
- **中间产物**：`./working/meeting/`
- **目录不存在**：主动创建；用户已有惯例则跟随
- **永远在 cwd 内**：不写 `/tmp/`、`~/Desktop/`、`~/Downloads/` 等 cwd 之外位置（用户明确指定除外）

---

## 从零创建会议纪要

### Step 1：确认信息

- 日期（`YYYY-MM-DD`）
- 主题（简短 kebab-case）
- 参会人
- 是否关联项目

### Step 2：搜索是否已存在

```
glob "./meetings/{date}-*.md"
```

### Step 3：从模板创建

写入 `./meetings/{YYYY-MM-DD}-{topic}.md`：

```markdown
---
type: meeting
date: 2026-05-16
attendees:
  - 张三
  - 李四
project: "[[IPverse 项目]]"
tags: [meeting]
---

# 会议：IPverse 周会

## 议题
1. 本周进展回顾
2. 下周计划
3. 技术风险讨论

## 讨论要点

### 本周进展
- 前端 v2 完成开发，进入测试
- API 性能优化完成，P99 从 800ms 降到 200ms

### 技术风险
- 第三方支付接口周末维护，可能影响上线

## 决议
- 前端 v2 下周三前完成测试
- 支付接口切换到备用方案

## Action Items
- [ ] 前端测试用例补全 — @李四 — 截止 2026-05-20
- [ ] 支付接口备用方案调研 — @张三 — 截止 2026-05-18
- [ ] 更新项目周报 — @张三 — 截止 2026-05-17

## 下次会议
- 时间：2026-05-23
- 重点：前端测试结果、支付方案确认
```

## 从录音/字幕提取纪要

### Step 1：读取字幕文件

字幕通常在 `./working/transcripts/` 或用户指定路径。

### Step 2：提取要点

1. **识别发言人**（如果字幕有 speaker 标注）
2. **跳过寒暄和重复**，只提取：
   - 关键讨论点（"我觉得..."、"问题是..."）
   - 决议（"那就这样..."、"我们决定..."）
   - Action Items（"谁来做..."、"下周前..."）
3. **按议题分组**，不是按时间线罗列

### Step 3：整理输出

用上面的会议纪要模板格式化。特别注意：
- Action Items 每条必须有：具体事项 + 负责人 + 截止日期
- 不清晰的 Action Item 要标注 `[需确认]`
- 决议要标注谁拍板的

## 会议类型模板

### 周会

固定议题：
1. 上周进展回顾（对照上周 Action Items 完成）
2. 本周计划
3. 风险/阻塞
4. Action Items

### 评审

固定议题：
1. 评审对象和范围
2. 评审标准
3. 逐项评审结果
4. 改进建议
5. 结论（PASS / CONDITIONAL PASS / FAIL）

### 汇报

固定议题：
1. 汇报主题
2. 当前进度（数据驱动）
3. 关键数据指标
4. 下一步计划
5. 需要的支持/资源

## Action Items 跟踪

### 格式规范

```markdown
- [ ] 具体事项 — @负责人 — 截止 YYYY-MM-DD
```

每条 Action Item 必须：
- **具体**：不是"优化性能"，是"将 /api/users 的 P99 响应时间优化到 <500ms"
- **有负责人**：`@人名`，不能是"大家"
- **有截止日期**：`YYYY-MM-DD`

### 后续跟踪

- 下次会议开头：回顾上次 Action Items 完成情况
- 未完成的 Action Item：标注原因，决定是否延期或取消
- 不要创建"跟踪待办完成情况"的新 Action Item（那不是待办，那是流程）
