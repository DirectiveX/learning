# Spring Boot

[官网](https://spring.io/projects/spring-boot/#learn)

Spring boot就是用于构建Spring应用的启动点，它主要的功能是简化配置，快速启动Spring应用

## 特点

创建独立的spring应用

内置tomcat，jetty或undertow(开箱即用)

提供可配置的启动器依赖来简化构建配置

尽可能自动配置spring和三方库

提供生产就绪特性，如度量、运行状况检查和外部化配置

没有冗余代码生成和XML配置

## 互联网架构演变

[互联网架构演变](https://dubbo.apache.org/zh/docs/v2.7/user/preface/background/)

单一应用架构（基于ORM）->垂直应用架构（基于MVC）->分布式架构（基于RPC）->流式计算架构（基于SOA）

## 什么是微服务架构

[论文] (https://www.cnblogs.com/liuning8023/p/4493156.html)

## 修改banner

[banner](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-banner)

## yaml

key:空格value

list: list

  \-a

  \-b

  \-c

使用@ConfigurationProperties进行前缀配置，使用@Value进行绑定

|                    | @ConfigurationProperties | @value                             |
| ------------------ | ------------------------ | ---------------------------------- |
| 功能               | 批量注入配置文件的属性   | 一个个指定                         |
| 松散绑定(松散语法) | 支持                     | 不支持                             |
| SPEL               | 不支持                   | 支持(计算,如上age的值所示）（#{}） |
| JSR303数据校验     | 支持 (邮箱验证）         | 不支持                             |
| 复杂类型封装       | 支持                     | 不支持                             |

## 注解的作用

1.生成文档，@Param，@Return，@link，@see

2.编译时格式检查如@Functional，@override

### 原理

反射

### 元注解

负责注解其他注解

有四个

@Target：描述注解使用范围

@Retention：类的有效范围，source，class，runtime

@Documented：是否被包含在javadoc中

@Inherited：子类可以继承父类注解

## spi

java spi是用提供给第三方软件的一个接口（jdk1.6之后提供的），第三方软件通过实现这个接口可以实现对应的功能，是一种解耦的思路。通过ServiceLoader扫描jar的META-INF下面的类获得接口的具体实现

**应用场景**

JDBC加载驱动，SLF4J门面模式，dubbo

**jdk9之后出现了巨大变化，增加了很多流式处理**

**spi打破双亲委派**

如果使用到了java内置的接口如JDBC，那么遵循双亲委派的做法是采用Class.forName通过当前类的ClassLoader进行加载，但是如果通过ClassLoader，那么加载DriverManager的ClassLoader必然是就是BootStrapClassLoader，而加载实现类肯定用不了BootStrapClassLoader，只能用自己实现的ClassLoader或者AppClassLoader，所以要向下寻找，spi使用了getContextClassLoader()方法去找到下面的ClassLoader进行一个加载

**用idea的坑爹情况**

建包的时候不要用.分割，一个个键，不然idea以为你包名带点

ps：

> ServiceLoader<xxxInterface> service = ServiceLoader.load(xxxInterface.class);

## 配置文件优先级

高到低分别为

当前目录下的config下的配置文件

当前目录下的配置文件

classpath下的config下的配置文件

classpath下的配置文件

## 多配置文件

application-xxx.yaml或者在yaml中以---分割

使用spring.profiles.active=xxx

## Servlet

[servlet](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-embedded-container)

### @WebServlet,继承HttpServlet

### @WebFilter

### @WebListener

### @ServletComponetScan

> 实现方式有三种方式：第一种：使用servlet注解。如上面我们演示的@Webservlet注解。
>
> 其实就是@ServletComponentScan+@webServlet
>
> 或者+@WebFilter或者+@WebListener注解
>
> 方式二：使用spring注解
>
> @Bean+Servlet(Filter\Listener)
>
> 方式三：使用RegistrationBean方法(推荐)
>
> ServletRegistrationBean
>
> FilterRegistrationBean
>
> ServletListenerRegistrationBean

## 静态文件

[static content](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-spring-mvc-static-content)

static和templates

## Spring MVC自动配置

[mvc](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-spring-mvc-auto-configuration)

### 自定义视图解析器

实现ViewResolver，加入到spring容器中即可，Spring会从容器中找到所有视图解析器的子类进行一个分析

### 注意

如果想要保留MVC的功能并且做更多的配置，可以实现WebMvcConfigurer并且标注解@Configuration，但是不能使用@EnableWebMvc注解

如果想要完全管理Mvc，不让springboot自动的配置生效，那么可以加上@EnableWebMvc注解或者直接导入@import(DelegatingWebMvcConfiguration.class)

## thymelaf

[中文文档](https://raledong.gitbooks.io/using-thymeleaf/content/)

所有的表达式都可以在org.thymeleaf.expression包下找到，如org.thymeleaf.expression.Calendars

## i18n国际化

注意点：resolver在请求成功的时候会被调用2次

## Spring Boot多数据源

### 集成druid

[druid-starter](https://github.com/alibaba/druid/tree/master/druid-spring-boot-starter)

**sql监控不到**

加过滤器 filters: stat,wall,sl4j

**Spring 使用AbstractRoutingDataSource类实现多数据源切换，将数据源绑定在ThreadLocal上**

# 开发者工具

JRebel和Devtools

