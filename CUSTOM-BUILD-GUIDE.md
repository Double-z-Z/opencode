# OpenCode 自定义构建使用指南

本文档说明如何使用和维护你的 OpenCode 自定义版本。

## 版本信息

- **基础版本**: v1.17.18
- **自定义分支**: `custom-v1.17.18`
- **可执行文件名**: `opencode-dev`
- **官方版本**: `opencode` (通过 npm/brew 安装)

## 已安装位置

- **自定义版本**: `~/.local/bin/opencode-dev`
- **官方版本**: `~/.opencode/bin/opencode`

两个版本可以共存，不会互相冲突，并且共享会话数据。

---

## 日常使用

### 启动自定义版本

```bash
# 直接运行
opencode-dev

# 在特定目录启动
opencode-dev /path/to/project

# 查看版本
opencode-dev --version
```

### 启动官方版本

```bash
# 直接运行
opencode

# 查看版本
opencode --version
```

### 会话数据共享

两个版本共享相同的配置和会话数据，位于：
- 配置: `~/.config/opencode/`
- 数据: `~/.local/share/opencode/`

---

## 进行源码修改

### 1. 修改代码

在 `/home/dz-fedora/workspace/opencode` 中修改源码。

### 2. 记录修改

每次修改后，在 `PATCHES.md` 中添加详细记录：

```markdown
#### N. [修改名称]

- **修改文件**: `packages/xxx/src/xxx.ts`
- **修改位置**: 第 XX 行
- **修改原因**: 详细说明
- **修改内容**: 代码片段
- **使用方式**: 如何使用这个修改
- **Commit**: commit hash 和 message
- **测试验证**: 如何验证
- **升级注意**: 注意事项
```

### 3. 提交修改

```bash
# 提交格式：custom: <修改说明> - 原因：<为什么要修改>
git add <files>
git commit -m "custom: 增加XXX功能 - 原因：解决YYY问题"
```

### 4. 重新构建

```bash
cd packages/opencode
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single
```

### 5. 安装新版本

```bash
cp packages/opencode/dist/opencode-linux-x64/bin/opencode-dev ~/.local/bin/
chmod +x ~/.local/bin/opencode-dev
```

### 6. 验证

```bash
opencode-dev --version
# 测试你的修改
```

---

## 版本升级流程

当官方发布新版本（如 v1.18.0）时：

### 1. 获取新版本 tags

```bash
cd /home/dz-fedora/workspace/opencode
git fetch --tags origin
```

### 2. 查看新版本

```bash
# 查看可用的新版本
git tag -l 'v1.*' | grep -E '^v1\.[0-9]+\.[0-9]+$' | sort -V | tail -10

# 查看新版本的变更
git log v1.17.18..v1.18.0 --oneline
```

### 3. 创建新的自定义分支

```bash
# 基于新版本创建分支
git checkout -b custom-v1.18.0 v1.18.0
```

### 4. 查看旧分支的自定义修改

```bash
# 查看所有自定义提交
git log custom-v1.17.18 --oneline --grep="custom:"

# 查看 PATCHES.md
git show custom-v1.17.18:PATCHES.md
```

### 5. 应用补丁

有两种方式：

#### 方式 A: Cherry-pick（推荐）

```bash
# Cherry-pick 特定的提交
git cherry-pick <commit-hash>

# 如果有冲突，解决后继续
git add <resolved-files>
git cherry-pick --continue
```

#### 方式 B: 手动重新实现

参考 `PATCHES.md` 中的记录，手动重新实现每个修改。

### 6. 更新 PATCHES.md

```bash
# 更新当前版本信息
# 修改 PATCHES.md 中的：
# - 基础版本: v1.18.0
# - 自定义分支: custom-v1.18.0
# - 构建日期: <当前日期>

git add PATCHES.md
git commit -m "docs: update PATCHES.md for v1.18.0"
```

### 7. 构建新版本

```bash
cd packages/opencode
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single
```

### 8. 安装并测试

```bash
cp packages/opencode/dist/opencode-linux-x64/bin/opencode-dev ~/.local/bin/
chmod +x ~/.local/bin/opencode-dev
opencode-dev --version
# 全面测试所有自定义功能
```

### 9. 推送到远程仓库

```bash
git push mine custom-v1.18.0
```

---

## 备份与恢复

### 备份当前分支

```bash
# 推送到远程仓库（当网络稳定时）
git push mine custom-v1.17.18

# 或创建本地备份
git bundle create ~/opencode-custom-v1.17.18.bundle custom-v1.17.18
```

### 恢复备份

```bash
# 从远程仓库拉取
git fetch mine
git checkout custom-v1.17.18

# 或从 bundle 恢复
git clone ~/opencode-custom-v1.17.18.bundle opencode-restored
```

---

## 故障排除

### 官方版本出问题时

使用自定义版本：
```bash
opencode-dev
```

### 自定义版本出问题时

切换回官方版本：
```bash
opencode
```

### 回退到旧版本

```bash
# 查看历史版本
git log --oneline

# 回退到特定提交
git checkout <commit-hash>

# 重新构建
cd packages/opencode
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single
cp dist/opencode-linux-x64/bin/opencode-dev ~/.local/bin/
```

### 推送到远程仓库失败

```bash
# 检查 SSH 连接
ssh -T git@github.com

# 如果需要，切换到 HTTPS
git remote set-url mine https://github.com/Double-z-Z/opencode.git
git push mine custom-v1.17.18
```

---

## 常用命令速查

```bash
# 查看当前分支和状态
git status
git branch -vv

# 查看自定义提交历史
git log --oneline --grep="custom:"

# 查看与官方版本的差异
git diff v1.17.18..HEAD

# 查看与官方最新 dev 分支的差异
git fetch origin dev
git diff origin/dev..HEAD

# 查看远程仓库
git remote -v

# 构建自定义版本
cd packages/opencode
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single

# 快速构建（跳过 Web UI，更快）
OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single --skip-embed-web-ui
```

---

## 重要提醒

1. **每次修改源码后**，必须更新 `PATCHES.md`
2. **Commit message 格式**：`custom: <说明> - 原因：<原因>`
3. **定期推送**到远程仓库备份（当网络稳定时）
4. **版本升级前**，先查看官方 Release Notes
5. **测试充分**后再替换生产环境的二进制文件

---

## 相关文件

- `PATCHES.md` - 修改记录文档
- `packages/opencode/script/build.ts` - 构建脚本（已修改）
- `~/.local/bin/opencode-dev` - 自定义版本可执行文件
- `~/.opencode/bin/opencode` - 官方版本可执行文件

---

## 获取帮助

- OpenCode 官方文档: https://opencode.ai/docs
- 官方 GitHub: https://github.com/anomalyco/opencode
- 你的 Fork: https://github.com/Double-z-Z/opencode
- Discord: https://opencode.ai/discord
