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

## 配置文件优先级

高到低分别为

当前目录下的config下的配置文件

当前目录下的配置文件

classpath下的config下的配置文件

classpath下的配置文件

## 多配置文件

application-xxx.yaml或者在yaml中以---分割

使用spring.profiles.active=xxx