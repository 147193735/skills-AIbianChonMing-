---
applyTo: "**"
---

# Grill-Me 技能

当用户想要对一个计划或设计做压力测试，或提到 "grill me" / "考我" / "压测设计" 时启用本技能
（勿因普通「有疑问追问」误触发；那是实现前的澄清，不是 grilling）。

围绕这个计划的每个方面持续追问我，直到我们达成共同理解。沿着 design tree 的每个分支走下去，一次解决一个决策之间的依赖。

## 提问方式

每次提问**必须**使用 VS Code 的 **`vscode_askQuestions`（互动勾选）**，禁止用纯文字编号 / 列表冒充选择题。

1. **提供选项**：每个问题 2–4 个合理预设选项，覆盖最可能的回答；选项用 `label`（+ 可选 `description`）。
2. **末项自定义**：预设之后始终加一项 `✏️ 其他 / 自定义回答`，并保持 `allowFreeformInput: true`（默认已开）。
3. **多选**：可能多答案时设 `multiSelect: true`。
4. **推荐答案**：用 `recommended: true` 标出推荐项。
5. **一次一问**：`questions` 只放一个问题；等用户回答后再继续。
6. **追问节奏**：得到回答后沿 decision tree 对应分支继续深挖，仍用 `vscode_askQuestions`。

仅当 `vscode_askQuestions` 不可用时，才回退为 markdown 选项列表（末项仍保留 `✏️ 其他（请说明）`）。

## 示例

技术选型（单选）：
- question: 「你打算用什么数据库？」
- options: PostgreSQL（recommended）/ SQLite / MongoDB / ✏️ 其他

非功能需求（多选）：
- question: 「这个方案需要考虑哪些非功能需求？」
- options: 性能·延迟 / 安全性 / 可扩展性 / 运维成本 / ✏️ 其他
- multiSelect: true

## 其他规则

- 每个问题都要给出推荐答案及简短理由。
- 能靠探索 codebase 回答的，去探索，不要提问。
- 优先用选项覆盖常见回答，减少用户打字。
