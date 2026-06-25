---
name: grill-me
description: 围绕 plan 或 design 持续 interview user，直到达成 shared understanding，并逐一解决 decision tree 的每个分支。Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

围绕这个计划的每个方面持续追问我，直到我们达成共同理解。沿着 design tree 的每个分支走下去，一次解决一个决策之间的依赖。

## 提问方式

每次提问必须使用 `vscode_askQuestions` 工具，按以下规则构造问题：

1. **提供选项**：为每个问题提供 2-4 个合理的预设选项，覆盖最可能的回答。选项使用 `options` 字段，每个 option 包含 `label`（选项文本）和可选的 `description`（补充说明）。

2. **最后一个选项为自定义输入**：在预设选项之后，始终添加一个形如 `✏️ 其他 / 自定义回答` 的选项。同时设置 `allowFreeformInput: true`（默认已开启），让用户可以自由输入。

3. **多选支持**：如果问题可能有多个正确答案（例如"哪些方面需要考虑？"），设置 `multiSelect: true`。

4. **推荐答案**：在 `options` 中，用 `recommended: true` 标记你的推荐选项。

5. **一次一问**：每次只问一个问题。`vscode_askQuestions` 的 `questions` 数组只放一个问题。

6. **追问节奏**：得到回答后，基于答案沿着 decision tree 的对应分支继续深挖，每次仍遵循以上格式。

## 示例

当追问技术选型时：
- question: "你打算用什么数据库？"
- options: ["PostgreSQL", "SQLite", "MongoDB", "✏️ 其他"]
- 附带推荐答案

当追问需要考虑的方面时：
- question: "这个方案需要考虑哪些非功能需求？"
- options: ["性能 / 延迟", "安全性", "可扩展性", "运维成本", "✏️ 其他"]
- multiSelect: true

## 其他规则

- 每个问题都要提供你的推荐答案（在选项上标记 `recommended`，或在 message 中说明）。
- 如果某个问题可以通过探索 codebase 回答，就去探索 codebase，而不是提问。
- 优先用选项覆盖常见回答，减少用户打字负担。
