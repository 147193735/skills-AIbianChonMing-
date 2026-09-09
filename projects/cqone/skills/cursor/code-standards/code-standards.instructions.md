---
applyTo: '**/*.{ts,tsx}'
---

# 代码规范（局部触发）

权威文档（skill 自持）：`upstream/代码规范.md`（勿依赖 `C:/myPro/doc`）  
cqone 清单：同目录 `SKILL.md` / `reference.md`

当生成、修改或审查 TypeScript 代码时，必须对照以下规则逐条检查。

## 0. cqone 快速自检

- 新文件：`@author zhangyongkang` + `@since yyyy-MM-dd`（CQ File Header；**禁止**抄邻近文件作者）
- 域词统一；布尔用 `get isXxx()`；父类方法签名一致
- FGUI `v` 前缀；`setCustomClass` 与 xml 同名；**勿重复注册 BasicViews 已有公共组件**（`Btn_a_r`/`Btn_a_y`/`CostCom`/`RelateFnBtn` 等）
- `Shop.csv` vs `ActivityShop.csv` 勿混用

## 1. 命名规范

### 原则

- **统一性**：同一事物在所有地方命名一致。
- **简短优先**：含义清楚前提下尽量用短词。
- **约定简写**：用 `i`(index)、`cur`(current)、`prev`/`next`、`w`/`h`(width/height)、`img`(image)、`btn`(button)、`txt`(text)、`win`(window)、`len`(length)、`num`(number)、`arr`(array)、`str`(string)、`fn`(function)、`src`/`dst`(source/destination)。
- **避免关键字重名**。
- **全大写缩写驼峰化**：`RMB` → `Rmb`，`GBK` → `Gbk`，`UTF` → `Utf`。

### 模块文件夹名

小写字母开头驼峰，如 `bag`、`player`、`myPlayer`。

### 类名

大写字母开头驼峰。除 `core`/`base`/`common` 外，`ctrl`/`data` 下以模块名开头。

- `XxxCtrl`（控制器）、`XxxData`（数据）、`XxxEvent`（事件）、`XxxConst`（常量）
- `XxxCo`（配置对象）、`XxxPo`（协议对象）、`XxxFo`（功能对象）、`XxxMo`（信息对象）
- 视图后缀：`Win`、`Pop`、`Cell`、`Li`、`Btn`、`Com`、`View`

### 变量名

- **常量**：`UPPER_SNAKE_CASE`，如 `CITY_SCENE_ID`
- **可变量**：小写字母开头驼峰
    - 视图子视图以 `v` 开头，如 `vBagList`、按钮 `vWear`

### 方法名

小写字母开头驼峰。

- 布尔状态：`is`/`has`/`need`/`can`/`allow` 开头
- 收协议：`on` + 协议类名去 Po
- 发协议：`req` + 含义名
- 刷新视图：`refresh` + 数据名

## 2. 注释规范

- **类注释**：`@author zhangyongkang` `@since yyyy-MM-dd`（固定作者名，勿抄邻近文件）
- **方法注释**：本类方法（含 private）精简单行；父类覆盖不加；`@param`/`@return` 仅复杂时用
- **后续新增同样要注释**：已有模块里新加的方法 / 字段 / getter 与新建同一套规则；勿只给脚手架首版写注释。改旧文件不必给未改动的旧方法补注释
- **成员变量**：单行 `/** 说明 */`；**`v*` FGUI 元素默认不加**（仅人手写时保留）
- **语句块**：只有需特别解释处才加 `// 原因`
- **禁对话提示型注释**：坑/注意/需手动/记得…只写在对话，不入库；已有则「检查代码」时删

## 3. 代码书写顺序

通用：静态成员 → 静态方法 → 分区行 → 实例成员 → 分区行 → 构造 → 普通方法。分区用 `//* ************************************************************************`（小文件可只用空行）。

**新建 Data**：`I` → 字段（必注释，无 getter；含 `RedDotTask`）→ 父类 → onSC → req → 自定义对外接口（含 getter）→ 私有实现 → 红点（`update*RedDotsLater` → `RedDotTask.runLater`，禁止 Timer 刷红点）。后续往 Data 里新加的方法 / 字段同样要注释。

**新建 View**：`v*`/业务字段 → constructor[/setWinMo] → initUi → onAddedToStage → onRemovedFromStage → [onClose] → initData → refresh* → on*/play*/render*。排版仅约束新建；注释对后续新增方法同样生效；勿为排版重排旧文件。

## 4. 编码规范

### 界面类

继承 `Win`，顺序：`constructor` → `setWinMo` → `initUi` → `onAddedToStage` → `initData` → `refreshXxx`

> `constructor`/`setWinMo`/`initUi` 只执行一次；每次 `show` 都执行 `initData`，不一定会执行 `onAddedToStage`。

### get/set

不写没用的 get/set，如 `get id(){return this._id;} set id(v){this._id=v;}` 应直接定义公有成员。

### Long 类型

- id 含义：业务域用 `string`，`id?.toString()` / `Long.fromString(id)`
- 数值含义：业务域用 `number`，`Long.toNumberOrZero(value)` / `Long.fromNumber(value)`

### 杂项

- **自己的事自己做**：缓动/特效由持有者在生命周期内自清；Win 只编排，不代子组件 `Tween.clearAll`
- 禁止将 `Po` 直接用作信息对象
- 避免在 `any` 类型上点属性/方法
- 优先组合而非类继承
