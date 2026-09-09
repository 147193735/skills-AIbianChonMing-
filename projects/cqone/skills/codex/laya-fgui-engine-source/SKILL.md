---
name: laya-fgui-engine-source
description: >-
  Locate and read cqone's matching Laya 2.13.1 and FairyGUI-layabox engine
  TypeScript sources (using codegraph MCP when configured, otherwise local
  search) when analyzing problems or
  explaining runtime behavior that touch the engine/FGUI layer (mask,
  GButton/Radio, displayObject, controllers, scrollRect, rendering, input,
  tween, loader, etc.). Use proactively when diagnosis reaches bin/libs or
  engine APIs; when the user asks how Laya or FairyGUI works; or mentions
  引擎源码, FGUI源码, LayaAir, FairyGUI-layabox, mask, setMask, relatedController.
---

# cqone 引擎 / FGUI 源码查阅

本机权威源码（对应 **cqone** 所依赖版本；查机制时优先于 `cqone/bin/libs` 压缩 JS）。

| 库 | 路径 | 说明 |
|---|---|---|
| LayaAir 2.13.1 | `C:/myPro/LayaAir-LayaAir_2.13.1` | 引擎源码；业务逻辑多在 `src/` |
| FairyGUI-layabox | `C:/myPro/FairyGUI-layabox-master` | FGUI for Laya；实现多在 `source/` |

项目内运行时打包：`C:/myPro/cqone/bin/libs/`（`laya.*.js` / `fairygui.js`）——仅作对照，**以本表源码为准**。

---

## 何时必读本 skill

- **分析问题触及底层**：行为落到引擎/FGUI API、`bin/libs`、显示对象、控制器、遮罩、渲染、输入、缓动、加载器等，不要只猜业务封装
- 解释遮罩、`displayObject.mask`、`GComponent.setMask`
- 解释按钮 / Radio / `button` 控制器 / `relatedController`
- 用户问「FGUI有没有…」「Laya本身是…」「源码里怎么写的」
- `bin/libs` 压缩代码难读或与预期不符

---

## Agent 做法

1. 若当前环境已配置 `codegraph_explore`，优先在上表两个仓库查符号/调用链；否则用 `rg` 和文件读取定位实现及调用方。不要先糊 `fairygui.min.js` / `laya.*.js`。
2. FGUI API（`GButton`、`GComponent.mask`/`setMask`、Controller）→ `FairyGUI-layabox-master/source/`。
3. 落到显示对象（`Sprite.mask`、`scrollRect`、`cacheAs`）→ `LayaAir-LayaAir_2.13.1/src/`。
4. 需要时再用 `cqone/bin/libs` 核对已打进项目的行为。
5. 回答时标明结论来自哪一侧源码（FGUI vs Laya），避免把业务封装（如 `UiTabGroup`）说成引擎 API。

---

## 常见对照（速记）

- FGUI `GComponent.setMask(displayObject, reversed)` → 最终仍是 Laya `displayObject.mask`（反转用 `destination-out` + `cacheAs`）。
- `GButton` 内置找名为 **`button`** 的控制器，页名 `up`/`down`/`over`…；组件外观在编辑器配，切页在 FGUI 运行时。
- 业务层 `UiTabGroup` / `HeadTab` 管组选中与业务态，不负责内部 `button` 控制器定义。
