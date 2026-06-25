# 在 VS Code 中使用本项目

本文件说明如何在新电脑上为 VS Code Copilot Chat 配置全局指令，使以下行为规则在**所有项目**中自动生效：

- **karpathy-guidelines**：四条编码行为规则（编码前思考、简洁优先、精准修改、目标驱动）
- **grill-me**：设计压力测试技能，提到"grill me / 考我 / 追问"时触发
- **git-commit-convention**：Git 提交规范，AI 执行代码提交时自动遵循 conventional commits 格式
- **opengl-concepts**：OpenGL 图形学概念技能，讨论渲染/着色器/光照/图形 Bug 时自动触发（关键词触发）
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

围绕这个计划的每个方面持续追问，直到达成共同理解。沿着 design tree 的每个分支走下去，一次解决一个决策之间的依赖。

## 提问方式

每次提问必须使用 `vscode_askQuestions` 工具，按以下规则构造问题：

1. **提供选项**：提供 2-4 个合理的预设选项，使用 `options` 字段，每个 option 包含 `label` 和可选的 `description`。
2. **末项自定义**：始终添加一个 `✏️ 其他 / 自定义回答` 选项，并保持 `allowFreeformInput: true`（默认开启）。
3. **多选支持**：如果问题可能有多个答案，设置 `multiSelect: true`。
4. **推荐答案**：在推荐选项上标记 `recommended: true`。
5. **一次一问**：`questions` 数组只放一个问题。
6. **追问节奏**：得到回答后沿 decision tree 分支继续深挖。

如果某个问题可以通过探索 codebase 回答，就去探索 codebase，而不是提问。
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

# OpenGL 图形学概念技能

## 触发条件

当用户讨论以下相关话题时，启用 OpenGL/图形学知识辅助回答：

- **渲染管线 / 着色器 / GLSL** — 顶点/片段/几何着色器、shader 调试、内置变量
- **光照与阴影** — 冯氏/Blinn-Phong/PBR 光照、阴影映射、PCF、CSM
- **纹理与帧缓冲** — 纹理过滤、Mipmap、sRGB、FBO、MRT、后处理
- **渲染 Bug 诊断** — 颜色异常、几何错乱、光影问题、透明遮挡、性能卡顿
- **后处理效果** — HDR、Tone Mapping、Bloom、SSAO、抗锯齿
- **跨引擎翻译** — Unity/Unreal/Godot/Cocos/Laya 中对应 OpenGL 概念的实现
- **坐标与变换** — MVP 矩阵、摄像机、欧拉角、正交/透视投影
- **引擎架构** — 场景图、渲染管线架构、剔除、合批、GPU Instancing

## 使用原则

1. 优先用引擎术语回答，除非用户问"为什么"
2. 诊断时先追问缩小范围，再给方案（参考诊断树）
3. 配合 CodeGraph 查引擎源码定位具体实现

## 详细知识库

完整的 OpenGL 图形学知识库（含 70 个核心概念字典、8 分支诊断树、GLSL 速查、跨引擎翻译表、15 条数学公式、Cocos/Laya 源码映射表）见本项目 `skills/opengl-concepts/SKILL.md`。当触发上述话题时，AI 应自动读取该文件获取详细知识。
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

---

## 第五步：创建 `git-commit-convention.instructions.md`

在同一目录中新建文件 `git-commit-convention.instructions.md`，内容如下：

```markdown
---
applyTo: "**"
---

# Git 提交规范

当用户请求你**提交代码**（git commit / git push / "帮我推送" / 任何涉及代码提交的操作）时，必须提醒并遵循以下 Git 提交规范。

## 提交信息格式

每次 commit 必须写有意义的提交信息，遵循 conventional commits 格式：

```
<type>: <简短描述>
```

## 类型

| 类型 | 使用场景 |
|------|---------|
| `feat` | 新功能（feature） |
| `fix` | 修复 Bug |
| `docs` | 仅文档变更 |
| `style` | 不影响代码含义的格式变动（空格、格式化等） |
| `refactor` | 重构（既不修复 Bug 也不添加功能） |
| `perf` | 性能优化 |
| `test` | 添加或修改测试 |
| `chore` | 构建过程、辅助工具等杂项 |

## 示例

- `feat: 添加用户登录功能`
- `fix: 修复空指针崩溃`
- `docs: 更新 API 使用说明`
- `chore: 合并上游 main 分支`

## 行为规则

1. 用户说"提交"或"推送"时，先问清楚本次变更内容，然后按上述格式生成提交信息
2. 如果用户自己写了提交信息，检查是否符合格式，不符合时给出修正建议
3. 生成提交信息时，用中文写描述（简短扼要），类型用英文
```

