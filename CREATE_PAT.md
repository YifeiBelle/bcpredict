# 创建 GitHub 个人访问令牌 (PAT)

按照以下步骤创建 PAT，用于上传 R 包到 GitHub。

1. 登录 GitHub 网站：https://github.com
2. 点击右上角头像 → **Settings** (设置)
3. 左侧边栏最下方 → **Developer settings**
4. 左侧 → **Personal access tokens** → **Tokens (classic)**
5. 点击 **Generate new token** → **Generate new token (classic)**
6. 填写备注 (Note)，例如 "bcpredict upload"
7. 选择过期时间 (Expiration)：建议 **90 days** 或 **No expiration**（根据你的安全策略）
8. 勾选权限 (Scopes)：
   - **repo** (全选) – 允许读写仓库
   - **write:packages** (可选)
   - **delete_repo** (可选)
   - 至少需要 **repo** 权限
9. 点击 **Generate token**
10. **复制生成的令牌**（一串以 `ghp_` 开头的字符），并立即保存到安全的地方。关闭页面后将无法再次查看。

## 使用 PAT 进行认证

### 方法一：GitHub CLI
在终端中运行（将 `YOUR_TOKEN` 替换为实际令牌）：
```bash
gh auth login --with-token <<< "YOUR_TOKEN"
```

### 方法二：Git 凭据
在 Git 命令中使用令牌作为密码：
```bash
git remote add origin https://YOUR_TOKEN@github.com/YifeiBelle/bcpredict.git
```
或使用 Git 凭据管理器存储令牌：
```bash
git config --global credential.helper manager
git push
```
系统会提示输入用户名和密码，用户名是你的 GitHub 用户名，密码就是令牌。

## 继续上传
获得令牌后，返回并运行上传脚本。