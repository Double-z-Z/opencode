# OpenCode 自定义补丁记录

本文档记录所有对 OpenCode 源码的自定义修改，便于版本升级时重新应用补丁。

## 当前版本

**基础版本**: v1.17.18  
**自定义分支**: custom-v1.17.18  
**构建日期**: 2026-07-11

---

## 补丁列表

#### 1. 支持自定义可执行文件名

- **修改文件**: `packages/opencode/script/build.ts`
- **修改位置**: 第 26 行（新增变量）、第 184 行、第 204 行（使用变量）
- **修改原因**: 
  - 需要同时使用自编译版本和官方 npm 安装的 opencode
  - 两个版本不应该互相冲突，但可以共享会话数据
  - 当一个版本出现问题时，可以使用另一个版本来解决问题
- **修改内容**:
  ```typescript
  // 新增环境变量支持
  const customBinaryName = process.env.OPENCODE_BINARY_NAME || "opencode"
  
  // 修改输出文件名
  outfile: `dist/${name}/bin/${customBinaryName}`,
  
  // 修改测试路径
  const binaryPath = `dist/${name}/bin/${customBinaryName}`
  ```
- **使用方式**:
  ```bash
  # 构建自定义名称的可执行文件
  OPENCODE_BINARY_NAME=opencode-dev bun run script/build.ts --single
  
  # 安装到用户 PATH
  cp packages/opencode/dist/opencode-linux-x64/bin/opencode-dev ~/.local/bin/
  ```
- **Commit**: `45091dd4f` - `custom: 支持通过环境变量自定义可执行文件名 - 原因：避免与官方npm安装的opencode冲突，便于同时使用两个版本`
- **测试验证**: 
  - 构建完成后运行 `opencode-dev --version` 验证版本号
  - 同时运行 `opencode --version` 和 `opencode-dev --version` 验证两者共存
- **升级注意**: 
  - 这是构建系统的修改，不涉及运行时逻辑
  - 新版本升级时需要重新应用此补丁
  - 如果构建脚本结构变化较大，可能需要手动调整

---

## 版本升级检查清单

升级到新版本时，请逐项检查：

- [ ] 查看新版本的 CHANGELOG 或 Release Notes
- [ ] 检查新版本是否已包含你的修改（如果是，可以移除相应补丁）
- [ ] 检查新版本的修改是否与你的补丁冲突
- [ ] 逐个应用补丁，使用 `git cherry-pick` 或手动重新实现
- [ ] 每个补丁应用后进行测试验证
- [ ] 更新本文档的"当前版本"信息
- [ ] 重新构建并测试自定义版本

---

## 相关命令

```bash
# 查看所有自定义提交
git log --oneline --grep="custom:"

# 对比两个版本的自定义修改
git log custom-v1.17.18..custom-v1.18.0 --oneline --grep="custom:"

# Cherry-pick 特定修改到新分支
git cherry-pick <commit-hash>

# 生成补丁文件（备用方案）
git format-patch -1 <commit-hash>
```
