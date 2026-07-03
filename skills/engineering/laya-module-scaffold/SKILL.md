---
name: laya-module-scaffold
description: >-
  Scaffold cqone/Laya business or activity modules (Data, Event, Const, Win, Pop, Mo),
  auto-patch Modules.ts and Fns.ts, and provide IDEA file templates. Use when creating
  a new biz/acts module, scaffolding UI module files, registering FnId/Protos/RedDots,
  or when the user mentions laya scaffold, 模块脚手架, IDEA templates for cqone.
---

# Laya / cqone 模块脚手架

为 **cqone**（Laya + FGUI）生成业务/活动模块骨架，并按规定注册到 conf。

**配套规范**：生成代码须同时遵守 [code-standards](../code-standards/SKILL.md)。

**日常 IDE**：IntelliJ IDEA 2025.1，格式化 scheme **tuoqi**（`Ctrl+Alt+L`）。

---

## 何时使用

| 场景 | 做法 |
|------|------|
| 新建 biz/acts 模块 | 运行 `scripts/scaffold-module.js` |
| 只补单个类（Data/Win/Li…） | IDEA **New → CQ Module …**（见 [IDEA.md](IDEA.md)） |
| 需要理解注册流程 | 读 [ARCHITECTURE.md](ARCHITECTURE.md) |

---

## 快速执行（Agent 必做）

1. 确认目标项目根目录（如 `C:/myPro/cqone`），且存在 `src/script/`。
2. 向用户确认：**模块名**、**biz 或 acts**、**lite / standard / full**。
3. 运行脚手架（路径相对于本 skill 目录）：

```bash
node skills/engineering/laya-module-scaffold/scripts/scaffold-module.js <moduleName> --biz --standard --project <项目根>
```

示例：

```bash
node skills/engineering/laya-module-scaffold/scripts/scaffold-module.js bag --biz --standard --project C:/myPro/cqone
node skills/engineering/laya-module-scaffold/scripts/scaffold-module.js treasureVault --acts --full --project C:/myPro/cqone --dry-run
```

4. 提醒用户在 IDEA 中对新建目录 **Ctrl+Alt+L** 格式化。
5. **standard/full** 后：补 `FnId`、按 checklist 手工改 `Protos.ts` / `RedDots.ts`。
6. 不要替用户 commit，除非明确要求。

---

## 模式

| 模式 | 生成 | conf |
|------|------|------|
| `--lite` | Data, Event, Const, Win | 无 |
| `--standard` | 同上 | 自动 `Modules.ts` + `Fns.ts` |
| `--full` | + Pop, Mo, `*.scaffold-checklist.txt` | 同 standard；Protos/RedDots **仅清单** |

### conf 策略（选项 C）

- **自动**：`Modules.ts`、`Fns.ts`（`FnId.TODO` 占位）
- **手动**：`Protos.ts`、`RedDots.ts`、`Wins.ts`、`BasicViews.ts` → 见 checklist

脚本会在 conf 中写入/使用标记：`// @scaffold:modules-import` 等（若缺失则自动插入）。

---

## IDEA 模板（首次安装）

```powershell
powershell -ExecutionPolicy Bypass -File skills/engineering/laya-module-scaffold/scripts/install-idea-templates.ps1
```

详情：[IDEA.md](IDEA.md)

---

## 参考模块

- 完整：`src/script/biz/bag/`
- 精简：`src/script/biz/cdk/`

---

## 安装为本机 Cursor Skill

将本目录链接或复制到个人 skills：

```powershell
# 符号链接（推荐）
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\skills\laya-module-scaffold" -Target "C:\myGit\skills-AIbianChonMing-\skills\engineering\laya-module-scaffold"
```

或在 cqone 项目的 `.cursor/skills/` 下做项目级链接。

---

## 附加资源

- [ARCHITECTURE.md](ARCHITECTURE.md) — 启动注册、conf 文件职责
- [IDEA.md](IDEA.md) — File Templates、External Tool
