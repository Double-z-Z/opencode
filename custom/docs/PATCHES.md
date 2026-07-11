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

#### 2. 启用共享数据库

- **修改文件**: `packages/opencode/script/build.ts`
- **修改位置**: 第 199-200 行（在 define 对象中新增）
- **修改原因**: 
  - 两个版本需要共享会话数据，实现无缝切换
  - 当一个版本出现恶性 BUG 时，可以用另一个版本继续工作
  - 通过严格同步更新两个版本来避免兼容性问题
- **修改内容**:
  ```typescript
  define: {
    // ... 其他定义
    // 自定义：强制使用共享数据库，避免渠道隔离
    "process.env.OPENCODE_DISABLE_CHANNEL_DB": JSON.stringify("1"),
  }
  ```
- **实现效果**:
  - 官方版本：使用 `~/.local/share/opencode/opencode.db`
  - 自定义版本：也使用 `~/.local/share/opencode/opencode.db`（不再使用独立的 `opencode-custom-v1.17.18.db`）
  - 两个版本看到完全相同的会话列表
- **风险控制**:
  - ✅ **已禁用自动更新**：配置文件中设置 `"autoupdate": false`
  - ✅ **环境变量保护**：`export OPENCODE_DISABLE_AUTOUPDATE=1`
  - ✅ **数据备份**：所有数据已备份到 `~/opencode-backups/`
  - ✅ **版本锁定**：两个版本必须手动同步更新
  - ✅ **健康监控**：提供 `custom/scripts/check-database-health.sh` 监控脚本
- **使用方式**:
  ```bash
  # 正常使用，会话数据自动共享
  opencode .        # 使用官方版本
  opencode-dev .    # 使用自定义版本，看到相同的会话
  
  # 检查数据库健康
  ./custom/scripts/check-database-health.sh
  
  # 测试共享功能
  ./custom/scripts/test-shared-database.sh
  ```
- **Commit**: `e51a62a0c` - `custom: 强制使用共享数据库 - 原因：两个版本需要共享会话数据，通过同步更新来避免兼容性问题`
- **测试验证**: 
  1. 在官方版本中创建会话
  2. 在自定义版本中应该能看到同一会话
  3. 在任一版本中编辑会话，另一版本应该能看到更新
- **升级注意**: 
  - ⚠️ **关键**：升级时必须同时更新两个版本到相同的基础版本
  - ⚠️ 升级前必须备份数据库：`./custom/scripts/backup-database.sh`
  - ⚠️ 检查新版本的 Release Notes，确认没有破坏性的数据库迁移
  - ⚠️ 升级后运行健康检查：`./custom/scripts/check-database-health.sh`
- **回滚方案**:
  ```bash
  # 如果出现问题，可以回滚到隔离模式
  # 1. 从构建脚本中移除 OPENCODE_DISABLE_CHANNEL_DB 设置
  # 2. 重新构建自定义版本
  # 3. 从备份恢复数据库
  cp ~/opencode-backups/20260711-145145/opencode.db ~/.local/share/opencode/
  cp ~/opencode-backups/20260711-145145/opencode-custom-v1.17.18.db ~/.local/share/opencode/
  ```

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
