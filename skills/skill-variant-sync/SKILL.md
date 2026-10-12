---
name: skill-variant-sync
description: >-
  Keeps every AI-tool variant of a skill in this repository in sync. Use when
  creating, editing, deleting or renaming anything under skills/ or
  projects/<project>/skills/** (SKILL.md, reference.md, *.instructions.md,
  *.mdc, scripts/), or when the user says 改技能, 同步技能, 技能维护, 多平台技能,
  其他软件也要改, Cursor/Codex/WorkBuddy/CodeBuddy/VS Code 技能.
---

# 技能多平台变体同步（硬性）

本仓库是**多平台技能分发仓库**：同一技能在多个 AI 工具下各有一份变体。
**改动任何一个变体，必须在同一会话内同步到所有变体**，否则换工具做同一件事就会漏规则。

**单源技能也可能有多个形态**：例如 `grill-me` 就有三份——
`skills/grill-me/SKILL.md`（Codex / WorkBuddy / CodeBuddy / Copilot 共用）、
`.cursor/rules/grill-me.mdc`（Cursor 规则，frontmatter 是 `description` + `globs` + `alwaysApply`）、
`skills/grill-me/grill-me.instructions.md`（VS Code prompts，frontmatter 是 `applyTo`）。
三份正文不同（各写各工具的互动选择题 API）但**规则必须等价**，改一个就要改另外两个。

## 触发时机（必做）

- 新建 / 修改 / 删除 / 重命名技能或其中任何文件
- 用户提到「改技能」「同步技能」「其他软件也要改」「多平台」等
- 修 bug、补规则、改清单编号、改报告模板——**一律算改动，都要同步**

## 变体位置

| 范围 | 路径 |
|------|------|
| 通用技能（单源，5 平台共用） | `skills/<skill>/` |
| 项目技能变体 | `projects/<project>/skills/codebuddy/`、`.../codex/`、`.../cursor/`、`.../vscode/`、`.../workbuddy/` |
| Cursor 规则 | `projects/<project>/cursor/rules/*.mdc`、`.cursor/rules/*.mdc` |
| VS Code prompts 源文件 | `skills/<skill>/<skill>.instructions.md`、`projects/<project>/skills/vscode/<skill>/<skill>.instructions.md`（安装到 `%APPDATA%\Code\User\prompts\`） |
| 安装器 | `scripts/install-*.ps1`、`projects/<project>/scripts/install-*.ps1` |

安装方式为 Junction / HardLink，改仓库源文件即生效；**新增技能必须同时更新对应安装器白名单**
（`install-cursor-global.ps1` 的 `$links`、`install-generic-global.ps1` 的 `$Skills`、
项目 `install-*.ps1` 的 `$skillNames`）。
通用 VS Code prompts 由 `scripts/install-vscode-prompts.ps1` 自动扫描
`skills/*/*.instructions.md`（放对文件即被安装，无需改白名单）；
项目 VS Code prompts 由 `projects/<project>/scripts/install-vscode.ps1` 复制。
prompts 目录里**没有仓库源文件**的同名文件（如手工创建的）不会被覆盖，也不会被同步。

## 同步步骤

1. **确定改动点**：改了哪个文件、哪一段（清单条目 / 自检项 / 报告模板 / frontmatter）。
2. **逐个变体打开同一位置**，做**等效**修改。
   - **禁止整目录覆盖或批量拷贝**：README 明确同名技能在不同 agent 下正文可能不同，批量同步会丢失平台差异。
3. **同变体附带文件一起改**：
   - VS Code 变体：除 `SKILL.md` 还有同名 `<skill>.instructions.md`
   - Cursor：除 `SKILL.md` 还有 `rules/*.mdc`（精简摘要，只加要点行）
   - Codex / WorkBuddy：`code-standards` 等另有 `.instructions.md`
4. **平台差异必须保留**：
   - 清单编号可能不同（如 cqone `code-check`：Cursor 用 `I`，其余变体用 `G`）
   - 报告定位格式不同（CodeBuddy 用「起止行引用块」，其余用 `path:行号`）
   - 平台路径示例不同，勿统一成一种
5. **新增技能**：把技能名加进对应安装器的 `$skillNames` / `$Skills` / `$links` 白名单，再跑安装脚本。
6. **汇报**：列出「已同步 / 未同步」的变体清单，未同步要说明原因。

## 自检

```
- [ ] 所有变体目录（codebuddy / codex / cursor / vscode / workbuddy）都已改到
- [ ] 各变体的 .instructions.md / .mdc 摘要也同步
- [ ] 平台差异（清单编号、报告格式、路径）未被覆盖抹平
- [ ] 新增技能已加入安装器白名单并跑过安装
- [ ] 回复里列出了已同步/未同步变体
```

## 反向提醒

用户只点名一个工具（如「Cursor 也改下」）时，**默认其余工具同样需要改**，先补齐再回复；
若用户明确要求只改某一个，才不同步，并在回复里说明「其余变体未同步」。
