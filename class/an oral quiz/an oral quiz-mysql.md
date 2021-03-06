# 描述一下数据库事务的基本特性

ACID：
> A（Atomic）：原子性，事务要么全部成功要么全部失败，不能一半成功一半失败。innodb的原子性是通过undo log和MVCC实现的
C（Consistency）：一致性，是指事务执行前执行后一致，是由AID来实现的
I（Isolation）：隔离性，是指事务之间不相互影响,是通过锁和mvcc来实现的
D（Duration）：持久化，是指事务一旦提交，数据修改就写入到磁盘，是永久的。是通过redo log来实现的

# sql join原理
总：sql join分三种simple nested join，index nested join和block nested join
分：
simple nested join：就是指从驱动表拿关联列，一行一行去非驱动表中查询，查询效率较慢
index nested join：如果非驱动表有索引，那么就使用索引嵌套查询，速度最快，索引嵌套查询是从驱动表一条一条取关联列，然后去查找非驱动表的索引，如果有值才返回值，或者当前索引非主键，进行回表
block nested join：指当前不存在索引的情况下，会将驱动表的关联列的数据放入到缓存中，然后从缓存中读取，与非驱动表进行一个匹配，然后合并返回值

# 脏读，不可重复读，幻读
脏读：读到当前事务之外别人还未提交的数据叫做脏读
不可重复读：指在一个事务中读到当前事务之外别人已经提交的数据，第一次读和第二次读数据不一致
幻读：指在读取一组数据范围的时候，由于中间有人插入或删除了符合条件的数据，导致两次读取的结果不一致（MVCC+间隙锁，幻读的产生原因是由于在使用DQL的时候使用的是快照读，而DML操作或者查询的时候用for update和lock in share mode时使用了当前读，两者一起使用导致了幻读）

## 幻读的产生原因
总：指在范围查询的时候，有其他事务插入或删除了当前范围内的数据，导致两次读出的数据不一致
分：如果说，读的时候全是快照读的话，幻读是不会产生的，innodb产生幻读的原因就是因为DML语句使用的当前读，DQL语句用的快照读，导致幻读，我们在解决的时候，通过在SQL后面加入for update或者lock in share mode可以解决幻读问题，其本质就是将快照读变成当前读，从而加入间隙锁，锁范围数据，让其他事务不能对范围数据进行操作，阻塞等待，解决幻读

# 如果数据库产生锁冲突怎么办
死锁mysql自己会处理，锁冲突的情况可以通过开启innodb_status_output_locks，然后再使用show engine innodb status检查

# 关于索引

我们知道mysql的索引的数据结构是根据不同的存储引擎来决定的，常见的MyISAM和Innodb使用的是B+树，而memory使用的是hash表。

## 为什么使用B+树

总：不管是索引还是数据，都是直接放在磁盘上的，只有磁盘IO效率提高，才能够提高查询效率。分：
首先是hash索引，虽然速度快但是只能够精确匹配，直接pass了
树结构从最早的二叉树开始，为了减少树的倾斜，产生了AVL平衡树，然后为了解决平衡树中牵一发而动全身的问题，改动成本太大，所以产生了红黑树，然而这些都没有偏离二叉树的概念，所有有一个通病就是当数据量激增时，就会产生树身过高，深度过大的问题，所以为了解决这个问题，多叉树就应运而生，产生了B树，B树解决了深度问题，但是B树的存储方式是在叶子节点和非叶子结点上都存储数据和索引，在这种情况下，我如果去读索引，还会同时读到真实数据，这样我一次IO读取到的索引数量就少很多了，会产生IO次数的增加，导致速度变慢，所以B+树在B树上进行了改进，将叶子节点和非叶子节点功能划分，在非叶子结点上只存储索引，这样增加了我一次IO读取到的索引数量，提高了效率，更加稳定，并且B树的子节点是没有互相连接的，所以用范围查询的时候只能使用先序遍历的方式进行查询，而mysql的B+树在叶子结点上有指向前面的指针和指向后面的指针，所以可以方便的进行范围查询。

## B树和B+树的区别

B树的存储方式是在叶子节点和非叶子结点上都存储数据和索引，在这种情况下，我如果去读索引，还会同时读到真实数据，这样我一次IO读取到的索引数量就少很多了，会产生IO次数的增加，导致速度变慢，所以B+树在B树上进行了改进，将叶子节点和非叶子节点功能划分，在非叶子结点上只存储索引，这样增加了我一次IO读取到的索引数量，提高了效率，更加稳定，并且B树的子节点是没有互相连接的，所以用范围查询的时候只能使用先序遍历的方式进行查询，而mysql的B+树在叶子结点上有指向前面的指针和指向后面的指针，所以可以方便的进行范围查询。

## 索引优化
1.is null和is not null无法使用索引（尽量少用，其实还是看情况的，看执行优化器怎么处理了，如果命中结果比较小的话会走索引的）
2.联合索引用的时候没有使用最左前缀原则（执行优化器可能会处理）
3.联合索引前面的字段使用范围查询（>,<,like）导致后面索引失效
4.索引列上不要做计算（隐式转化，函数转化）
5.少使用or操作符，因为只有or连接的字段均为单独索引字段时才生效
6.对于数据长度比较长的像BLOB,TEXT,VARCHAR使用全文索引类似于"abc%"
7.如果明确知道只有一条结果返回，limit能提高效率
8.关联的时候字段长度和编码不一致会导致失效
9.like查询的时候不要用%放在前面去查询，索引会失效
10.union的时候如果没有特殊要求用union all，不让他做多余的过滤操作

# MySQL分库分表
（拒绝回答，抄答案）
使用mycat或者shardingsphere中间件进行分库分表，进行水平分库，水平分表，垂直分库，垂直分表
遵循以下原则：
1.能不分尽量不分
2.一定要分要提前做好规划
3.空间换时间，做好反范式设计，分表的时候减少join

## 名词MMM,MHA,MGR（三个架构模式）
MMM（Master Master replication Management）（主备）
MHA（MySQL High Avaliable）（主备）
MGR（MySQL Group Replication）（多主/单主（读写分离））

# mysql的存储引擎
MyISAM,Innodb，memory，performance_schema,CSV,MGR_MyISAM,ARCHIVE

# innodb和MyISAM区别
1.innodb支持事务，MyISAM不支持事务
2.innodb支持行锁，MyISAM不支持行锁
3.innodb存储的时候索引与数据放在一块，MyISAM分开存储
4.innodb增删改比较块，MyISAM查询比较快
5.innodb支持外键，MyISAM不支持外键
6.innodb支持聚簇索引和非聚簇索引，MyISAM不支持聚簇索引，只支持非聚簇索引

# 谈一谈SQL调优
从几个方面来谈：表设计（设计表的时候，字段尽量简洁，存储越小越好，避免允许null值，因为null不利于加索引，允许部分数据冗余，反范式设计），连接设置（具体问题具体分析，还是要看上线之后的具体情况），sql优化（根据索引优化比如联合索引的时候用最左前缀原则，尽量少用范围查询导致后续索引失效，对于字段长的可以采取全文索引，join的时候不要用数据格式不同的数据，少用or，因为不稳定，不要用is null或者is not null，不一定能用到索引）（配合performace_schema，explain执行计划，profiling具体查看）

实际项目相关
1.把子查询移到外面来
2.冗余字段，减少join数量
3.减少函数的使用
4.最左前缀使用索引

# 聚簇索引和非聚簇索引的区别
聚簇索引就是索引和数据存放在一块，物理上按相同顺序存放，非聚簇索引就是不放一块

加分项：对比到MySQL中，像innodb和MyISAM就是一个典型，innodb因为存储的时候数据和索引都存到了idb中，并且B+树的叶子结点既存放也存放数据，所以为聚簇索引（成团成簇），当然也可以支持聚簇索引，MyISAM因为存储的时候索引文件放在了MYI，而数据文件放在了MYD中，在B+树的叶子结点存的是对应MYD的地址，所以为非聚簇索引

# 事务有哪些隔离级别，分别解决了什么问题
事务有四个隔离级别，分别为
1.读未提交，未解决任何问题
2.读已提交，解决了脏读问题
3.可重复读，解决了不可重复读的问题
4.串行化，解决了幻读的问题

# MySQL主从复制原理
1.Slave会开启一个IO线程来请求Master的binlog
2.Master会开启一个log dump线程来向IO线程输出binlog events
3.IO线程获取了binlog events之后将其写到slave本地的relay log（中继日志）中
4.slave开启SQL线程读取relay log并执行到从数据库

## 为什么需要中继日志
因为中继日志是顺序IO，直接append上去的，速度较快效率较高，而直接写的话，DDL和DML语句都是随机读取的，随机IO，速度较慢

# MySQL主从延时问题的产生和解决
MySQL产生主从延时的主要原因就是因为DML和DDL执行的时候是随机IO的，如果当前并发很高，binlog events数据过多，然后又因为SQL线程是单线程处理的，所以处理不过来，产生了主从延时

解决方案：5.7之后使用MTS并行复制技术

# 主从复制的模式
主主复制，一主一从，一主多从

# 如何优化SQL，查询计划的结果中看哪些相关数据
1.从前向后看，首先要看的是id，描述了SQL的执行顺序，id越大越先执行
2.然后要看访问类型（type列）
3.然后要看实际用的的索引（key），如果是联合索引这种，还要看索引长度（key_len），是否全部用到了
4.然后要看extra列，主要注意using filesort即无法使用索引

# 描述一下mysql一条数据是如何保存到数据库的
首先，一条数据结果客户端向MySQL服务器提交数据，MySQL服务器中的连接器最先接收到数据，并验证连接，然后将数据转交给分析器，进行词法分析和语法分析，转化成AST，AST是一颗由Token结点构成的树，然后再转交给优化器，优化器对语法树进行优化，（基于成本优化CBO，基于规则优化RBO），优化完成交给执行器，执行器会调用对应的存储引擎然后存储引擎和执行器一起完成数据的存储

上面是从架构方面说的怎么存储，然后说说执行器接收到sql语句后都做了啥，首先先分析当前的sql是哪种，是增删改还是查，如果是查，先从内存中找数据是否存在，如果存在就返回如果不存在就去磁盘上找，然后返回，如果是增删改，那么第一步也是从内存中找数据，找不到还是从磁盘上拿，拿到了之后对数据在内存中进行增删改操作，操作好了之后存log，存redolog和binlog（用来做数据持久化的log），还会存undolog（用来做MVCC和回滚的），存完之后再进行一个数据的写入，写入到OS buffer中，然后默认情况下每秒都会调用fsync的方法异写到磁盘上

## undolog怎么实现MVCC和回滚
undolog存的是一条链式结构，他把之前的操作的数据都保存下来了，MVCC的时候，通过对应版本号从undolog中找，然后能够找到对应版本号的数据，然后返回，从而完成MVCC功能

回滚的话也是一样的，找到链条的最老的版本进行回滚

### MVCC的具体实现

总：MVCC是依靠三个隐藏字段和undo log，read view来实现的

分：

隐藏字段分别为事务id，rowid和指向上一条记录的地址

undo log用于链式存储之前的每一个修改记录

read view用于可见性分析，read view有三个属性，分别保存了创建read view时，活跃事务的id和活跃列表中最小事务id和即将创建的下一个事务id 

当进行快照读的时候，会先从当前的数据行读出对应的事务id，即为当前事务id，然后会和生成的read view去进行计算，计算当前数据的可见性，具体算法是如果当前事务id小于read view中的最小活跃事务id，那么可见，如果大于read view中的下一个即将生成的事务id，那么代表当前的行是read view产生之后创建的，不可见，最后比较是否处理活跃列表中，如果处于活跃列表，表示事务未提交，也不可见，如果不处于，那么表示事务提交，可见

#### rc情况下的mvcc和rr情况下的mvcc有什么不同

rc情况下，mvcc的read view视图是在事务开启后每次进行快照读的都会创建，所以一旦有事务提交，就可见

rr情况下，mvcc的read view视图是在事务开启后第一次进行快照读的时候创建的，以后再重复读取都只会用第一次创好的read view，所以不会出现不可重复读的问题

ps：当前读会刷新read view
## redo log的结构和bin log的结构
redo log的结构是循环写的日志，存放的最终状态的数据，通过write pos（写入）和check point（删除位置）实现，写的时候如果写满了，就会清除前面部分的内容，然后进行写入，所以redo log存放的日志是不完整的

binlog是一个不断向后append的log，是追加写的，它存储的是完整数据，如果不够的话，会新建一个新的文件继续写，binlog中存储的数据分几类，STATEMENT,RAW和MIXED，对于STATEMENT来说，存储的是原本的SQL语句，对于RAW来说，存储的是执行完毕的那行数据，对于MIXED来说，两者混用

STATEMENT状态下，不好的点在于它存储一些计算语句比如计算当前时间的方法，会不准确
RAW状态下，不好的点在于它存储那种批处理语句，如果原本只需要一行语句插入100行数据，变成RAW模式的话就要存100行数据，MIXED结合了一下，两者都用，在变化的时候用STATEMENT，在不变的时候用RAW

## redo log 和 bin log的二阶段提交
数据写入的时候，先往redo log中写入一条prepare状态的记录，然后再向bin log中写入数据，最后提交，提交的时候吧redo log中的数据状态改成commit

这样做的好处是为了使两个日志保持最终一致性，以方便后面不管拿哪个日志来进行数据恢复，都可以恢复成正确的数据

# 描述一下mysql的乐观锁和悲观锁，锁的种类

乐观锁：mysql中不存在，如果要实现乐观锁，那么就加一个version字段，然后每次修改的时候看version的版本是否和当前版本一致，如果一致就修改然后version+1，如果不一致就放弃修改
悲观锁：mysql中绝大部分锁都是悲观锁，按锁的粒度来分可以分为行锁和表锁，行锁可以分为排他锁，共享锁，临键锁，间隙锁，记录锁等，表锁又分为意向排他锁和意向共享锁，自增锁

## 关于间隙锁，临键锁和记录锁
间隙锁：是指在索引记录之间的空隙加锁叫间隙锁
记录锁：是指在索引行上上的锁
临键锁：是指间隙锁+记录锁

### 什么时候使用间隙锁，临键锁和记录锁

RR+表无显式主键没有索引：
RR+表无显式主键有唯一索引：
RR+表无显式主键有普通索引：
RR+表有显式主键没有索引：
RR+表有显式主键有唯一索引：
RR+表有显式主键有普通索引：
RC+表无显式主键没有索引：
RC+表无显式主键有唯一索引：
RC+表无显式主键有普通索引：
RC+表有显式主键没有索引：
RC+表有显式主键有唯一索引：
RC+表有显式主键有普通索引：

## 怎么监控锁

先通过修改inoodb_status_output_lock这个属性让引擎能够输出当前锁的信息，然后用show engine innodb status进行监控，IX为意向排他锁，X为临键锁，X no gap为记录锁，X no rec为间隙锁

# 介绍mysql的锁，谈谈锁的认识

1.mysql锁分类
2.锁在哪里用，引出事务的隔离级别，为了提高数据库的并发能力
3.不同隔离级别下，不同索引加什么锁

# 做过MySQL优化吗，简单聊一下

做过，mysql的优化有很多方面

优化其实从刚开始创建表的时候就已经开始了，像我之前做的项目里面，有一个与外部系统做交互的模块，那个模块里面有一个字段存储的是ip地址，我们知道ip地址的本质其实是一个32位无符号整数，所以当时用的是int去存储的，而没有用字符串去存储，获取的时候用函数转化一下就可以了，然后要存储字段的时候，像新加坡的UEN，NRIC这种，固定位数的，10位就是10位，不会去多分配空间，寻找合适的字段进行存储，然后表设计的时候会冗余一些字段，比如说要去找account信息的时候，经常需要查询它对应的license的company信息，我就多存了一份

然后平时对于sql的优化的话我一般会走几个流程，比如说去查那个profile和performance_schema进行sql监控，然后加索引，根据explain执行计划进行一个分析，有时候还要进行参数的调优，比如说连接数啊这种的。

像我做的那个ip模块，由于dm做了太多太多的数据，因为以前也有车辆的运行记录嘛，所以老数据搬了好多进来，搬了差不多100w+吧，因为我们页面上查询条件太多了，然后那个表还连着一张很大的修改记录表，然后发现查询就变得很慢了，查询变慢了之后就找原因嘛，一个是先把当时查询用到的条件先加索引，加了索引之后去测的时候发现没效果，然后发现当时加的那个索引是联合索引，而sql语句写的时候没有遵循最左匹配原则，导致索引失效。


# antlr和calcite（mark一下）