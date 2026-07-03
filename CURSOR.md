# Using this repo with Cursor

This project includes a **Cursor project rule** so the Karpathy-inspired behavioral guidelines apply automatically when you work here.

## In this repository

1. Open the folder in Cursor.
2. Rules committed in `.cursor/rules/`:
   - [`.cursor/rules/karpathy-guidelines.mdc`](.cursor/rules/karpathy-guidelines.mdc) — `alwaysApply: true`，行为准则自动生效。
   - [`.cursor/rules/grill-me.mdc`](.cursor/rules/grill-me.mdc) — 设计压力测试，提到"grill me / 考我 / 追问"时触发。勾选式提问，末项支持自定义输入。
   - [`.cursor/rules/code-standards.mdc`](.cursor/rules/code-standards.mdc) — cqone 代码规范，编辑 `**/*.{ts,tsx}` 时触发。
3. In Cursor, you can confirm them under **Settings → Rules** (or the project rules UI).

## Global setup (all projects — recommended for cqone)

Run once (Windows PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File C:\myGit\skills-AIbianChonMing-\scripts\install-cursor-global.ps1
```

This creates junctions:

| Global path | Repo source |
|-------------|-------------|
| `%USERPROFILE%\.cursor\skills\code-standards` | `skills/engineering/code-standards/` |
| `%USERPROFILE%\.cursor\skills\laya-module-scaffold` | `skills/engineering/laya-module-scaffold/` |
| `%USERPROFILE%\.cursor\rules\code-standards.mdc` | `.cursor/rules/code-standards.mdc` |

After `git pull` in this repo, global skills/rules update automatically (junctions, not copies).

**Do not** maintain a second copy under `~/.cursor/skills/code-standards` — use the junction above.

Authoritative doc: `C:/myPro/doc/代码规范.md`

## Use the same guidelines in another project

**Cursor (recommended):** Copy `.cursor/rules/karpathy-guidelines.mdc` into that project’s `.cursor/rules/` directory (create the folders if needed). Adjust or merge with existing rules as you like.

**Other tools:** If a stack only supports a root instruction file, copy [`CLAUDE.md`](CLAUDE.md) into that project instead (or merge its contents into your existing instructions).

## Optional: personal Agent Skills

Symlink engineering skills (recommended for cqone):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-cursor-global.ps1
```

Or copy [`skills/karpathy-guidelines/SKILL.md`](skills/karpathy-guidelines/SKILL.md) into `~/.cursor/skills/` manually.

## Claude Code vs Cursor

- **Claude Code:** Install via the plugin marketplace and [`README.md`](README.md) instructions; the plugin exposes the skill from this repo. Per-project use can also rely on `CLAUDE.md`.
- **Cursor:** Use the committed `.cursor/rules/` file as described above. Cursor does not read `.claude-plugin/` or `CLAUDE.md` by default.

## For contributors

When you change the four principles, keep **[`CLAUDE.md`](CLAUDE.md)** and **[`.cursor/rules/karpathy-guidelines.mdc`](.cursor/rules/karpathy-guidelines.mdc)** in sync. If the published skill/plugin text should match, update **[`skills/karpathy-guidelines/SKILL.md`](skills/karpathy-guidelines/SKILL.md)** as well.
