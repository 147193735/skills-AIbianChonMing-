---
name: grilling
description: >-
  Interview the user relentlessly about a plan or design. Use when the user wants
  to stress-test a plan before building, or uses grill trigger phrases ("grill me",
  "考我", "压测设计") — not ordinary implementation follow-ups like「有疑问追问」.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions **one at a time**, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

**Interactive picker (required when available):**
- **Cursor** → `AskQuestion`（互动勾选）
- **VS Code / Copilot** → `vscode_askQuestions`
- Do **not** fake choices with plain numbered/bullet lists while the picker tool exists.
- Always include a final escape option like `✏️ 其他 / 自定义回答`.
- Prefer 2–4 concrete options; mark a recommendation.

If a question can be answered by exploring the codebase, explore the codebase instead.
