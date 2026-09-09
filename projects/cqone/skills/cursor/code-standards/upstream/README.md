# upstream — skill 自持规范快照

本目录由 `code-standards` skill **自行维护**，供 Agent 读取。  
**不要**再依赖 `C:/myPro/doc`（SVN，可能被覆盖）。

| 文件 | 用途 |
|------|------|
| `代码规范.md` | 命名/注释/方法等权威正文 |
| `代码规范-idea设置.md` | IDEA 格式化与检查导入说明 |
| `idea-code-style.xml` | Code Style 导入（idea设置引用） |
| `idea-inspections.xml` | Inspections 导入（idea设置引用） |

## 如何与 SVN doc 同步

仅在你**确认** `C:/myPro/doc` 有意更新、且要灌进 skill 时：

```bat
copy /Y C:\myPro\doc\代码规范.md C:\Users\lu\.cursor\skills\code-standards\upstream\
copy /Y C:\myPro\doc\代码规范-idea设置.md C:\Users\lu\.cursor\skills\code-standards\upstream\
copy /Y C:\myPro\doc\idea-code-style.xml C:\Users\lu\.cursor\skills\code-standards\upstream\
copy /Y C:\myPro\doc\idea-inspections.xml C:\Users\lu\.cursor\skills\code-standards\upstream\
```

日常编码以本目录 + skill 的 `SKILL.md` / `reference.md` 为准；skill 侧增量约定（如 UI 后缀、红点）写在 skill 内，不必回写 SVN。
