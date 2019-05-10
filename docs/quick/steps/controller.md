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

## API定义及访问控制的基础建设

### API定义
API定义即MVC或WebApi的 `Area-Controller-Action` 定义，为方便及规范此步骤的工作，OSharp定义了一些 `API基础控制器基类`，继承这些基类，很容易实现API定义。
#### ApiController
`ApiController` 用于非Area的Api控制器，基类添加了 操作审计`[AuditOperation]`，`[ApiController]`特性，并定义了一个 `[Route("api/[controller]/[action]")]` 的路由特性
```C#
/// <summary>
/// WebApi控制器基类
/// </summary>
[AuditOperation]
[ApiController]
[Route("api/[controller]/[action]")]
public abstract class ApiController : Controller
{
    /// <summary>
    /// 获取或设置 日志对象
    /// </summary>
    protected ILogger Logger => HttpContext.RequestServices.GetLogger(GetType());
}
```
#### AreaApiController
与 无区域控制器基类`ApiController`相对应，对于区域控制器，也定义了一个基类 `AreaApiController`
```C#
/// <summary>
/// WebApi的区域控制器基类
/// </summary>
[AuditOperation]
[ApiController]
[Route("api/[area]/[controller]/[action]")]
public abstract class AreaApiController : Controller
{ }
```

#### AdminApiController
对于相当常用的 管理`Admin` 区域，也同样定义了一个控制器基类`AdminApiController`，此基类继承于`AreaApiController`，并添加了区域特性`[Area("Admin")]`和角色访问限制特性`[RoleLimit]`
```C#
[Area("Admin")]
[RoleLimit]
public abstract class AdminApiController : AreaApiController
{ }
```

#### 博客模块API实现
```
[Description("管理-博客信息")]
public class BlogController : {==AdminApiController==}
{ }

[Description("管理-文章信息")]
public class PostController : {==AdminApiController==}
{ }
```

### Module树形结构及依赖
#### ModuleInfoAttribute
为了描述 API的层级关系，OSharp定义了一个`ModuleInfoAttribute`特性，把当前功能(Controller或者Action)封装为一个模块(Module)节点，可以设置模块依赖的其他功能，模块的位置信息等。此特性用于系统初始化时自动提取模块树信息Module。
```C#
/// <summary>
/// 描述把当前功能(Controller或者Action)封装为一个模块(Module)节点，可以设置模块依赖的其他功能，模块的位置信息等
/// 此特性用于系统初始化时自动提取模块树信息Module
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class ModuleInfoAttribute : Attribute
{
    /// <summary>
    /// 获取或设置 模块名称，为空则取功能名称
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// 获取或设置 模块代码，为空则取功能Action名
    /// </summary>
    public string Code { get; set; }

    /// <summary>
    /// 获取或设置 层次序号
    /// </summary>
    public double Order { get; set; }

    /// <summary>
    /// 获取或设置 模块位置，父级模块，模块在树节点的位置，默认取所在类的位置，需要在命名空间与当前类之间加模块，才设置此值
    /// </summary>
    public string Position { get; set; }

    /// <summary>
    /// 获取或设置 父级位置模块名称，需要在命名空间与当前类之间加模块，才设置此值
    /// </summary>
    public string PositionName { get; set; }
}
```
`[ModuleInfo]`特性主要有两种用法：

* 在`Controller`上，主要控制模块的顺序`Order`，模块的位置`Position`，模块名称`PositionName`，例如：
```C# hl_lines="1"
[ModuleInfo(Position = "Blogs", PositionName = "博客模块")]
[Description("管理-博客信息")]
public class BlogController : AdminApiController
{ }
```
* 在 `Action`上，主要用于标注哪些Action是作为可权限分配的API，通常无需使用属性，例如：
```C# hl_lines="6"
/// <summary>
/// 读取博客
/// </summary>
/// <returns>博客页列表</returns>
[HttpPost]
[ModuleInfo]
[Description("读取")]
public PageData<BlogOutputDto> Read(PageRequest request)
{ }
```

### API访问控制
API的访问控制，分为三种：

* 匿名访问`AllowAnonymousAttribute`：表示当前功能不需要登录即可访问，无视登录状态和角色要求
* 登录访问`LoginedAttribute`：表示当前功能需要登录才能访问，未登录拒绝访问
* 角色访问`RoleLimitAttribute`：表示当前功能需要登录并且用户拥有指定角色，才能访问，未登录或者登录但未拥有指定角色，拒绝访问

API访问控制的控制顺序按照 **就近原则**，即离要执行的功能最近的那个限制生效。以Controller上的标注与Action上的标注为例：

* Controller无，Action无，不限制 
* Controller有，Action无，以Controller为准
* Controller无，Action有，以Action为准
* Controller有，Action有，以Action为准

在`AdminApiController`基类中，已经设置了`[RoleLimit]`，表示Admin区域中的所有Controller和Action的默认访问控制方式就是 角色访问。
```C# hl_lines="2"
[Area("Admin")]
[RoleLimit]
public abstract class AdminApiController : AreaApiController
{ }
```
如想额外控制，则需要在实现Action的时候进行单独配置
```C# hl_lines="3"
[HttpPost]
[ModuleInfo]
[Logined]
[Description("读取")]
public PageData<BlogOutputDto> Read(PageRequest request)
{ }
```

### 自动事务提交
在传统框架中，事务的提交是在业务层实现完业务操作之后即手动提交的，这种方式能更精准的控制事务的结束位置，但也有不能适用的情况，例如当一个业务涉及多个服务的时候，每个服务各自提交了事务，便无法保证所有操作在一个完整的事务上进行了。

为此，OSharp框架提出了一种新的事务提交方式：**在Action中通过Mvc的Filter来自动提交事务**。

自动提交事务是通过如下的`UnitOfWorkAttribute`实现的：
```C# hl_lines="35 48 53 81"
/// <summary>
/// 自动事务提交过滤器，在<see cref="OnResultExecuted"/>方法中执行<see cref="IUnitOfWork.Commit()"/>进行事务提交
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
[Dependency(ServiceLifetime.Scoped, AddSelf = true)]
public class UnitOfWorkAttribute : ActionFilterAttribute
{
    private readonly IUnitOfWorkManager _unitOfWorkManager;

    /// <summary>
    /// 初始化一个<see cref="UnitOfWorkAttribute"/>类型的新实例
    /// </summary>
    public UnitOfWorkAttribute(IServiceProvider serviceProvider)
    {
        _unitOfWorkManager = serviceProvider.GetService<IUnitOfWorkManager>();
    }

    /// <summary>
    /// 重写方法，实现事务自动提交功能
    /// </summary>
    /// <param name="context"></param>
    public override void OnResultExecuted(ResultExecutedContext context)
    {
        ScopedDictionary dict = context.HttpContext.RequestServices.GetService<ScopedDictionary>();
        AjaxResultType type = AjaxResultType.Success;
        string message = null;
        if (context.Result is JsonResult result1)
        {
            if (result1.Value is AjaxResult ajax)
            {
                type = ajax.Type;
                message = ajax.Content;
                if (ajax.Successed())
                {
                    _unitOfWorkManager?.Commit();
                }
            }

        }
        else if (context.Result is ObjectResult result2)
        {
            if (result2.Value is AjaxResult ajax)
            {
                type = ajax.Type;
                message = ajax.Content;
                if (ajax.Successed())
                {
                    _unitOfWorkManager?.Commit();
                }
            }
            else
            {
                _unitOfWorkManager?.Commit();
            }
        }
        //普通请求
        else if (context.HttpContext.Response.StatusCode >= 400)
        {
            switch (context.HttpContext.Response.StatusCode)
            {
                case 401:
                    type = AjaxResultType.UnAuth;
                    break;
                case 403:
                    type = AjaxResultType.UnAuth;
                    break;
                case 404:
                    type = AjaxResultType.UnAuth;
                    break;
                case 423:
                    type = AjaxResultType.UnAuth;
                    break;
                default:
                    type = AjaxResultType.Error;
                    break;
            }
        }
        else
        {
            type = AjaxResultType.Success;
            _unitOfWorkManager?.Commit();
        }
        if (dict.AuditOperation != null)
        {
            dict.AuditOperation.ResultType = type;
            dict.AuditOperation.Message = message;
        }
    }
}
```
如一次请求中涉及数据的 新增、更新、删除 操作时，在 Action 上添加 `[ServiceFilter(typeof(UnitOfWorkAttribute))]`，即可实现事务自动提交。
```C# hl_lines="8"
/// <summary>
/// 新增文章
/// </summary>
/// <param name="dtos">新增文章信息</param>
/// <returns>JSON操作结果</returns>
[HttpPost]
[ModuleInfo]
[ServiceFilter(typeof(UnitOfWorkAttribute))]
[Description("新增")]
public async Task<AjaxResult> Create(PostInputDto[] dtos)
{ }
```
### AjaxReuslt
对于 **前后端分离** 的项目，前端向后端的请求都是通过 `application/json` 的方式来交互的，这就需要在后端对操作结果进行封装。OSharp提供了`AjaxResult`类来承载操作结果数据
```C#
/// <summary>
/// 表示Ajax操作结果 
/// </summary>
public class AjaxResult
{
    /// <summary>
    /// 初始化一个<see cref="AjaxResult"/>类型的新实例
    /// </summary>
    public AjaxResult()
        : this(null)
    { }

    /// <summary>
    /// 初始化一个<see cref="AjaxResult"/>类型的新实例
    /// </summary>
    public AjaxResult(string content, AjaxResultType type = AjaxResultType.Success, object data = null)
        : this(content, data, type)
    { }

    /// <summary>
    /// 初始化一个<see cref="AjaxResult"/>类型的新实例
    /// </summary>
    public AjaxResult(string content, object data, AjaxResultType type = AjaxResultType.Success)
    {
        Type = type;
        Content = content;
        Data = data;
    }

    /// <summary>
    /// 获取或设置 Ajax操作结果类型
    /// </summary>
    public AjaxResultType Type { get; set; }

    /// <summary>
    /// 获取或设置 消息内容
    /// </summary>
    public string Content { get; set; }

    /// <summary>
    /// 获取或设置 返回数据
    /// </summary>
    public object Data { get; set; }

    /// <summary>
    /// 是否成功
    /// </summary>
    public bool Successed()
    {
        return Type == AjaxResultType.Success;
    }

    /// <summary>
    /// 是否错误
    /// </summary>
    public bool Error()
    {
        return Type == AjaxResultType.Error;
    }

    /// <summary>
    /// 成功的AjaxResult
    /// </summary>
    public static AjaxResult Success(object data = null)
    {
        return new AjaxResult("操作执行成功", AjaxResultType.Success, data);
    }
}
```
其中`AjaxResultType`的可选项为：
```C#
/// <summary>
/// 表示 ajax 操作结果类型的枚举
/// </summary>
public enum AjaxResultType
{
    /// <summary>
    /// 消息结果类型
    /// </summary>
    Info = 203,

    /// <summary>
    /// 成功结果类型
    /// </summary>
    Success = 200,

    /// <summary>
    /// 异常结果类型
    /// </summary>
    Error = 500,

    /// <summary>
    /// 用户未登录
    /// </summary>
    UnAuth = 401,

    /// <summary>
    /// 已登录，但权限不足
    /// </summary>
    Forbidden = 403,

    /// <summary>
    /// 资源未找到
    /// </summary>
    NoFound = 404,

    /// <summary>
    /// 资源被锁定
    /// </summary>
    Locked = 423
}
```
业务服务层的操作结果`OperationResult`，可以很轻松的转换为`AjaxResult`
```C#
/// <summary>
/// 将业务操作结果转ajax操作结果
/// </summary>
public static AjaxResult ToAjaxResult<T>(this OperationResult<T> result, Func<T, object> dataFunc = null)
{
    string content = result.Message ?? result.ResultType.ToDescription();
    AjaxResultType type = result.ResultType.ToAjaxResultType();
    object data = dataFunc == null ? result.Data : dataFunc(result.Data);
    return new AjaxResult(content, type, data);
}

/// <summary>
/// 将业务操作结果转ajax操作结果
/// </summary>
public static AjaxResult ToAjaxResult(this OperationResult result)
{
    string content = result.Message ?? result.ResultType.ToDescription();
    AjaxResultType type = result.ResultType.ToAjaxResultType();
    return new AjaxResult(content, type);
}

```
通过这些扩展方法，可以很简洁的完成由`OperationResult`到`AjaxResult`的转换
```C#
public async Task<AjaxResult> Creat(PostInputDto[] dtos)
{
    OperationResult result = await _blogsContract.CreatePosts(dtos);
    return result.ToAjaxResult();
}
```

## 博客模块API实现
### 博客 - Blog
### 文章 - Post
