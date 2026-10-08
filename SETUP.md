# AI 技能仓库安装入口

**本文件是新电脑的唯一入口。** 让 AI 阅读本文件，即可完成全部安装。

本仓库是**多平台 AI 技能分发仓库**：仓库内保存技能源文件，通过 Junction/符号链接挂载到
各 AI 工具的用户级技能目录。因此 `git pull` 后各工具的技能会自动更新，无需重装。

> 脚本使用 `$PSScriptRoot` 相对定位，**不依赖仓库路径**——克隆到任意位置
> （如 `C:\skills-AIbianChonMing-`）均可正常工作。

## AI 执行清单

1. 克隆本仓库（见「前置条件」）。
2. 在仓库根目录运行 `.\scripts\install-all.ps1`。
   脚本会列出 `projects/` 下的可安装项目并询问编号——按需选择（安装 cqone 则输入其编号）或输入 `N` 跳过。
3. 若脚本报告「拒绝替换非链接路径」而停止，**先向用户确认目标可被替换**，再决定是否加 `-ReplaceExisting`。
   不要擅自覆盖用户已有文件。
4. 提示用户**重启**对应软件（Cursor / Codex / VS Code / WorkBuddy / CodeBuddy），使技能被重新发现。
5. 按「验证位置」核对链接是否就位。
6. （可选）若还需要代码知识图谱能力，按「配套：CodeGraph MCP」另行配置。

## 前置条件

1. 克隆本仓库到任意位置：

   ```bash
   git clone https://github.com/147193735/skills-AIbianChonMing-.git
   ```

2. Windows PowerShell 5.1+（系统自带）。
3. 创建 Junction 链接通常无需管理员权限；若被拒绝，脚本自动降级为复制并给出提示。

## 一条命令完成安装

在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-all.ps1
```

需要覆盖已有的同名配置时（**先确认目标可被替换**）：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-all.ps1 -ReplaceExisting
```

## 安装内容

### 通用技能（对所有项目生效）

| 目标 | 内容 | 来源 |
| --- | --- | --- |
| Cursor | 技能 + 规则 | `skills/`、`.cursor/rules/` |

由 `scripts/install-cursor-global.ps1` 完成。通用内容保持项目无关；项目专属技能**不会**
通过根目录通用安装器混入通用技能库。`skills/deprecated/` 不安装。

### 项目专属技能

统一脚本会列出 `projects/` 下所有可安装项目并询问，可全部跳过。

`projects/cqone/` 支持 **5 个平台**，各有独立安装器，统一脚本会依次全部调用：

| 平台 | 安装器 | 目标目录 | 技能数 |
| --- | --- | --- | ---: |
| Cursor | `install-cursor.ps1` | `%USERPROFILE%\.cursor\skills`、`.cursor\rules` | 8 |
| Codex | `install-codex.ps1` | `%USERPROFILE%\.codex\skills` | 9 |
| VS Code / Copilot | `install-vscode.ps1` | `%APPDATA%\Code\User\prompts`、`%USERPROFILE%\.copilot\skills` | 8 |
| WorkBuddy | `install-workbuddy.ps1` | `%USERPROFILE%\.workbuddy\skills` | 9 |
| CodeBuddy | `install-codebuddy.ps1` | `%USERPROFILE%\.codebuddy\skills` | 9 |

> WorkBuddy / CodeBuddy / Codex 三者的技能**规则正文一致**（后两者由 `codex` 变体派生，
> 仅调整平台路径），保证跨工具行为一致。

## 安全约定

- 默认保留目标目录中已有的普通文件；发现冲突时**停止并报告**。
- 只有用户明确要求覆盖时才使用 `-ReplaceExisting`。
- 安装脚本只创建或更新技能链接/提示文件，**不修改项目源代码**。
- 卸载：删除目标目录下对应的 Junction 即可，仓库源文件不受影响。

## 验证位置

- Cursor：`%USERPROFILE%\.cursor\skills`、`%USERPROFILE%\.cursor\rules`
- Codex：`%USERPROFILE%\.codex\skills`
- WorkBuddy：`%USERPROFILE%\.workbuddy\skills`
- CodeBuddy：`%USERPROFILE%\.codebuddy\skills`
- VS Code：`%APPDATA%\Code\User\prompts`
- VS Code Copilot skills：`%USERPROFILE%\.copilot\skills`

安装完成后**重启对应软件**，使新技能被重新发现。

## 项目选择规则

运行统一脚本时：

- 输入 `N`：不安装任何项目专属技能
- 输入单个编号：安装一个项目
- 输入 `1,2`：安装多个项目

## 配套：CodeGraph MCP（独立仓库，可选）

代码知识图谱（`codegraph_explore` 工具）来自**另一个仓库**，不随本仓库安装：

- 仓库：`https://github.com/147193735/codegraph-jianShaoYoken-.git`
- 配置方式：在该仓库运行 `CodeGraph 快速工具.bat` → 主菜单 `[12] 配置 MCP (多平台)`
- 已支持：VS Code / Cursor / Codex / **WorkBuddy** / **CodeBuddy** 的全局 MCP 配置

没有它技能也能用，只是 `laya-fgui-engine-source`、`code-check` 等技能会退化为
`rg` + 文件读取的慢路径。

## 已知注意事项

- `projects/cqone/skills/*/laya-module-scaffold/IDEA.md` 中的 IDEA External Tool 参数是
  **绝对路径**。若仓库不在 `C:\myGit\skills-AIbianChonMing-`，需按实际位置修改后再在
  IDEA 中配置该外部工具。
- 部分技能正文内含平台相关路径示例（如 `code-standards/upstream/README.md`）。
  各平台变体目录（`codex` / `workbuddy` / `codebuddy`）已按各自安装位置适配，无需手工修改。
