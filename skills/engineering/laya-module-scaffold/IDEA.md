# IDEA 2025.1 配置

日常开发 IDE：`C:\Program Files\JetBrains\IntelliJ IDEA 2025.1`

代码风格：**tuoqi**（生成后 `Ctrl+Alt+L`，脚本不格式化）

---

## 1. 安装 File Templates

在 skill 目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-idea-templates.ps1
```

模板源：`idea-templates/`（7 个 CQ Module 模板 + includes 头）

| 模板 | 文件名示例 |
|------|------------|
| CQ Module Data | `BagData.ts` |
| CQ Module Event | `BagEvent.ts` |
| CQ Module Const | `BagConst.ts` |
| CQ Module Win | `BagWin.ts` |
| CQ Module Pop | `BagFullPop.ts` |
| CQ Module Li | `BagItemLi.ts` |
| CQ Module Mo | `BagTabMo.ts` |

### 启用检查

1. **Settings（设置）→ Editor（编辑器）→ File and Code Templates（文件和代码模板）**
2. **Includes（包含）**：确认 `CQ File Header.ts`
3. **Files（文件）**：确认 7 个 `CQ Module *`，勾选 **Reformat according to style（根据样式重新格式化）**
4. 在 `data/` / `view/` 下 **New（新建）→ CQ Module …**

活动模块 Win 通常改继承 `ActWin` 并设置 `actFnId`。

---

## 2. External Tool（可选）

**Settings（设置）→ Tools（工具）→ External Tools（外部工具）→ +**

| 字段 | 值 |
|------|-----|
| Name | CQ Scaffold (standard) |
| Program | `node` |
| Arguments | `"C:\myGit\skills-AIbianChonMing-\skills\engineering\laya-module-scaffold\scripts\scaffold-module.js" $Prompt$ --biz --standard --project $ProjectFileDir$` |
| Working directory | `$ProjectFileDir$` |

可建 `--acts --full` 变体。

---

## 3. 开发流程

```
FGUI 出包 → scaffold 或 IDEA 模板建类
    → Ctrl+Alt+L
    → 补 FnId、Protos（清单）、RedDots（清单）
    → 联调
```
