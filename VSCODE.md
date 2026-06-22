# 在 VS Code 中使用本项目

本文件说明如何在新电脑上为 VS Code Copilot Chat 配置全局指令，使以下行为规则在**所有项目**中自动生效：

- **karpathy-guidelines**：四条编码行为规则（编码前思考、简洁优先、精准修改、目标驱动）
- **grill-me**：设计压力测试技能，提到"grill me / 考我 / 追问"时触发
- **typescript-safety**：TypeScript 类型安全规则，禁止不必要的 `as any`

---

## 全局 prompts 目录位置

| 系统 | 路径 |
|------|------|
| Windows | `%APPDATA%\Code\User\prompts\` |
| macOS | `~/Library/Application Support/Code/User/prompts/` |
| Linux | `~/.config/Code/User/prompts/` |

---

## 第一步：创建 `karpathy-guidelines.instructions.md`

在上方目录中新建文件 `karpathy-guidelines.instructions.md`，内容如下：

```markdown
---
applyTo: "**"
---

# Karpathy behavioral guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
\```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
\```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Language

All reasoning, analysis, and responses must be in **Simplified Chinese (简体中文)**.
```

---

## 第二步：创建 `grill-me.instructions.md`

在同一目录中新建文件 `grill-me.instructions.md`，内容如下：

```markdown
---
applyTo: "**"
---

# Grill-Me 技能

当用户想要对一个计划或设计进行压力测试，或者提到"grill me"/"考我"/"追问"时，启用以下行为：

围绕这个计划的每个方面持续追问，直到达成共同理解。沿着 design tree 的每个分支走下去，一次解决一个决策之间的依赖。每个问题都提供你的推荐答案。

一次只问一个问题。

如果某个问题可以通过探索 codebase 回答，就去探索 codebase。
```

---

## grill-me 使用示例

在 Copilot Chat 中，只需在对话里提到触发词，技能即自动激活：

**场景 1：压测技术方案**
> 我打算用 Redis 做分布式锁，grill me

Copilot 会逐一追问：锁的粒度是什么？超时时间怎么设？客户端崩溃后如何释放？是否需要可重入？……每个问题附带推荐答案。

**场景 2：追问架构设计**
> 我想把单体应用拆成微服务，考我一下

会沿 design tree 追问：服务边界怎么划？数据如何拆？跨服务事务怎么处理？服务发现用什么方案？……

**场景 3：代码评审前自检**
> 我要给这个 PR 加缓存层，追问我

会问：缓存的失效策略？缓存击穿/雪崩如何处理？是否需要写穿透？数据一致性如何保证？……

**关键行为**：
- 每次**只问一个问题**，等你回答后再追下一个
- 每个问题都给出**推荐答案**供参考
- 如果答案能从代码库找到，会先探索代码再问

---

## 验证

重启 VS Code 后，在任意项目中打开 Copilot Chat，指令即自动生效。

如需仅对单个项目生效，改为在该项目根目录创建 `.github/copilot-instructions.md`（参考本项目已有文件）。

---

## 第三步：创建 `opengl-concepts.instructions.md`

在同一目录中新建文件 `opengl-concepts.instructions.md`，内容如下：

```markdown
---
applyTo: "**"
---

# OpenGL 图形学概念知识库

当遇到渲染异常、shader 问题、画面 Bug、性能瓶颈时，使用此知识库。

## 渲染管线速查

顶点数据 → 顶点着色器 → [曲面细分] → [几何着色器] → 光栅化 → 片段着色器 → 深度/模板/混合 → 帧缓冲

## 核心概念（20个）

### 数据流
- VAO: 顶点格式说明书 → Unity: Mesh.SetVertexBufferParams
- VBO: GPU 显存里的顶点数组 → Unity: Mesh.vertices
- EBO: 索引数组，8 个顶点画立方体 → Unity: Mesh.triangles
- FBO: 渲染到纹理 → Unity: RenderTexture
- UBO: 批量传 uniform → Unity: MaterialPropertyBlock

### 着色器
- 顶点着色器: 逐顶点坐标变换 → Unity: #pragma vertex
- 片段着色器: 逐像素决定颜色（视觉核心） → Unity: #pragma fragment
- 几何着色器: 创建/销毁图元 → Unity: #pragma geometry

### 纹理
- 纹理: GPU 上的图片贴到模型上 → Unity: Texture2D
- Mipmap: 纹理缩略图链，远处不闪烁 → Unity: Generate Mip Maps
- 纹理单元: 同时绑多张纹理的插槽
- 立方体贴图: 6 张纹理围成立方体 → 天空盒/环境反射 → Unity: Cubemap

### 光照
- 冯氏光照: 环境光+漫反射+镜面反射 → Unity: Legacy Shader
- 阴影映射: 从光源视角渲染深度图判断遮挡 → Unity: Shadow Map
- PBR: 能量守恒+微表面+菲涅耳 → Unity: Standard/Lit Shader
- 法线贴图: 纹理编码凹凸细节（不增顶点） → Unity: Normal Map

### 后期处理
- 深度测试: 比较像素深度决定遮挡 → Unity: ZWrite/ZTest
- 混合: 新旧颜色叠加（玻璃/烟雾/粒子） → Unity: Blend 命令
- HDR: 超 0-1 的颜色范围 → Unity: HDR 色彩空间
- 延迟渲染: 先存几何再算光（多光源友好） → Unity: Deferred Rendering Path

## 渲染 Bug 诊断树

遇到渲染问题时按此排查：

### 颜色异常
- 单个物体：查该物体材质/纹理/着色器 uniform
- 全部物体：查 Gamma 校正/HDR/后处理
- 一直偏暗：Gamma/sRGB 转换遗漏
- 特定角度：光照方向或法线计算错误

### 几何异常
- 模型不显示：VAO 未绑定 / 面剔除方向反了
- 位置形状错：MVP 矩阵顺序 / 坐标系混淆 / 顶点属性错位

### 光影异常
- 阴影锯齿：Shadow Map 分辨率低 / 缺 PCF
- 阴影条纹：depth bias 不够（阴影痤疮）
- 阴影分离：bias 太大（彼得潘现象）
- 法线贴图无效：切线空间 TBN 矩阵错误
- 高光位置错：Phong vs Blinn-Phong / 法线方向

### 透明异常
- 透明挡住透明：排序错误，需关 ZWrite 从远到近排
- 不透明被透明挡：先画不透明（ZWrite on）再画透明（ZWrite off）
- 两个面闪烁：Z-Fighting，近远平面比例太大

### 性能问题
- 特定方向卡：过度绘制 / Draw Call 太多
- 静止也卡：纹理带宽瓶颈 / 着色器太复杂
- 特定物体出现时卡：顶点太多 / 纹理分辨率太高

## OpenGL ↔ 引擎翻译

| OpenGL | Unity | Unreal | Godot |
|--------|-------|--------|-------|
| FBO | RenderTexture | SceneCaptureComponent | ViewportTexture |
| Depth Test | ZWrite/ZTest | Depth Stencil State | depth_draw_mode |
| Blend | Blend 命令 | Blend Mode | blend_mode |
| Mipmap | Generate Mip Maps | Texture Mip Gen | mipmaps |
| Shadow Map | Shadow settings | Light Mobility | Shadow settings |
| Instancing | GPU Instancing | ISMC Instancing | MultiMeshInstance |
| Stencil | Stencil 命令 | Stencil Buffer | — |
| Face Culling | Cull 命令 | Two Sided | cull_mode |

## 关键公式
- MVP = P × V × M（右乘）→ gl_Position
- N·L = cos(θ) → 漫反射强度
- H = normalize(L+V) → Blinn-Phong 半程向量
- Blend: Result = Src×Fsrc + Dst×Fdst

## 使用原则
1. 优先用引擎术语回答，除非用户问"为什么"
2. 诊断时先追问缩小范围，不要直接给方案
3. 配合 CodeGraph 查引擎源码定位具体实现
```

---

## 第四步：创建 `typescript-safety.instructions.md`

在同一目录中新建文件 `typescript-safety.instructions.md`，内容如下：

```markdown
---
applyTo: "**/*.{ts,tsx}"
---

# TypeScript 类型安全规则

生成 TypeScript/TSX 代码时，必须遵循以下类型安全规则。

**核心原则：能明确知道类型时，禁止使用 `as any`。**

---

## 为什么禁止 `as any`

`as any` 会完全绕过 TypeScript 的类型系统，让编译器放弃对该表达式的所有类型检查。`any` 会穿透整个类型链——一个 `as any` 可能导致后续多处类型检查失效，将运行时错误隐藏到很远的地方才暴露。

---

## 禁止场景（必须用具体类型替代）

| 场景 | 不要这样写 | 应该这样写 |
|------|-----------|-----------|
| API 响应 | `const data = response.data as any` | `const data = response.data as ApiResponse` 或定义接口 |
| 函数返回值 | `function get(): any` | `function get(): User` 或其它具体类型 |
| 对象属性 | `(obj as any).prop` | 定义正确类型或使用类型守卫 |
| 数组元素 | `items.map(i => i as any)` | `items.map(i => i as KnownType)` |
| 修复类型错误 | `// @ts-ignore` + `as any` | 修复实际类型问题，或使用类型守卫 |
| 泛型 | `Map<string, any>` | `Map<string, User>` |

---

## 允许的例外场景（但必须按规则使用）

只有在**确实无法确定类型**时才允许，且应优先使用 `as unknown as T` 而非直接 `as any`：

1. **与无类型第三方库交互** — 库没有 .d.ts 类型定义
2. **JSON.parse 后重构类型** — 用 `JSON.parse(str) as unknown as T`
3. **渐进迁移遗留代码** — 必须加注释 `// TODO: 移除 as any，定义正确类型`

**任何允许的 `as any` 都必须加注释说明理由。**

---

## 优先替代方案

按优先级从高到低：

1. **定义接口/类型** — 最推荐，类型完整保留
2. **类型守卫** — `isX(value): value is X` 缩小类型范围
3. **`as const`** — 固定字面量类型，而非 `as any`
4. **`satisfies`** — 验证类型匹配但不改变推断结果
5. **`as unknown as T`** — 逃生口，至少声明了目标类型
6. **` as any`（最后选择）** — 仅在前 5 项都不适用时

---

## 检查原则

收到用户代码时，注意识别 `as any` 的使用：

- 如果是**新增代码**中出现了不必要的 `as any` → 建议用具体类型替代
- 如果是**已有遗留代码**中的 `as any` → 除非在相关改动范围附近，否则不动
- 如果是你生成的代码中出现了 `as any` → 先自问"这里我真的不知道类型吗？"再使用
```

