

## 使用Spring Boot2.x Actuator监控应用

### 开启监控

   ```xml
<dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-starter-actuator</artifactId>
 </dependency>
   ```



 

### 默认端点

Spring Boot 2.0 的Actuator只暴露了health和info端点，提供的监控信息无法满足我们的需求

在1.x中有n多可供我们监控的节点，官方的回答是为了安全….



### 开启所有端点

在application.yml中加入如下配置信息

*代表所有节点都加载

```properties
#开启所有端点
management.endpoints.web.exposure.include=*
```



所有端点都开启后的api列表

```
{"_links":{"self":{"href":"http://localhost:8080/actuator","templated":false},"archaius":{"href":"http://localhost:8080/actuator/archaius","templated":false},"beans":{"href":"http://localhost:8080/actuator/beans","templated":false},"caches-cache":{"href":"http://localhost:8080/actuator/caches/{cache}","templated":true},"caches":{"href":"http://localhost:8080/actuator/caches","templated":false},"health":{"href":"http://localhost:8080/actuator/health","templated":false},"health-path":{"href":"http://localhost:8080/actuator/health/{*path}","templated":true},"info":{"href":"http://localhost:8080/actuator/info","templated":false},"conditions":{"href":"http://localhost:8080/actuator/conditions","templated":false},"configprops":{"href":"http://localhost:8080/actuator/configprops","templated":false},"env":{"href":"http://localhost:8080/actuator/env","templated":false},"env-toMatch":{"href":"http://localhost:8080/actuator/env/{toMatch}","templated":true},"loggers":{"href":"http://localhost:8080/actuator/loggers","templated":false},"loggers-name":{"href":"http://localhost:8080/actuator/loggers/{name}","templated":true},"heapdump":{"href":"http://localhost:8080/actuator/heapdump","templated":false},"threaddump":{"href":"http://localhost:8080/actuator/threaddump","templated":false},"metrics":{"href":"http://localhost:8080/actuator/metrics","templated":false},"metrics-requiredMetricName":{"href":"http://localhost:8080/actuator/metrics/{requiredMetricName}","templated":true},"scheduledtasks":{"href":"http://localhost:8080/actuator/scheduledtasks","templated":false},"mappings":{"href":"http://localhost:8080/actuator/mappings","templated":false},"refresh":{"href":"http://localhost:8080/actuator/refresh","templated":false},"features":{"href":"http://localhost:8080/actuator/features","templated":false},"service-registry":{"href":"http://localhost:8080/actuator/service-registry","templated":false}}}
```



### api端点功能

#### Health

会显示系统状态

{"status":"UP"}

 

#### shutdown 

用来关闭节点

开启远程关闭功能

```properties
management.endpoint.shutdown.enabled=true
```



使用Post方式请求端点

{

  "message": "Shutting down, bye..."

}

 

 autoconfig 

获取应用的自动化配置报告 
 beans 

获取应用上下文中创建的所有Bean 

 

#### configprops 

获取应用中配置的属性信息报告 

  

#### env 

获取应用所有可用的环境属性报告 

#### Mappings

 获取应用所有Spring Web的控制器映射关系报告

####  info 

获取应用自定义的信息 

#### metrics

返回应用的各类重要度量指标信息 

**Metrics**节点并没有返回全量信息，我们可以通过不同的**key**去加载我们想要的值

 metrics/jvm.memory.max

 

### Threaddump

1.x中为**dump**

返回程序运行中的线程信息 

 

 

东宝商城（仿淘宝）项目技术架构图
高并发电商系统瓶颈分析
秒杀系统多级“读、写”分离
神一样的CAP定理以及BASE理论