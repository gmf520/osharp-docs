# 快速开始
---
## 开发环境
OSharp 框架使用现在流行的 **前后端分离** 的架构模式，开发环境的初始化涉及后端开发环境和前端开发环境。

### 后端开发环境
后端开发环境指的是 **.NetCore** 的开发环境，涉及到的开发环境为SDK，IDE，数据库等。

#### .NetCore SDK
OSharp 框架的后端是基于 .NetCore 的最新稳定版本的，目前最新稳定版本为 ![Microsoft.AspNetCore.App](https://img.shields.io/nuget/v/Microsoft.AspNetCore.App.svg)，当 3.0 版本发布稳定版本之后，不出意外 OSharp 会跟随脚步升级到 3.0，所以，请安装最新版本的 SDK。
最新 SDK 下载地址如下：
> https://dotnet.microsoft.com/download

* 点击 **Download .NET Core SDK** 按钮进行最新 SDK 的下载。
* 在服务器部属的时候，不需要完整的 SDK，点击 **Download .NET Core Runtime** 按钮进行最新 Runtime 的下载。

安装完成后，在 `命令提示符` 或 `PowerShell` 窗口输入如下命令，即可查看到本机已安装的 .NetCore 的 SDK 和 Runtime 版本详细信息
> dotnet --info

我的电脑输出如下，可以看到，已经安装了 `2.2.203` 版本的 SDK 和 `2.2.4` 版本的 Runtime：
```
.NET Core SDK（反映任何 global.json）:
 Version:   2.2.203
 Commit:    e5bab63eca

运行时环境:
 OS Name:     Windows
 OS Version:  10.0.17763
 OS Platform: Windows
 RID:         win10-x64
 Base Path:   C:\Program Files\dotnet\sdk\2.2.203\

Host (useful for support):
  Version: 2.2.4
  Commit:  f95848e524

.NET Core SDKs installed:
  2.2.203 [C:\Program Files\dotnet\sdk]

.NET Core runtimes installed:
  Microsoft.NETCore.App 2.2.4 [C:\Program Files\dotnet\shared\Microsoft.NETCore.App]

To install additional .NET Core runtimes or SDKs:
  https://aka.ms/dotnet-download
```

#### IDE (集成开发环境)
* Visual Studio 2019：开发 .NET 程序，当前首先宇宙最强IDE **Visual Studio**，.NetCore 2.2 的可用VS版本为 VS2017 和 VS2019，推荐使用最新版本的 VS2019。
* Visual Studio Code：如果你觉得VS太过笨重，喜欢比较轻量级的IDE，VS Code 也是个很不错的选择，只需装上 `C#` 插件即可完美运行 .NetCore 代码。VS Code 也是目前最好用的前端IDE，后面将作为前端IDE进行前端代码的开发。

两个IDE都可以在如下的地址中下载：
> https://visualstudio.microsoft.com/zh-hans/downloads/


> 补充：当使用 Visual Studio 时，Resharper 这个插件是个不可错过的插件，可以在 智能提示、变量命名、代码优化、代码重构、代码结构导航、dll反编译查看源代码等方面对 Visual Studio 进行大量不可多得的功能补充。当然，这个插件比较吃资源，需要你有一台性能优良的硬件机器才能流畅使用。

#### 数据库
OSharp 框架的数据存储是基于 EntityFrameworkCore (简称EFCore) 这个ORM实现的，只要 EFCore 支持的数据库，都可以作为 OSharp 的数据存储，现已支持数据库如下：

* Microsift SqlServer 2012+
* MySql 5.7+
* Sqlite
* PostgreSql
* Oracle

### 前端开发环境
在前后端分离的项目中，三大前端技术框架 Angular、Vue、React 已经成为不可跨越的必选项，基于历史的原因（osharp的.net fx 版本基于AngularJS），OSharp 的前端是基于 Angular 实现的，考虑到 Vue 在国内不可忽视的市场，Vue 版本的前端也在计划之内，而 React 版本目前还没有排上日程。
要上三大前端，NodeJS 是必须的，可在如下地址获得 NodeJS 的安装包：
> https://nodejs.org/en/

NodeJS 安装 好之后，NPM 也就可以用了。但 NPM 的默认安装源在国外，通常会比较慢，因此需要把 NPM 的安装源设置到国内镜像源，[淘宝镜像](http://npm.taobao.org)是个不错的选择，执行如下命令设置将淘宝镜像设置为NPM的安装源：
> npm config set registry https://registry.npm.taobao.org

#### Angular
OSharp 的 [Angular](https://angular.cn) ![](https://img.shields.io/npm/v/@angular/core.svg) 版前端是基于 [NG-ALAIN](https://ng-alain.com) ![](https://img.shields.io/npm/v/ng-alain.svg) 前端框架开发的。NG-ALAIN 是一个基于 Antd 中后台前端解决方案，提供更多通用性业务模块，让开发者更加专注于业务。
首先，需要通过 npm 命令全局安装 @@angular/cli ![](https://img.shields.io/npm/v/@angular/cli.svg) 运行环境
> npm install -g @@angular/cli

#### Vue
OSharp 的 [Vue](https://cn.vuejs.org/index.html) ![](https://img.shields.io/npm/v/vue.svg) 版前端是基于 [IView](https://iviewui.com) ![](https://img.shields.io/npm/v/iview.svg) 前端框架开发的。IView 是一套基于 Vue.js 的高质量 UI 组件库。
首先，需要通过 npm 命令全局安装 @@vue/cli ![](https://img.shields.io/npm/v/@vue/cli.svg) 运行环境
> npm install -g @@vue/cli

> 由于精力有限及优先级的问题，Vue版本现在尚未开发完成。


## 项目初始化



## 打开项目，运行项目