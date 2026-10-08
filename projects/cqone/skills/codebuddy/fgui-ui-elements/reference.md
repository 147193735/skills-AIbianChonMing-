# FGUI 元素解析规则（对齐「拷贝生成代码」）

插件源：`…/FairyGUI-Editor/plugins/ui-extensions/Export/ExportCodeInspector.ts`

## 收录条件

| 来源 | 条件 |
|------|------|
| 子节点 | `name` 以 `v` 开头，且不在忽略表 |
| 控制器 | `controller/@name` 以 `v` 开头 |
| 动效 | `transition/@name` 以 `v` 开头 |

**默认忽略**：`vFrame`、`vClose`（插件 `config.json` → `ignores`）。

## 数组合并

若名形如 `vFoo_0`、`vFoo_1`…（`_` 后为纯数字），合并为：

```ts
vFoo: Type[];
```

保留基名 `vFoo`，类型取该组之一。

## 类型推断（XML）

### 1. 自定义类（优先）

子节点若有 `fileName="Xxx.xml"`（或 `src` 对应资源名 `Xxx`）：

1. 在 `src/script/conf/view/BasicViews.ts` 查 `setCustomClass("Xxx", ClassName)` → 类型用 **ClassName**（标识符名）。
2. 本包其它组件也可被 `setCustomClass` 注册；无注册则继续下面规则。

### 2. 扩展类型

若引用组件的根节点有 `extention="Button|Label|ComboBox|ProgressBar|Slider|ScrollBar"`：

| extention | TS 类型 |
|-----------|---------|
| Button | GButton |
| Label | GLabel |
| ComboBox | GComboBox |
| ProgressBar | GProgressBar |
| Slider | GSlider |
| ScrollBar | GScrollBar |

### 2.1 官方 Button / 官方控制器名（必记）

`extention="Button"`（或自定义类继承 `UiBtn` / `RedDotBtn`）时：

| FGUI 官方名 | 是否导出为 `v*` | TS 用法 |
|-------------|-----------------|--------|
| 子节点 `title` | **否**（非 `v` 开头，list-fgui-fields / 拷贝生成代码都不导出） | `this.title = "..."`（`GButton` 官方属性） |
| 控制器 `button`（up/down/over…） | **否**（官方控制器名，非 `v` 开头） | 由 FGUI Button 自己驱动，业务勿再声明/乱改 |

自定义 Tab/Item 若是按钮：基类用 `RedDotBtn`/`UiBtn`，文案只走 `title`，红点用 `vRedDot` + `setRedDotVisible`。**不要**再声明 `title: GTextField` 或手写非 `v*` 字段去绑官方节点。

### 3. 节点标签

| XML 标签 | TS 类型 |
|----------|---------|
| image | GImage |
| graph | GGraph |
| list | GList |
| loader | GLoader |
| text | GTextField |
| richtext | GRichTextField |
| inputtext | GTextInput |
| group | GGroup |
| movieclip | GMovieClip |
| component | GComponent |
| loader3D | GLoader3D |

控制器 → `Controller`；动效 → `Transition`。

## 只扫一层

与插件一致：只扫**该组件根下**直接子节点 / 控制器 / 动效，**不递归**子组件内部的 `v*`（子组件自有类自己声明）。

## 运行时绑定

`UiUtil.setVFields(gComp, uiComp?)`：把 `gComp` 上以 `v` 开头的子节点、控制器、动效赋给 `uiComp` 同名成员。

### 抬字段到 Win：避免同名覆盖

`setVFields(子Com, this)` 把子组件根下 `v*` **写到 Win**。多个子 Com 若都有 `vRedDot`，后一次调用会覆盖前一次，红点绑错对象。

| 场景 | 命名 |
|------|------|
| 子组件**自有类**内部用（不抬到 Win） | 可用 `vRedDot` |
| 经 `setVFields(子Com, Win)` **抬到 Win**（红点/关键控件） | 用业务语义名：`vPassRewardRedDot`、`vRewardRedDot` 等，与入口 `vPassRewardBtn` 成对 |
| Agent 在包内**自增**通用按钮/Com 的红点 | 先想清是否会 `setVFields(..., this)`；会抬 → 禁泛名 `vRedDot` |

示例：`BtnHurt` 内红点叫 `vPassRewardRedDot`，Win：`UiUtil.setVFields(this.vPassRewardBtn, this)` → `this.vPassRewardRedDot.setData(...)`。

## 示例（FiveElementsTower / FiveElementsTowerWin）

从 XML 可得（忽略 vFrame 后）：

```
vFakeBg: GComponent;
vFloors: GList;
vChallenge: /* BasicViews → 常为 RedDotBtn 等 */;
vHideBoss: GButton;
vToday: GLabel;
vTomorrow: GLabel;
vSurplus: PlayTimesLabel;
vAdd: /* Btn_add → BasicViews */;
vIsLastTwo: Controller;
```

（具体公共类名以当前仓库 `BasicViews.ts` 为准，以脚本输出为准。）
