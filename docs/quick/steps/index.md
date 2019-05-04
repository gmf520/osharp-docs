# 设计一个博客模块(BlogsPack)
---
## Pack模块简介

Pack模块是应用程序中的一个高内聚的子系统，负责完成一类功能或者一系列相关联的业务处理，是构建 OSharp 应用程序的基本功能单元。一系列低耦合的Pack模块共同组合在一起创建一个 OSharp 应用程序。每个 Pack模块是以一个实现了模块基类（[OsharpPack](https://docs.osharp.org/api/OSharp.Core.Packs.OsharpPack.html)）的类作为入口的，这个类完成本模块的服务添加（AddService）和模块初始化工作（UsePack）。本系列教程中，我们将一步一步实现一个博客模块，通过这个博客模块，可以给应用程序添加一个完整的博客功能。

OsharpPack 基类定义如下：
``` csharp
/// <summary>
/// OSharp模块基类
/// </summary>
public abstract class OsharpPack
{
    /// <summary>
    /// 获取 模块级别，级别越小越先启动
    /// </summary>
    public virtual PackLevel Level => PackLevel.Business;

    /// <summary>
    /// 获取 模块启动顺序，模块启动的顺序先按级别启动，同一级别内部再按此顺序启动，
    /// 级别默认为0，表示无依赖，需要在同级别有依赖顺序的时候，再重写为>0的顺序值
    /// </summary>
    public virtual int Order => 0;

    /// <summary>
    /// 获取 是否已可用
    /// </summary>
    public bool IsEnabled { get; protected set; }

    /// <summary>
    /// 将模块服务添加到依赖注入服务容器中
    /// </summary>
    /// <param name="services">依赖注入服务容器</param>
    /// <returns></returns>
    public virtual IServiceCollection AddServices(IServiceCollection services)
    {
        return services;
    }

    /// <summary>
    /// 应用模块服务，初始化模块
    /// </summary>
    /// <param name="provider">服务提供者</param>
    public virtual void UsePack(IServiceProvider provider)
    {
        IsEnabled = true;
    }

    /// <summary>
    /// 获取当前模块的依赖模块类型
    /// </summary>
    /// <returns></returns>
    internal Type[] GetDependPackTypes(Type packType = null)
    {
        // ...
    }
}
```

## 业务Pack模块包含什么
一个完整的业务模块，要实现一系列相关联的业务功能，需要一个完整的 **数据层 - 服务层 - WebAPI层 - 前端UI层** 的代码链的支持，各个层次各司其职，共同来完成当前模块的业务处理。

### 博客业务需求分析

* **已登录** 并且未开通博客的用户，可以向系统申请开通博客
* **博客管理员** 审核并开通博客，并给相应用户分配 **博主** 角色
* **博客管理员** 可以对博客、文章进行 **更新、删除** 的管理操作
* **博主** 可以对博客进行更新操作
* **博主** 可以对文章进行 **新增、更新、删除** 操作
* 博客、文章均开启 **逻辑删除** 功能，保留历史数据


### 数据层
OSharp的数据层，主要是 **数据实体** 的定义，只要数据实体定义好，并做好 **数据实体映射**，再配合框架中已定义好的数据仓储 **IRepository&lt;TEntity, TKey&gt;**，即可轻松完成数据的数据库存取操作。
一个最简单的博客系统，需要有 作者、博客、文章 三个数据实体。

* 作者 - User

    博客系统的作者就是OSharp框架的 **用户(User)**，直接使用即可。

* 博客 - Blog

    | 字段        | 数据类型 | 描述         | 备注         | InputDto | OutputDto |
    | ----------- | -------- | ------------ | ------------ | -------- | --------- |
    | Id          | int      | 博客编号     | 主键，唯一   | 是       | 是        |
    | Url         | string   | 博客地址     | 唯一         | 是       | 是        |
    | Display     | string   | 博客显示名称 |              | 是       | 是        |
    | IsEnabled   | boolean  | 已开通       |              | 是       | 是        |
    | CreatedTime | DateTime | 创建时间     |              | 否       | 是        |
    | UserId      | int      | 作者编号     | 外键，一对一 | 是       | 是        |

* 文章 - Post

    | 字段        | 数据类型 | 描述     | 备注         | InputDto | OutputDto |
    | ----------- | -------- | -------- | ------------ | -------- | --------- |
    | Id          | int      | 文章编号 | 主键，唯一   | 是       | 是        |
    | Title       | string   | 文章标题 |              | 是       | 是        |
    | Content     | string   | 文章内容 |              | 是       | 是        |
    | CreatedTime | DateTime | 创建时间 |              | 否       | 是        |
    | BlogId      | int      | 博客Id   | 外键，多对一 | 是       | 是        |
    | UserId      | int      | 作者编号 | 外键，多对一 | 是       | 是        |

### 服务层
服务层负责实现模块的业务处理，是整个系统的最核心部分，一个系统有什么功能，能对外提供什么样的服务，都是在服务层实现的。

| 实体 | 业务操作                       |
| ---- | ------------------------------ |
| 博客 | 申请开通、开通审核、更新、删除 |
| 文章 | 新增、更新、删除               |

### WebAPI层
WebAPI层负责对外提供数据操作API，并对API进行授权约束。

* 博客管理 - Blog

    | 操作     | 访问类型 | 操作角色               |
    | -------- | -------- | ---------------------- |
    | 申请开通 | 登录访问 | 已登录未开通博客的用户 |
    | 读取     | 角色访问 | 博客管理员、博主       |
    | 开通审核 | 角色访问 | 博客管理员             |
    | 更新     | 角色访问 | 博客管理员、博主       |
    | 删除     | 角色访问 | 博客管理员             |

* 文章管理 - Post

    | 操作 | 访问类型 | 操作角色         |
    | ---- | -------- | ---------------- |
    | 读取 | 角色访问 | 博客管理员、博主 |
    | 新增 | 角色访问 | 博主             |
    | 更新 | 角色访问 | 博客管理员、博主 |
    | 删除 | 角色访问 | 博客管理员、博主 |

### 前端UI层
前端UI层是整个系统的对外操作界面，是直面最终用户的终端，整个系统最终表现形式全靠前端展现出现。
博客模块UI设计如下：

* 统一使用后台管理界面来提供 博客、文章 的管理
* 博客管理列表
    * 博主
        * 已登录未开通博客，显示开通按钮
        * 申请之后，博客处理未审核状态
        * 博客更新可用
    * 博客管理员
        * 可以对博客进行审核、更新、删除操作
* 文章管理列表
    * 博主可以新增文章
    * 博主、博客管理员可以更新、删除文章

至此，博客模块的详细设计设计完毕，后面我们将一步一步来实现这个业务需求。