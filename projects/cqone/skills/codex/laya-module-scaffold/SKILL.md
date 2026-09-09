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
**活动模块**：`--acts` 前须先读 [acts-module](../acts-module/SKILL.md) 完成玩法/Data 基类选型，并在交付时过活动专属检查。  
**功能归档**：脚手架/新功能交付后按 [my-features](../my-features/SKILL.md) 更新 `C:/Users/lu/Desktop/MyFeatures`。  
**脚手架清单**：`--full` 生成的 `*.scaffold-checklist.txt` **只写** `MyFeatures/checklists/`，**禁止**写入 cqone 工程（易误提交 SVN）。Agent 手写清单同样只放 MyFeatures。  
**已有 FGUI 包**：实现前按 [fgui-ui-elements](../fgui-ui-elements/SKILL.md) 摸清 `v*` 元素，结合策划有疑先问。  
**文件头 `@author`**：固定 `zhangyongkang`；勿抄参考模块或 git 用户名。

**日常 IDE**：IntelliJ IDEA 2025.1，格式化 scheme **tuoqi**（`Ctrl+Alt+L`）。

---

## 何时使用

| 场景 | 做法 |
|------|------|
| 新建 biz 模块 | 运行 `scripts/scaffold-module.js` |
| 新建 acts 模块 | 先 [acts-module](../acts-module/SKILL.md) 选型，再 `--acts` scaffold |
| 只补单个类（Data/Win/Li…） | IDEA **New → CQ Module …**（见 [IDEA.md](IDEA.md)） |
| 需要理解注册流程 | 读 [ARCHITECTURE.md](ARCHITECTURE.md) |

---

## 快速执行（Agent 必做）

1. 确认目标项目根目录（如 `C:/myPro/cqone`），且存在 `src/script/`。
2. 向用户确认：**模块名**、**biz 或 acts**、**lite / standard / full**。
3. 若为 **acts**：先按 [acts-module](../acts-module/SKILL.md) 确认玩法族、Data 模板（默认 `CommonAct*X`）、是否双组、参考模块；**未选型不得生成后当完成**。
4. 在本 skill 目录中运行脚手架：

```bash
node scripts/scaffold-module.js <moduleName> --biz --standard --project <项目根>
```

示例：

```bash
node scripts/scaffold-module.js bag --biz --standard --project C:/myPro/cqone
node scripts/scaffold-module.js treasureVault --acts --full --project C:/myPro/cqone --dry-run
```

5. 提醒用户在 IDEA 中对新建目录 **Ctrl+Alt+L** 格式化。
6. **standard/full** 后：补 `FnId`、按 **MyFeatures/checklists/** 中清单手工改 `Protos.ts` / `RedDots.ts`（勿在工程里落 `*.scaffold-checklist.txt`）。写 `RedDots` 时遵循 [code-standards](../code-standards/SKILL.md)「红点挂载」：**兄弟页签独立 Fn 禁止互相 `addChild`**；改 Fn 分层后重审挂载。
7. **acts**：脚手架 Data 仍是普通骨架 → 按选型改为 `CommonActDataX`（或确认的其它基类）并补 GroupMo/Mo；交付过 acts-module 检查。
8. 不要替用户 commit，除非明确要求。

---

## 模式

| 模式 | 生成 | conf |
|------|------|------|
| `--lite` | Data, Event, Const, Win | 无 |
| `--standard` | 同上 | 自动 `Modules.ts` + `Fns.ts` |
| `--full` | + Pop, Mo；清单 → **`MyFeatures/checklists/<module>.scaffold-checklist.txt`**（不进工程） | 同 standard；Protos/RedDots **仅清单** |

### 硬性：清单不进工程

- **禁止**在 `src/script/**`（或任何 cqone 工程路径）创建/保留 `*.scaffold-checklist.txt`
- 默认写入：`C:/Users/lu/Desktop/MyFeatures/checklists/<folder>.scaffold-checklist.txt`
- 可用环境变量 `MY_FEATURES` 覆盖 MyFeatures 根目录
- Agent 手写待办清单同样只放 MyFeatures（可写入对应 `features/<包名>.md` 或 `checklists/`）

### conf 策略（选项 C）

- **自动**：`Modules.ts`、`Fns.ts`（`FnId.TODO` 占位）
- **手动**：`Protos.ts`、`RedDots.ts`、`Wins.ts`、`BasicViews.ts` → 见 **MyFeatures/checklists/** 清单（不进工程）

脚本会在 conf 中写入/使用标记：`// @scaffold:modules-import` 等（若缺失则自动插入）。

---

## IDEA 模板（首次安装）

在本 skill 目录中运行 `scripts/install-idea-templates.ps1`。

详情：[IDEA.md](IDEA.md)

---

## 参考模块

- 完整：`src/script/biz/bag/`
- 精简：`src/script/biz/cdk/`
- 活动（选型与标杆）：见 [acts-module](../acts-module/SKILL.md)；X 标杆 `acts/treasureVault/`

---

## 附加资源

- [ARCHITECTURE.md](ARCHITECTURE.md) — 启动注册、conf 文件职责、acts 壳层
- [acts-module](../acts-module/SKILL.md) — 活动选型差异与交付检查
- [IDEA.md](IDEA.md) — File Templates、External Tool
