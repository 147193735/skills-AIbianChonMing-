# AI 技能仓库安装入口

新电脑只需让 AI 阅读本文件，然后在仓库根目录执行统一安装脚本。

## Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-all.ps1
```

如果需要覆盖已有的同名配置，必须明确使用：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-all.ps1 -ReplaceExisting
```

## 安装内容

- Cursor 通用技能和规则：`skills/`、`.cursor/rules/`
- 项目专属技能：安装脚本会列出 `projects/` 下所有可安装项目，询问安装哪些项目；可以全部跳过。

`skills/deprecated/` 不安装。项目技能不会通过根目录通用安装器混入通用技能库。

## 安全约定

- 默认保留目标目录中已有的普通文件；发现冲突时停止并报告。
- 只有用户明确要求覆盖时才使用 `-ReplaceExisting`。
- 安装脚本只创建或更新技能链接/提示文件，不修改项目源代码。

## 验证位置

- Cursor：`%USERPROFILE%\.cursor\skills`、`%USERPROFILE%\.cursor\rules`
- Codex：`%USERPROFILE%\.codex\skills`
- VS Code：`%APPDATA%\Code\User\prompts`

安装完成后重启对应软件，使新技能被重新发现。

运行统一脚本时，项目选择规则如下：

- 输入 `N`：不安装任何项目专属技能
- 输入单个编号：安装一个项目
- 输入 `1,2`：安装多个项目
