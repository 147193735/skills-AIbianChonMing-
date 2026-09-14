---
name: my-features
description: >-
  Maintains the personal cqone feature catalog at C:/Users/lu/Desktop/MyFeatures
  (FEATURES.md + features/*.md). Use when finishing a new or changed biz/acts
  feature, registering FnId/FGUI packages, scaffolding a module, or when the user
  mentions MyFeatures, 我的功能, 功能维护, 维护功能, FGUI包名清单.
---

# 我的功能维护（MyFeatures）

**仓库路径**：`C:/Users/lu/Desktop/MyFeatures`（独立 git）  
**索引**：`FEATURES.md`  
**详情**：`features/<FGUI主包名>.md`  
**模板**：`_template.md`  
**脚手架清单**：`checklists/<moduleFolder>.scaffold-checklist.txt`（**禁止**写入 cqone 工程，易误提交 SVN）

与 [code-standards](../code-standards/SKILL.md)、[laya-module-scaffold](../laya-module-scaffold/SKILL.md)、活动则另过 [acts-module](../acts-module/SKILL.md) 配套：功能代码交付后**必须**同步本库。

---

## 何时必须更新

在 cqone 中完成以下任一情况后，**同一会话内**更新 MyFeatures：

1. 新建 biz/acts 功能模块（有独立 FGUI 包或主 Win）
2. 新增/变更主 FGUI 包、附属包（如商店专用 `ShopFunctionGift2`）
3. 新增/变更主 `FnId` 或 Win 注册
4. 重要决策写入详情「要点」（红点、不足弹窗顺序、包区分等）
5. **配置表**：详情「配置表」列出本功能专用/强相关表；**忽略** `Item` 道具表、`Function` 功能开放表及同类全项目基础大表
6. **脚手架/待办清单**：`*.scaffold-checklist.txt` 与同类手写清单只放 `checklists/`（或写入详情 md）；**禁止**落在 cqone `src/` 下

纯修 bug、改文案且无包名/FnId/结构变化 → 可不改索引；若有决策补充可只改详情。

---

## 更新步骤（必做）

1. 读 `C:/Users/lu/Desktop/MyFeatures/FEATURES.md` 与 `_template.md`
2. **新建**：复制模板为 `features/<主FGUI包名>.md`，填表；在 `FEATURES.md` 追加一块（见文件末尾模板）
3. **变更**：改对应详情 + 必要时改索引块
4. 附属包只写在详情「FGUI」表，不单独占索引块（除非独立成功能）
5. 在 `C:/Users/lu/Desktop/MyFeatures` 执行 git 提交（用户未禁止提交时）：

```bash
cd C:/Users/lu/Desktop/MyFeatures
git add FEATURES.md features/ checklists/ README.md _template.md
git commit -m "docs: add/update <中文名> (<PkgName>)"
```

---

## 详情必填字段

| 字段 | 说明 |
|------|------|
| FGUI 主包 | 与 `fgui/assets/`、`setUiResName` 一致 |
| 脚本目录 | `biz/xxx` 或 `acts/xxx` |
| 主 Win / Data | 类名 |
| FnId | 常量名 + 数值 + 绑定界面 |
| FGUI 表 | 主包 + 附属包/组件 |
| 配置表 | 本功能专用/强相关；忽略 Item、Function 等基础大表；含 SystemConstant 键 |
| 要点 | 非显而易见决策 |

---

## 配置表规则

只记**本功能**配置：

| 记 | 不记 |
|----|------|
| 玩法专用表（如 `TianGongTreasureReward`） | `Item` 道具表 |
| 按 `functionId` / `shopType` / `battlePassType` 过滤的业务表 | `Function` 功能开放表 |
| 本功能 `SystemConstant` / DesignConst 键 | 全项目通用大表（如无差别的 `Txt`、通用 `RechargeCard`） |
| 本功能 ClientSettingId（若有） | |

详情用「配置表」小节，见 `_template.md`。

---

## 自检

```
- [ ] FEATURES.md 有对应块
- [ ] features/<包名>.md 已建/已更新
- [ ] FnId、包名与代码一致
- [ ] 配置表已整理（忽略 Item / Function 等基础大表）
- [ ] 若有脚手架清单：仅在 checklists/，工程内无 *.scaffold-checklist.txt
- [ ] MyFeatures 目录已 git commit（若用户允许）
```
