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

| OpenGL | Unity | Unreal | Godot | Cocos Creator 4.0 | LayaAir 3.3 |
|--------|-------|--------|-------|-------------------|-------------|
| VAO+VBO | Mesh.vertices | FStaticMeshVertexBuffer | ArrayMesh | InputAssembler + Buffer(Vertex) | VertexBuffer + VertexDeclaration |
| FBO | RenderTexture | SceneCaptureComponent | ViewportTexture | Framebuffer + RenderPass | RenderTexture |
| Depth Test | ZWrite/ZTest | Depth Stencil State | depth_draw_mode | DepthStencilState.depthTest | RenderStateType.DepthTest |
| Blend | Blend 命令 | Blend Mode | blend_mode | BlendState + BlendTarget | BlendState + BlendComponent |
| Mipmap | Generate Mip Maps | Texture Mip Gen | mipmaps | TextureFlagBit.GEN_MIPMAP | FilterMode (Point/Bilinear/Trilinear) |
| Shadow Map | Shadow settings | Light Mobility | Shadow settings | shadow/shadow-flow.ts + CSM | ShadowCasterPass |
| Uniform | Material.SetFloat() | Material Parameter | shader.set_shader_parameter() | DescriptorSet + PipelineLayout | Material.setFloat() |
| Instancing | GPU Instancing | ISMC Instancing | MultiMeshInstance | instanced-buffer | VertexBuffer.instanceBuffer |
| Stencil | Stencil 命令 | Stencil Buffer | — | DepthStencilState.stencilTest* | StencilState |
| Face Culling | Cull 命令 | Two Sided | cull_mode | CullMode (NONE/FRONT/BACK) | CullMode (Off/Front/Back) |
| Texture Wrap | Wrap Mode | Texture Addressing | wrap_mode | Address (WRAP/MIRROR/CLAMP) | WrapMode (Repeat/Clamp/Mirrored) |
| Depth Bias | Depth Bias | Shadow Bias | depth_bias | RasterizerState.depthBias | ShadowMap.bias |

## 引擎架构概念（游戏开发必备）

### 场景图与变换
- **场景图**：树形结构组织物体，父子节点变换级联
- Cocos: `Scene → Node → children[]`  |  Laya: `Scene → Sprite → _children`
- 脏标记优化：只有变了才重算世界矩阵

### 渲染管线架构
- Cocos: **FrameGraph** 声明式 — `RenderGraph → ExecutorContext → SceneCulling`
- Laya: **命令式** — `RenderContext3D → Laya3DRender → CommandBuffer`
- 常见 Bug: Pass 不渲染 → FrameGraph 依赖链断了 / BaseRender 没注册

### 剔除系统
- 视锥剔除：包围盒在视锥外 → 不渲染
- Cocos: `SceneCulling.frustumCulling()`  |  Laya: Camera 遍历时 AABB 检测
- LOD: 远处用低模 → `LODGroup`(Cocos) / `HLOD`(Laya)

### 合批与实例化
- 静态合批：不动物体合并 Mesh
- GPU Instancing：一个 Draw Call 画多个相同物体
- Cocos: `RenderInstancedQueue`  |  Laya: `VertexBuffer.instanceBuffer`

### 组件系统
- Cocos: `Node.addComponent<T>()` → `onLoad → start → update`
- Laya: `ComponentDriver` → `_addComponent → _init → _update`

### 资源生命周期
- 引用计数：`addRef/decRef` → 归零才释放
- 常见 Bug: 切换场景纹理变黑 → 资源被提前释放

### 引擎差异速查
| 场景 | Cocos Creator 4.0 | LayaAir 3.3 |
|------|-------------------|-------------|
| 获取摄像机 | `director.root.cameraList[0]` | `Scene3D._camera` |
| 创建材质 | `new Material()` + `initialize({effectAsset})` | `new Material()` + `setShaderName()` |
| GPU Instancing | Material 勾选 `useInstancing` | `VertexBuffer.instanceBuffer = true` |

## 关键公式
- MVP = P × V × M（右乘）→ gl_Position
- N·L = cos(θ) → 漫反射强度
- H = normalize(L+V) → Blinn-Phong 半程向量
- Blend: Result = Src×Fsrc + Dst×Fdst

## 使用原则
1. 优先用引擎术语回答，除非用户问"为什么"
2. 诊断时先追问缩小范围，不要直接给方案
3. 配合 CodeGraph 查引擎源码定位具体实现
