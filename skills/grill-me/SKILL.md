---
name: grill-me
description: >-
  围绕 plan 或 design 持续 interview user，直到达成 shared understanding，并逐一解决
  decision tree 的每个分支。Use when user wants to stress-test a plan, get grilled
  on their design, or mentions "grill me" / "考我" / "压测设计"（勿因普通「有疑问追问」
  误触发；那是实现前澄清，不是 grilling）。
---

围绕这个计划的每个方面持续追问我，直到我们达成共同理解。沿着 design tree 的每个分支走下去，一次解决一个决策之间的依赖。

## 提问方式（按编辑器选互动勾选工具）

每次提问**必须**走编辑器的**互动勾选 / 选择式追问** UI，**禁止**用纯文字编号列表冒充选择题。

| 环境 | 工具 | 说明 |
|------|------|------|
| **Cursor** | `AskQuestion` | 互动勾选面板；选项用 `id` + `label`；多选用 `allow_multiple: true` |
| **VS Code / Copilot** | `vscode_askQuestions` | 互动勾选；选项用 `label`（+ 可选 `description` / `recommended`）；多选用 `multiSelect: true` |
| 工具不可用 | markdown 选项列表 | 仅回退；末项仍写 `✏️ 其他（请说明）` |

构造规则（两种工具通用）：

1. **提供选项**：每个问题 2–4 个合理预设选项，覆盖最可能回答。
2. **末项自定义**：预设之后始终加 `✏️ 其他 / 自定义回答`（或 `✏️ 其他（请说明）`）。VS Code 侧保持 `allowFreeformInput: true`（默认已开）。
3. **多选**：可能多答案时开启多选（Cursor: `allow_multiple`；VS Code: `multiSelect`）。
4. **推荐答案**：标明推荐项（VS Code: `recommended: true`；Cursor: 在 `label` 加 `⭐ 推荐` 或在消息里说明）。
5. **一次一问**：每次只问一个问题；`questions` 数组只放一题。等用户答完再沿 decision tree 继续。
6. **追问节奏**：得到回答后，基于答案走对应分支继续深挖，格式不变。

## 示例

技术选型（单选）：
- prompt: 「你打算用什么数据库？」
- options: PostgreSQL（推荐）/ SQLite / MongoDB / ✏️ 其他

非功能需求（多选）：
- prompt: 「这个方案需要考虑哪些非功能需求？」
- options: 性能·延迟 / 安全性 / 可扩展性 / 运维成本 / ✏️ 其他
- 开启多选

## 其他规则

- 每个问题都要给出推荐答案及简短理由。
- 能靠探索 codebase 回答的，去探索，不要提问。
- 优先用选项覆盖常见回答，减少用户打字。
