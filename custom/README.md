# Custom 目录

本目录包含所有自定义内容，与官方源码分离，便于版本升级时避免冲突。

## 目录结构

```
custom/
├── README.md          # 本文件
├── docs/              # 文档
│   ├── PATCHES.md                # 源码修改记录
│   └── CUSTOM-BUILD-GUIDE.md     # 完整使用指南
├── scripts/           # 脚本
│   └── rebuild-custom.sh         # 快速重新构建脚本
├── tools/             # 工具
├── plugins/           # 插件
└── logs/              # 日志
```

## 目录说明

### docs/
存放所有自定义文档：
- `PATCHES.md` - 记录所有源码修改，包括修改原因、位置、内容等
- `CUSTOM-BUILD-GUIDE.md` - 完整的使用、构建、升级指南

### scripts/
存放辅助脚本：
- `rebuild-custom.sh` - 快速重新构建和安装自定义版本

### tools/
存放自定义工具（未来可能添加）：
- 代码生成工具
- 自动化测试工具
- 部署工具等

### plugins/
存放自定义插件（未来可能添加）：
- OpenCode 插件
- 开发辅助插件等

### logs/
存放日志文件（已添加到 .gitignore）：
- 构建日志
- 测试日志
- 调试日志等

## 使用方式

### 查看文档
```bash
# 查看使用指南
cat custom/docs/CUSTOM-BUILD-GUIDE.md

# 查看修改记录
cat custom/docs/PATCHES.md
```

### 运行脚本
```bash
# 重新构建自定义版本
./custom/scripts/rebuild-custom.sh
```

## 版本升级

升级到新版本时，只需要：
1. 切换到新版本分支
2. `custom/` 目录内容不会产生冲突（除非官方也添加了同名目录）
3. 继续使用 `custom/` 中的文档和脚本

## Git 忽略规则

`custom/logs/` 目录已添加到 `.gitignore`，不会被提交到仓库。
其他 `custom/` 子目录的内容会被提交，以便多机同步。
