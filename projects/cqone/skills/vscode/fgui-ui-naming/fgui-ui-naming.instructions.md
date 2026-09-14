---
applyTo: '**'

name: fgui-ui-naming
description: >-
  Enforces cqone FGUI UI element naming: v + semantic + type suffix (vMonsterNameTxt,
  vPassRewardBtn, vDrawMv, vPassRewardRedDot). Use when naming or renaming FGUI v*
  nodes, reviewing UI field names, aligning XML with Win/Pop TS, setVFields lift
  naming, or when the user mentions UI命名, 元素命名, v后缀, 规范命名, 重命名界面元素.
---

# FGUI UI 元素命名（专属）

**目的**：`v*` 一眼能看出**业务含义 + 控件类型**；XML 名与 TS 字段、策划用语一致。  
**配套**：发现元素用 [fgui-ui-elements](../fgui-ui-elements/SKILL.md)；类/方法规范用 [code-standards](../code-standards/SKILL.md)。本 skill 只管 **UI 节点命名**。

**公式**：

```
v + 业务语义(驼峰) + 类型简写后缀
```

| 好 | 差 |
|----|----|
| `vMonsterNameTxt` | `vMonsterName`（缺类型） |
| `vPassRewardBtn` | `vPassReward`（按钮不明） |
| `vDrawMv` | `vDraw`（与攻击档 Com 易混） |
| `vPassRewardRedDot` | `vRedDot`（抬到 Win 时易重名覆盖） |

细则与后缀表见 [reference.md](reference.md)。

---

## 何时使用

- 新建/改 FGUI 包内节点名，或声明 Win/Pop/`Item` 的 `v*` 字段
- 用户要求「规范命名 / 对照策划改名 / 重命名 UI 元素」
- Agent **自增**包内按钮/Com 上的红点或可抬字段时
- Code review 发现 `vXxx` 看不出控件类型

纯 Data/协议、不碰 UI 名 → 跳过。

---

## Agent 流程

### A. 新建绑定（默认）

```
- [ ] 1. 用 fgui-ui-elements 列现有 v*
- [ ] 2. 对照策划：语义词与策划用语对齐（关卡/通关/达标等）
- [ ] 3. 按 reference 后缀表起名；抬到 Win 的字段尤须唯一
- [ ] 4. XML name 与 TS 字段同名；再写逻辑
```

### B. 规范既有命名（用户明确要求时才做）

可做：改 `fgui/assets/<Pkg>/*.xml` 的 `name`，并同步本模块全部 TS 引用（含 `setVFields` 抬出的字段）。

```
- [ ] 1. 列清单：旧名 → 新名（附类型依据 + 策划对应）
- [ ] 2. 不确定的先问用户，勿批量瞎改
- [ ] 3. 改 XML `name="..."`（优先改 name，少动 id）
- [ ] 4. 同步 TS 字段声明与所有引用
- [ ] 5. 检查同包其它组件是否引用旧名（少见；relation 多用 id）
- [ ] 6. 提醒用户：FairyGUI **重新发布**该包后运行时才生效
```

**勿主动全包重命名**存量历史模块，除非用户点名包/界面。

### C. 能力边界（改名）

| 能 | 不能/须用户 |
|----|-------------|
| 改源 XML 节点名 + TS | 编辑器里拖拽预览 |
| 对照逻辑与策划提案 | 自动发布 `bin` |
| 一批改完给新旧对照表 | 保证美术切图文件名（一般不动） |

---

## 硬规则（摘要）

1. **有类型后缀**：文本 `Txt`、按钮 `Btn`、列表 `List`、进度 `Pro`、特效位 `Mv`、红点 `RedDot`、组件 `Com`/`Container` 等（全表见 reference）。
2. **语义在前**：`vPassRewardBtn`，不要 `vBtnPassReward`。
3. **按钮**：优先「对象/结果 + Btn」（`vRankBtn`、`vPassRewardBtn`）；老规范「纯动作名」`vWear` 仅存量，**新做不用**。
4. **抬字段到 Win**：`setVFields(子Com, this)` 的子节点必须业务唯一名（`vPassRewardRedDot`），禁多个 `vRedDot`。
5. **组件自有类内部**：仅本类使用的红点仍可用 `vRedDot`；一旦抬到 Win → 必须改语义名。
6. **数组**：`vItem_0`… → 字段 `vItem[]`；单项语义仍要带类型后缀（如 `vPrizeItem` 组件名另议）。
7. **默认不改**：`vFrame` / `vClose`（框体）；控制器页名按业务布尔/枚举，可不加 `Ctrl` 后缀（与现网一致时）。
8. **基类契约名禁止改**：父类（如 `ActWin` / `Win`）及公共组件（如 `ScrollGoalCom` / `ScrollGoalItem` / `ScrollRecordContainer`）已声明并用字段名驱动的通用逻辑，子类 FGUI **必须同名命中**；即使缺类型后缀也**不得**为规范去改。例：`ActWin.vActiveCountdown`；`ScrollGoalItem.vScore`。改名前先查基类 `v*` 与 `this.vXxx`。跨包复制的同名组件（如 `GainReward` 内再抽 Com）改名时须**一并改**。

---

## 与其它 skill

| Skill | 分工 |
|-------|------|
| fgui-ui-elements | **有哪些** `v*`、类型推断、有疑必问 |
| **fgui-ui-naming（本 skill）** | **该叫什么**、改名流程、后缀表 |
| code-standards | 类/方法/`v*` 不加注释等全局规范 |
| acts-module | 活动壳；UI 名仍走本 skill |

改完 UI 名且涉及已归档功能时，按需更新 MyFeatures 文案中的元素名（若有）。

---

## 自检

```
- [ ] 未改动基类契约名（如 `vActiveCountdown`、`vFrame`、`vClose`）
- [ ] 每个**非契约**业务 v* 能读出含义 + 控件类型
- [ ] 无抬 Win 的泛名 vRedDot 冲突
- [ ] XML 与 TS 同名；引用已全量替换
- [ ] 新名与策划用语一致；存疑已问过
- [ ] 已提醒发布 FGUI 包（若改了 XML）
```
