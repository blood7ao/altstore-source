# Chat App AltStore 源

这个项目提供 Chat App 的 **AltStore Classic Source**：

- `apps.json` 由 GitHub Pages 托管，作为 AltStore 的 Source URL。
- `.ipa` 文件上传到 GitHub Releases，不提交到 Git 仓库。
- Chat App 的 `build_ipa.sh` 会自动构建 IPA、创建 Release、上传 IPA，并更新 `apps.json`。

> 这是给 AltStore Classic（支持直接下载 IPA）的模板。AltStore PAL 使用的是 ADP/`manifest.json` 分发流程，不能直接把这里的 IPA URL 当成 PAL 的下载地址。

## 目录结构

```text
altstore-source/
├── apps.json             # AltStore Source JSON
├── assets/
│   └── README.md         # 图标和截图放置说明
└── README.md
```

## 当前 App

当前源已配置 Chat App：

- Bundle ID：`com.teddy.chatapp`
- 当前版本：`1.0.7 (7)`
- GitHub 仓库：[blood7ao/altstore-source](https://github.com/blood7ao/altstore-source)

## 第一次使用

### 1. 创建 GitHub 仓库

仓库已经创建。后续如果重新初始化本地源，可执行：

```bash
cd /Users/teddy/soft/altstore-source
git init
git add .
git commit -m "Initialize AltStore source"
git branch -M main
git remote add origin https://github.com/blood7ao/altstore-source.git
git push -u origin main
```

### 2. 开启 GitHub Pages

在仓库的 **Settings → Pages** 中选择：

- **Source**：Deploy from a branch
- **Branch**：`main`
- **Folder**：`/ (root)`

部署完成后，Source URL 是：

```text
https://blood7ao.github.io/altstore-source/apps.json
```

在 AltStore 的 **Add Source** 中添加这个 Pages 地址。不要使用 GitHub 的 `blob` 页面地址。

### 3. 自动发布 IPA

在 `chat_app` 目录直接运行：

```bash
cd /Users/teddy/soft/Silly/chat_app
./build_ipa.sh --export-method ad-hoc
```

脚本会自动：

- 递增 Chat App 版本号和构建号；
- 校验 IPA 内的 Bundle ID、版本号和构建号；
- 创建或更新 `chatapp-vX.Y.Z` GitHub Release；
- 上传 `ChatApp-vX.Y.Z.ipa`；
- 更新 `apps.json` 的最新版本、下载地址和文件大小；
- 提交并推送源配置。

首次使用需要本机完成一次 `gh auth login`，之后不需要手动管理 Release 或 `apps.json`。

## 需要替换的字段

编辑 `apps.json` 中的示例 App，至少替换下面这些内容：

| 字段 | 填什么 |
| --- | --- |
| `name` | Source 或 App 的显示名称 |
| `iconURL` | 可公开访问的 PNG/JPG 图标地址 |
| `website` | 你的项目主页或 GitHub 仓库地址 |
| `bundleIdentifier` | IPA 的 `CFBundleIdentifier`，必须完全一致且区分大小写 |
| `developerName` | 开发者名称 |
| `localizedDescription` | App 介绍 |
| `category` | `developer`、`entertainment`、`games`、`lifestyle`、`other`、`photo-video`、`social` 或 `utilities` |
| `version` | IPA 的 `CFBundleShortVersionString` |
| `buildVersion` | IPA 的 `CFBundleVersion` |
| `date` | ISO 8601 日期，例如 `2026-08-16` |
| `downloadURL` | GitHub Release 中 IPA 附件的公开直链 |
| `size` | IPA 文件大小，单位是字节 |
| `entitlements` | IPA 使用的非系统必需 entitlements |
| `privacy` | `Info.plist` 中实际使用的 `UsageDescription` 字段及文案 |

图标和截图可以放进仓库的 `assets/`，然后使用 Pages 地址引用，例如：

```text
https://YOUR_GITHUB_USERNAME.github.io/altstore-source/assets/app-icon.png
```

当前配置中的应用标识、图标地址和权限已与 Chat App 的 iOS 工程保持一致。

## 手动发布（不推荐）

推荐始终使用 `chat_app/build_ipa.sh`，避免版本号、下载地址和文件大小不一致。

例如：

```json
"versions": [
  {
    "version": "1.1.0",
    "buildVersion": "2",
    "date": "2026-09-01",
    "localizedDescription": "修复问题并优化启动速度。",
    "downloadURL": "https://github.com/blood7ao/altstore-source/releases/download/chatapp-v1.1.0/ChatApp-v1.1.0.ipa",
    "size": 13000000
  },
  {
    "version": "1.0.0",
    "buildVersion": "1",
    "date": "2026-08-16",
    "localizedDescription": "首次发布。",
    "downloadURL": "https://github.com/blood7ao/altstore-source/releases/download/chatapp-v1.0.0/ChatApp-v1.0.0.ipa",
    "size": 12345678
  }
]
```

AltStore 会把 `versions[0]` 当作当前最新版本，所以新版本必须放在数组最前面。

## 本地检查

提交前可以检查 JSON 语法：

```bash
cd ~/soft/altstore-source
python3 -m json.tool apps.json >/dev/null && echo "apps.json syntax OK"
```

JSON 语法正确不代表 IPA 一定能安装。发布后还要确认：

1. 在浏览器中可以直接打开 Pages 的 `apps.json`。
2. `downloadURL` 不会跳转到登录页，并能下载到 IPA。
3. `bundleIdentifier`、版本号、build 号和 IPA 内的 `Info.plist` 一致。
4. 图标和截图 URL 可以公开访问。

## 可选：使用 AltSource CLI

AltServer for macOS 提供了实验性的 `altsource` 工具，可以根据 IPA 自动创建或更新部分 Source 信息。无论是否使用它，仍应人工检查 `bundleIdentifier`、版本号、下载地址、权限和隐私说明。

## 注意事项

- GitHub Releases 的 IPA 必须公开，否则手机上的 AltStore 无法下载。
- 不要把 Apple ID、证书私钥、`.p12`、`.mobileprovision` 或其他敏感文件提交到仓库。
- 免费 Apple ID 的 AltStore Classic 侧载应用仍受 Apple 的签名有效期和设备数量限制；自建 Source 只负责提供元数据和下载地址。
- 如果 IPA 不是你自己开发或没有合法分发权限，请不要通过公开 Source 分发。
