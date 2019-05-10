# 添加业务对外API
---
## 概述
一个模块的 API层（Web层），主要负责如下几个方面的工作：

* 接收 `前端层` 提交的数据查询请求，使用 `服务层` 提供的 `IQueryable<T>` 查询数据源，查询出需要的数据返回前端
* 接收 `前端层` 提交的业务处理请求，调用 `服务层` 的服务，处理业务需求，并将操作结果返回前端
* 使用MVC的 `Area-Controller-Action`的层次关系，联合 [`[ModuleInfo]`](https://docs.osharp.org/api/OSharp.Core.Modules.ModuleInfo.html)特性， 定义 Api模块`Module` 的 **树形组织结构**，API模块 的 **依赖关系**，构建出`Module`的树形数据
* 定义 API 的`可访问方式`，API的访问方式可分为 `匿名访问`，`登录访问`和`角色访问`
* 定义自动事务提交，涉及数据库变更的业务，可在API定义自动事务提交，在业务层实现业务时即可不用考虑事务的问题

整个过程如下图所示
![API层数据流](../../assets/imgs/quick/steps/controller/001.png "API层数据流"){.img-fluid tag=1}

## API层 代码布局

### API层 代码布局分析

API层 即是Web网站服务端的MVC控制器，控制器可按粒度需要不同，分为模块控制器和单实体控制器，这个由业务需求决定。

通常，后台管理的控制器，是实体粒度的，即每个实体都有一个控制器，并且存在于 `/Areas/Admin/Controlers` 文件夹内。

博客模块的 API 层控制器，如下图所示：

```
src                                         # 源代码文件夹
└─Liuliu.Blogs.Web                          # 项目Web工程
    └─Areas                                 # 区域文件夹
       └─Admin                              # 管理区域文件夹
            └─Controllers                   # 管理控制器文件夹
                └─Blogs                     # 博客模块文件夹
                    ├─BlogController.cs     # 博客管理控制器
                    └─PostController.cs     # 文章管理控制器
```

## API定义及访问控制

### API定义
API定义即MVC或WebApi的 `Area-Controller-Action` 定义，为方便及规范此步骤的工作，OSharp定义了一些基础控制器基类，继承这些基类，很容易实现API定义。


### Module树形结构及依赖

### API访问控制

### 自动事务提交

### AjaxReuslt

## 博客模块API实现
### 博客 - Blog
### 文章 - Post
