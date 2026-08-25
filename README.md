# TG Panel UI Prototype

这是一个 iOS 26 SwiftUI Liquid Glass 界面原型，当前只使用本地演示数据。

Liquid Glass 组件模式参考并适配自 [GlobalRefresh-PiP](https://github.com/Yoroin/GlobalRefresh-PiP)，保留原作者 CaiWanFeng 与维护者 Yoroin 的署名，详见 `NOTICE`。只复用了 UI 玻璃效果写法，没有引入参考项目的 PiP、高刷或后台保活业务逻辑。

## SwiftUI 文件

将 `swift/` 目录中的 5 个文件加入一个新的 iOS App 项目：

- `TGPanelApp.swift`
- `Models.swift`
- `Theme.swift`
- `Components.swift`
- `Views.swift`

项目 Deployment Target 设置为 iOS 26.0。源码使用 iOS 26 的 `glassEffect`、`GlassEffectContainer` 兼容 API 方向和 `.buttonStyle(.glass)`。

## 当前范围

- 概览页
- 账号列表和搜索
- 账号详情 Sheet
- 设置页
- 本地演示数据

当前没有真实网络请求，不会连接 VPS，也不会执行 Telegram 操作。后续接入时，建议新增 `APIClient.swift` 和 `AccountStore.swift`，保持现有 View 只依赖账号模型与 Store。

## 浏览器预览

直接打开同级目录的 `index.html`，或从 Minis 工作区打开：

`minis://workspace/tg-panel-ui/index.html`
