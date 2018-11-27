---
title:	个人信息
---

# <center>Android开发工程师

# 姓名 刘正
 **电话：** 188 1751 1354       
 **邮箱：**  zheng.liumoment@gmail.com    
 **GitHub：** [https://github.com/momentslz](https://github.com/momentslz)      
 **个人主页**：[http://liuzheng.space/](http://liuzheng.space/)  

# 项目经验

## 麦萌漫画

> **简介**：二次元漫画、小说、图片社区   
> **预览**：[下载链接](http://sj.qq.com/myapp/detail.htm?apkName=com.cn.maimeng)  

#### 相关技术细节

***模块化改造***
> 在项目原有路由activityrouter基础上进行模块化改造,实现模块间解耦操作，模块中对外提供的接口在通用模块中注册，供其他模块调用。

***广告模块添加***
> 按接口配置信息下载展示，主流程为先下载后展示，下载失败时直接展示网络图片，公共下模块实现解耦，可对接第三方广告服务或自用接口。

***事件追踪模块添加***
> 在公用的路由跳转中添加事件追踪功能，通过监听跳转链接，实现了对业务逻辑跳转的追踪。活动跳转追踪暂时未实现自动化，只能在需要监听的地方手动标记（待优化）

***海外版国际化改造***
> 通过采用服务端配置文件的方法，在asset文件中设置json配置文件，通过配置文件实现业务逻辑的动态化打包及加载。   
> 目前实现的逻辑：***api接口差异化打包***、***语言环境差异化打包***、***第三方登录差异化打包***、***分享模块差异化打包***    

***海外版支付对接***
> MyCard、MolPay支付sdk对接实现了对支付接口的封装，支持其他支付扩展

***性能优化***
> 页面层级优化、内存泄漏优化（LeakCanary）、内存抖动优化、冷启动白屏优化、图片加载优化

**技术栈**
[ActivityRouter](https://github.com/mzule/ActivityRouter)、[Retrofit](https://github.com/square/retrofit)、[Fresco](https://github.com/facebook/fresco)

## 口袋故事

> **简介** 儿童有声故事平台  
> **预览** [下载链接](http://sj.qq.com/myapp/detail.htm?apkName=com.appshare.android.ilisten)  

#### 相关技术细节：

***网络优化***
> 接入 HTTPDNS 及 HTTPS 实现网页入侵预防，保证客户端网络连接稳定性

***下载优化***
> 通过使用注册监听的模式替换之前读写数据库的操作，提升下载稳定性及用户体验

***性能优化***
> 调整 UI 层级（解决 overdraw 问题）、调整复杂页面数据源结构从而达到页面布局复用（ListView + Header 布局问题）、通过分析工具 LeakCanary 解决引用
内存泄漏问题

***布局适配***
> 使用 [***AndroidAutoLayout***](https://github.com/hongyangAndroid/AndroidAutoLayout) 进行多机型布局适配

***错误追踪***
> 自定义网络异常追踪类，同步、异步或根据规则上传客户端网络异常信息

***插件化***
> 使用 Small 开源框架对项目进行改造，添加 Router 类完成公司自定义路由与 Small 框架路由之间的跳转，项目结构调整在 MVP 的基础上添加了数据聚合层及数据源管理层（可实现从本地数据库到 API 数据的无缝切换），数据聚合层采用RxJava进行数据多流聚合操作

**技术栈**：
[***AndroidAutoLayout***](https://github.com/hongyangAndroid/AndroidAutoLayout)、[***Small***](https://github.com/wequick/Small)

# 工作经历
### 2017-11 ~ 至今
> #### 上海寒决网络科技有限公司    
> **工作描述**：负责 ***麦萌漫画*** 开发迭代

### 2017-07 ~ 2017-10
> #### 上海知诺网络科技有限公司
> **工作描述**：负责 ***开黑大师*** 客户端优化迭代降低应用崩溃率

### 2016-03 ~ 2017-06
> #### 上海童锐网络科技有限公司
> **工作描述**：带领Android团队负责 ***口袋故事*** 客户端研发，用户崩溃率维持在千分之三左右，通过应用内存优化，客户端内存占用率下降了40%左右

### 2015-04 ~ 2016-02
> #### 北京知根教育科技有限公司
> **工作描述**：负责 ***条条*** 研发，项目已下线

# 开源项目
## Eyepetizer
**简介**
> [仿开眼视频Eyepetizer客户端](https://github.com/momentslz/Eyepetizer)：本项目采用Google-MVP及kotlin开发，主要用于熟悉及掌握相关技能.  
> **预览**：[下载链接](https://www.pgyer.com/O4Pf)  

#### 相关技术细节

***自定义TabLayout***
> 为实现开眼客户端首页tab选项卡切换功能，在参考 [***FlycoTabLayout***](https://github.com/H07000223/FlycoTabLayout) 相关源码后用kotlin实现对TabLayout进行定制使用，如：指示器距离文字的距离、文字选中加粗、文字选中变大等，具体使用详见： [***自定义TabLayout***](https://juejin.im/post/5a8fde236fb9a06334268374)

***Android图片加载***
> 基于现有项目存在大量高清美图展示的模块，所以在使用并对比了Glide和fresco的加载效果及使用体验后定下来的，两个框架都非常优秀但其侧重点略有不同之所以会选择Glide是因为本人挺喜欢Glide的API风格，简单方便而且不会涉及到自定义view，具体使用详见：[***Android图片加载-Glide4.0框架封装***](https://juejin.im/post/5a93852b5188257a6c692bab)

**技术栈** [GoogleMvp](https://github.com/googlesamples/android-architecture)、[SlidingTabLayout](https://www.jianshu.com/p/c283a2403190)、[RxAndroid](https://github.com/ReactiveX/RxAndroid)、[RxRelay](https://github.com/JakeWharton/RxRelay)、[RecyclerViewSnap](https://github.com/rubensousa/RecyclerViewSnap)、[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)

# 相关技能
- Kotlin
- RxJava
- Small
- golang

# 致谢
感谢您花时间阅读我的简历，期待能有机会和您共事.
