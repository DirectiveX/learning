# Spring Cloud

## 了解webservice与SOA

是用来实现SOA基本通讯的方式，可以实现跨平台通讯，里面使用了很多标准，例如soap（Simple Object Access Protoco）协议，wsdl（Web Services Description Language），UDDI（Universal Description，Discovery and Integration），主要目的是实现松散耦合，交互的方式是基于XML文本和HTTP协议

## 微服务架构图

![微服务架构图](picture/Microservice Architecture.jpg)

组成：

1. 服务注册与发现组件：Eureka，Zookeeper，Consul,Nacos等。Eureka基于REST风格的。

2. 服务调用组件：Hystrix(熔断降级，在出现依赖服务失效的情况下，通过隔离 系统依赖服务  的方式，防止服务级联失败，同时提供失败回滚机制，使系统能够更快地从异常中恢复)，Ribbon（客户端负载均衡，用于提供客户端的软件负载均衡算法，提供了一系列完善的配置项：连接超时、重试等），OpenFeign（优雅的封装Ribbon，是一个声明式RESTful网络请求客户端，它使编写Web服务客户端变得更加方便和快捷）。

3. 网关：路由和过滤。Zuul，Gateway。

4. 配置中心：提供了配置集中管理，动态刷新配置的功能；配置通过Git或者其他方式来存储。

5. 消息组件：Spring Cloud Stream（对分布式消息进行抽象，包括发布订阅、分组消费等功能，实现了微服务之间的异步通信）和Spring Cloud Bus（主要提供服务间的事件通信，如刷新配置）

6. 安全控制组件：Spring Cloud Security 基于OAuth2.0开放网络的安全标准，提供了单点登录、资源授权和令牌管理等功能。

7. 链路追踪组件：Spring Cloud Sleuth（收集调用链路上的数据），Zipkin（对Sleuth收集的信息，进行存储，统计，展示）。

### 微服务概况

- 无严格定义。
- 微服务是一种架构风格，将单体应用划分为小型的服务单元。
- 微服务架构是一种使用一系列粒度较小的服务来开发单个应用的方式；每个服务运行在自己的进程中；服务间采用轻量级的方式进行通信(通常是HTTP API)；这些服务是基于业务逻辑和范围，通过自动化部署的机制来独立部署的，并且服务的集中管理应该是最低限度的，即每个服务可以采用不同的编程语言编写，使用不同的数据存储技术。
- 英文定义：

```sh
看这篇文章：
http://www.martinfowler.com/articles/microservices.html
```

- 小类比

  合久必分。分开后通信，独立部署，独立存储。

## Netflix

### Netflix Eureka

英文意思是我发现了

[github](https://github.com/Netflix/eureka/wiki)

#### 机制

**renew**

Eureka客户端每30秒向服务器发送一次心跳，服务器90s内没有更新客户端信息的话，就会从注册表删除实例

**fetch registty**

Eureka客户端从服务器获取注册表信息并将其缓存在本地

**cancel**

关闭客户端的时候发送取消请求，让服务器删除对应实例

**time lag**

同步时间延迟，指数据由于上传和拉取的间隔，在一段时间内可能导致server中的数据不一致，在客户端的操作可能要等一段时间才能反应给服务器

**Communication mechanism**

通讯机制，Http协议下的Rest请求，默认情况下Eureka使用Jersey和Jackson以及JSON完成节点间的通讯

#### 访问

##### 通过统一的rest风格的api去获取服务数据并且操作元数据

[eureka api](https://github.com/Netflix/eureka/wiki/Eureka-REST-operations)

还可以冷加载一些自定义的元数据信息，通过配置文件
```yaml
eureka.instance.metadata-map.xx.xx=123
```
效果
```xml
<metadata>
<management.port>8082</management.port>
<xx.xx>123</xx.xx>
</metadata>
```

##### java访问
1.使用eurekaClient类（具体实现）去接收
```java
@AutoWired
DiscoveryClient eurekaClient;
```
2.使用ribbon进行负载均衡
```java
@AutoWired
LoadBalance lb;
```

#### server

[eureka server](https://docs.spring.io/spring-cloud-netflix/docs/current/reference/html/#spring-cloud-eureka-server)

**集群**

无（多）主模式集群

```yaml
spring:
  profiles:
    active: e1
  application:
    # 这个不配置的话就都会归为UNKNOWN集群，虽然可用，但是最好设置一下，效果和配置appname一样
    name: EServer
---
spring:
  config:
    activate:
      on-profile: e1
eureka:
  client:
    serviceUrl:
      # 这边是节点间通讯的地址，一般是访问地址+eureka/,如果配置https，需要做一些额外工作
      defaultZone: http://eureka2:8081/eureka/
  instance:
    # 当前主机名，用来区分主机的
    hostname: eureka1
server:
  # eureka web服务器的地址
  port: 8080
---
spring:
  config:
    activate:
      on-profile: e2
eureka:
  client:
    serviceUrl:
      defaultZone: http://eureka1:8080/eureka/
  instance:
    hostname: eureka2
server:
  port: 8081
```

ps:做集群的时候注意hostname是查找主机地址的，appname是标识集群分组的

#### client

[eureka client](https://docs.spring.io/spring-cloud-netflix/docs/current/reference/html/#service-discovery-eureka-clients)

# 杂项

**服务熔断**

指后面服务不可运行，进行一个熔断，不再向这些服务器进行请求

**服务降级**

指服务器比较忙，调用服务的时候本来要调用多个服务的，降级成调用一个服务

