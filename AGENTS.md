# Pica - Objective-C iOS 项目

## 项目概览
- **语言**: Objective-C（无 Swift）
- **平台**: iOS 13.0+
- **依赖管理**: CocoaPods
- **UI 框架**: QMUIKit（主要），自定义主题系统 `PCThemeManager`
- **网络层**: YTKNetwork，带 HMAC-SHA256 签名
- **JSON 解析**: YYModel
- **图片加载**: SDWebImage
- **WebSocket**: SocketRocket
- **本地数据库**: GYDataCenter/FMDB
- **下拉刷新**: MJRefresh
- **分页视图**: JXPagingView
- **统计**: 友盟 (UMCommon, UMDevice, UMAPM)

## 构建与运行
```bash
# 安装依赖
pod install

# 打开工作区（不是 .xcodeproj）
open Pica.xcworkspace
```

**重要**: 必须打开 `Pica.xcworkspace`，不能打开 `Pica.xcodeproj`——CocoaPods 需要工作区。

## 项目结构
```
Pica/
├── Application/     # AppDelegate，主入口
├── Login/           # 登录流程、注册、TabBar
├── Category/        # 漫画浏览、搜索、评论、排行榜
├── Chat/            # WebSocket 聊天（旧版 OldChat + 新版 NewChat）
├── Game/            # 游戏模块
├── NSFW/            # NSFW 内容（默认关闭，需下载资源）
├── Setting/         # 用户设置、主题颜色、聊天设置
├── User/            # 个人资料、收藏、历史
├── Common/          # 公共工具
│   ├── Category/    # ObjC 分类（扩展）
│   ├── Class/       # PCSocket、PCLocalAuthentication、PCSpeechSynthesizer
│   ├── Configuration/ # 主题、UI 辅助、PCThemeManager
│   ├── Controller/  # 基础视图控制器 (PCViewController, PCTableViewController)
│   ├── Request/     # PCRequest 基类
│   └── View/        # 基础 TableViewCell
├── Header/          # 全局头文件 & API 常量
│   ├── PCAPIHeader.h      # API 端点定义
│   ├── PCLocalKeyHeader.h # 本地存储 key 常量
│   ├── PCDefineHeader.h   # 宏定义 (weakify/strongify)
│   ├── PCIconHeader.h     # 图标字体常量
│   └── PCStatisticHeader.h # 友盟事件常量
└── Resource/        # 资源、字体 (iconfont.ttf)
```

## 架构模式

### 网络请求层
- 所有 API 请求继承自 `PCRequest`（YTKNetwork 子类）
- 请求各自定义 URL、method、parameters
- API 端点是 `PCAPIHeader.h` 中的字符串常量
- 认证 token 存储在 `NSUserDefaults`，key 为 `PC_AUTHORIZATION_TOKEN`
- 请求签名使用 HMAC-SHA256（密钥硬编码在 `PCRequest.m`，不要修改）
- 自动处理 401 错误，跳转登录页

### 视图控制器
- 基类: `PCViewController`、`PCTableViewController`、`PCNavigationController`
- 功能控制器命名: `{功能}Controller.h/.m`
- 使用 QMUIKit 实现统一 UI 组件
- 生命周期: `didInitialize` -> `initSubviews` -> `setupNavigationItems` -> `viewDidLoad`

### 主题系统
- 基于 QMUIThemeManager 的业务封装
- 颜色通过类属性访问: `UIColor.pc_backgroundColor`、`UIColor.pc_tintColor`
- 主题协议定义在 `PCThemeProtocol.h`
- 主题颜色: `PCColorPink`、`PCColorHotPink`、`PCColorLightPink`

### 数据持久化
- **NSUserDefaults**: 用户设置、token、功能开关
- **GYDataCenter**: 漫画历史记录 (`PCComicHistory`)
- **FMDB**: 聊天消息 (`PCChatMessage`)

## 关键配置

### API 常量
- 基础 URL: `PC_API_HOST_ANDROID`（定义在 `PCAPIHeader.h`）
- API 版本控制通过 HTTP 头 `accept: application/vnd.picacomic.com.v1+json`
- 动态 UUID 生成避免账号封禁
- 分流设置: `PC_API_CHANNEL` (1-3)

### Info.plist
- 需要权限: 相机、麦克风、相册、FaceID、语音识别
- 启用后台音频模式
- 自定义字体: `iconfont.ttf`
- 强制浅色模式 (`UIUserInterfaceStyle: Light`)
- 允许任意加载 (`NSAllowsArbitraryLoads: YES`)

## 功能模块详解

### 登录模块 (Login)
- `PCLoginController`: 登录界面，支持新旧聊天室登录
- `PCRegistController`: 注册界面
- `PCTabBarViewController`: 主 TabBar，包含分类、聊天、游戏、我的
- 游戏标签可通过 `PC_TAB_GAME_HIDDEN` 用户默认值隐藏

### 分类模块 (Category)
- `PCCategoryController`: 主页，显示热门分类和搜索关键词
- `PCComicListController`: 漫画列表（支持分类、搜索、排行榜等）
- `PCComicDetailController`: 漫画详情，包含章节列表和推荐
- `PCComicPictureController`: 漫画阅读器，支持横向/竖向翻页
- `PCCommentController`: 评论列表
- 支持继续阅读功能（记录历史位置）

### 聊天模块 (Chat)
- **新版 (NewChat)**: `PCNewChatViewController` + `PCNewChatManager`
  - WebSocket 连接，支持文字、图片消息
  - 支持回复、@提及功能
  - 下拉加载历史记录
- **旧版 (OldChat)**: `PCChatViewController` + `PCChatManager`
- 聊天设置: `PCChatSettingController`

### 游戏模块 (Game)
- `PCGameListController`: 游戏列表
- `PCGameDetailController`: 游戏详情

### NSFW 模块
- 默认关闭，设置中开启
- 需要下载资源文件 (`NSFWSourceRequest`)
- `NSFWBrowerViewController`: 文件浏览器

### 用户模块 (User)
- `PCProfileController`: 个人主页，使用 JXPagingView
- 支持修改头像、slogan
- 显示收藏的漫画和评论

### 设置模块 (Setting)
- 修改密码、清除缓存、修改 ID
- 分流设置、简繁转换
- 游戏区隐藏、安全锁、NSFW 开关
- 聊天设置 (`PCChatSettingController`)

## 常见问题

1. **CocoaPods**: 拉取代码后必须运行 `pod install`
2. **工作区 vs 项目**: 必须用 `.xcworkspace` 构建
3. **签名**: 需要有效的 Apple 开发者账号和 bundle ID
4. **真机调试**: 相机、FaceID 等功能需要真机测试
5. **API 密钥**: 硬编码在 `PCRequest.m` 中——不要修改提交
6. **NSFW 资源**: 首次使用需要下载资源包

## 功能开关 (NSUserDefaults)
- `PC_NSFW_ON`: NSFW 模块开关
- `PC_TAB_GAME_HIDDEN`: 游戏标签隐藏
- `PC_DATA_TO_SIMPLIFIED_CHINESE`: 简繁转换
- `PC_LOCAL_AUTHORIZATION`: 安全锁
- `PC_READ_DIRECTION`: 阅读方向（横向/竖向）
- `PC_CATEGORY_WEB_HIDDEN`: 隐藏网页分类
- `PC_API_CHANNEL`: API 分流 (1-3)

## 代码规范
- 使用 `@weakify(self)` / `@strongify(self)` 避免循环引用
- 控制器使用懒加载模式
- 请求使用 `sendRequest:failure:` 方法
- UI 使用 QMUIKit 组件
- 图片使用 `SDWebImage` 加载
- 列表使用 `MJRefresh` 下拉刷新/上拉加载
