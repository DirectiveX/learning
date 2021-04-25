# Redis

## 相关常识

秒 > 毫秒 > 微秒 > 纳秒

**磁盘**
> 寻址速度：ms
> 带宽：G/M  每秒 

**内存**
> 寻址速度： ns
> 带宽：几G到几十G 每秒

**I/O Buffer**
成本问题：磁盘与磁道，扇区：512Byte
扇区小了之后导致索引成本变大
操作一般读取的时候以4K做一次读取

**mysql**
mysql将数据分页存储，一页大小为16K，读取时先将B+树的树干（非叶子节点加载到内存）进行查询，找到对应范围之后再去磁盘上进行读取

如果表特别大，性能会下降？
如果有索引，增删改变慢（因为增删改都会去修改索引），查询少量数据还是很快，并发大的时候受硬盘带宽影响速度（因为会将读出的数据加载到内存，如果落在不同的4K上，就会读取不同的区域到内存，读取的时候要看磁盘带宽，依次读取）

**SAP HANA（2T）**
内存级别的关系型数据库，太贵，用不起

ps:数据在磁盘和内存体积不一样

## 为什么要使用Redis?

因为hana用不起，磁盘型的关系型数据库的速度较慢，所以采用了折中的方法，用了非关系型数据库Redis和memcached

由于冯诺依曼体系的硬件和以太网的出现，TCP/IP的网络。导致可能出现数据不一致的情况，所以才会产生带宽问题

## Redis是什么

redis可以用作数据库，缓存，消息代理

它提供了一些数据结构，比如string，lists，sets，hashes，sorted sets，bitmap，hyperloglogs，geospatial indexes,streams

Redis具有内置的复制、Lua脚本、LRU缓存、事务和不同级别的磁盘持久性，并通过Redis 哨兵和Redis 集群的自动分区提供高可用性。

## Redis与memcached

|          | Redis                                 | memcached                  |
| -------- | ------------------------------------- | -------------------------- |
| 数据类型 | 提供list，set，hash，bitmap等数据类型 | 简单数据类型，string和整数 |
| 灾难恢复 | 可以通过aof恢复                       | 无法恢复                   |
| 数据备份 | 支持                                  | 不支持                     |
| 执行速度 | 慢                                    | 快                         |
| 线程     | 单线程                                | 多线程                     |

## epoll
### BIO到NIO的发展
很久很久以前，用户向内核态发送读取文件请求的时候，会先通过内核的socket方法去查询fd，然后调用内核的read方法去根据fd（文件描述符）进行一个文件的读取，这时候由于socket是一个阻塞的查询，需要打开多个线程进行一个单独的查询和读取，这时候就是BIO的时代

然后后来发现socket出现了阻塞查询（底层调用accept方法，阻塞等待用户连接）的问题，内核发生了改变，增加了socket的type，提供了一种非阻塞的socket调用，提供了非阻塞调用后，此时我们可以使用单线程轮循去请求fd文件（可能成功也可能失败，因为非阻塞socket有可能不返回fd），此时是一个同步非阻塞时期（NIO的时代降临了）

然后发现了轮循请求数量多的时候，每一次socket都会切换进内核态，产生内核态和用户态的切换，成本过高。此时内核进行了升级，内核开始提供select方法，select方法接收一组文件描述符（单线程监听很多socket请求），在内核态进行一个批量监控（可以同时管理监听套接字和连接套接字），返回一批的fds，再去循环调用read，此时依然在NIO时代，这项技术叫多路复用（用一个线程去监控多个I/O流的状态）的NIO

然后发现用户态和内核态的fds数据交互会产生速度上的瓶颈，内核态再次升级，就产生了mmap方法（内存映射，将文件或者设备跟内存地址进行一个映射），提供一个共享空间，用epoll去控制I/O流，用户态和内核态共同访问一份内核中的数据，此时依然在NIO时代，但是速度更快了。在共享空间中，I/O请求注册在红黑树中，文件描述符返回放入链表中

ps：mmap并不是0拷贝，0拷贝是用sendfile方法去实现的，mmap表示的是设备与内存间的映射（可以挂载到设备或者文件），sendfile的意思是不对文件进行任何的操作，直接从一个地址拷贝文件到另外一个输出地址

ps：kafka通过mmap挂载了文件，将数据写入共享空间内，然后kernel通过观察到共享空间的变化，对文件进行一个直接更改。消费者消费的时候使用sendfile对文件进行0拷贝发送给对应的socket

注意：0拷贝和mmap的本质区别是，0拷贝不通过用户态，不能进行一个文件修改，但是mmap可以对文件进行修改

### select/poll/epoll
select 是最早出现了，它实现了对一组fds的监控，但是它有很多问题，比如不支持多线程，还有一旦有一个或者多个fds获取了，就会立即返回但是不告诉用户放在链表中的哪个位置，如果I/O流较多的情况下，遍历一次链表的成本也是很高的，并且它还有1024连接数的限制，而且会修改传入参数

为了解决以上问题，poll出现了，poll打破了1024的规定，不会修改传入参数，但是还是没有解决多线程和位置问题

后来，epoll解决了多线程和位置（告诉具体在链表的哪个位置）问题，在并发很高，量级很大的情况下，poll和select处理速度都会变得很慢，但是epoll不受影响
epoll是一组指令
epoll_create 创建epoll fd
epoll_ctl 在epoll fd中注册/删除/修改事件
epoll_wait 等待I/O事件在epoll fd上的发生

### AIO
异步非阻塞IO，指read的过程也交给内核去做，read请求注册到内核中，用户线程不用去关心什么时候进行read操作

## redis原理
redis是单进程，单线程（指的是对数据的处理是单线程的，内部实际上还是有很多线程的），单实例的
对于多个客户端的访问，redis调用内核的epoll方法来达到多路复用，检查哪个请求产生了数据
对于每个连接请求，每个连接内的命令是顺序的

当客户端向服务器发送请求，请求发送到内核态，redis调用epoll命令对请求进行一个获取并解析数据，redis获取解析数据的过程是单线程的，然后再返回数据

PS: redis 的 key上带了value的数据类型（防止用户请求数据不是对应的类型，如果类型不对应，就直接不进行查询，加快查询速度），还带了encoding（用来判断进行一些数值计算钱，是否要进行转化的排错检测）和value的length长度。

PS：redis是二进制安全的，所以永远读的字节流，不会读字符流，这样只要对应的服务器编解码一致，就不会产生数据问题

## Redis使用
### 帮助
help @xxx
eg: help @string,help @list,help @set

### generic
查看数据类型
> type k

value的类型（会改变，但是只要显示了那种类型，那么肯定符合）
> object encoding k

所有的key
>keys *

### 字符串命令（主要包含了string的操作，数值的操作，二进制位的操作）
设置k-v(默认有16个库，从0-15)
> set abc 123

通过k获取v
> get abc

选择数据库
> select [n]

清除数据库
> flushdb/flushall

设置k-v时如果没有值就创建，有值不动
> set k v nx

设置k-v时如果有值就更新,没值不管
> set k v xx

设置一组kv(多笔操作的时候是原子操作)
> mset k1 v1 k2 v2

获取一组kv
> mget k1 k2

向key追加一些数据
> append k1 vaaa

找value中的部分值
> getrange k 0 1
> 可以使用负向索引 getrange k 0 -1

找value中的长度
> strlen k

统计字符串被设置为1的bit数
> bitcount k

找第一个出现0/1的位置
> bitpos k 0 [start] [end]
> start end为开始结束的字节位置

在字符串之间执行位运算
> bitop and destkey  k1 k2

对于数字类型编码的value，向上+1/-1
> incr k1
> decr k1

对于数字类型编码的value，向上+n/-n
> incrby k1 n
> decrby k1 n

对于数字类型编码的value，向上+n/-n(n为小数)
> incrbyfloat k1 n
> decrbyfloat k1 n

设置新值，返回老值
> getset k xxx

#### 位图的使用
1.有用户系统，统计某个用户登陆天数，且窗口随机
数据结构：key为用户id，value为bitmap，每一位存储的是365天用户是否登陆
setbit + bitcount就能完成

2.计算活跃用户的数量
数据结构：key为日期，value为bitmap，每一位对每个用户进行一个标识，标识用户是否在那天登陆
setbit 去设置，使用bitop 进行或运算，然后用bitcount计算人数

### List的使用
> BITCOUNT key [start end]
  summary: Count set bits in a string
  since: 2.6.0
  group: string

阻塞弹出左边元素
> BLPOP key [key ...] timeout
  summary: Remove and get the first element in a list, or block until one is available
  since: 2.0.0

阻塞弹出右边元素
> BRPOP key [key ...] timeout
  summary: Remove and get the last element in a list, or block until one is available
  since: 2.0.0

> BRPOPLPUSH source destination timeout
  summary: Pop a value from a list, push it to another list and return it; or block until one is available

按索引查找
> LINDEX key index
  summary: Get an element from a list by its index

在某个值（注意不是索引）前/后插入一个值（注意只插入一个，并且是第一个位置插入）
> LINSERT key BEFORE|AFTER pivot value
  summary: Insert an element before or after another element in a list

list的大小
> LLEN key
  summary: Get the length of a list

从左边弹出元素
> LPOP key
  summary: Remove and get the first element in a list

从左边添加多个元素到list中
> LPUSH key value [value ...]
  summary: Prepend one or multiple values to a list

当list存在时向左追加一个值
> LPUSHX key value
  summary: Prepend a value to a list, only if the list exists

按索引范围查找
> LRANGE key start stop
  summary: Get a range of elements from a list

正负向移除对应个数的value
> LREM key count value
  summary: Remove elements from a list

按索引设置
> LSET key index value
  summary: Set the value of an element in a list by its index

保留start stop之间的数据，对两端数据进行删除
> LTRIM key start stop
  summary: Trim a list to the specified range

从右边弹出元素
> RPOP key
  summary: Remove and get the last element in a list

> RPOPLPUSH source destination
  summary: Remove the last element in a list, prepend it to another list and return it

> RPUSH key value [value ...]
  summary: Append one or multiple values to a list

当list存在时向右追加一个值
> RPUSHX key value
  summary: Append a value to a list, only if the list exists


#### list 数据结构
key上带的头尾指针 + 双向链表

#### list描述java的数据结构
同向命令可以描述 栈
反向命令可以描述 队列
索引操作可以描述 数组
阻塞命令可以描述 阻塞队列（单播队列FIFO）

### hash
#### 数据结构
k-v中的v是hash，每个hash中又有键值对

#### 使用
删除key中的属性
> HDEL key field [field ...]
        summary: Delete one or more hash fields

查看属性是否存在
>         HEXISTS key field
        summary: Determine if a hash field exists

获取key中的属性对应的值
>         HGET key field
        summary: Get the value of a hash field

获取key中的所有属性以及属性对应的值
>         HGETALL key
        summary: Get all the fields and values in a hash

对数值类型进行一个整形加运算
>         HINCRBY key field increment
        summary: Increment the integer value of a hash field by the given number

对数值类型进行一个浮点加运算
>         HINCRBYFLOAT key field increment
        summary: Increment the float value of a hash field by the given amount

获取key中所有属性
>         HKEYS key
        summary: Get all the fields in a hash

查看key中有多少属性
>         HLEN key
        summary: Get the number of fields in a hash

批量根据field获取值
>         HMGET key field [field ...]
        summary: Get the values of all the given hash fields

批量根据field设置值
>         HMSET key field value [field value ...]
        summary: Set multiple hash fields to multiple values

随机获取一个或多个属性
>         HRANDFIELD key [count [WITHVALUES]]
        summary: Get one or multiple random fields from a hash

fw（redis 6.2.2有问题）
>         HSCAN key cursor [MATCH pattern] [COUNT count]
        summary: Incrementally iterate hash fields and associated values

设置key 和 field
>         HSET key field value [field value ...]
        summary: Set the string value of a hash field

当field不存在时，设置key 和 field
>         HSETNX key field value
        summary: Set the value of a hash field, only if the field does not exist

获取属性长度
>         HSTRLEN key field
        summary: Get the length of the value of a hash field
        HVALS key
        summary: Get all the values in a hash

key中所有属性的所有值
>    HVALS key
  summary: Get all the values in a hash

#### 应用场景
对一组数据对象的存取，比如页面详情页，可以做数值计算

### set
#### 使用
添加元素
>SADD key member [member ...]
summary: Add one or more members to a set

获取集合大小
>SCARD key
summary: Get the number of members in a set

求差集
>SDIFF key [key ...]
summary: Subtract multiple sets

求差集并放入目标集合
>SDIFFSTORE destination key [key ...]
summary: Subtract multiple sets and store the resulting set in a key

求交集
>SINTER key [key ...]
summary: Intersect multiple sets

求交集并放入目标集合
>SINTERSTORE destination key [key ...]
summary: Intersect multiple sets and store the resulting set in a key

判断集合中是否包含某值
>SISMEMBER key member
summary: Determine if a given value is a member of a set

获取集合中所有值
>SMEMBERS key
summary: Get all the members in a set

判断集合中是否包含某些值
>SMISMEMBER key member [member ...]
summary: Returns the membership associated with the given elements for a set

从某个集合中移动一个值到另一个集合中
>SMOVE source destination member
summary: Move a member from one set to another

移除返回一/多个随机值
>SPOP key [count]
summary: Remove and return one or multiple random members from a set
>应用场景：一个个抽奖

获取一个随机值，如果正数，尽量满足要求，最多为集合大小，如果负数，可能出现重复值，一定满足要求
>SRANDMEMBER key [count]
>summary: Get one or multiple random members from a set
>应用场景：一起抽奖

移除一个或多个值
>SREM key member [member ...]
summary: Remove one or more members from a set

迭代遍历
>SSCAN key cursor [MATCH pattern] [COUNT count]
summary: Incrementally iterate Set elements

求并集
>SUNION key [key ...]
summary: Add multiple sets

求并集并放入目标集合
>SUNIONSTORE destination key [key ...]
summary: Add multiple sets and store the resulting set in a key

### sorted set
#### 数据结构
跳表实现排序（跳表是随机造层的，元素较多时，平均值相对较优）
链表
物理内存左小右大
存放的value是分值+元素

ps：随机造层：可是到底要不要插入上一层呢？跳表的思路是抛硬币，听天由命，产生一个随机数，50%概率再向上扩展，否则就结束。这样子，每一个元素能够有X层的概率为0.5^(X-1)次方
#### 使用

>BZPOPMAX key [key ...] timeout
>summary: Remove and return the member with the highest score from one or more sorted sets, or block until one is available

>BZPOPMIN key [key ...] timeout
>summary: Remove and return the member with the lowest score from one or more sorted sets, or block until one is available

添加元素，附带分值，类型
>ZADD key [NX|XX] [GT|LT] [CH] [INCR] score member [score member ...]
>summary: Add one or more members to a sorted set, or update its score if it already exists

查询有多少元素
>ZCARD key
>summary: Get the number of members in a sorted set

计算分值在最大最小值之间的值
>ZCOUNT key min max
>summary: Count the members in a sorted set with scores within the given values

>ZDIFF numkeys key [key ...] [WITHSCORES]
>summary: Subtract multiple sorted sets

>ZDIFFSTORE destination numkeys key [key ...]
>summary: Subtract multiple sorted sets and store the resulting sorted set in a new key

增加分值，可以为浮点数
>ZINCRBY key increment member
>summary: Increment the score of a member in a sorted set
>场景：排行榜

>ZINTER numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX] [WITHSCORES]
>summary: Intersect multiple sorted sets

>ZINTERSTORE destination numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]
>summary: Intersect multiple sorted sets and store the resulting sorted set in a new key

>ZLEXCOUNT key min max
>summary: Count the number of members in a sorted set between a given lexicographical range

>ZMSCORE key member [member ...]
>summary: Get the score associated with the given members in a sorted set

>ZPOPMAX key [count]
>summary: Remove and return members with the highest scores in a sorted set

>ZPOPMIN key [count]
>summary: Remove and return members with the lowest scores in a sorted set

获取一/多个随机元素（带分值）
>ZRANDMEMBER key [count [WITHSCORES]]
>summary: Get one or multiple random elements from a sorted set

获取索引范围内的元素
>ZRANGE key min max [BYSCORE|BYLEX] [REV] [LIMIT offset count] [WITHSCORES]
>summary: Return a range of members in a sorted set

>ZRANGEBYLEX key min max [LIMIT offset count]
>summary: Return a range of members in a sorted set, by lexicographical range

获取分值范围内的元素
>ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]
>summary: Return a range of members in a sorted set, by score

>ZRANGESTORE dst src min max [BYSCORE|BYLEX] [REV] [LIMIT offset count]
>summary: Store a range of members from sorted set into another key

算出元素的位置
>ZRANK key member
>summary: Determine the index of a member in a sorted set

根据元素移除对应元素
>ZREM key member [member ...]
>summary: Remove one or more members from a sorted set

>ZREMRANGEBYLEX key min max
>summary: Remove all members in a sorted set between the given lexicographical range

>ZREMRANGEBYRANK key start stop
>summary: Remove all members in a sorted set within the given indexes

>ZREMRANGEBYSCORE key min max
>summary: Remove all members in a sorted set within the given scores

>ZREVRANGE key start stop [WITHSCORES]
>summary: Return a range of members in a sorted set, by index, with scores ordered from high to low

>ZREVRANGEBYLEX key max min [LIMIT offset count]
>summary: Return a range of members in a sorted set, by lexicographical range, ordered from higher to lower strings.

>ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]
>summary: Return a range of members in a sorted set, by score, with scores ordered from high to low

>ZREVRANK key member
>summary: Determine the index of a member in a sorted set, with scores ordered from high to low

>ZSCAN key cursor [MATCH pattern] [COUNT count]
>summary: Incrementally iterate sorted sets elements and associated scores

查看元素的分值
>ZSCORE key member
>summary: Get the score associated with the given member in a sorted set

带分值求并集
>ZUNION numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX] [WITHSCORES]
>summary: Add multiple sorted sets
>ps：numkeys -- key数量
>WEIGHTS weigh -- 权重，按分数比例相乘
>AGGREGATE SUM|MIN|MAX --求值策略

带分值求并集并放入目标key
>ZUNIONSTORE destination numkeys key [key ...] [WEIGHTS weight] [AGGREGATE SUM|MIN|MAX]
>summary: Add multiple sorted sets and store the resulting sorted set in a new key

ps：带REV的都是反向命令
# 数据库引擎

https://db-engines.com/en/

技术选型

# JVM中一个线程的成本
栈默认是1MB
线程多了，线程间切换成本高，内存成本高

# 杂项
1.字符集 ascii
其他字符集都叫做扩展字符集
ascii码一般形式为0xxxxxxx
扩展的意思是其他字符集不会再对ascii码进行重编码