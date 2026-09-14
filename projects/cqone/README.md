# cqone Project Skills

This archive contains workflows specific to the cqone Laya/FairyGUI project and its local tooling. It is intentionally isolated from the generic `skills/` library.

## Archived Variants

| Agent | Skills | Source snapshot |
| --- | ---: | --- |
| Cursor | 8 | `skills/cursor/` |
| VS Code / Copilot | 8 | `skills/vscode/` |
| Codex | 9 | `skills/codex/` |

The Codex archive additionally contains `gain-reward-prize-type`. Several same-named skills differ between agents, so the two directories are preserved independently and must not be overwritten by bulk synchronization.

Cursor-specific rules are under `cursor/rules/`. VS Code / Copilot project instructions are under `skills/vscode/`; install them with `scripts/install-vscode.ps1`. The cqone VS Code setup guide is [VSCODE.md](VSCODE.md).

## Explicit Installation

Project skills are never installed by the root global installer. Use one of these commands only while working on cqone:

```powershell
powershell -ExecutionPolicy Bypass -File projects/cqone/scripts/install-cursor.ps1
powershell -ExecutionPolicy Bypass -File projects/cqone/scripts/install-codex.ps1
powershell -ExecutionPolicy Bypass -File projects/cqone/scripts/install-vscode.ps1
```

Both scripts refuse to replace a non-link skill by default. After reviewing the target, pass `-ReplaceExisting` to replace it with the archived project variant.

## Reuse Policy

When another project needs one of these workflows, copy the skill into that project's archive. Do not make the new project depend on this archive or add the skill to the generic library without explicit confirmation that it is project-independent.
