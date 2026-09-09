# 代码格式化规则
设置路径：File | Settings | Editor | Code Style  
导入：同目录 `idea-code-style.xml`（本 upstream 快照）

# 代码检查规则
设置路径：File | Settings | Editor | Inspections  
导入：同目录 `idea-inspections.xml`

# 开启ESLint
设置路径：File | Settings | Languages & Frameworks | JavaScript | Code Quality Tools | ESLint
勾选：Automatic ESLint Configuration

ESLint规则参见项目中的.eslintrc.json

# ts文件头
设置路径：File | Settings | Editor | File and Code Templates -> TypeScript File
```ts
/**
 * @author caijinhui
 * @since ${YEAR}-${MONTH}-${DAY}
 */

```
@author后面改为自己的姓名

（cqone 业务新文件以 skill / IDEA「CQ File Header」为准：`@author zhangyongkang`。）
