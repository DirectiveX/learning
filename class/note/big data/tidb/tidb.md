# TiDb

[官网](https://pingcap.com/zh/product/)

## 应用场景

- 对数据一致性及高可靠、系统高可用、可扩展性、容灾要求较高的金融行业属性的场景
- 对存储容量、可扩展性、并发要求较高的海量数据及高并发的 OLTP 场景
- Real-time HTAP 场景
- 数据汇聚、二次加工处理的场景

## NewSQL

### 特点

- 无限水平扩展
- 分布式强一致性
- 完整的分布式事务处理能力与ACID特性

### 选型

常见的NewSQL：Google的Spanner和F1，缺点，只能在谷歌平台上跑

## 定义

开源分布式数据库

**好处**

1.一键水平扩容或者缩容

2.金融级高可用

3.实时 HTAP

4.云原生的分布式数据库

5.兼容 MySQL 5.7 协议和 MySQL 生态

## 数据发展的阶段

**基于管理来看**

- 人工管理阶段（数据少）
- 文件系统阶段（普通数据）
- 数据库系统阶段（大数据量）

**基于模型来看**

- 层次与网状数据管理系统（指针维护数据间的关系）
- 关系数据库管理系统（二维表维护数据间关系）
- 新一代数据库（面向对象/特定领域）

## 数据库类型

### 关系型数据

**缺点**

海量数据无法处理

MSSQL，MySQL，Oracle，DB2，PostgreSQL

### NoSQL（not only SQL）

**缺点**

不支持ACID事务，不支持复杂SQL，不保证强一致性

#### 键值对数据库

MemcacheDB，Redis

#### 文档型数据库

MongoDB

#### 列式数据库

存储结构化半结构化数据

HBase，Cassandra

#### 图数据库

存储图关系

Neo4J

### NewSQL

集合NoSQL和关系型数据库的特性

TiDB

## TiDB架构

计算与存储分离的架构(高度分层架构)（由于现阶段硬件与网络的发展推动了这一架构）

![tidb-architecture-v3.1](picture/tidb-architecture-v3.1.png)

### 核心组件

#### TiDB Server（集群三核之一）

![1643470938(1)](picture/1643470938(1).png)

**计算层（无状态）**

兼容MySQL的计算引擎（>5.7），不落地数据

DDL语句，MVCC版本控制的老数据删除

1.接受客户端sql

2.解析编译

3.生成执行计划

4.执行

#### PD Server（集群三核之一）

![1643471157(1)](picture/1643471157(1).png)

**Placement Driver（大脑）**

1.负责元信息管理

2.分布式事务ID的分配

3.调度中心，分配（控制TiKV中region分布）等

> 1.每个TiKV节点定时发送自己的元信息给PD（分片数量，Leader数量，读写吞吐量）
>
> 2.PD接收数据进行计算，发出平衡调度（例如将region从较多的节点移动到少的节点）

为了保证HA，PD为三节点并且遵从raft协议

#### TiKV Server（集群三核之一）

![1643470997(1)](picture/1643470997(1).png)

**存储层**

行式存储

分布式且支持事务的KV存储引擎，数据持久化，算子下推，自身副本高可用和强一致性（multi-raft）

##### TiFlash

列式存储（通过raft共识算法与TiKV同步）（OLAP）

![1643471221(1)](picture/1643471221(1).png)

#### TiSpark（辅助解决复杂OLAP）

#### TiDB Operator（简化云上管理）

## 与MySQL差别

|                                                              | TiDB                                                         | MySQL        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------ |
| 默认排序规则                                                 | 二进制排序（区分大小写）                                     | 不区分大小写 |
| MySQL 复制协议                                               | 不支持 （[TiDB Data Migration (DM)](https://docs.pingcap.com/zh/tidb-data-migration/stable/overview)）（[TiCDC](https://docs.pingcap.com/zh/tidb/stable/ticdc-overview)） | 支持         |
| 存储过程与函数                                               | 不支持                                                       | 支持         |
| 触发器                                                       | 不支持                                                       | 支持         |
| 事件                                                         | 不支持                                                       | 支持         |
| 自定义函数                                                   | 不支持                                                       | 支持         |
| 外键约束                                                     | 不支持                                                       | 支持         |
| 全文/空间函数与索引                                          | 不支持                                                       | 支持         |
| 非`ascii`/`latin1`/`binary`/`utf8`/`utf8mb4` 的字符集        | 不支持                                                       | 支持         |
| SYS schema                                                   | 不支持                                                       | 支持         |
| MySQL 追踪优化器                                             | 不支持                                                       | 支持         |
| XML 函数                                                     | 不支持                                                       | 支持         |
| X-Protocol                                                   | 不支持                                                       | 支持         |
| Savepoints                                                   | 不支持                                                       | 支持         |
| 列级权限                                                     | 不支持                                                       | 支持         |
| `XA` 语法                                                    | 不支持                                                       | 支持         |
| `CREATE TABLE tblName AS SELECT stmt` 语法                   | 不支持                                                       | 支持         |
| `CHECK TABLE` 语法                                           | 不支持                                                       | 支持         |
| `CHECKSUM TABLE` 语法                                        | 不支持                                                       | 支持         |
| `GET_LOCK` 和 `RELEASE_LOCK` 函数                            | 不支持                                                       | 支持         |
| [`LOAD DATA`](https://docs.pingcap.com/zh/tidb/stable/sql-statement-load-data) 和 `REPLACE` 关键字 | 不支持                                                       | 支持         |

# 思考

## 为什么要使用NewSQL？

1.对比RDBMS，NewSQL可以处理海量数据

2.对比NoSQL，NewSQL可以进行OLTP和OLAP

## OLTP？

联机事务处理：支持短时间内大量并发的事务操作，强调强一致性

## OLAP？

联机分析处理：复杂的只读查询，读取海量数据进行分析计算

代表作：Greenplum，TeraData，AnalyticDB

## HTAP？

混合事务 / 分析处理，Hybrid Transactional/Analytical Processing

HTAP 数据库能够在一份数据上同时支撑业务系统运行和 OLAP 场景

代表作：TiDB，HybridDB for MySQL，BaikalDB

## RTO和RPO

rto：恢复时间目标（服务容灾相关）

rpo：恢复点目标（数据容灾相关）

## 数据架构选型的一些参考？

重要性逐级递减

1.稳定性（数据不可丢失 RPO=0，HA即RTO尽量小）

2.效率

3.成本

4.安全

5.开源（社区支持）

![1643467302(1)](picture/1643467302(1).png)

