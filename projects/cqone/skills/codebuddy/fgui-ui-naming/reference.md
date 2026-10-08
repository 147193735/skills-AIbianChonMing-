# FGUI UI 元素命名 — 细则

## 1. 命名公式

```
v + SemanticCamel + TypeSuffix
```

- `v`：视图子节点固定前缀（code-standards / 代码规范）
- **Semantic**：业务含义，尽量与策划文档用词一致（关卡 floor/pass、达标 goal、排行 rank…）
- **TypeSuffix**：控件/角色简写，见下表

缩写原则与全局一致：用约定简写，不自造（`btn/txt/num/fn/cur/mv` 等）。

---

## 2. 类型后缀表（标准）

| 后缀 | 典型运行时类型 | 何时用 | 示例 |
|------|----------------|--------|------|
| `Txt` | `GTextField` / `GRichTextField` / `GLabel`（纯展示文案） | 标题、数值、说明 | `vMonsterNameTxt`、`vPassTxt`、`vCountdownTipsTxt` |
| `Btn` | `GButton` / `RedDotBtn` / `UiBtn` | 可点按钮 | `vPassRewardBtn`、`vRankBtn`、`vRuleBtn` |
| `List` | `GList` | 列表 | `vPassList`、`vRewardList` |
| `Pro` | `GProgressBar` | 进度条 | `vPassPro`、`vHpPro` |
| `Mv` | `MvArea` / 动效挂点 | 循环/非循环特效位 | `vMonsterMv`、`vDrawMv` |
| `RedDot` | `RedDotView` | 红点图标 | `vPassRewardRedDot`（抬 Win 时） |
| `Com` | 包内/业务 `*Com` | 可复用块 | `vDrawActionCom`、`vHeadCom` |
| `Container` | 滚动容器等 | 记录条/滚动槽 | `vRecordContainer` |
| `Item` | 列表项/奖池格（常为自定义 Item） | 单项展示格 | `vPrizeItem`（数组 `vItem_0` 另见下） |
| `Icon` / `Img` | `GLoader` / 图 | 图标、底图加载 | `vHasIcon`、`vBannerImg` |
| `Bar` | 特殊条（非 ProgressBar 时） | 少用；优先 `Pro` | — |
| `Tab` | 页签按钮 | 页签 | `vRankTab`（或 `vTab` + 控制器） |

**富文本**：仍用 `Txt`（不必 `RichTxt`），除非同屏普通文本与富文本成对且需区分。

**勾选**：多为 `GButton`（checkbox），后缀 `Btn` 或语义 `vSkipDrawAnimBtn`；selected 状态靠按钮本身。

**自定义按钮 Item/Tab**（`extention="Button"`）：文案用官方 `this.title`，勿为 `title` 起 `v*` 名或再声明字段；官方控制器 `button` 同理不导出。详见 [fgui-ui-elements/reference.md](../fgui-ui-elements/reference.md)「2.1 官方 Button」。

---

## 3. 基类契约名（命中则不改）

父类用**固定 `v*` 名**做通用逻辑时，子界面 XML/字段必须同名；**规范改名任务也跳过**。

| 契约名 | 基类 | 作用 |
|--------|------|------|
| `vActiveCountdown` | `ActWin` | 活动剩余倒计时文案 |
| `vFrame` / `vClose` | 框体惯例 | 窗体框架 / 关闭（发现清单默认可忽略业务绑定） |
| `vScrollCom` / `vTotalNum` / `vBar` / `vReference` | `ScrollGoalCom` | 达标滚动条壳（含 Inner 抬字段） |
| `vItemCell` / `vScore` / `vItemCount` / `vRedDot` / `vClickArea` / `vGainState` / `vHideBar` | `ScrollGoalItem` | 达标 item |
| `vContainer` | `ScrollRecordContainer` | 欧皇/滚动记录槽 |

改名清单流程：先扫继承链上的 `v*` 声明与 `this.vXxx` 使用 → 命中则标「保留（基类契约）」→ 再对其余字段套后缀规则。

---

## 4. 与旧代码规范的关系

[upstream/代码规范.md](../code-standards/upstream/代码规范.md) 写过：按钮可用「动作名」如 `vWear`。

| 场景 | 做法 |
|------|------|
| **新界面 / 规范重命名任务** | 必须用「语义 + 类型后缀」（本 skill） |
| **存量未点名整改** | 不主动改 `vWear` 这类历史名 |
| **动作仍要表达** | 语义里带动作或对象：`vWearBtn`、`vPassRewardBtn` |

---

## 5. `setVFields` 与重名

`UiUtil.setVFields(gComp, uiComp)` 按 **name** 赋给 `uiComp` 同名成员；多次 `setVFields(子, this)` 时 **后写覆盖先写**。

| 场景 | 命名 |
|------|------|
| 仅在子组件类内使用 | `vRedDot` 可接受 |
| 抬到 Win/Pop | 必须 `v{业务}RedDot`，如 `vPassRewardRedDot` |
| 外包 Com 抬列表 | 内外同名可故意覆盖（见 code-standards）；红点等关键节点勿依赖覆盖 |

成对示例：

```
BtnHurt.xml:  name="vPassRewardRedDot"
Win:          vPassRewardBtn + vPassRewardRedDot
initUi:       UiUtil.setVFields(this.vPassRewardBtn, this);
              this.vPassRewardRedDot.setData(RedDots.…);
```

---

## 6. 数组与控制器

| 形态 | 规则 |
|------|------|
| `vItem_0`…`vItem_n` | TS：`vItem: XxxItem[]`；组件资源名可含 Item |
| 控制器 | 常用 `vIsXxx` / `vPage`；可不加 `Ctrl`；页含义写进策划对照，勿靠猜 |
| 动效 Transition | 一般不进业务 `v*` 字段；需要时再声明 |

---

## 7. 对照策划改名（示例：沙滩猎宝）

| 策划含义 | 旧名（示意） | 规范名 |
|----------|--------------|--------|
| 活动倒计时 | `vActiveCountdown` | **保留**（`ActWin` 契约，勿改 `…Txt`） |
| 怪物名文本 | `vMonsterName` | `vMonsterNameTxt` |
| 怪物模型/特效 | `vMonsterMv` | `vMonsterMv`（已有 Mv，可保留） |
| 抽奖特效 | `vDrawMv` | `vDrawMv` |
| 通关入口 | `vPassRewardBtn` | `vPassRewardBtn` |
| 通关入口红点（抬 Win） | `vRedDot` | `vPassRewardRedDot` |
| 关卡数 | `vPassTxt` | `vPassTxt` |
| 血条 | `vPassPro` | `vPassPro` |
| 排行按钮 | `vRankBtn` | `vRankBtn` |

改名产出建议给用户一张表：`组件 | 旧 name | 新 name | TS 是否已同步 | 需发布`。

---

## 8. 改名操作注意

1. **优先改 `name`，保留 `id`**：relation / 包内引用多靠 id，减少破坏。
2. **TS 全量替换**：字段声明、赋值、`onClick`、注释中的标识符。
3. **发布**：改 `fgui/assets` 后必须在 FairyGUI 发布对应包，否则运行时仍是旧名（`setVFields` 找不到新字段会为 `undefined`）。
4. **不要改** 图集文件名、非 `v` 装饰节点（`n48` 等）除非业务需要。

---

## 9. 反例

```
❌ vName / vTitle          → 缺类型，且过泛
❌ vBtn1 / vText2          → 无业务语义
❌ vRedDot（抬到 Win）     → 多次 setVFields 覆盖
❌ vBtnPassReward          → 后缀应在末尾：vPassRewardBtn
❌ 同屏两个 vCountTxt 不同义 → 应 vFloorCountTxt / vBagCountTxt
```
