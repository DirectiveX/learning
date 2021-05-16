# Zookeeper

## 定位
zookeeper是一个为分布式提供分布式的，开源的协调服务的应用。有扩展性，可靠性，时序性，快速

它暴露了一系列原语，分布式应用可以基于这些原语来实现一些高等级的服务，像同步，配置维护，分组，命名。它被设计成类似于文件系统的目录结构

配置维护：依赖于数据存储实现
分组：目录结构
命名：序列化
同步：临时节点

对应的应用场景
同步
> 分布式锁（创建临时节点就能做到）
> 如果锁依托于父节点并且具备-s，代表父节点有多把锁，如果后面的锁监控前面的锁，就像CLH了，能实现队列式的事务锁，公平锁
> HA 选主，通过锁的方式
> 消息队列，通过分布式锁+序列化功能+目录结构

## 使用者

阿里Druid集群使用ZK管理，用于服务发现、协调和领导选举

## 特点

**顺序一致性**
保证进来的数据逐一执行,不进行并发

ZK是有序的，它为每个事务都标记了一个版本号（邮戳）（事务id），由于读写分离，所以这个id永远只有主维护，很容易唯一一个递增的id，随后可以使用一些操作完成更高级别的抽象，像同步锁

**原子性**
保证更新操作要么成功要么失败
**单系统镜像**
保证主从模型中的所有server存储数据一致
**持久化(可靠性)**
指数据会持久化
**及时性**
数据会在一小段时间内达到最终一致性

## 基础
### 数据结构
分层命名空间，类似于文件系统的目录树结构
其中存储的是node，node大小为1M

### zookeeper集群结构
![zkservice](picture/zkservice.jpg)
主从复制集群，里面有leader，读写分离，可能会产生主的单点故障问题，为了解决单点故障问题，引入新的技术

**优势**
官方压测，在主宕机之后，会暂停一段时间的服务，时长不超过200ms，然后就能立即选出一个新的主对外提供服务

zookeeper数据也是存在内存中的，速度非常快，吞吐量很高。ZK支持复制，主从复制，读写分离。推荐读写比10:1，速度最快

ZK 服务器彼此认识。他们维护一个内存中的图像的状态,以及一个事务日志和一个供持久化存储使用的快照。只要大部分服务器可以,ZK就服务可用。

### 客户端连接服务器做的事情
客户端连接到服务器，客户端维护了TCP连接，做了如下几件事
1.发送请求
2.获取监听的事件
3.获取响应
4.发送心跳
如果服务器连接断开，客户端会选择其他服务器

### node（持久节点） 和 ephemeral（短暂，临时） node
node是zk中的节点，每个节点都容量都很小，只有1M，为了提高zk的速度，不适合用作数据库

持久节点:持久化数据
临时节点:使用session进行通讯
序列节点:带序列号的节点

## 安装
https://zookeeper.apache.org/doc/current/zookeeperStarted.html
### 参数
tickTime：心跳，每多少秒发一次消息
initLimit：初始创建的时候，允许花费tickTime * initLimit的时间，超过就是有问题
syncLimit：传输数据的时候允许花费syncLimit * tickTime的时间，超过代表有问题
dataDir：持久化数据的目录
clientPort：客户端连接端口号
server.x=host:port:port zookeeper通过配置来知道集群在哪，通过为每台服务器创建一个名为myid的文件，将服务器id赋予每台机器，该文件位于该服务器的数据目录中，由配置文件参数dataDir指定。第一个port用来连接上leader，leader接收写请求，第二个port用来选举

### 注意
如果要用命名的方式给定host，记得修改/etc/host下的文件

### 杂项
1.关于选举主服务器
通过谦让制度，让id最大的当选，当然，由于选举只要求数量过半，所以如果有1234四台机器，可能是3或4当选

## 操作
> create [-s] [-e] [-c] [-t ttl] path [data] [acl]
> 创建路径，-e创建临时节点，-s创建序列化节点（保证数据不会覆盖）
> 注意，删除之前创建的序列化id，不会影响计数，但是如果创建一个后面的序列化id，当产生冲突时会报错Node already exists，并且这个id会随着当前目录下create的操作次数增长，不管是否产生了序列化的id

> ls [-s] [-w] [-R] path
> 查看节点下的目录

> get [-s] [-w] path
> 获取节点值

> delete [-v version] path
> 删除节点

> set [-s] [-v version] path data
> 设置节点值

> stat [-w] path
> 查看目录状态
> cZxid = 0x30000000e --前32位表示leader的纪元，后32位表示事务id，创建
ctime = Sat May 01 21:43:59 CST 2021  --创建时间
mZxid = 0x30000000e --修改
mtime = Sat May 01 21:43:59 CST 2021 --修改时间
pZxid = 0x30000000f -- 当前目录下创建的最后一个子节点的id
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0 --临时持有者，指定归属的session id，如果有的话对应会话退出当前目录就消失
dataLength = 0
numChildren = 1

## 扩展性
**Zookeeper角色**
Leader：接受增删改查的操作，同步各个follower和observer中的信息
Follower：接受读请求，leader挂了之后进行投票选举（可以当成是选民）
Observer：被剥夺政治权利的民众，只能接受读请求

读写分离：由observer放大查询能力

*设置observer*
配置server.x=host:port:port:observer

## 可靠性
来源于快速故障恢复，数据最终一致性

## paxos
**定义**
基于消息传递的一致性算法

**实现前提**
网络稳定，没有拜占庭将军问题

**故事**
Paxos描述了这样一个场景，有一个叫做Paxos的小岛(Island)上面住了一批居民，岛上面所有的事情由一些特殊的人决定，他们叫做议员(Senator)。议员的总数(Senator Count)是确定的，不能更改。岛上每次环境事务的变更都需要通过一个提议(Proposal)，每个提议都有一个编号(PID)，这个编号是一直增长的，不能倒退。每个提议都需要超过半数((Senator Count)/2 +1)的议员同意才能生效。每个议员只会同意大于当前编号的提议，包括已生效的和未生效的。如果议员收到小于等于当前编号的提议，他会拒绝，并告知对方：你的提议已经有人提过了。这里的当前编号是每个议员在自己记事本上面记录的编号，他不断更新这个编号。整个议会不能保证所有议员记事本上的编号总是相同的。现在议会有一个目标：保证所有的议员对于提议都能达成一致的看法。

好，现在议会开始运作，所有议员一开始记事本上面记录的编号都是0。有一个议员发了一个提议：将电费设定为1元/度。他首先看了一下记事本，嗯，当前提议编号是0，那么我的这个提议的编号就是1，于是他给所有议员发消息：1号提议，设定电费1元/度。其他议员收到消息以后查了一下记事本，哦，当前提议编号是0，这个提议可接受，于是他记录下这个提议并回复：我接受你的1号提议，同时他在记事本上记录：当前提议编号为1。发起提议的议员收到了超过半数的回复，立即给所有人发通知：1号提议生效！收到的议员会修改他的记事本，将1号提议由记录改成正式的法令，当有人问他电费为多少时，他会查看法令并告诉对方：1元/度。
（过半通过，两阶段提交）

现在看冲突的解决：假设总共有三个议员S1-S3，S1和S2同时发起了一个提议:1号提议，设定电费。S1想设为1元/度, S2想设为2元/度。结果S3先收到了S1的提议，于是他做了和前面同样的操作。紧接着他又收到了S2的提议，结果他一查记事本，咦，这个提议的编号小于等于我的当前编号1，于是他拒绝了这个提议：对不起，这个提议先前提过了。于是S2的提议被拒绝，S1正式发布了提议: 1号提议生效。S2向S1或者S3打听并更新了1号法令的内容，然后他可以选择继续发起2号提议。
来源： https://www.douban.com/note/208430424/

## ZAB(zookeeper atomic broadcast protocol)
### ZAB有主的情况
Zookeeper在写入的时候，由leader去写，当一个写请求到达follower，follower会向leader发送一个消息，leader收到这个消息，会通过一个队列（每个连接都会维护一个队列，以达到原子性）进行广播，让所有follower进行一个日志记录（记录到磁盘），如果收到半数以上的回复ok，那么leader会继续发送写请求到队列中，由follower消费，然后发回给初始请求的那个follower一个ok，证明写入成功

此时如果有client去读那些已经更新完成的节点，自然能读到准确的信息，但是如果读到那些还未消费完毕队列中消息的节点，那么可能取出老数据，这时候由使用zk的用户去选择，要不要在读之前进行一个sync请求，保证数据的准确性

### ZAB无主的情况
**启动时选举**
目前有5台服务器，每台服务器均没有数据，它们的编号分别是1,2,3,4,5,按编号依次启动，它们的选择举过程如下：

服务器1启动，给自己投票，然后发投票信息，由于其它机器还没有启动所以它收不到反馈信息，服务器1的状态一直属于Looking(选举状态)。
服务器2启动，给自己投票，同时与之前启动的服务器1交换结果，由于服务器2的编号大所以服务器2胜出，但此时投票数没有大于半数，所以两个服务器的状态依然是LOOKING。
服务器3启动，给自己投票，同时与之前启动的服务器1,2交换信息，由于服务器3的编号最大所以服务器3胜出，此时投票数正好大于半数，所以服务器3成为领导者，服务器1,2成为小弟。
服务器4启动，给自己投票，同时与之前启动的服务器1,2,3交换信息，尽管服务器4的编号大，但之前服务器3已经胜出，所以服务器4只能成为小弟。
服务器5启动，后面的逻辑同服务器4成为小弟。

**启动后leader挂了选举**
首先停止服务，开始选举
1.存活服务器发起投票，先投自己，再发送给其他服务器自己的server id和事务id
2.接收到投票请求后，先比较事务id和本服务器的事务id，如果事务id大，那么就进行投票，如果小，就不投，如果一样就比较server id，大的当选
3.最后选出那个事务id最大的，并且server id相对大的，作为leader

ZK选举过程
1.通过3888进行俩俩通讯
2.只要任何人投票，都会触发准leader发起自己投票
3.推举制：先比较zxid，如果zxid相同，再比较myid，myid大的当选

## watch
通过watch可以产生事件回调

应用场景：可以做client间的心跳检测，基于enode + session，然后watch的结点由于session过期产生delete event被监听到，直接回调callback方法告知client

## API
zk的方法几乎都有回调，异步非阻塞的操作

### ZK的watch
watch会进行回调
watch的注册只在读数据时

有两类：
第一类：new 的时候传入的watch，只监测session
第二类：get或者exist传入，监测对应node的变化

注意：get传入的exist不能监控目录的生成，exist可以，请准确使用

### create
zk.create(path,data,List<acl/>,CreateMode)
> acl是访问权限，返回值为节点名称

### get
zk.getData(path,watcher,stat)
> watch是一次性的，stat是info中的信息（元信息）
> 如果watch是true，那么使用new的那个watch

### set
zk.setData(path,data,version);

### ps
api创建zk对象时，是异步创建，会立即返回一个正在连接状态的zk对象，可以通过countdownlatch去判断是否创建完成

## zookeeper刷盘
zookeeper在磁盘上存储的文件与redis等数据库刷盘不同，由于zookeeper采用了paxos协议，所以刷盘发生在接收到数据之后，不管存有多少数据，服务器一旦收到数据，就会进行磁盘的写入，即刷盘，不会定时进行刷盘，因为没有必要

## 分布式协调实例
充分利用react回调方式
可以做配置中心，服务注册发现

```java
//测试类
class Test {
    ZooKeeper zooKeeper;
    static JdbcConf jdbcConf;

    @BeforeAll
    public static void before() throws IOException, InterruptedException {
        jdbcConf = new JdbcConf();
    }

    @AfterAll
    public static void after(){

    }

    @org.junit.jupiter.api.Test
    public void test() throws IOException, InterruptedException, KeeperException {
        JdbcZKUtils jdbcZKUtils = new JdbcZKUtils(jdbcConf);
        while (true){
            jdbcConfMiss(jdbcZKUtils);
            System.out.println(jdbcConf);
            System.out.println("=======================");
            Thread.sleep(3000);
        }
    }

    private void jdbcConfMiss(JdbcZKUtils jdbcZKUtils) throws KeeperException, InterruptedException {
        if(jdbcConf == null || jdbcConf.getJdbcDriver() == null || jdbcConf.getJdbcUrl() == null|| jdbcConf.getPassword() == null|| jdbcConf.getUserName() == null){
            jdbcZKUtils.watchConfigChange();
        }
    }
}

//连接类
public class ZKUtils {
    private static final String NODE_1 = "192.168.1.200";
    private static final String NODE_2 = "192.168.1.201";
    private static final String NODE_3 = "192.168.1.202";
    private static final String NODE_4 = "192.168.1.203";
    protected static final String SPLIT = ",";

    private static final String HOST = NODE_1 + SPLIT + NODE_2 + SPLIT + NODE_3 + SPLIT + NODE_4;
    private CountDownLatch countDownLatch = new CountDownLatch(1);

    protected ZooKeeper connect(String path) throws IOException, InterruptedException {
        ZooKeeper zooKeeper = new ZooKeeper(HOST + path,100000,new DefaultWatcher());
        countDownLatch.await();
        return zooKeeper;
    }

    class DefaultWatcher implements Watcher{
        public void process(WatchedEvent watchedEvent) {
            switch (watchedEvent.getState()) {
                case Unknown:
                    break;
                case Disconnected:
                    break;
                case NoSyncConnected:
                    break;
                case SyncConnected:
                    countDownLatch.countDown();
                    break;
                case AuthFailed:
                    break;
                case ConnectedReadOnly:
                    break;
                case SaslAuthenticated:
                    break;
                case Expired:
                    break;
                case Closed:
                    break;
            }
        }
    }
}
//配置方法
public class JdbcZKUtils extends ZKUtils {
    private JdbcConf jdbcConf;
    private static final String PATH = "/jdbc";
    private ZooKeeper zk;
    private CountDownLatch countDownLatch1;
    private CountDownLatch countDownLatch2;
    private CountDownLatch countDownLatch3;
    private CountDownLatch countDownLatch4;

    public JdbcZKUtils(JdbcConf jdbcConf) throws IOException, InterruptedException {
        zk = connect(PATH);
        this.jdbcConf = jdbcConf;
        countDownLatch1 = new CountDownLatch(1);
        countDownLatch2 = new CountDownLatch(1);
        countDownLatch3 = new CountDownLatch(1);
        countDownLatch4 = new CountDownLatch(1);
    }

    public void watchConfigChange() throws KeeperException, InterruptedException {
        JDBCWatcher jdbcDriverWatcher = new JDBCWatcher();
        JDBCWatcher userNameWatcher = new JDBCWatcher();
        JDBCWatcher passwordWatcher = new JDBCWatcher();
        JDBCWatcher jdbcUrlWatcher = new JDBCWatcher();

        zk.exists("/" + JDBC_DRIVER,jdbcDriverWatcher,jdbcDriverWatcher,JDBC_DRIVER);
        countDownLatch1.await();
        zk.exists("/" + USERNAME,userNameWatcher,userNameWatcher,USERNAME);
        countDownLatch2.await();
        zk.exists("/" + PASSWORD,passwordWatcher,passwordWatcher,PASSWORD);
        countDownLatch3.await();
        zk.exists("/" + JDBC_URL,jdbcUrlWatcher,jdbcUrlWatcher,JDBC_URL);
        countDownLatch4.await();
    }

    class JDBCWatcher implements Watcher, AsyncCallback.StatCallback, AsyncCallback.DataCallback {
        public void process(WatchedEvent event) {
            System.out.println(event.toString());
            switch (event.getType()) {
                case None:
                    break;
                case NodeCreated:
                    zk.getData(event.getPath(),this,this,"node create");
                    break;
                case NodeDeleted:
                    try {
                        setNullConfig(event.getPath());
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    break;
                case NodeDataChanged:
                    zk.getData(event.getPath(),this,this,"node update");
                    break;
                case NodeChildrenChanged:
                    break;
                case DataWatchRemoved:
                    break;
                case ChildWatchRemoved:
                    break;
                case PersistentWatchRemoved:
                    break;
            }
        }

        private void setNullConfig(String path) throws InterruptedException {
            switch (path.split("/")[1]){
                case JDBC_DRIVER:
                    countDownLatch1 = new CountDownLatch(1);
                    jdbcConf.setJdbcDriver(null);
                    break;
                case USERNAME:
                    countDownLatch2 = new CountDownLatch(1);
                    jdbcConf.setUserName(null);
                    break;
                case PASSWORD:
                    countDownLatch3 = new CountDownLatch(1);
                    jdbcConf.setPassword(null);
                    break;
                case JDBC_URL:
                    countDownLatch4 = new CountDownLatch(1);
                    jdbcConf.setJdbcUrl(null);
                    break;
            }
        }

        @Override
        public void processResult(int rc, String path, Object ctx, Stat stat) {
            if(stat != null) {
                zk.getData(path, this, this, ctx);
            }
        }

        @Override
        public void processResult(int rc, String path, Object ctx, byte[] data, Stat stat) {
            switch (path.split("/")[1]){
                case JDBC_DRIVER:
                    jdbcConf.setJdbcDriver(data == null?null:new String(data));
                    countDownLatch1.countDown();
                    break;
                case USERNAME:
                    jdbcConf.setUserName(data == null?null:new String(data));
                    countDownLatch2.countDown();
                    break;
                case PASSWORD:
                    jdbcConf.setPassword(data == null?null:new String(data));
                    countDownLatch3.countDown();
                    break;
                case JDBC_URL:
                    jdbcConf.setJdbcUrl(data == null?null:new String(data));
                    countDownLatch4.countDown();
                    break;
            }
        }
    }
}
//配置类

public class JdbcConf {
    static final String JDBC_DRIVER = "jdbcDriver";
    static final String USERNAME = "userName";
    static final String PASSWORD = "password";
    static final String JDBC_URL = "jdbcUrl";

    private String jdbcDriver;
    private String userName;
    private String password;
    private String jdbcUrl;

    @Override
    public String toString() {
        return "jdbcDriver='" + jdbcDriver + '\'' +
                ", userName='" + userName + '\'' +
                ", password='" + password + '\'' +
                ", jdbcUrl='" + jdbcUrl;
    }

    public String getJdbcDriver() {
        return jdbcDriver;
    }

    public void setJdbcDriver(String jdbcDriver) {
        this.jdbcDriver = jdbcDriver;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getJdbcUrl() {
        return jdbcUrl;
    }

    public void setJdbcUrl(String jdbcUrl) {
        this.jdbcUrl = jdbcUrl;
    }
}
```


可以做分布式锁

> 1.在一个目录下创建一组带sequence的临时节点
> 2.每个结点都watch前面那个结点
> 3.当前面那个结点结束，就会被删除，后面的结点就能被callback方法通知到，这样的公平锁可以防止资源争抢，加快加锁速度

```java
//核心

public class DistributedLock implements AsyncCallback.Create2Callback, AsyncCallback.ChildrenCallback, Watcher, AsyncCallback.StatCallback, AsyncCallback.DataCallback {
    private static final String PATH = "/lock";
    //实现可重入
    private String threadName;
    private String curName;
    private String lockName;
    private ZooKeeper zk;
    private CountDownLatch countDownLatch;

    public DistributedLock(String threadName, String lockName) throws IOException, InterruptedException {
        this.threadName = threadName;
        this.lockName = lockName;
        zk = new ZKUtils().connect(PATH);
        countDownLatch = new CountDownLatch(1);
    }

    public void unlock() {
        zk.getData("/" + lockName + "/" + curName, false, (rc, path, ctx, data, stat) -> {
            if (stat != null) {
                String s = new String(data);
                int value = Integer.parseInt(s.split(":")[1]);
                String threadName = s.split(":")[0];
                if (this.threadName.equals(threadName)) {
                    if (value == 1) {
                        zk.delete("/" + lockName + "/" + curName, stat.getVersion(), (rc12, path12, ctx12) -> {
                            //重置
                            countDownLatch = new CountDownLatch(1);
                            curName = null;
                        }, "");
                    } else {
                        zk.setData(path, (threadName + ":"+ (value - 1)).getBytes(), stat.getVersion(), (rc1, path1, ctx1, stat1) -> {
                            if (stat1 == null) {
                                unlock();
                            }
                        }, "");
                    }
                }else{
                    //other thread unlock,ignore
                }
            }
        }, "");
    }

    private void initPath() {
        zk.exists("/" + lockName, false, (rc, path, ctx, stat) -> {
            if (stat != null) {
                acquireLock();
            } else {
                zk.create("/" + lockName, "".getBytes(), ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT, (rc1, path1, ctx1, name, stat1) -> {
                    acquireLock();
                }, "");
            }
        }, "");
    }

    public void tryLock() throws InterruptedException {
        if (curName != null) {
            zk.getData("/" + lockName + "/" + curName, false, this, "");
        } else {
            initPath();
        }
        countDownLatch.await();
    }

    @Override
    public void processResult(int rc, String path, Object ctx, byte[] data, Stat stat) {
        if (stat != null) {
            String s = new String(data);
            int value = Integer.parseInt(s.split(":")[1]);
            String threadName = s.split(":")[0];
            if (this.threadName.equals(threadName)) {
                zk.setData(path, (threadName  + ":"+ (value + 1)).getBytes(), stat.getVersion(), (rc1, path1, ctx1, stat1) -> {
                    if (stat1 == null) {
                        zk.getData("/" + lockName + "/" + curName, false, this, "");
                    }
                }, "");
            } else {
                //wait queue
            }
        }
    }

    private void acquireLock() {
        zk.create("/" + lockName + "/" + lockName, (threadName  + ":"+"1").getBytes(), ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL, this, "");
    }

    @Override
    public void processResult(int rc, String path, Object ctx, String name, Stat stat) {
        if (stat != null) {
            curName = name.split("/")[2];
            System.out.println(Thread.currentThread().getName() + " create node " + name);
            zk.getChildren("/" + lockName, false, this, "");
        }
    }

    @Override
    public void processResult(int rc, String path, Object ctx, List<String> children) {
        Collections.sort(children);
        for (int i = 0; i < children.size(); i++) {
            if (children.get(i).equals(curName)) {
                if (i == 0) {
                    countDownLatch.countDown();
                } else {
                    zk.exists(path + "/" + children.get(i - 1), this, this, "");
                }
            }
        }
    }

    @Override
    public void processResult(int rc, String path, Object ctx, Stat stat) {
        //监控失败，再监控前面一个
        if (stat == null) {
            zk.getChildren("/" + lockName, false, this, "");
        }
    }

    @Override
    public void process(WatchedEvent event) {
        switch (event.getType()) {
            case None:
                break;
            case NodeCreated:
                break;
            case NodeDeleted:
                zk.getChildren("/" + lockName, false, this, "");
                break;
            case NodeDataChanged:
                zk.getChildren("/" + lockName, false, this, "");
                break;
            case NodeChildrenChanged:
                break;
            case DataWatchRemoved:
                break;
            case ChildWatchRemoved:
                break;
            case PersistentWatchRemoved:
                break;
        }
    }
}

//测试

    @org.junit.jupiter.api.Test
    public void test() throws IOException, InterruptedException, KeeperException {
        for(int i = 0;i < 10;i ++){
            Thread thread = new Thread(()->{
                DistributedLock lock = null;
                try {
                    lock = new DistributedLock(Thread.currentThread().getName(),"testLock");
                    lock.tryLock();
                    lock.tryLock();
                    lock.tryLock();
                    System.out.println(Thread.currentThread().getName());
                    Thread.sleep(1000);
                } catch (IOException e) {
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }finally {
                    lock.unlock();
                    lock.unlock();
                    lock.unlock();
                }
            },"t" + i);
            thread.start();
        }
        Thread.sleep(100000);
    }

//工具类

    private static final String NODE_1 = "192.168.1.200";
    private static final String NODE_2 = "192.168.1.201";
    private static final String NODE_3 = "192.168.1.202";
    private static final String NODE_4 = "192.168.1.203";
    protected static final String SPLIT = ",";

    private static final String HOST = NODE_1 + SPLIT + NODE_2 + SPLIT + NODE_3 + SPLIT + NODE_4;
    private CountDownLatch countDownLatch = new CountDownLatch(1);

    public ZooKeeper connect(String path) throws IOException, InterruptedException {
        ZooKeeper zooKeeper = new ZooKeeper(HOST + path,10000,new DefaultWatcher());
        countDownLatch.await();
        return zooKeeper;
    }

    class DefaultWatcher implements Watcher{
        public void process(WatchedEvent watchedEvent) {
            switch (watchedEvent.getState()) {
                case Unknown:
                    break;
                case Disconnected:
                    break;
                case NoSyncConnected:
                    break;
                case SyncConnected:
                    countDownLatch.countDown();
                    break;
                case AuthFailed:
                    break;
                case ConnectedReadOnly:
                    break;
                case SaslAuthenticated:
                    break;
                case Expired:
                    break;
                case Closed:
                    break;
            }
        }
    }
```

## 面试题
1.如果中途客户端连着的那台server挂了，那么客户端进行一个重新连接，连接到其他服务器，此时临时数据还在吗？
在，首先，从设计上来讲，集群和单机对客户端不可见，只要还有服务器是可用的，那么数据就不会消失，然后从实际来讲，其实集群中的各个服务器都存有连接的session id，所以就算连着的挂了，去到另外一台依然认识这个client。
session id何时被写入？当客户端发生写操作的时候，主会将id分享给所有从服务器，正常退出的时候会走一个删除id的操作。session创建和删除都会消耗事务id。

