# OpenCode 自定义版本

这是一个自定义的 OpenCode 开发环境。

## 快速链接

📚 **文档**
- [使用指南](custom/docs/CUSTOM-BUILD-GUIDE.md) - 完整的使用、构建、升级指南
- [修改记录](custom/docs/PATCHES.md) - 所有源码修改的详细记录

🛠️ **脚本**
- [快速重新构建](custom/scripts/rebuild-custom.sh) - 一键重新构建和安装

📁 **目录说明**
- [Custom 目录](custom/README.md) - 自定义内容组织说明

## 快速开始

```bash
# 使用自定义版本
opencode-dev

# 使用官方版本
opencode

# 重新构建
./custom/scripts/rebuild-custom.sh
```

## 版本信息

- **自定义版本**: opencode-dev (基于 v1.17.18)
- **官方版本**: opencode
- **分支**: custom-v1.17.18
- **远程仓库**: https://github.com/Double-z-Z/opencode

## 目录结构

```
opencode/
├── custom/                    # 所有自定义内容
│   ├── README.md             # Custom 目录说明
│   ├── docs/                 # 文档
│   │   ├── PATCHES.md               # 修改记录
│   │   └── CUSTOM-BUILD-GUIDE.md    # 使用指南
│   ├── scripts/              # 脚本
│   │   └── rebuild-custom.sh        # 重新构建脚本
│   ├── tools/                # 工具
│   ├── plugins/              # 插件
│   └── logs/                 # 日志（不提交）
├── packages/                  # 官方源码
│   └── opencode/
│       └── script/
│           └── build.ts      # 构建脚本（已修改）
└── CUSTOM.md                 # 本文件
```

## 工作流程

1. 修改源码
2. 在 `custom/docs/PATCHES.md` 中记录修改
3. 提交：`git commit -m "custom: <说明> - 原因：<原因>"`
4. 重新构建：`./custom/scripts/rebuild-custom.sh`
5. 测试验证
6. 推送：`git push --no-verify`

---

详细文档请查看 [使用指南](custom/docs/CUSTOM-BUILD-GUIDE.md)
