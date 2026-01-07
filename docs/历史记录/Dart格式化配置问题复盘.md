# Dart 格式化配置问题复盘

## 问题现象

打开 Flutter/Dart 文件时，IDE 反复弹出 "正在运行 Dart 格式化程序 (configure)" 提示，导致编辑器卡住。

## 问题原因

本项目是 **monorepo 结构**，`app_flutter` 是一个独立的 Flutter 子项目：

```
project-root/
├── .vscode/settings.json    ← 根目录配置
├── server-nestjs/
├── web/
└── app_flutter/             ← Flutter 子项目（独立工作区）
    └── lib/
```

当直接在根目录打开整个 monorepo 时：
- 根目录的 `.vscode/settings.json` 对 `app_flutter` 内的 Dart 文件**不生效**
- Dart 扩展找不到格式化器配置，每次保存都会弹出配置提示

## 解决方案

在 `app_flutter` 目录下创建独立的 VS Code 配置：

```bash
app_flutter/.vscode/settings.json
```

配置内容：

```json
{
    "[dart]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "Dart-Code.dart-code"
    },
    "dart.enableSdkFormatter": true
}
```

## 经验总结

1. **Monorepo 中的子项目需要独立配置** - 特别是使用不同技术栈的子项目（如 Flutter、Node.js、前端）
2. **Dart 扩展的配置作用域** - Dart-Code 扩展会优先读取 Dart 项目所在目录的 `.vscode/settings.json`
3. **排查思路** - 当 IDE 配置不生效时，检查配置文件是否在正确的目录层级

## 相关文件

- 根目录配置：`.vscode/settings.json`
- Flutter 项目配置：`app_flutter/.vscode/settings.json`
