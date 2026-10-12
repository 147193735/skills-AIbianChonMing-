# Agent Instructions

## 新电脑 / 首次使用

**先读 [`SETUP.md`](./SETUP.md)** —— 本仓库的安装入口，一条命令装好全部平台的技能。

For setup on a new machine, read [`SETUP.md`](./SETUP.md) first; it is the installation entry point.

## Multi-Platform Variants (hard rule)

同一技能在 `codebuddy` / `codex` / `cursor` / `vscode` / `workbuddy` 下各有一份变体。
**改动任一变体，必须同步所有变体**（VS Code 的 `<skill>.instructions.md`、Cursor 的 `rules/*.mdc` 一并改）；
**禁止整目录覆盖或批量拷贝**——各变体正文可能有意不同。新增技能要同时更新对应
`install-*.ps1` 的技能名白名单。详见技能 `skill-variant-sync`。

## Skill Scope Policy

This repository separates reusable skills from project skills.

- Treat a skill as generic only when its workflow is independent of a company, product, codebase, local path, and internal conventions.
- Before creating or expanding a non-generic skill, ask whether it belongs to an existing project archive or a new project archive. Do not infer that a project workflow is generic.
- Store project skills under `projects/<project>/`. Keep Cursor and Codex variants separate when their instructions differ.
- Reuse a skill across projects by copying it into the receiving project's archive. Do not share a project skill through a common path or global installer.
- Root global-install scripts may install generic skills only. Project skills require an explicit project installer.
