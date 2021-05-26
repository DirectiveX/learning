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

```properties
#续约发送间隔默认30秒，心跳间隔
eureka.instance.lease-renewal-interval-in-seconds=5
#表示eureka client间隔多久去拉取服务注册信息，默认为30秒，对于api-gateway，如果要迅速获取服务注册状态，可以缩小该值，比如5秒
eureka.client.registry-fetch-interval-seconds=5
# 续约到期时间（默认90秒）
eureka.instance.lease-expiration-duration-in-seconds=60
```

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

**自我保护机制**
用来防止网络分区，如果每分钟心跳次数小于numberOfRenewsPerMinThreshold时，会开启自我保护，此时，不会进行服务的自动下线操作，但是提供的服务列表可能不可用
renwalPercentThreshold = 0.85,占比，可以设置

numberOfRenewsPerMinThreshold = $服务数*2*0.85$

```properties
#关闭自我保护模式
eureka.server.enable-self-preservation=false
#失效服务间隔
eureka.server.eviction-interval-timer-in-ms=3000
```

#### client

[eureka client](https://docs.spring.io/spring-cloud-netflix/docs/current/reference/html/#service-discovery-eureka-clients)

**actuator**

server启动的时候会自带acturator监控健康信息，但是client没有，所以要自己引入对应的jar包，拆封即用，无需配置

*可以开启actuator的健康检查,如果需要的话可以开启远程上下线功能*

```properties
#暴露 Endpoint
management.endpoints.jmx.exposure.exclude=
#jmx方式排除需要公开的端点
management.endpoints.jmx.exposure.include=*
#jmx方式包含需要公开的端点
management.endpoints.web.exposure.exclude=
#http方式排除需要公开的端点
management.endpoints.web.exposure.include=info, health

#上下线
management.endpoint.shutdown.enabled=true
```

**应用场景**

通常会做服务供应端的自身健康检测，并上报给注册中心

在client端配置：将自己真正的健康状态传播到server。

```yaml
#不加这个的话会默认使用心跳去判断服务器是否可用，而不是通过actuator的health节点去观察，会产生错误
eureka:
  client:
    healthcheck:
      enabled: true
```

改变健康状态的Service

```java
@Service
public class HealthStatusService implements HealthIndicator{
private Boolean status = true;

public void setStatus(Boolean status) {
	this.status  = status;
}

@Override
public Health health() {
	// TODO Auto-generated method stub
	if(status)
	return new Health.Builder().up().build();
	return new Health.Builder().down().build();
}

public String getStatus() {
	// TODO Auto-generated method stub
	return this.status.toString();
}
```

```java
	@GetMapping("/health")
	public String health(@RequestParam("status") Boolean status) {
		
		healthStatusSrv.setStatus(status);
		return healthStatusSrv.getStatus();
	}
```

##### provider

```yaml
spring:
  application:
    name: provider
  profiles:
    active: dev2
---
spring:
  config:
    activate:
      on-profile: dev1
server:
  port: 7072
eureka:
  client:
    service-url:
      defaultZone: http://eureka1:7070/eureka/
#  instance:
#    hostname: provider1
---
spring:
  config:
    activate:
      on-profile: dev2
server:
  port: 7073
eureka:
  client:
    service-url:
      defaultZone: http://eureka1:7070/eureka/
      #如果加了hostname那么一定要配对应的hosts文件，默认是当前主机名
#  instance:
#    hostname: provider2
```

##### consumer
```properties
eureka.client.serviceUrl.defaultZone=http://eureka2:8080/eureka/
eureka.instance.appname=clientConsumer
server.port=8082
```

#### 整合security

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
```

```properties
spring.security.user.name=jiahao
spring.security.user.password=123456

# 连接的时候带用户名和密码
defaultZone: http://jiahao:123456@eureka2:8081/eureka/
```

新版本security会有防止csrf攻击的问题，如下方式解决

```java
@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter{

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		// TODO Auto-generated method stub
		http.csrf().disable();
		super.configure(http);
	}

}
```

#### 负载均衡

​		当系统面临大量的用户访问，负载过高的时候，通常会增加服务器数量来进行横向扩展（集群），多个服务器的负载需要均衡，以免出现服务器负载不均衡，部分服务器负载较大，部分服务器负载较小的情况。通过负载均衡，使得集群中服务器的负载保持在稳定高效的状态，从而提高整个系统的处理能力。

```sh
软件负载均衡：nginx,lvs

硬件负载均衡：F5

我们只关注软件负载均衡，
第一层可以用DNS，配置多个A记录，让DNS做第一层分发。
第二层用比较流行的是反向代理，核心原理：代理根据一定规则，将http请求转发到服务器集群的单一服务器上。
```

软件负载均衡分为：服务端（集中式），客户端。

服务端负载均衡：在客户端和服务端中间使用代理，nginx。

客户端负载均衡：根据自己的情况做负载。Ribbon就是。

客户端负载均衡和服务端负载均衡最大的区别在于 ***服务端地址列表的存储位置，以及负载算法在哪里***。

[ribbon官网](https://github.com/Netflix/ribbon)

##### 基于客户端

在客户端上存放服务列表，新版本（3.x.x）客户端移除了Ribbon, Hystrix, Zuul 和 Turbine，默认实现使用BlockingLoadBalancerClient

**Ribbon**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
</dependency>
```

choose的时候使用负载均衡策略

内置策略如下

> 默认实现：
>
> ZoneAvoidanceRule（区域权衡策略）：复合判断Server所在区域的性能和Server的可用性，轮询选择服务器。
>
> 其他规则：
>
> BestAvailableRule（最低并发策略）：会先过滤掉由于多次访问故障而处于断路器跳闸状态的服务，然后选择一个并发量最小的服务。逐个找服务，如果断路器打开，则忽略。
>
> RoundRobinRule（轮询策略）：以简单轮询选择一个服务器。按顺序循环选择一个server。
>
> RandomRule（随机策略）：随机选择一个服务器。
>
> AvailabilityFilteringRule（可用过滤策略）：会先过滤掉多次访问故障而处于断路器跳闸状态的服务和过滤并发的连接数量超过阀值得服务，然后对剩余的服务列表安装轮询策略进行访问。
>
> WeightedResponseTimeRule（响应时间加权策略）：据平均响应时间计算所有的服务的权重，响应时间越快服务权重越大，容易被选中的概率就越高。刚启动时，如果统计信息不中，则使用RoundRobinRule(轮询)策略，等统计的信息足够了会自动的切换到WeightedResponseTimeRule。响应时间长，权重低，被选择的概率低。反之，同样道理。此策略综合了各种因素（网络，磁盘，IO等），这些因素直接影响响应时间。
>
> RetryRule（重试策略）：先按照RoundRobinRule(轮询)的策略获取服务，如果获取的服务失败则在指定的时间会进行重试，进行获取可用的服务。如多次获取某个服务失败，就不会再次获取该服务。主要是在一个时间段内，如果选择一个服务不成功，就继续找可用的服务，直到超时。

*切换负载均衡策略*

1.bean

```java
@Bean
	public IRule myRule(){
		//return new RoundRobinRule();
		//return new RandomRule();
		return new RetryRule(); 
```

2.配置文件

```properties
provider.ribbon.NFLoadBalancerRuleClassName=com.netflix.loadbalancer.RandomRule
```

**Ribbon脱离Eureka**

```sh
ribbon.eureka.enabled=false
ribbon.listOfServers=localhost:80,localhost:81
```

为service-sms设置 请求的网络地址列表。

Ribbon可以和服务注册中心Eureka一起工作，从服务注册中心获取服务端的地址信息，也可以在配置文件中使用listOfServers字段来设置服务端地址。

**Ribbon配合restTemplate**

```java
@Bean
@LoadBalanced
public RestTemplate restTemplate(){
	return new RestTemplate();
}
------------
    @RequestMapping("/searchInfo1")
    public ResponseEntity<String> searchInfo1(){
        ResponseEntity<String> forEntity = restTemplate.getForEntity("http://PROVIDER/"+ URL, String.class);
        return forEntity;
    }
```

###### 为什么使用rest风格

1.支持异构，跨平台

2.HTTP请求，可插拔（不同于长连接，一直建立连接），弱依赖，无状态服务

3.生态

缺点：性能没有传输二进制对象好，增加了可用性

##### 基于服务器

在服务器（网关）上存放服务列表

#### feign的坑
在进行feign的参数配置时，要使用@RequestParam注解才能正确传递值，多参数的时候，只能同时有一个@RequestBody，不写的默认@RequestBody

传多个值+对象的时候对象用@SpringQueryMap注解注释，当然也可以用@RequestBody+@RequestParam
# 杂项

**服务熔断**

指后面服务不可运行，进行一个熔断，不再向这些服务器进行请求

**服务降级**

指服务器比较忙，调用服务的时候本来要调用多个服务的，降级成调用一个服务

