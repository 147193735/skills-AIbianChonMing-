---
applyTo: '**'

name: fgui-ui-elements
description: >-
  Discovers cqone FGUI UI elements (v* children, controllers, transitions) from
  package XML under fgui/assets, mirroring the FairyGUI ui-extensions「拷贝生成代码」
  rules. Use proactively when implementing or wiring a Win/Pop/Item from an
  existing FGUI package, when the user gives a FGUI 包名, when combining 策划文档
  with UI binding, or when mentioning 界面元素, 拷贝生成代码, fgui 字段, vFields,
  setVFields, or UI 元素清单.
---

# FGUI 界面元素发现（开发前置）

**目的**：写业务代码前先掌握「界面上已有哪些 `v*` 元素」，再结合策划文档；对作用不明的元素**主动询问**，避免猜绑。

**数据源**：仓库 `fgui/assets/<包名>/`（与编辑器插件同源，**不依赖** FairyGUI 是否打开）。  
**插件对照**：`C:/Users/lu/AppData/Roaming/FairyGUI-Editor/plugins/ui-extensions` 的「拷贝生成代码」；规则见 [reference.md](reference.md)。

配套：[code-standards](../code-standards/SKILL.md)（类/方法/`v*` 注释）、[fgui-ui-naming](../fgui-ui-naming/SKILL.md)（**`v*` 语义+类型后缀命名 / 改名**）、[laya-module-scaffold](../laya-module-scaffold/SKILL.md)、[my-features](../my-features/SKILL.md)、活动另过 [acts-module](../acts-module/SKILL.md)。

---

## 何时必须先做

在以下任一场景，**写 Win/Pop/Item 逻辑或声明 `v*` 字段之前**执行本 skill：

1. 用户给出 **FGUI 包名**（或 MyFeatures / 需求里已有包名）
2. 基于已有 FGUI 包实现 / 改界面逻辑
3. 对照策划文档做交互绑定时

纯改 Data/协议且不碰 UI → 可跳过。

---

## Agent 必做流程

```
- [ ] 1. 确认包名（及可选：主组件名如 XxxWin）
- [ ] 2. 列出/解析该包界面元素（脚本或读 XML）
- [ ] 3. 对照策划文档：能确定作用的记下；不确定的列成问题问用户
- [ ] 4. 用户确认后再写字段声明与 initUi 绑定
```

### 1. 定位资源

| 输入 | 路径 |
|------|------|
| 包名 `Pkg` | `{项目根}/fgui/assets/Pkg/package.xml` |
| 组件 | 同目录下 `*.xml`（`package.xml` 的 `<component name="...">`） |

项目根：当前 cqone 仓库（如 `C:/myPro/cqone5`）。若包不存在，先问用户包名是否写错或未出包。

### 2. 获取元素清单（优先脚本）

在 skill 目录执行（把 `PROJECT` / `Pkg` 换成实际值）：

```bash
node scripts/list-fgui-fields.js --root PROJECT --pkg Pkg
# 只看某一个界面：
node scripts/list-fgui-fields.js --root PROJECT --pkg Pkg --com XxxWin
```

输出：按组件分组的 `v*` 字段声明（类型规则与「拷贝生成代码」对齐）。  
脚本不可用时：直接读各组件 xml 的 `displayList` / `controller` / `transition`，规则见 [reference.md](reference.md)。

### 3. 结合策划、有疑必问

拿到清单后：

- **能从命名 + 策划对应上的**：直接用于实现（如 `vChallenge` ↔ 挑战按钮）。
- **命名模糊、策划未写、或多个候选**：向用户提问，例如：
  - 「`vToday` / `vTomorrow` 是否对应今日/明日属性展示？」
  - 「列表 `vFloors` 的 item 是否用包内 `FiveElementsTowerItem`？」
  - 「控制器 `vIsLastTwo` 的两页分别表示什么？」
- **默认忽略**（一般不绑业务）：`vFrame`、`vClose`（与插件 `config.json` 一致）；父类已处理的框体字段勿重复纠结。

**禁止**：在未确认前把模棱两可的节点猜成业务按钮/列表并写死逻辑。

### 4. 落到代码

- 字段声明与清单一致；`v*` **默认不加注释**（code-standards）。
- **命名**：语义 + 类型后缀（`vMonsterNameTxt`、`vPassRewardBtn`），见 [fgui-ui-naming](../fgui-ui-naming/SKILL.md)；本 skill 只负责发现与绑定，不替代命名规范。
- 运行时赋值靠 `UiUtil.setVFields`（基类通常已调）；子 Com 外包时用 `UiUtil.setVFields(com, this)`。
- **挂到 Win 的子组件内红点等**：勿用泛名 `vRedDot`。多次 `setVFields(子Com, this)` 会按**同名覆盖** Win 字段；应用业务语义名（如入口按钮 `vPassRewardBtn` 内红点 → `vPassRewardRedDot`），与 Win 声明一致。组件自身类内部用的 `vRedDot`（不抬到 Win）可保留。
- 公共组件类型以 `BasicViews.setCustomClass` / 脚本解析结果为准，勿重复 `setCustomClass` 已注册名。

---

## 与插件的关系

| | 编辑器「拷贝生成代码」 | 本 skill |
|--|------------------------|----------|
| 输入 | 当前选中组件 | 包名（+ 可选组件名） |
| 产出 | 剪贴板字段声明 | 开发用元素清单 + 疑问清单 |
| 环境 | FairyGUI 打开 | 只读仓库 XML |

逻辑对齐即可，**不要**要求用户先点插件再粘贴。

---

## 插件能力索引（ui-extensions，备查）

完整能力不在本 skill 展开；开发摸元素只需「拷贝生成代码」同源规则。其余菜单项：

- 打开节点树 / 查找 Controller 引用 / 查找未使用资源 / 查找显示列表中节点 / 查找非正常跨包资源
- 检视器：拷贝生成代码；XYWH 输入支持运算

---

## 自检

```
- [ ] 已读取目标包（及主 Win/Pop）的 v* 清单
- [ ] 策划对不上的元素已提问，未瞎猜
- [ ] 字段类型与清单/BasicViews 一致
- [ ] 未把 vFrame/vClose 当业务点纠结（除非需求明确）
```
