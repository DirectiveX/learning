# 核心思想

- 分而治之
- 并行计算
- 计算向数据移动
- 数据本地化读取

# Hadoop

hadoop是apache旗下的顶级项目

大数据生态：[cloudera](https://www.cloudera.com/)

##  [官网](http://hadoop.apache.org/)

## 思考

单机的瓶颈在哪？

磁盘IO

## HDFS

### 思考

文件系统那么多，为什么hadoop项目中还要开发一个hdfs文件系统？

为了支持分布式计算

### 存储模型

- 文件线性按字节切割成块，有offset，id
- 文件与文件的block大小可以不一样
- 一个文件除最后一个block，其他block大小一致
- 单个文件block大小相等，除了最后一个block
- block大小依据硬件的I/O特性调整
- block被分散存放在集群的节点中，具有location
- block具有副本，没有主从概念，副本不能出现在同一节点
- 副本是满足可靠性和性能的关键
- 文件上传可以指定block大小和副本数，上传后只能修改副本数
- 一次写入多次读取，不支持修改
- 支持追加数据

### 架构设计

- 主从架构
- 由NameNode和一些DataNode组成
- 面向文件包含：文件数据和文件元数据
- NameNode负责存储和管理文件元数据，并维护了一个层次型的文件目录树
- DataNode负责存储文件数据（Block块），并提供block的读写
- DataNode与NameNode维护心跳，并汇报自己持有的block信息
- Client和NameNode交互文件元数据和DataNode交互文件block数据

### NameNode和DataNode

NameNode
> 完全基于内存存储文件元数据，目录结构，文件block的映射
> 需要持久化方案
> 提供副本放置策略：
>
> > 第一个副本：放置在上传文件的DN，如果是集群外提交，则随机挑选一台磁盘不太满，CPU不太忙的节点
> >第二个副本：放置在于第一个副本不同的机架的节点上
> > 第三个副本：与第二个副本相同机架的节点
> > 更多副本：随机节点

DataNode
> 基于本地磁盘存储block（文件形式）
> 并保存block的校验和数据保证block的可靠性
> 与NameNode保持心跳，汇报block列表状态

#### 元数据持久化
EditsLog：日志（恢复速度慢，实时保存，体积膨胀）
FsImage：镜像，快照（恢复速度块，容易丢失数据，体积小）

**FI时点的滚动更新**
第一次开机的时候只写一次FI，假设8到9之间的增量EL，去分析EL，再根据当前FI进行合并

**安全模式**

- HDFS搭建时会格式化，格式化操作会产生一个空的FsImage

- 当NameNode启动时，它从硬盘中读取EditLog和FsImage

- 将所有Editlog中的事务作用在内存中的FsImage上

- 并将这个新版本的FsImage从内存中保存到本地磁盘上

- 然后删除旧的Editlog

  

- NameNode启动后会进入安全模式

- 安全模式的NameNode不会进行数据块复制
- NameNode从所有的DataNode接收心跳信号和块状态报告
- 每当NameNode检测确认某个数据块的副本数目达到这个最小值，那么该数据块就会被认为是副本安全的
- 在一定百分比的数据块被NameNode检测确认是安全之后（再加上一个额外的30s等待时间），NameNode将退出安全模式状态
- 接下来它会确定还有哪些数据块的副本没有达到指定数目，并将这些数据块复制到其他DataNode上

**SecondaryNameNode（SNN）**

- 在非HA模式下（2.x有HA模式），SNN一般是独立的节点，周期完成对NN的Editlog向FsImage合并，减少EditLog大小，减少NN启动时间
- 根据配置文件设置的时间间隔fs.checkpoint.period 默认3600秒
- 根据配置文件设置EditLog大小fs.checkpoint.size 规定edits文件的最大默认值是64MB

如图

![snn](picture/snn.png)

### HDFS写流程

![hdfs write flow](picture/hdfs write flow.png)

- Client和NN连接创建文件元数据
- NN判定元数据是否有效
- NN触发副本放置策略，返回一个有序的DN列表
- Client和DN建立Pipeline连接
- Client将块切分成packet（64KB），并使用chunk（512B）+chucksum（4B）填充
- Client将packet放入发送队列dataqueue中，并向第一个DN发送
- 第一个DN收到packet后本地保存并发送给第二个DN
- 第二个DN收到packet后本地保存并发送给第三个DN
- 这一个过程中，上游节点同时发送下一个packet
- 生活中类比工厂的流水线：结论：流式其实也是变种的并行计算
- Hdfs使用这种传输方式，副本数对于client是透明的
- 当block传输完成，DN们各自向NN汇报，同时client继续传输下一个block
- 所以，client的传输和block的汇报也是并行的

### HDFS读流程

 ![hdfs read flow](picture/hdfs read flow.png)

- 为了降低整体的带宽消耗和读取延时，HDFS会尽量让读取程序读取离它最近的副本。
- 如果在读取程序的同一个机架上有一个副本，那么就读取该副本。
- 如果一个HDFS集群跨越多个数据中心，那么客户端也将首先读本地数据中心的副本。
- 语义：下载一个文件：
  -- Client和NN交互文件元数据获取fileBlockLocation
  -- NN会按距离策略排序返回
  -- Client尝试下载block并校验数据完整性
- 语义：下载一个文件其实是获取文件的所有的block元数据，那么子集获取某些block应该成立
  -- Hdfs支持client给出文件的offset自定义连接哪些block的DN，自定义获取数据
  -- 这个是支持计算层的分治、并行计算的核心

## Hadoop模式

**local 非分布式（debug）**
**pseudo distribute 伪分布式**
单节点 每个角色一个进程，放在一个机器
**full distribute 完全分布式（线上使用）**
单节点每个角色分开放到不同机器

## 实操

https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html

### 基础设施

**设置静态路由**

```sh
vim /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.23
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=114.114.114.114
```

**设置主机名**

```sh
vim /etc/sysconfig/network

#####################
NETWORKING=yes
HOSTNAME=node01
########### 或者
hostnamectl  set-hostname hostname
```

**设置host映射**

```sh
vim /etc/hosts

#####################
192.168.1.23 node01
192.168.1.46 node02
```

**关闭防火墙**

**时间同步**

**安装jdk**

**设置SSH免秘钥**

### Hadoop部署

**下载**

**配置环境变量**

```sh
export HADOOP_HOME=/xxx/xxx/x
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

**修改配置文件**

etc/hadoop/core-site.xml:（配置nn位置）

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

etc/hadoop/hdfs-site.xml:（配置副本， 设置保险的目录防止nn，dn，sn数据丢失）

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/var/bigdata/hadoop/local/dfs/name</value>
    </property>
    <!-- 原始的目录存放于临时文件夹中，非常不安全 -->
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/var/bigdata/hadoop/local/dfs/data</value>
    </property>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>node01:9868</value>
    </property>
    <property>
        <name>dfs.namenode.checkpoint.dir</name>
        <value>/var/bigdata/hadoop/local/dfs/namesecondary</value>
    </property>
</configuration>
```

etc/hadoop/workers（dn位置）

```xml
node01
```

### 初始化和使用

见官网

**格式化硬盘(初始化nn，创建nn目录)**

```sh
bin/hdfs namenode -format
# 其中nn的clusterId相同才能连接对应的dn
```

**第一次启动创建dn和snn目录（启动时）**

```sh
start-dfs.sh
```

**修改配置项**

**访问node01:9870端口有页面显示**

**使用（使用dfs子命令，类似于linux的文件系统）**

```sh
hdfs dfs -help
hdfs dfs -put xxx.zip /directory
hdfs dfs -mkdir /bigdata
hdfs dfs -mkdir -p /user/root
hdfs dfs -dfs.blocksize
# 可以注意到datanode里面有meta 校验和 文件（block）
```

**注意**

psdh默认采用rsh登陆，要用ssh登陆要修改下

export PDSH_RCMD_TYPE=ssh

## HA

单点产生的两个问题（单独问题）？

1. 单点故障

   > 高可用方案，主备切换

2. 压力过大

   > 联邦机制：Federation（元数据分片）
   >
   > 多个NN，管理不同的元数据

### 单点故障问题解决

HDFS通过实现了Paxos协议的JN（分布式存储）实现分布式存储通讯，用于同步editslog，保证数据最终一致性

写数据时，主NN向JN写数据，等待JN返回，备机会读取JN（JournalNode）中的数据

JN实现：主从模式，通过Paxos协议进行数据传递和保证数据一致性

HDFS通过实现了ZAB协议的ZK实现分布式协调，快速选择主节点

![1647075431(1)](picture/1647075431(1).png)

ZK客户端的FailoverController 会干一些事情，并且与NN存在同一个物理机上，保证监控的准确性

1.初始化的时候，所有FailoverController 会抢锁，先抢到锁的作为active，其他为standby NN

2.FailoverController 检测当前master NN是否宕机，如果宕机，则删除当前在ZK上的临时节点，触发事件回调机制，回调之前其他FailoverController 在ZK上注册的事件

3.其他机器接收到事件先进行主存活判断（连接主IP的NN查看是否真正死亡），如果真正死亡就将自己设置成master；如果由于FailoverController宕机造成的删除事件，则将当前的master降级成standby，然后将自己本机设成standby；如果由于FailoverController网与主机NN不通产生的问题，无法将当前升级成master。

![1647076714](picture/1647076714.png)

#### HA模式下的SNN

1.HA模式不存在SNN，备机的NN会定时做出fsimage给主机

2.非HA模式下，SNN定期拉取editslog去合并，而HA模式NN通过JournalNode实时同步editslog

#### HA下的角色

ACTIVE，STANDBY，JN,ZK，FailoverController（ZKFC）

### 压力过大，内存受限问题解决

联邦制解决，元数据分治，复用DN存储，DN使用目录隔离block（DN会为每个NN创建一个目录 ）

**注意**

访问的时候要搭建一个中转（中台 ）去访问，抽象层

### HA模式搭建

[HA](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html)

#### 目标

|        | NN   | JN   | DN   | ZK   | ZKFC | NM   | RS   |
| :----- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| node01 | *    | *    |      | *    | *    |      |      |
| node02 | *    | *    | *    |      | *    | *    |      |
| node03 |      | *    | *    | *    |      | *    | *    |
| node04 |      |      | *    | *    |      | *    | *    |

#### 操作

**基础设置**

ssh免密：

1.由于启动时NN要ssh连接其他机器去启动集群，所以启动机器一定得能免密登录其他机器

2.由于ZKFC要监控NN的状态，还要检测其他NN的状态，所以这些机器之间也要能免密登陆

#### 配置文件

按照官网要求配置文件

*hdfs-site.xml中*

要配置集群映射

```xml
<property>
  <name>dfs.nameservices</name>
  <value>hdfsCluster</value>
</property>
<property>
  <name>dfs.ha.namenodes.hdfsCluster</name>
  <value>nn1,nn2</value>
</property>
<property>
  <name>dfs.namenode.rpc-address.hdfsCluster.nn1</name>
  <value>node01:8020</value>
</property>
<property>
  <name>dfs.namenode.rpc-address.hdfsCluster.nn2</name>
  <value>node02:8020</value>
</property>
<property>
  <name>dfs.namenode.http-address.hdfsCluster.nn1</name>
  <value>node01:9870</value>
</property>
<property>
  <name>dfs.namenode.http-address.hdfsCluster.nn2</name>
  <value>node02:9870</value>
</property>
```

要配置JN

```xml
<property>
  <name>dfs.namenode.shared.edits.dir</name>
  <value>qjournal://node01:8485;node02:8485;node03:8485/hdfscluster</value>
</property>
<property>
  <name>dfs.journalnode.edits.dir</name>
  <value>/var/bigdata/hadoop/ha/jn/dfs/data</value>
</property>
```

要配置FC代理方法

```xml
<property>
  <name>dfs.client.failover.proxy.provider.hdfsCluster</name> <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>
```

要配置FC远程连接模式

```xml
<property>
      <name>dfs.ha.fencing.methods</name>
      <value>sshfence</value>
    </property>

    <property>
      <name>dfs.ha.fencing.ssh.private-key-files</name>
      <value>/root/.ssh/id_rsa</value>
    </property>
 <property>
   <name>dfs.ha.automatic-failover.enabled</name>
   <value>true</value>
 </property>
<!-- 这个不可以配 -->
<property>
  <name>dfs.ha.nn.not-become-active-in-safemode</name>
  <value>true</value>
</property>
```

*core-site.xml中*

修改defaultFS为集群

```xml
<property>
        <name>fs.defaultFS</name>
        <value>hdfs://hdfsCluster</value>
    </property>
<!-- zk 配置 -->
 <property>
   <name>ha.zookeeper.quorum</name>
   <value>node01:2181,node03:2181,node04:2181</value>
 </property>

<!-- 由于启动脚本的问题，NN启动后，十秒内会检测JN是否启动，如果没启动，NN自动退出，把尝试次数和间隔调长就好了 -->
<property>
    <name>ipc.client.connect.max.retries</name>
    <value>100</value>
    <description>Indicates the number of retries a client will make to establish a server connection.</description>
</property>
<property>
    <name>ipc.client.connect.retry.interval</name>
    <value>10000</value>
    <description>Indicates the number of milliseconds a client will wait for before retrying to establish a server connection.</description>
</property>
```

*安装zk*

在zoo.cfg

```xml
server.1=node01:2888:3888
server.2=node03:2888:3888
server.3=node04:2888:3888
```

配置myid，环境变量

启动 zkServer.sh start

#### 启动

**启动前注意**

1.加载journalnode（*hdfs --daemon start journalnode*）

2.加载NN 并格式化JN和NN（主节点格式化，备机同步：同步前启动主机NN  hdfs --daemon start namenode）（*hdfs namenode -format*）（*hdfs namenode -bootstrapStandby*）

3.启动自动故障恢复 hdfs zkfc -formatZK

4.配置用户

5.start-dfs.sh

### Hadoop用户

hadoop的用户跟随着本机，启动nn的用户为超级用户，其他为普通用户，无法进行用户的创建，但是可以进行用户的管理，用户的根目录在 user/ {user}下

#### 验证

步骤

- 添加用户

  > useradd -m {user} //带目录创建user
  >
  > passwd {user}

- 资源分配给用户

  > chown -R meijiaojiao /home/timo/hadoop/hadoop-3.3.1
  >
  > chown -R meijiaojiao /var/bigdata/hadoop/ha

- 配置hdfs-site.xml的免密

- 切换用户启动

- 创建目录，使用其他用户操作目录

  > hdfs dfs -mkdir /meinv
  >
  > hdfs dfs -put b.txt /meinv
  >
  > hdfs dfs -get /meinv/b.txt
  >
  > hdfs dfs -chmod 770 /meinv
  >
  > hdfs dfs -chown meijiaojiao:mygroup /meinv
  >
  > useradd -m testUser
  >
  > groupadd mygroup
  >
  > usermod -a -G mygroup testUser
  >
  > hdfs dfsadmin -refreshUserToGroupsMappings
  >
  > su testUser
  >
  > hdfs dfs -get /meinv/b.txt

### ssh

复制密钥到其他机器

ssh-copy-id -i id_rsa node02

## 开发

开发hdfs的client所使用的用户为

> 1.当前操作系统用户
>
> 2.参考环境变量HADOOP_USER_NAME
>
> 3.代码控制

### maven依赖

> hadoop-common
>
> hadoop-hdfs

### 操作

```java
public class Test {

    private Configuration configuration;
    private FileSystem fileSystem;

    @Before
    public void before() throws Exception {
        configuration = new Configuration(true);
//        fileSystem = FileSystem.get(configuration);
        fileSystem = FileSystem.get(URI.create("hdfs://hdfsCluster"),configuration,"meijiaojiao");
    }

    @org.junit.Test
    public void mkdir() throws IOException {
        fileSystem.mkdirs(new Path("bigdata1"));
    }

    @org.junit.Test
    public void upload() throws IOException {
        FileInputStream fileInputStream = new FileInputStream("E:\\workspace\\src\\test\\test.txt");
        FSDataOutputStream bigdata1 = fileSystem.create(new Path("bigdata1/out.txt"));
        IOUtils.copyBytes(fileInputStream,bigdata1,1024,true);
    }

    @org.junit.Test
    public void download() throws IOException {
        FSDataInputStream bigdata1 = fileSystem.open(new Path("bigdata1/out.txt"));
        FileOutputStream fileInputStream = new FileOutputStream("E:\\workspace\\src\\test\\test1.txt");
        IOUtils.copyBytes(bigdata1,fileInputStream,1024,true);
    }

    @org.junit.Test
    public void delete() throws IOException {
        fileSystem.deleteOnExit(new Path("bigdata1/out.txt"));
    }

    @After
    public void after() throws IOException {
        fileSystem.close();
    }
}
```

**块级操作（可以做到计算向数据移动，分治）**

```java
 @org.junit.Test
    public void block() throws IOException {
        Path path = new Path("a.txt");
        FileStatus fileStatus = fileSystem.getFileStatus(path);
        BlockLocation[] fileBlockLocations = fileSystem.getFileBlockLocations(fileStatus, 0, fileStatus.getLen());

        for (BlockLocation i : fileBlockLocations){
            System.out.println(i.toString());
            //块信息
            //0,1048576,node03,node02
            //1048576,927032,node02,node04
        }
        //由于文件被划分为各个块，块存在于不同的宿主机上，依存于距离（取得最近的块，能本机就本机，不行就机房，依次类推），可以通过seek实现做到计算向数据移动，分治
        FSDataInputStream open = fileSystem.open(path);
        open.seek(1048576);
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
        System.out.println((char)open.readByte());
}
```

# MapReduce

Map:以一条记录为单位进行映射

Reduce:以一组为单位进行计算

描述：数据以一条记录为单位经过map方法映射成KV，相同的Key为一组，这一组数据调用一次reduce方法，在方法内迭代计算这一组数据

![1651496744](picture/1651496744.png)

![1651498014(1)](picture/1651498014(1).png)

## MapReduce 原理

**MR计算框架**

思考：如何实现计算向数据移动？

## MR角色

### hadoop1 角色

Cli：客户端

> 1.client通过NN获取hadoop区块信息，进行split的计算，获得切片清单（获得locations信息和offset信息），map数量就有了
>
> 2.客户端生成计算程序未来运行时的相关文件
>
> 3.未来的移动应该相对可靠
>
> - cli会将jar包，split清单，配置xml上传到hdfs（副本数10）

JobTracker：资源管理，任务调度

> 1.从hdfs中取回split清单
>
> 2.根据清单，根据TaskTracker上报的心跳信息进行资源分配，确定需要执行split对应的map的节点
>
> 3.未来，TaskTracker通过心跳获取自己是否有分配的任务，从而拉取jar包和xml进行任务的启动和管理

TaskTracker：任务管理，资源汇报

> 1.定时上报心跳信息
>
> 2.从hdfs拉取任务信息（jar包和xml）
>
> 3.管理计算资源，启动任务，执行map方法或reduce方法

最终，代码在某一个节点被启动，是通过cli上传，TT下载的方式去完成的

**JobTracker的问题**

1.单点故障

2.压力过大

3.集成任务调度和资源管理，耦合过高

- 弊端：未来新的计算框架不能复用资源管理
- 重复造轮子
- 因为各自实现资源管理，不能够感知对方的使用，产生资源争抢

### hadoop2.x

为了解决JobTracker的问题，hadoop进行了重构，产生了yarn架构

#### yarn架构图

![1651586959(1)](picture/1651586959(1).png)



##### yarn角色（主从架构）

Cli：发出请求，计算任务清单，配置文件xml，jar包，提交任务

Resource Manager：

- 资源管理（统一管理，完全解耦）
- 接收Node Manager和App Mstr上报的信息

Node Manager

- 收集本机的资源信息，上报资源
- 启动container资源来执行任务

App Mstr

- 接收Resource Manager传来的信息，拉取split，进行任务调度（阉割版的JobTracker）

Container

- 拉取jar包，通过反射调用任务

##### 流程（MR run on yarn）

1.Client请求Resource Manager 获取节点信息

2.Client根据返回的信息进行配置文件xml的生成，split分片文件的生成，将做好的文件上传到HDFS

3.Resource Manager 获得到请求后挑选一个相对空的节点开启App Mstr（原JobTracker，阉割版，无资源分配）

4.开启后的App Mstr会先去Resource Manager获取Node Manager上报的信息，拉取split进行任务调度，请求RS申请资源

5.RS会让NM在指定的机器上启动container

6.container会先去App Mstr上注册自己

7.App Mstr会发送信息给对应的container，让其执行任务

8.container执行任务的时候去拉取对应的配置文件和jar，进行任务执行，反射进行任务调用

9.不管是App Mstr还是container都有task失败重试的机制

**结论**

通过解耦资源分配与任务调度

1.解决了JT压力过大的问题

2.通过RS ha机制解决了JT单点故障问题

3.解决了由多个JT产生的资源无法通讯问题，统一了资源管理

##### MR启动 + yarn启动

*mapreduce on yarn*

1.修改mapreduce配置文件和yarn配置文件，设置YARN_NODEMANAGER_USER

https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/DistributedCacheDeploy.html

https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/ResourceManagerHA.html

2.启动yarn

start-yarn.sh

yarn --daemon start resourcemanager

3.查看对应8088端口

##### 官方案例解读

> 1.构造测试文件：
>
> for i in `seq 1 100000`;do echo 'hello hadoop '$i >> a.txt; done
>
> 2.上传文件
>
> hdfs dfs -D dfs.blocksize=1048576 -put -f a.txt
>
> 3.执行wordcount程序
>
> cd $HADOOP_HOME/share/hadoop/mapreduce
>
> hadoop jar hadoop-mapreduce-examples-3.3.1.jar wordcount a.txt /output/

# 杂项

## 服务器类型
塔式：竖直长方体
机架：扁直长方体
刀片：刀片式服务器可以一片一片的叠放在机柜上

## ZK和JN的区别

ZK做分布式协调，JN做分布式存储

