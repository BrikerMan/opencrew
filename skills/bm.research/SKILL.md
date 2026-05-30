---
name: bm.research
description: "调研方法论：多源搜索、对比分析、方案调研、信息核实。Use when user needs to investigate, compare, analyze options, do deep research, 调研, 对比, 分析, 方案, 选型, 调查, 事实核查. Do NOT use for task completion verification; use bm.verification for 完成/搞定/跑通/done. 结构化调研流程，产出带来源的分析报告。"
source: opencrew
version: "20260521.01"
---

# Skill: 调研方法论

多源信息收集、对比分析、方案推荐的可执行流程。

## 🔴 第一原则：Cite or it didn't happen

调研的核心不是"信息量"，是"**每条声明都能 cite 回原文**"。

- 报告里每一条结论 / 数据 / 推荐都必须 inline 引用具体 source（URL 或 `[[sources/NN-slug]]`）。
- 禁止"据我所知 / 通常来说 / 一般认为"——这是模型先验，不是调研。
- 来自模型记忆而非搜索的内容必须标 `[模型先验，未验证]`。
- Source 文件保存原文逐字摘录，方便用户复查。
- 找不到出处的判断 → 标 `[未验证]` / `[推断]`，不要伪装成事实。

**Citation 覆盖率不到 100% 的报告等于没做调研。**

## 文件落点

- **最终产物**：`./research/{topic}/REPORT.md`（代码项目 → `./docs/research/{topic}/REPORT.md`）
- **Source 文件**：同上目录下的 `sources/{NN}-{slug}.md`
- **搜索日志**：同上目录下的 `search-log.md`
- **中间产物**：`./working/research/{topic}/`
- **目录不存在**：主动创建；用户已有惯例则跟随
- **永远在 cwd 内**：不写 `/tmp/`、`~/Desktop/`、`~/Downloads/` 等 cwd 之外位置（用户明确指定除外）

**代码项目检测**：如果 cwd 下存在代码项目标志（`package.json`、`Cargo.toml`、`go.mod`、`pyproject.toml`、`setup.py`、`pom.xml`、`Gemfile`、`composer.json`，或有 `src/` + `.git/`），则最终产物统一放到 `./docs/` 下对应子目录，而不是项目根目录。中间产物 `./working/` 不变。用户明确指定路径时优先遵循用户指定。

## 适用边界

- 简单事实问答：可以直接回答，不创建 `./research/`。
- 需要多源比较、推荐、方案选型、事实核查报告：使用本 skill；如果由 Lead 编排，优先委派 `researcher`。
- 任务完成前的验证、测试、lint、检查清单：不要用本 skill，用 `bm.verification`。

---

## 搜索策略

1. **多关键词搜索同一问题**：从不同角度搜索 3-5 组关键词
2. **中英文都搜**：中文搜知乎/掘金/CSDN，英文搜官方文档/SO/Reddit/HN
3. **三层信息源**：
   - 官方文档和 GitHub README（权威性最高）
   - 社区讨论（Stack Overflow / Reddit / 技术博客）
   - 实际案例（GitHub Issues、生产环境报告）
4. **反向搜索**：搜问题和坑
   - `xxx problems`、`xxx issues`、`xxx limitations`
   - `xxx vs yyy`、`xxx alternative`、`migrating from xxx to yyy`
   - `xxx production`、`xxx scale`、`xxx performance`

## 对比分析流程

### Step 1：定义对比维度

| 维度 | 说明 | 权重 |
|------|------|------|
| 功能覆盖 | 能不能做需要的事？缺什么？ | 高 |
| 性能 | 基准数据、极端场景（大数据量/高并发）表现 | 看场景 |
| 生态/社区 | npm/PyPI 下载量、GitHub stars、Issues 响应速度、插件数量 | 中 |
| 学习成本 | 文档质量、API 设计直觉度、示例丰富度 | 中 |
| 维护状态 | 最近 commit 时间、发布频率、核心团队活跃度、open issues 数 | 高 |
| 适合场景 | 最佳场景 vs 不适用场景 | 高 |
| 迁移成本 | 从当前方案迁移需要多少工作量 | 看场景 |

### Step 2：逐项填充对比表

```
| 维度 | 方案 A | 方案 B |
|------|--------|--------|
| 功能 | ... | ... |
| 性能 | ... | ... |
| ... | ... | ... |
```

### Step 3：给推荐

**不要列菜单让用户选。** 推荐一个方案，说明为什么。格式：

```
## 推荐：方案 A

理由：
1. [理由一]
2. [理由二]

什么时候选方案 B：
- [条件一]
- [条件二]
```

## 可行性分析流程

验证特定方案时，检查以下清单：

- [ ] 前置条件是否满足（运行环境、依赖版本、团队技能）
- [ ] 技术风险在哪（已知 bug、未解决的 GitHub Issues）
- [ ] 已知限制（不支持的功能、性能天花板、平台限制）
- [ ] 有没有生产环境验证案例（不只是 todo-list demo）
- [ ] 迁移路径是否清晰（有没有官方迁移指南）

## 输出格式

```markdown
## 结论
[一句话推荐]

## 背景
[为什么做这个调研，解决什么问题]

## 发现

### 方案 A：xxx
- 优点：...
- 缺点：...
- 适用场景：...
- 生产案例：...

### 方案 B：xxx
- 优点：...
- 缺点：...
- 适用场景：...

## 推荐
[推荐哪个 + 理由 + 什么时候选另一个]

## 风险和注意
[已知坑、迁移成本、兼容性问题、时间敏感信息]
```

## 原则

- **Cite or didn't happen**：每条声明都有 inline source 引用，否则不交付（见顶部"第一原则"）。
- **不用模型先验冒充调研**：禁止"据我所知 / 通常 / 一般认为"，要么搜出处，要么标 `[模型先验，未验证]`。
- **给推荐不给菜单**：推荐一个，不要"都可以，看情况"——但每条理由都要带 cite。
- **标注不确定**：信息不足时明确 `[未验证]` / `[推断]` / `[争议中]`，不伪装成事实。
- **务实**：关注实际使用体验，不只看 feature list 和 benchmark。
- **时效性**：标注资料发布时间，超过 1 年的信息要提醒可能过时。
- **深度优先**：默认 L3 深度（多轮搜索、多源验证），不给"谁都能搜到"的答案。
