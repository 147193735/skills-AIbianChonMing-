# Using this repo with Cursor

This repository keeps reusable skills separate from project-specific archives.

## In this repository

1. Open the folder in Cursor.
2. Rules committed in `.cursor/rules/`:
   - [`.cursor/rules/karpathy-guidelines.mdc`](.cursor/rules/karpathy-guidelines.mdc) — `alwaysApply: true`，行为准则自动生效。
   - [`.cursor/rules/grill-me.mdc`](.cursor/rules/grill-me.mdc) — 设计压力测试，提到"grill me / 考我 / 压测设计"时触发。提问必须用 Cursor **`AskQuestion`（互动勾选）**，末项支持自定义输入。普通「有疑问追问」不走本规则。
3. In Cursor, you can confirm them under **Settings → Rules** (or the project rules UI).

## Generic Global Setup

Run once (Windows PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File C:\myGit\skills-AIbianChonMing-\scripts\install-cursor-global.ps1
```

This creates junctions:

| Global path | Repo source |
|-------------|-------------|
| `%USERPROFILE%\.cursor\skills\karpathy-guidelines` | `skills/karpathy-guidelines/` |
| `%USERPROFILE%\.cursor\rules\karpathy-guidelines.mdc` | `.cursor/rules/karpathy-guidelines.mdc` |
| `%USERPROFILE%\.cursor\rules\grill-me.mdc` | `.cursor/rules/grill-me.mdc` |

After `git pull` in this repo, global skills/rules update automatically (junctions, not copies).

The root installer is intentionally limited to generic content. It refuses to replace a non-link target unless you explicitly pass `-ReplaceExisting`.

## Project Setup

Project workflows live under `projects/<project>/` and require an explicit project installer. For cqone, read [projects/cqone/README.md](projects/cqone/README.md) and run:

```powershell
powershell -ExecutionPolicy Bypass -File projects/cqone/scripts/install-cursor.ps1
```

When a different project needs one of these workflows, copy the skill into that project's archive. Do not link the new project to cqone's skill directory.

## Use the same guidelines in another project

**Cursor (recommended):** Copy `.cursor/rules/karpathy-guidelines.mdc` into that project’s `.cursor/rules/` directory (create the folders if needed). Adjust or merge with existing rules as you like.

**Other tools:** If a stack only supports a root instruction file, copy [`CLAUDE.md`](CLAUDE.md) into that project instead (or merge its contents into your existing instructions).

## Claude Code vs Cursor

- **Claude Code:** Install via the plugin marketplace and [`README.md`](README.md) instructions; the plugin exposes the skill from this repo. Per-project use can also rely on `CLAUDE.md`.
- **Cursor:** Use the committed `.cursor/rules/` file as described above. Cursor does not read `.claude-plugin/` or `CLAUDE.md` by default.

## For contributors

When you change the four principles, keep **[`CLAUDE.md`](CLAUDE.md)** and **[`.cursor/rules/karpathy-guidelines.mdc`](.cursor/rules/karpathy-guidelines.mdc)** in sync. If the published skill/plugin text should match, update **[`skills/karpathy-guidelines/SKILL.md`](skills/karpathy-guidelines/SKILL.md)** as well.
