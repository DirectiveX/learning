## Pipelining管道
一次请求发送多条命令到服务器，再获取返回值，节省往返时间

### 操作
安装nc指令
> echo -e "set k v" | nc localhost 6379

###  nc命令
NetCat，在网络工具中有“瑞士军刀”美誉，其有Windows和Linux的版本。因为它短小精悍（1.84版本也不过25k，旧版本或缩减版甚至更小）、功能实用，被设计为一个简单、可靠的网络工具，可通过TCP或UDP协议传输读写数据。同时，它还是一个网络应用Debug分析器，因为它可以根据需要创建各种不同类型的网络连接。

### 冷加载
从文件中读取多个指令。通过管道送入到redis服务器中
http://www.redis.cn/topics/batch-insert.html

1.下载unix2dos指令，用于转换\n变成\n\r
2.书写指令文件，并且使用unix2dos指令  unix2dos xxx.txt
3.建立管道进行通讯 cat d.txt | redis-cli --pipe

## redis发布订阅的使用
help @pubsub

### 指令
消费发布到通道的符合规则的消息
> PSUBSCRIBE pattern [pattern ...]
  summary: Listen for messages published to channels matching the given patterns

发布消息到通道中
> PUBLISH channel message
  summary: Post a message to a channel

检查发布订阅系统状态
> PUBSUB subcommand [argument [argument ...]]
  summary: Inspect the state of the Pub/Sub subsystem

退订指定模式
> PUNSUBSCRIBE [pattern [pattern ...]]
  summary: Stop listening for messages posted to channels matching the given patterns

从通道中消费消息（注意只有先监听才能收到监听后其他客户端发送来的请求）
> SUBSCRIBE channel [channel ...]
  summary: Listen for messages published to the given channels

停止从部分通道中消费消息
> UNSUBSCRIBE [channel [channel ...]]
  summary: Stop listening for messages posted to the given channels

### 应用场景
聊天群
分为三类聊天数据（读取）
1.实时性的，使用pub/sub，发布订阅模式
2.历史性的
  三天内的，用redis缓存，可以用sort_set进行一个排序
  更老的，放入磁盘数据库

存储：用户向redis服务器发送消息，redis服务器订阅并存储消息到sorted_set，然后其他用户和RS也订阅消息

## redis事务
### 指令
取消事务
> DISCARD -
  summary: Discard all commands issued after MULTI

开始执行所有命令
> EXEC -
  summary: Execute all commands issued after MULTI

标记事务的开始
> MULTI -
  summary: Mark the start of a transaction block

忘记观察键的修改
> UNWATCH -
  summary: Forget about all watched keys

提供CAS，一旦watch的键被修改了，所有事务都不执行
> WATCH key [key ...]
  summary: Watch the given keys to determine execution of the MULTI/EXEC block

### redis不支持回滚的一个解释
1.不支持回滚让redis更快
2.redis只会因为错误语法而失败，可以通过编程去修正这些错误

## 布隆过滤器
解决缓存穿透问题

什么是缓存穿透？
就是查询一些redis中和数据库中都不存在的数据，请求直接到达数据库，导致进行了无用操作，给数据库服务器增加了压力

bloom过滤器如何解决缓存穿透问题？
通过一些映射函数将数据库中的数据元素映射到布隆过滤器的位图上，然后客户端进行请求的时候，先看redis中是否存在，如果不存在，再看布隆过滤器的位图中经过映射函数算出的每个位是否都是1，如果都是1，那么就去数据库查询，不然直接返回空。
由于函数映射涉及的位置不是一对一的，所以有概率请求仍然会穿透到数据库，造成不必要的浪费，但是经过测试，bloom过滤器可以阻挡住99%以上的穿透

ps：如果数据不巧穿透了，但是db取不出数据，可以加入一个key到redis中，将value置为null。如果db被加入了数据，需要同步加入到bloom过滤器中
### 使用
扩展功能模块
redis-server --loadmodule ./redisbloom.so

ps：redisbloom.so相当于windows中的dll文件
### BF命令(Bloom)

### CF命令(Cuckoo)

### ps：布谷鸟过滤器（Cuckoo）
bloom vs cuckoo
Bloom过滤器在插入项时通常表现出更好的性能和可伸缩性（因此，如果您经常向数据集添加项，那么Bloom过滤器可能是理想的）。布谷鸟过滤器检查操作更快，也允许删除。

## redis缓存
用于解决数据的读请求