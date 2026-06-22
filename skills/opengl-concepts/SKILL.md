---
name: opengl-concepts
description: OpenGL/图形学底层概念知识库。帮助 AI 理解渲染管线、着色器、纹理、光照、帧缓冲等核心原理，用于诊断渲染 Bug、跨引擎翻译（Unity/Unreal/Godot）、性能优化。当遇到渲染异常、shader 问题、画面 Bug、性能瓶颈时自动调用。
---

# OpenGL 图形学概念知识库

> **用这个知识库做什么：** 看到渲染 Bug → 定位到管线环节 → 找到引擎源码中对应的实现 → 精准修复。
> **什么时候用它：** 渲染异常排查、shader 调试、跨引擎概念翻译、性能瓶颈分析。
> **配合 CodeGraph：** 概念定位后，用 CodeGraph 查引擎源码中对应实现的具体代码。

---

## 一、渲染管线速查（数据怎么流）

```
顶点数据 → 顶点着色器 → [曲面细分] → [几何着色器] → 光栅化 → 片段着色器 → 深度/模板/混合 → 帧缓冲
```

每个阶段出问题的典型表现：
- **顶点着色器阶段** → 模型位置/形状错乱
- **光栅化阶段** → 锯齿、面朝向错误
- **片段着色器阶段** → 颜色/光照/纹理异常
- **深度测试阶段** → 遮挡关系错误、Z-Fighting
- **混合阶段** → 透明物体叠加顺序错误
- **帧缓冲阶段** → 后处理失效、渲染到纹理黑屏

---

## 二、核心概念字典（20 个关键概念）

### 2.1 数据流概念

| # | 概念 | 一句话 | 引擎对应 |
|---|------|--------|----------|
| 1 | **VAO** | 顶点格式说明书——告诉 GPU 怎么读 VBO 里的数据 | Unity: Mesh.SetVertexBufferParams |
| 2 | **VBO** | GPU 显存里的顶点数据数组（位置、法线、UV...） | Unity: Mesh.vertices |
| 3 | **EBO** | 索引数组——8 个顶点画一个立方体而不是 36 个 | Unity: Mesh.triangles |
| 4 | **FBO** | 渲染目标容器——渲染到纹理而不是屏幕 | Unity: RenderTexture |
| 5 | **UBO** | 批量传递 uniform 参数的缓冲 | Unity: MaterialPropertyBlock |

### 2.2 着色器概念

| # | 概念 | 一句话 | 引擎对应 |
|---|------|--------|----------|
| 6 | **顶点着色器** | 逐顶点运行——把 3D 坐标变换到屏幕 | Unity: #pragma vertex |
| 7 | **片段着色器** | 逐像素运行——决定最终颜色，视觉效果的核心 | Unity: #pragma fragment |
| 8 | **几何着色器** | 可创建/销毁图元——爆破效果、法线可视化 | Unity: #pragma geometry |

### 2.3 纹理概念

| # | 概念 | 一句话 | 引擎对应 |
|---|------|--------|----------|
| 9 | **纹理** | GPU 上的图片——给模型"贴图" | Unity: Texture2D |
| 10 | **Mipmap** | 纹理的缩略图链——远处用小的，不闪烁 | Unity: Generate Mip Maps |
| 11 | **纹理单元** | 同时绑多张纹理的插槽 | Unity: Shader 属性自动分配 |
| 12 | **立方体贴图** | 6 张纹理围成立方体——天空盒、环境反射 | Unity: Cubemap |

### 2.4 光照概念

| # | 概念 | 一句话 | 引擎对应 |
|---|------|--------|----------|
| 13 | **冯氏光照** | 环境光+漫反射+镜面反射——经典光照入门 | Unity: Legacy Shader |
| 14 | **阴影映射** | 从光源视角渲染深度图 → 判断遮挡 | Unity: Shadow Map |
| 15 | **PBR** | 能量守恒+微表面+菲涅耳——现代物理渲染 | Unity: Standard/Lit Shader |
| 16 | **法线贴图** | 用纹理编码凹凸——不增加顶点的假细节 | Unity: Normal Map |

### 2.5 后期处理概念

| # | 概念 | 一句话 | 引擎对应 |
|---|------|--------|----------|
| 17 | **深度测试** | 比较像素深度——谁在前面谁显示 | Unity: ZWrite / ZTest |
| 18 | **混合** | 新旧颜色按公式叠加——玻璃、烟雾、粒子 | Unity: Blend 命令 |
| 19 | **HDR** | 超出 0-1 的颜色范围——亮的地方真的很亮 | Unity: HDR 色彩空间 |
| 20 | **延迟渲染** | 先存几何信息再算光——大量光源不卡 | Unity: Deferred Rendering Path |

---

## 三、渲染 Bug 诊断树（症状 → 根因）

### 当用户说"画面有问题"时，按此流程排查：

```
第 0 步：分类症状
  ├── 颜色异常 → 走分支 A
  ├── 几何/形状异常 → 走分支 B
  ├── 光影/阴影异常 → 走分支 C
  ├── 透明/遮挡异常 → 走分支 D
  └── 性能卡顿 → 走分支 E

分支 A：颜色异常
  Q1: 所有物体还是单个物体？
    → 单个: 检查该物体的材质/纹理 → 纹理过滤、sRGB 格式、着色器 uniform
    → 全部: 检查全局设置 → Gamma 校正、HDR、色调映射、后处理
  Q2: 是一直偏暗还是某些角度？
    → 一直偏暗: Gamma/sRGB 转换遗漏
    → 特定角度: 光照计算错误（法线方向、光照方向）

分支 B：几何/形状异常
  Q1: 模型完全不显示？
    → VAO 未绑定 / 面剔除方向反了 / 顶点数据错误
  Q2: 模型显示但位置或形状不对？
    → MVP 矩阵顺序错 / 坐标系混淆 / 顶点属性错位

分支 C：光影/阴影异常
  Q1: 阴影有锯齿？→ Shadow Map 分辨率低 / 缺 PCF
  Q2: 阴影有条纹（痤疮）？→ depth bias 不够
  Q3: 阴影和物体分离？→ bias 太大（彼得潘现象）
  Q4: 法线贴图不生效？→ 切线空间 TBN 矩阵错误
  Q5: 镜面高光位置不对？→ 用的是 Phong 还是 Blinn-Phong / 法线方向

分支 D：透明/遮挡异常
  Q1: 透明物体挡住其他透明物体？
    → 渲染顺序错误：需关 ZWrite，从远到近排
  Q2: 不透明物体被透明物体挡住？
    → 先画不透明（开 ZWrite），再画透明（关 ZWrite）
  Q3: 两个面交替闪烁？→ Z-Fighting: 近远平面比例太大

分支 E：性能卡顿
  Q1: 看什么方向最卡？→ 过度绘制（粒子叠层）/ Draw Call 太多
  Q2: 静止也卡？→ 纹理带宽瓶颈 / 着色器太复杂
  Q3: 特定物体出现时卡？→ 顶点数太多 / 纹理分辨率太高
```

---

## 四、OpenGL ↔ 引擎翻译表

| OpenGL | Unity | Unreal | Godot | Cocos Creator 4.0 | LayaAir 3.3 |
|--------|-------|--------|-------|-------------------|-------------|
| VAO+VBO | Mesh.vertices + SetVertexBufferParams | FStaticMeshVertexBuffer | ArrayMesh | InputAssembler + Buffer(Vertex) | VertexBuffer + VertexDeclaration |
| EBO/IBO | Mesh.triangles | FStaticMeshIndexBuffer | — | Buffer(Index) | IndexBuffer |
| FBO | RenderTexture | SceneCaptureComponent | ViewportTexture | Framebuffer + RenderPass | RenderTexture + InternalRenderTarget |
| Depth Test | ZWrite, ZTest | Depth Stencil State | depth_draw_mode | DepthStencilState.depthTest/depthWrite | RenderStateType.DepthTest/DepthFunc |
| Depth Compare | ZTest | Depth Stencil State | depth_draw_mode | ComparisonFunc (LESS, EQUAL...) | CompareFunction (Less, Equal...) |
| Stencil | Stencil 命令 | Stencil Buffer | — | DepthStencilState.stencilTestFront/Back | StencilState + RenderStateType.StencilTest |
| Blend | Blend 命令 | Blend Mode | blend_mode | BlendState + BlendTarget | BlendState + BlendComponent |
| Mipmap | Generate Mip Maps | Texture Mip Gen | mipmaps | TextureFlagBit.GEN_MIPMAP + sampler.mipFilter | FilterMode (Point/Bilinear/Trilinear) |
| Texture Filter | Filter Mode | Texture Filtering | texture_filter | Filter (POINT/LINEAR/ANISOTROPIC) | FilterMode (Point/Bilinear/Trilinear) |
| Texture Wrap | Wrap Mode | Texture Addressing | wrap_mode | Address (WRAP/MIRROR/CLAMP) | WrapMode (Repeat/Clamp/Mirrored) |
| Face Culling | Cull 命令 | Two Sided | cull_mode | CullMode (NONE/FRONT/BACK) | CullMode (Off/Front/Back) |
| Depth Bias | Depth Bias | Shadow Bias | depth_bias | RasterizerState.depthBias/depthBiasSlop | ShadowCasterPass bias params |
| Shadow Map | Shadow settings | Light Mobility | Shadow settings | shadow/shadow-flow.ts + CSM | ShadowCasterPass + ShadowSliceData |
| Instancing | GPU Instancing | ISMC Instancing | MultiMeshInstance | instanced-buffer + render-instanced-queue | VertexBuffer.instanceBuffer |
| Uniform | Material.SetFloat() | Material Parameter | shader.set_shader_parameter() | DescriptorSet + PipelineLayout | Material.setFloat() / setTexture() |

---

## 五、配合 CodeGraph 使用

当通过以上诊断锁定概念后，用 CodeGraph 定位引擎源码：

```bash
# 示例：诊断出是"阴影映射 bias 不够"
# → 查引擎中相关实现
codegraph explore "shadow bias depth offset unity"

# 返回 ShadowUtils.cs 中 SetupShadowCasterConstantBuffer() 的源码
# → AI 看到 m_ShadowBias 变量 → 指导用户调参
```

**工作流程：** 现象 → 诊断树定位概念 → CodeGraph 查源码 → 精准修复方案

---

## 六、关键数学速查

| 公式 | 用途 | 说明 |
|------|------|------|
| MVP = P × V × M | 顶点变换到裁剪空间 | 注意是右乘！gl_Position = P × V × M × localPos |
| N·L = cos(θ) | 漫反射强度 | N=法线, L=光源方向 |
| H = normalize(L+V) | Blinn-Phong 半程向量 | 替代反射向量，更高效 |
| (R·V)^s | 镜面高光 | R=反射向量, V=视角, s=光泽度 |
| Result = Src×Fsrc + Dst×Fdst | 混合公式 | 控制透明叠加行为 |

---

## 七、引擎架构概念（渲染管线之上的层）

> 以下概念是纯 GPU 渲染之上的"引擎层"——OpenGL 不管这些，但每个游戏引擎必须实现。

### 7.1 场景图与变换层级

| 概念 | 一句话 | Cocos Creator 4.0 | LayaAir 3.3 |
|------|--------|-------------------|-------------|
| **场景图** | 树形结构组织所有物体，父节点变换影响子节点 | `Scene` → `Node` → `children: Node[]` | `Scene` → `Sprite` → `_children` |
| **局部→世界变换** | 每个节点存 local 变换，递归乘父矩阵得世界变换 | `Node.worldMatrix`, `Node.position` | `Sprite.transform` → 递归计算 |
| **脏标记** | 只有"变了"才重算世界矩阵，省性能 | `_worldMatDirty` 标记 | `_transformChanged` |

**常见 Bug 诊断：**
- 子物体位置不对 → 父节点矩阵未更新 / 脏标记没置位
- 旋转后坐标系错乱 → 世界空间 vs 局部空间计算错误
- 大量节点移动卡顿 → 脏标记传播过深，需要手动 `updateWorldTransform()`

### 7.2 渲染管线架构

| 维度 | Cocos Creator 4.0 | LayaAir 3.3 |
|------|-------------------|-------------|
| **架构风格** | **FrameGraph**（声明式）：`RenderGraph` 描述整个帧的依赖关系 → `ExecutorContext` 执行 | **命令式**：`RenderContext3D` → `Laya3DRender` → 逐个 `CommandBuffer` 提交 |
| **管线类型** | Forward / Deferred / Custom | 主要 Forward |
| **渲染队列** | `RenderQueue`, `RenderInstancedQueue` | `BaseRender` 管理 `IRenderElement3D[]` |
| **可见性** | `SceneCulling` 显式剔除 | 集成在渲染遍历中 |

**Cocos FrameGraph 流程：**
```
RenderGraph 构建 → 资源依赖分析 → SceneCulling 剔除
    → ExecutorContext 分配 GPU 资源 → 并行录制 CommandBuffer → 提交
```

**Laya 渲染流程：**
```
RenderContext3D 每帧遍历 → Camera culling → 
    Laya3DRender.render() → BaseRender 排序 → CommandBuffer.submit()
```

**常见 Bug 诊断：**
- 某个 Pass 不渲染 → Cocos: FrameGraph 依赖链断了；Laya: BaseRender 没注册
- 渲染顺序错乱 → Cocos: RenderQueue 优先级；Laya: `renderQueue` 排序

### 7.3 剔除系统

| 剔除类型 | 原理 | Cocos Creator 4.0 | LayaAir 3.3 |
|---------|------|-------------------|-------------|
| **视锥剔除** | 物体包围盒完全在摄像机视锥外 → 不渲染 | `SceneCulling.frustumCulling()` | Camera 遍历时 AABB 检测 |
| **遮挡剔除** | 被前面物体完全挡住 → 不渲染 | 基于深度缓冲的 Occlusion Query | 无显式实现 |
| **LOD** | 远处用低模 | `LODGroup` 组件 | `HLOD` / `LODGroup` 组件 |

**常见 Bug：**
- 物体在屏幕边缘消失 → 包围盒计算偏小 / 视锥检测过于激进
- LOD 切换时有跳变 → LOD 距离阈值太近 / 缺少过渡混合

### 7.4 合批与实例化

| 概念 | 解释 | Cocos Creator 4.0 | LayaAir 3.3 |
|------|------|-------------------|-------------|
| **静态合批** | 不动的物体合并成一个大 Mesh | `StaticBatcher` | 编辑器预处理 |
| **动态合批** | 小 Mesh 动态合并 | `DynamicBatcher` | `SpineInstanceBatch` (针对性) |
| **GPU Instancing** | 一个 Draw Call 画多个相同物体 | `RenderInstancedQueue` + `InstancedBuffer` | `VertexBuffer.instanceBuffer` |

**Draw Call 过多诊断：**
- Cocos: 看 `RenderInstancedQueue` 是否启用 → 检查 Material 是否支持 instancing
- Laya: 看 `instanceBuffer` 是否激活 → 检查 VertexBuffer 的 `_instanceBuffer` 标记
- 通用: 同 Material 同 Mesh → 可合批；不同 Material → 需打断

### 7.5 组件系统

| 引擎 | 模式 | 添加方式 | 生命周期 |
|------|------|---------|---------|
| **Cocos** | `Node.addComponent<T>()`（类 Unity） | `node.addComponent(MyScript)` | `onLoad → start → update → onDestroy` |
| **Laya** | `ComponentDriver` 注册 | `node.addComponentIntance(component)` | `_addComponent → _init → _update → _destroy` |

**常见 Bug：**
- 组件 `update` 不调用 → 没加到正确节点 / 组件被禁用
- Cocos: `this.node` 为空 → `onLoad` 之前访问
- Laya: 组件 `owner` 没设置 → 忘记调用 `_setOwner`

### 7.6 资源生命周期

| 概念 | 解释 | 关键点 |
|------|------|--------|
| **引用计数** | 资源被引用时+1，释放时-1，归零才真释放 | `Asset.addRef()` / `Asset.decRef()` |
| **懒加载** | 用到才加载，不用不占内存 | 异步加载 → 回调设置 |
| **资源释放** | 场景切换时清理 | 注意：纹理/Mesh 可能被多个对象共享 |

**常见 Bug：**
- 切换场景后纹理变黑 → 资源被提前释放 / 引用计数为 0
- 内存泄漏 → 资源引用没释放（事件监听、闭包持有引用）
- Cocos: `resources.load()` 后的纹理需要手动 `release()`
- Laya: `Laya.loader.create()` → `texture.destroy()`

### 7.7 引擎架构差异速查表

| 场景 | Cocos Creator 4.0 做法 | LayaAir 3.3 做法 |
|------|------------------------|-------------------|
| 获取主摄像机 | `director.root.cameraList[0]` | `Scene3D._camera` |
| 遍历场景节点 | `scene.walk(node => ...)` | `scene._children` 递归 |
| 创建材质 | `new Material()` + `material.initialize({ effectAsset })` | `new Material()` + `material.setShaderName()` |
| 设置 RenderTexture | `camera.targetTexture = rt` | `RenderTexture` + `CommandBuffer.drawToRenderTexture2D()` |
| 强制更新变换 | `node.updateWorldTransform()` | `sprite._update()` |
| GPU Instancing | Material 勾选 `useInstancing` | `VertexBuffer.instanceBuffer = true` |

---

## 八、注意事项

1. **不要对用户抛概念** — 除非用户问"为什么"，否则优先用引擎术语回答
2. **诊断时先问问题** — 不要看一个模糊描述就给解决方案，按诊断树走
3. **概念是工具不是目的** — 用户只关心"怎么修好"，不关心 OpenGL，只在解释根因时引用
4. **跨引擎翻译** — 当用户说"Unity 里的 XXX"，用此知识库找到概念 ⮕ 翻译到目标引擎
