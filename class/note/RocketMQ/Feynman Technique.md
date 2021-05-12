# MQ选用问题

## 使用的什么MQ？

RocketMQ

## 有什么好处？

**解耦**

服务解耦，服务之间相互调用产生了强依赖关系，如果服务a调用服务b，需要服务b的返回，那么服务b一旦下线，会直接导致服务a不可用，使用MQ解决了这一问题，通过将数据先放到MQ中，然后直接返回给服务a成功的信息

**异步**

微服务之间的调用如果不使用MQ，直接调用，等待其他服务的返回，就会产生同步调用，网络是不可控的，有可能由于网络原因导致响应时间过长，加入了MQ之后就可以进行异步调用了，先把数据放入MQ中，等待后续的consumer进行消费

**削峰**

每个时间段数据的流量不一致，有可能在某个时间段数据特别多，服务器需要做一个限流削峰的操作，来防止服务器响应过慢或者被击瘫，如果服务器能够支撑的流量小于到达的流量，做了限流可能会产生数据丢失，需要MQ对数据进行一个暂存，让consumer可以均匀的消费数据

## 关于MQ的选型？

市面上常见的MQ有ActiveMQ，RocketMQ，RabbitMQ还有Kafka，正常来说，如果数据体量小，选用ActiveMQ，不然的话选其他三种，其他三种综合来讲差不太多，主要看项目组的熟悉程度，选用大家都熟悉的MQ进行开发，然后后三种也有一些小区别，比如说RabbitMQ由于Erlang的语言的天然优势，天然支持分布式的，所以RabbitMQ响应速度较快，延迟较低，但是RocketMQ和Kafka吞吐量相对高一点，RocketMQ是用Java写的，对于开发人员来说更加熟悉，做定制化更加的简单，RocketMQ使用相对方便，提供了一些电商所需要的的api，比如说顺序消费，Kafka的吞吐量是最高的，Kafka给自己的初始定位就是处理数据体量较大的情况，它同时使用了mmap和sendfile两张零拷贝技术，对于大数据的处理是比较快速的，但是使用时要开发自己的api

# RocketMQ由哪些角色组成，作用和特点是什么？

RocketMQ主要由4个角色组成，分别是nameserver，broker，consumer和producer

首先是nameserver，是一个注册中心的功能，底层使用netty实现，它的特点是一个无状态服务器，无状态服务器的意思是指它不会持久化状态，所有状态都存储在内存中。nameserver存放的是路由消息，可以通过topic找到对应的broker。它可以构成nameserver集群，不过各个nameserver之间是互不通讯的，新的nameserver上线后，broker可以通过动态列表来感知

然后是broker，broker是一个消息的存储区域，用来存放具体的消息的服务器

然后是consumer，是消费者，消费消息的

然后是producer，是生产者，向broker中生产消息的

## RocketMQ中的Topic和ActiveMQ的Topic有什么区别？

因为RocketMQ没有遵循jms协议，所以它的topic的定义与ActiveMQ中有所不同，它的topic是一个逻辑上的概念，而ActiveMQ中的Topic是一个物理上的概念，ActiveMQ中的Topic表示这个消息是一个广播消息，而RocketMQ中的Topic内部包含了一组Queue，通过Topic将Queue存放在不同的broker中，做负载均衡，是否是广播消息决定于consumer的消费模式

### Topic的结构

Topic的结构是有多个Queue（队列）组成的

# RocketMQ Broker中的消息消费后会立即删除吗？

不会，consumer的消费进度存储在本地（Broadcast模式），consumer的消费进度存储在broker中（Cluster模式），broker中收到消息之后会进行持久化，持久化到本地的CommitLog中。

**关于消息的删除**

默认是要超过设定的时间（4.6版本后48小时）才会删除不活跃的CommitLog（指最后一次使用时间到现在超过48小时），可以指定时间删除，默认凌晨4点

# RocketMQ消费模式有几种？

有两种，一种是Cluster模式，一种是BroadCast模式

Cluster模式中，以group name分组，拥有同一个groupname的consumer为一组，一组中的consumer消费同一个topic，找到topic下面对应的queue，根据负载均衡策略针对queue中内容进行一个消费，消费进度存储在broker中

BroadCast模式中，在同一个group name中的consumer都会收到同样的消息，消息消费进度由consumer本地维护

## 消费消息时使用的是pull还是push？

创建消费者的时候可以选择，但是实际上还是使用的pull，push的内部依然是使用pull去取数据

使用push的时候更多的属性已经封装完成，而pull的时候可以自定义抓取逻辑，不需要手动抓取

## 为什么要主动拉取消息而不使用事件监听？

主要原因是因为主动拉取消息，可以根据消费者自身的消费能力去拉取消息，不会导致消息拉取过来消费不了，或者消费速度很慢，给消费者的压力较大。如果使用事件监听，由broker去定时发送消息，就会导致消费者可能无法快速处理发过来的消息，还有一点就是broker的压力会变大，要开定时任务去发送消息

## consumer拉取数据的机制

consumer会开启一个长轮询进行数据拉取，consumer向broker发送请求，broker中如果有数据就返回，没数据就挂起，等到有数据才继续返回

# 常见的消息同步机制？

在4.5之前，使用异步写入，或者同步双写

在4.5之后，使用Dledger类来实现数据同步，Dledger类实现了raft协议的数据同步机制

# broker是如何处理拉取请求的？

1.接收到consumer的拉取请求，如果有数据直接返回数据

2.接收到consumer的拉取请求，如果没有数据，挂起请求

​      开启线程，每隔1s根据offset查询CommitLog中有没有新的消息，如果有的话将消息写入pullRequestTable，开启线程，每5s一次（如果开启了长轮询，每5秒一次，如果开启短轮询，每隔1s一次）查询pullRequestTable中是否有数据，如果有立即推送。

# RocketMQ如何做负载均衡

