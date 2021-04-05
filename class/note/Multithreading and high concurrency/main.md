[TOC]
# 多线程
## 线程基础知识
### 什么是进程，线程，纤程/协程，程序？
1.进程就是运行在电脑上的程序，是操作系统进行资源分配的最小单位，一个程序可以在电脑上运行多份，也就是说一个程序对应多个进程

2.线程是cpu调度执行的最小单位，一个进程有多个线程

3.纤程/协程是绿色线程，一个线程有多个纤程，它不被操作系统管理，由程序自己管理

4.程序是一个磁盘上的可执行文件

### 线程的上下文切换过程
有T1，T2两个线程，T1线程执行到cpu时间片结束，被挂起，此时将T1线程的信息存储到缓存中，然后执行T2的内容，等到T2用完了时间片，再从缓存中读取T1信息，继续在cpu中运行

### 单核CPU设定多线程是否有意义？
有意义，当线程运行时，有时候会进行io操作，需要等待用户输入（会进入等待状态，不消耗cpu），此时如果使用多线程的话就可以充分利用cpu资源

### 线程数是不是设置的越大越好？
不是，因为线程间的切换也需要消耗资源

### 线程数量设置多少最为合适？
具体问题具体分析，根据cpu计算能力来设置，通过压力测试找到合适数。

《Java并发编程实践》中推荐的公式如下

公式为`$N_{threads} = N_{cpu} * U{cpu} * (1 + W / C)$`

即 `$线程数 = cpu核数 * cpu期望利用率[0-1] * （1 + 等待时间 / 计算[cpu使用]时间）$`

如何获取W和C？
使用Profiler（性能分析工具），本地使用JProfiler，服务器可以使用Arthas

## 线程实践
### 创建线程的五种方法
1.继承Thread类，重写run方法

2.实现Runnable接口，重写run方法

3.callable接口，重写call方法，装载到FuntureTask中，使用new Thread执行

4.lamda表达式

5.executors创建线程池，实现execute方法或者submit方法，通过future去获取计算返回值

------------------------------------------
1.new MyThread().start()

2.new Thread(runnable).start()

3.new Thread(lamda).start()

4.ThreadPool

5.FutureTask Callable
#### 使用runnable好还是thread好？
java是单继承多实现的语言，使用runnable更好

## 线程状态
### 线程的六种状态
1.NEW

线程被创建完成，未调用start方法

2.RUNNABLE

线程处于可运行状态（可能是ready状态也可能是running状态）

3.BLOCK

线程处于阻塞状态，等待锁

4.WAITING

线程处于等待状态需要被notify,notifyAll等方法唤醒

5.TIMED_WATING

线程处于等待状态需要等待时间结束自动唤醒

6.TERMINATED

线程处于终止状态

### 线程状态转化图
![image](picture/线程状态转化图.png)

## 线程的打断（interrupt）
### 相关方法
1.interrupt()

打断某个线程（设置标志位，默认为false）等待处理

2.isInterrupted()

查询某个线程是否被打断（查询标志位）

3.static interruptted()

查询当前线程是否被打断，并重置

### interrupt()与sleep(),wait(),join()
在sleep(),wait(),join()方法执行过程中，线程被设置标志位后，会抛出InterruptedException异常，并且系统会重置标志位

### interrupt()与synchronized修饰符， lock.lock()
不会有反应，但是使用lockInterruptibly()方法可以监视标志位是否改变并且抛出异常

### 面试题：如何优雅的结束线程？
1.调用stop方法（不推荐，废弃方法）（过于粗暴，会无脑释放所有锁，会产生数据不一致的问题）

2.调用suspend和resume方法（不推荐，废弃方法）（过于粗暴，suspend会无脑保持所有锁，会产生死锁）

3.violatile 变量控制线程结束

4.interrupt 结束线程

## 锁
### synchronized
synchronized加在方法前和synchronized(this)包住整个方法体等效
如果是静态方法synchronized加在方法前和synchronized(X.class)包住整个方法体等效
加了synchronized就无须加volatile，因为synchronized保证了可见性和原子性

**对象头**
对象中除了存有本身信息，还会有个对象头的信息，对象头中记录了markword和类型指针，markdown中标记了当前对象锁信息和偏向锁的id

**注意**
synchronized不能锁String常量，Integer，Long

#### 性质
是可重入锁（当同一线程去获取同一把锁时可以重复获取，不然会出现死锁问题）

#### 题目
1.模拟银行账户，对业务读方法加锁，对业务写方法不加锁，可行吗？
看业务逻辑，如果脏读不影响整体逻辑，就无所谓，不然就不行

#### 异常和锁
如果出现异常，默认锁会被释放

#### 偏向锁，自旋锁，重量级锁
1.偏向锁
当线程去获取对象锁的时候，如果是第一个访问该对象的线程，会在对象头中记录锁为偏向锁，并且设置线程ID，等下一次同线程访问的时候可以直接访问，而不同线程访问的时候不允许访问

2.自旋锁
如果能请求到对象锁就执行，如果不能请求到锁就自旋等待，等待锁的时间内会占用CPU资源

3.重量级锁
进入等待队列去操作系统内核请求分配一把锁，开销较大，会导致用户态和内核态的切换，不占用CPU资源

#### 底层实现
JDK早期 重量级（每次去OS申请锁）
后来（1.6之后）改进：锁升级（无法降级）（1.8某个版本加入了偏向锁）

Hotspot实现：
当sync (Object),会在对象头中用markword记录线程ID和锁类型（偏向锁）
如果线程争用，升级为自旋锁（占用CPU，不访问操作系统）
自旋到一定值（10）或者自旋锁数量达到阈值（自旋线程超过cpu内核数一半），升级为重量级锁（不占用CPU，访问操作系统）

ps：锁的选择：执行时间长用重量级锁，短的并且线程数少用自旋锁

#### 锁重入机制
每个对象都有一个monitor，线程去请求这个对象的锁时，会去看monitor计数器是否为0，如果为0线程就持有该对象，如果不为0就去判断是否为当前线程持有，如果持有就将monitor计数器-1，不然就等待

#### synchronized优化
1.细化或粗化synchronized
2.最好将锁引用设置为final，不然如果某些情况下引用转移会导致锁失效
3.不要用String，Integer，Long做锁

# 并发编程的三大特性
## 可见性（visibility）
保证在线程中运行的变量对所有线程可见
### volatile
使用volatile保证属性可见（主要的工作是每次用到volitile的属性时都从主内存读，而不是从线程缓存中读）
volatile修饰引用类型，引用类型内部属性更改对其他线程不可见
ps:某些语句操作的时候会触发缓存同步

### 三级缓存

![多核CPU](picture/多核CPU.png)

### 缓存行
一次读64字节（Byte），CPU之间通过缓存一致性协议去保持一致

**使用**
LinkedBlockingQueue
Disruptor(单机效率最高的MQ)中有用到缓存行对齐

**1.8时使用@Contended来保证数据不在同一行，只有1.8起作用，使用时要指定-XX:-RestrictContended**

### 题目
1.volatile作用
①保证线程可见性
总线嗅探和缓存一致性协议（Modified,Exclusive,Shared,Invalid）
（ps：总线嗅探：通过对总线上的数据进行嗅探检查自己缓存数据是否有效，如果无效，就将自己的缓存的数据状态改成Invalid，过多的使用volatile会导致cpu做过多的嗅探和CAS，导致总线带宽达到峰值，造成风暴）
②防止指令重排序
主要是借助了内存屏障
内存屏障分两类
load barrier：在读指令前插入读屏障，让高速缓存中数据失效，重新从主内存读取数据
store barrier：在写指令后插入写屏障，让写入缓存的最新数据写回到内存
使用分4种
storestore确保store1保存的数据在store2保存前已经保存完毕
storeload确保store1保存的数据在load2读取前已经刷新了缓冲区
loadstore确保load1读入的数据在store2保存前读入
loadload确保load1读入的数据在load2读入前读入

JMM内存屏障策列
每个volatile写前插入storestore
每个volatile写后插入storeload
每个volatile读后插入loadstore
每个volatile读后插入loadload

2.实现一个容器，提供两个方法，add，size，写两个线程，线程1添加10个元素到容器中，线程2实现监控元素的个数，当个数到5个时，线程2给出提示并结束

分析下面程序，能完成这个功能吗？
```java
    private static List<Object> container = new ArrayList<>();

    private static void add(Object o){
        container.add(o);
    }
    private static int size(){
        return container.size();
    }

	private static Thread thread1;
	private static Thread thread2;
    public static void main(String[] args) {
        thread2 = new Thread(()->{
            LockSupport.park();
            System.out.println("thread 2 shutdown" + size());
            LockSupport.unpark(thread1);
        });

        thread1 = new Thread(()->{
            for(int i = 0;i < 10;i ++){
                add(new Object());
                if(size() == 5) {
                    LockSupport.unpark(thread2);
            		LockSupport.park();
                }
            }
        });

        thread2.start();
        thread1.start();
    }
```


## 有序性（ordering）
### 乱序的验证
```java
//乱序代码
public class Test {
    static int a;
    static int b;
    static int x;
    static int y;

    public static void main(String[] args) throws InterruptedException {
        int i = 0;
        while (true) {
            a = 0;
            b = 0;
            x = 0;
            y = 0;
            CountDownLatch countDownLatch = new CountDownLatch(2);
            new Thread(new Runnable() {
                @Override
                public void run() {
                    a = 1;
                    y = b;
                    countDownLatch.countDown();
                }
            }).start();
            new Thread(new Runnable() {
                @Override
                public void run() {
                    b = 1;
                    x = a;
                    countDownLatch.countDown();
                }
            }).start();
            countDownLatch.await();
            i++;
            if (x == 0 && y == 0) {
                System.out.println("第" + i + "次");
                break;
            }
        }
    }
}
```
### 为什么会存在乱序
cpu去内存读取数据的时候，可能先做一些本地的操作，在不影响单线程最终一致性的情况下，先执行某些语句

### 创建对象
```
0 new #2 <java/lang/Object> //申请空间
3 dup
4 invokespecial #1 <java/lang/Object.<init>> //初始化
7 astore_1   // 连接
8 return
```

### this对象逸出
在执行对象初始化时进行this对象的调用，由于指令重排序，47重排，可能会找到还未被初始化好的值，这件事情警告我们千万不要在初始化方法中启动线程（调用start方法）

## 原子性（atomicity）

# 新型锁
## ReentrantLock
相比synchronized
1.ReentrantLock可以实现tryLock等待在一段时间内获取锁
2.ReentrantLock可以用lockInterruptibly去检测中断
3.ReentrantLock可以做公平锁
4.底层CAS，sync使用锁升级机制
5.ReentrantLock要手动加锁和释放锁，sync不用

### condition本质
不同的等待队列，底层用的LockSupport.park实现阻塞

### 公平锁
使用FIFO队列来实现公平锁，加锁前查看是否在等待队列中有其他线程在等待这把锁，如果有就让其他线程先执行，否则自己执行

## CountDownLatch
每次调用latch.countDown()时计数器减一，直到计数器变为0，才能够通过latch.await()方法

## CyclicBarrier
每次调用await方法会将计数器加一，要达到一定线程数量才会继续执行

## Phaser
维护着一个叫 phase 的成员变量代表当前执行的阶段
调用arriveAndAwaitAdvance方法或arriveAndDeregister方法推进阶段
使用时重写onAdvance方法，分阶段拦截，增强版的CyclicBarrier

## ReentrantReadWriteLock（重要）
构成：共享锁（读锁）+ 排它锁（互斥锁）（写锁）
共享锁：当大家一起读的时候，允许一起访问
排它锁：如果正在写，那么不允许其他线程访问

### StampedLock
由于ReadWriteLock拥有写线程需要等待读线程执行完成才能写入的问题，产生了StampedLock
**特点**
是一个不可重入锁，是一个乐观读锁
通过tryOptimisticRead去判断是否有写锁进行操作，如果有进行特定处理，如果没有就直接执行业务逻辑
**使用**
通过tryOptimisticRead判断当前是否有写操作，如果有写操作，就升级为读锁，再重新读取数据，如果没有就执行业务逻辑

## Semaphore
通过s.acquire()去取信号量，当信号量减少到0时其他线程无法获取，通过s.release()释放信号量，可以做限流

## Exchanger
线程之间交换数据用，第一次调用exchange方法的时候会写入数据并阻塞，第二次调用的时候会交换数据并运行

## AQS（上述全部是AQS的子类）
是由CAS+volatile实现的，它的核心变量是state是volatile修饰的，修改的时候使用CAS
是CLH锁的变体

AQS是双向链表+state，可重入锁

用了CAS就不用再给整个链表加锁，增加了效率

jdk1.9之后添加了VarHandle（指向某个变量的引用）来处理节点之间的关系，VarHandle里面提供了一些原子性的操作，比反射速度快（因为直接操作的二进制码）

### CLH锁
基于单向链表的高性能公平锁，申请加锁的线程需要在其前驱节点的本地变量上自旋，减少了不必要的处理器缓存同步的次数

实现：通过Node节点存储线程状态，使用lock时，将本线程的Node状态转化为true，自旋检测上一个线程的Node状态是否为false，false时执行主方法，解锁时，需要将本地线程Node状态转为false，最后一定要让Node指向一个不会受到影响的Node节点，不然同一线程获得锁再释放锁再获得锁时会产生死锁

```java
//代码
public class CLHLock implements Lock {
    private final ThreadLocal<Node> prev;
    private final ThreadLocal<Node> node;
    private final AtomicReference<Node> tail = new AtomicReference<Node>(new Node());

    public CLHLock() {
        this.node = new ThreadLocal<Node>() {
            protected Node initialValue() {
                return new Node();
                
            }
        };

        this.prev = new ThreadLocal<Node>() {
            protected Node initialValue() {
                return null;
            }
        };
    }

    private class Node {
        private volatile boolean locked;
    }

    @Override
    public void lock() {
        final Node node = this.node.get();
        node.locked = true;
        Node pred = this.tail.getAndSet(node);
        this.prev.set(pred);
        // 自旋
        while (pred.locked);
    }

    @Override
    public void unlock() {
        final Node node = this.node.get();
        node.locked = false;
        this.node.set(this.prev.get());
    }

    @Override
    public void lockInterruptibly() throws InterruptedException {

    }

    @Override
    public boolean tryLock() {
        return false;
    }

    @Override
    public boolean tryLock(long time, TimeUnit unit) throws InterruptedException {
        return false;
    }

    @Override
    public Condition newCondition() {
        return null;
    }
}
```

## LockSupport
可以实现指定唤醒，unpack可以先于park调用

## 强软弱虚
1.强引用
一般的引用，不会被GC回收

2.软引用
当内存不够使用的时候会被GC回收

3.弱引用
当GC检测到弱引用就会被回收，java中的WeakHashMap和ThreadLocalMap中的Entry的key都使用了弱引用，防止内存泄露

4.虚引用
当GC检测就会被回收，并且和弱引用不同点在于虚引用的对象无法用get方法去访问，只有在垃圾回收后会被放入队列中。虚引用通常用于处理堆外内存也就是直接内存。比如我们通过Unsafe类的allocateMemory方法去申请一块内存，需要用freeMemory去释放。

## 题目
1.两个线程交替输出A1B2C3D4...Z26
```java
    public static void main(String[] args) {
        Exchanger exchanger = new Exchanger();
        Thread thread2 = new Thread(()->{
            for(int i = 0;i < 26;i ++){
                char v = (char) ('A'+ i);
                System.out.print(v);
                try {
                    int exchange = (int)exchanger.exchange(i);
                    System.out.print(exchange);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            System.out.println();
        });

        Thread thread1 = new Thread(()->{
            for(int i = 1;i <= 26;i ++){
                try {
                    exchanger.exchange(i);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        thread1.start();
        thread2.start();
    }
```
2.写一个固定容量的同步容器，拥有put和get方法，以及getCount方法，能够支持2个生产者线程以及10个消费者线程的阻塞调用
使用wait和notify/notifyAll来实现

```java
    static class ConcurrentContainer<T>{
        private final LinkedList<T> container = new LinkedList<>();
        private int max = 10;
        private int count = 0;

        public synchronized T get(){
           while (count <= 0){
               try {
                   this.wait();
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
           }
           try {
               count --;
               return container.removeFirst();
           }finally {
               this.notifyAll();
           }
        }

        public void put(T v){
            synchronized (this) {
                while (count >= max){
                    try {
                        this.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }

                count ++;
                container.add(v);
                this.notifyAll();
            }
        }
    }
    // 精准唤醒
    static class ConcurrentContainer<T>{
        private final LinkedList<T> container = new LinkedList<>();
        private int max = 10;
        private int count = 0;
        ReentrantLock reentrantLock = new ReentrantLock();
        Condition consumer = reentrantLock.newCondition();
        Condition producer = reentrantLock.newCondition();

        public T get(){
            reentrantLock.lock();
            while (count <= 0){
               try {
                   consumer.await();
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
           }
           try {
               count --;
               return container.removeFirst();
           }finally {
               producer.signalAll();
               reentrantLock.unlock();
           }
        }

        public void put(T v){
            reentrantLock.lock();
            while (count >= max){
                try {
                    producer.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            count ++;
            container.add(v);
            consumer.signalAll();
            reentrantLock.unlock();
        }
    }
```


# 线程池
**基础**

并发和并行（concurrent vs parallel）
并发是看起来同时发生，实际上是一个线程切换执行任务，并行是多个线程同时执行任务

## 常用线程池体系结构

1.Executor:线程池顶级接口，定义了execute方法
2.ExecutorService:线程池次级接口，扩展Executor接口，在Executor基础上增加了线程池的服务
3.ScheduledExecutorService:扩展ExecutorService接口，增加定时任务
4.AbstractExecutorService:抽象类，实现了一部分方法，运用了模板方法的设计模式
5.ThreadPoolExecutor:普通线程池
6.ScheduledThreadPoolExecutor:定时任务线程池
7.ForkJoinPool:java7新增线程池，基于工作窃取（work-stealing）理论实现，拆分大任务变成小任务，分部运算，得到结果
7.Excutors:线程池工具类，定义了一些操作线程池的方法

### Future的意义
主要用来控制线程，控制线程执行，取消，获取线程执行结果

**扩展**
CompletableFuture
用于组合任务的结果，是个任务的管理类

### ExecutorService
给线程池提供一些基础服务
```java
void shutdown();
List<Runnable> shutdownNow();
boolean isShutdown();
<T> Future<T> submit(Callable<T> task);
```
### AbstractExecutorService
定义一些模板方法，实现了对线程池中线程的启动和关闭

**invokeAll()** 
执行所有任务

ps：调用invokeAll方法时如果时间给的很短，会导致所有的任务取消，所以会有一些任务没有执行的返回值

**invokeAny()**

只要有一个完成，就完成任务

**cancelAll()**
jdk11中出现，打断所有正在运行的线程

**ExecutorCompletionService**
当任务完成后或抛出异常后或被中断后，将Future类型的实例放入到completionQueue中
通过poll可以取到最先完成的任务

### ThreadPoolExecutor
线程池的组成：线程容器，任务队列（BlockingQueue）（如果没有指定大小，就是无限大小），创建线程的工厂（threadFactory），核心线程数（corePoolSize）（长期占有机器资源），最大线程数（maximumPoolSize）（最大线程数=核心线程数+临时线程数），keepAliveTime（临时线程，不需要的时候释放资源）等待时间，TimeUnit 时间单位，RejectExecutionHandler 拒绝执行处理器（任务队列满的时候要执行什么策略）

**构造函数**
```java
public ThreadPoolExecutor(int corePoolSize,
                     int maximumPoolSize,
                     long keepAliveTime,
                     TimeUnit unit,
                     BlockingQueue<Runnable> workQueue,
                     ThreadFactory threadFactory,
                     RejectedExecutionHandler handler)
```

**ThreadFactory（interface）**
创建线程

**RejectExecutionHandler（interface）**
当workQueue未设置容量，永远不会产生RejectExecutionHandler

策略模式，当任务数量 > `maximumPoolSize + workQueue.size()`,拒绝任务处理器，四种拒绝策略

1.ThreadPoolExecutor.AbortPolicy
终止策略（默认）：死给你看，抛出RejectedExecutionException异常

2.ThreadPoolExecutor.CallerRunsPolicy
呼叫者自处理策略：自己玩去（背压：用消费者抑制生产者的生产水平）

3.ThreadPoolExecutor.DiscardPolicy
丢弃策略：全给你丢完
应用场景：当获取的数据只有最后一次有效的时候，比如说位置信息的更新

4.ThreadPoolExecutor.DiscardOldestPolicy
丢弃老的策略：老的不用了，把最前面没执行的干掉，你去排队

5.自定义（常用）
实现RejectExecutionHandler接口，存入信息到kafka或者存到db或者重新放入队列执行，主要还是要看具体的业务逻辑

**BlockingQueue（interface）**
生产者消费者模型（线程安全）,定义了阻塞队列的增删改查
阻塞队列：当存的时候，如果队列满，就阻塞，当取的时候，如果队列空，就阻塞

**==DefaultThreadFactory==**
1.创建的线程是不是守护线程，如果没有设置，默认是守护线程
2.默认的权限是正常权限NORM_PRIORITY=5

```java
//src
//class: Executors
    static class DefaultThreadFactory implements ThreadFactory {
        private static final AtomicInteger poolNumber = new AtomicInteger(1);
        private final ThreadGroup group;
        private final AtomicInteger threadNumber = new AtomicInteger(1);
        private final String namePrefix;

        DefaultThreadFactory() {
            SecurityManager s = System.getSecurityManager();
            group = (s != null) ? s.getThreadGroup() :
                                  Thread.currentThread().getThreadGroup();
            namePrefix = "pool-" +
                          poolNumber.getAndIncrement() +
                         "-thread-";
        }

        public Thread newThread(Runnable r) {
            Thread t = new Thread(group, r,
                                  namePrefix + threadNumber.getAndIncrement(),
                                  0);
            if (t.isDaemon())
                t.setDaemon(false);
            if (t.getPriority() != Thread.NORM_PRIORITY)
                t.setPriority(Thread.NORM_PRIORITY);
            return t;
        }
```
**状态参数**
ctl中前3位存储了线程池状态，后29位存储了工作线程数（所以工作线程数上限为2^29 - 1），分别通过runStateOf和workerCountOf去计算，默认running状态

```java
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
    private static final int COUNT_BITS = Integer.SIZE - 3;
    private static final int CAPACITY   = (1 << COUNT_BITS) - 1;

    // runState is stored in the high-order bits
	//接受新任务并且处理队列任务
    private static final int RUNNING    = -1 << COUNT_BITS;
	//不接受新任务，但是执行队列任务
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
	//不接受新任务，不执行队列任务，并且中断正在执行的任务
    private static final int STOP       =  1 << COUNT_BITS;
	//所有任务中断，workerCount清0，回调terminated()方法
    private static final int TIDYING    =  2 << COUNT_BITS;
	//terminated()执行完成
    private static final int TERMINATED =  3 << COUNT_BITS;

    // Packing and unpacking ctl
    private static int runStateOf(int c)     { return c & ~CAPACITY; }
    private static int workerCountOf(int c)  { return c & CAPACITY; }
    private static int ctlOf(int rs, int wc) { return rs | wc; }
```

**状态转换**

```java
RUNNING -> SHUTDOWN：shutdown()
(RUNNING or SHUTDOWN) -> STOP：shutdownNow()
SHUTDOWN -> TIDYING：当Queue和线程池均为空
STOP -> TIDYING：线程池为空
TIDYING -> TERMINATED：terminated()回调完成
```
#### 方法解析
**==execute方法==**
1.如果当前线程数小于核心线程数，直接加核心线程并启动
2.如果核心线程数满，放入阻塞队列
3.如果阻塞队列满，尝试添加临时线程处理，如果处理不了，直接调用RejectExecuteHandler

**addWorker方法**
1.判断线程池状态是否能够添加新的工作线程，如果能就先增加工作线程数量计数器
2.创建工作线程并添加进工作线程组（HashSet中）
3.如果添加成功，启动线程，如果添加失败，试图从移除刚加入的工作线程，并减少工作线程数量计数器

**runWorker方法**
1.判断线程池状态，如果不能执行任务，就将所有任务包括队列中的任务中断
2.如果能执行，就执行任务，在执行任务前调用beforeExecute处理，在执行任务后调用afterExecute处理

**processWorkerExit方法**
清理工作线程，如果线程正常退出，如果异常退出（beforeExecute，afterExecute出错），就减少工作线程数量计数器

**shutdown**
1.核实shutdown权限
2.推进到SHUTDOWN状态
3.打断空闲工作线程
4.回调shutdown方法
5.尝试调用terminate

**shutdownNow**
1.核实shutdown权限
2.推进到STOP状态
3.打断工作线程
4.清空队列并返回
5.尝试调用terminate

**tryTerminate**
如果符合线程池关闭条件，就转为TERMINATED状态，如果工作线程不为空，就减少一个工作线程数量并退出

**Worker类**
实现了Runnable接口，继承至AQS

#### 题目
1.如何获取线程池中线程执行抛出的异常？
①继承ThreadPoolExecutor并重写afterExecute方法
②自己线程内部用try catch包裹
③从FutureTask中获取
④线程池中创建线程的时候给线程设置未捕捉异常处理器（uncaughtExceptionHandler）

2.当线程遭遇了用户异常，会新起一个线程吗？
会，因为遭遇异常时会先将移除当前工作线程，然后重新添加一个非核心线程

3.ctl是什么？
用来记录线程池状态和工作线程数的

4.execute干了什么？
判断当前工作线程数是否小于核心线程数，如果小于就添加核心线程
如果大于就判断阻塞队列是否满，不满就将任务添加到阻塞队列中，检查工作线程数是否为0，如果为0就添加
如果阻塞队列满了，看看能否加入临时工作线程进行处理，不能就调用拒绝执行处理器执行

### ScheduledThreadPoolExecutor
执行延迟任务

**结构**
使用DelayedWorkQueue（无界Queue，谨慎使用），最大线程数设置为Integer.MAX_VALUE,存活时间为0，默认时间单位为nanotime，由于无界队列，最大线程数，存活时间，默认时间单位不生效

使用自定义任务类型ScheduledFutureTask，是一个小顶堆
sequenceNumber：序列号
time：超时时间
period：周期
outerTask：
heapIndex：堆中索引

#### 主方法
**scheduleAtFixedRate()**
任务一开始就开始计时

**scheduleWithFixedDelay()**
当任务执行完才开始计时

**schedule()**
装饰任务，延迟执行任务

#### 题目
1.ScheduledThreadPoolExecutor的maximumPoolSize和keepAliveTime和时间单位生效吗？
不生效，因为ScheduledThreadPoolExecutor使用的是DelayWorkQueue,是一个无界队列（每次增长幅度为原始的1.5倍），所以不生效

2.怎么控制周期的？
通过DelayedWorkQueue的take方法去控制获取任务的时间

3.核心线程数设置为0时，如何处理？
添加非核心线程（ensurePrestart）

4.假如提供一个闹钟服务，订阅这个服务的人特别多，有10亿人，怎么优化？
①负载均衡服务器分发到各个真实服务器上
②每台服务器用线程池+任务队列

源码5：56分

### ForkJoinPool
用于分解汇总的任务，用很少的线程可以执行很多的任务，CPU密集型，将大任务切分成小任务

**使用**
继承RecursiveAction类（无返回值的任务），调用流式处理的parallelStream也会使用到ForkJoinPool

### CAS（无锁优化 自旋 乐观锁）
AtomicXXX底层都是CAS，CAS用Unsafe支持，通过Unsafe.getUnsafe()去获取实例对象

compareAndSwap
对比某个地址上的值是否与期望值相等，相等就设置值

实现自旋锁的原理：
无限制与某块地址进行值比较，如果为初始值，就修改值并退出，如果不为初始值，就代表有其他线程正在使用，轮循访问那块地址，直到其他地方的线程将其改回成初始值

**ABA问题如何解决**
通过对对象进行版本号的添加（AtomicStampedReference），可以解决ABA问题
如果基础类型，无所谓，引用类型，可能导致

**synchronized long,AtomicLong,LongAdder**
高并发情况下，速度依次加快，AtomicLong用了CAS,LongAdder使用了分段锁+CAS

### Executors
1.SingleThreadExecutor
为什么要有单线程的线程池？
如果我们自己去new线程的话，需要自己去维护任务队列和线程生命周期的管理

2.CachedThreadPool
阻塞队列使用SynchronousQueue，这个Queue的大小为0，只能进行阻塞等待任务受理

3.FixedThreadPool
全是核心线程

4.ScheduledThreadPool
复制情况下用quartz，cron，简单情况下用Timer

5.WorkStealingPool
底层使用ForkjoinPool，对于每一个线程都拥有一个自己的阻塞队列，执行任务的时候先去自己的队列中取，如果能执行， 就执行，如果队列为空，就跑去其他线程的队列尾部偷一个过来执行。自己对队列的存取用push，pop方法，对其他队列操作用poll方法

**问题**
什么时候用Fixed什么时候用Cached
任务数量比较平稳，用Fixed，任务数量比较不稳定，用Cached

### 相关题目
1.Executors建立线程的弊端
使用FixedThreadPool和SingleThreadPool的时候，使用的阻塞队列长度为Integer.MAX_VALUE,可能建立很多请求，会导致OOM
使用CachedThreadPool时，允许创建的线程数量为Integer.MAX_VALUE,可能建立很多线程导致OOM

# 容器
## Map
### HashTable（不使用）
所有方法都使用Synchronized锁

### HashMap
所有方法都不加锁，通过Collections.synchronizedHashMap可以变成同步版本（在方法外套用synchronized锁，粒度较HashTable快一点）

### ConcurrentHashMap
插入相较于HashTable和Collections.synchronizedHashMap慢，但是读取特别快

### TreeMap
用的红黑树

#### ConcurrentSkipListMap
跳表(用多层链表的索引增加链表的搜索速度)，高并发下排序，实现了一个类似于TreeMap的并发容器

## Collection

### List

#### ArrayList
所有方法都不加锁

#### CopyOnWriteArrayList
写时复制，写的时候加锁，读的时候由于读的是复制前的表，不需要加锁，适用于写的不是很频繁，但是读很多的情况

#### Vector（不使用）
所有方法都使用Synchronized锁

### Queue
提供了add，offer，poll，peek方法

#### PriorityQueue
优先级队列，是个小根堆

#### ConcurrentLinkedQueue
使用CAS去操作

#### BlockingQueue
提供了take和put这两个阻塞方法

##### LinkedBlockingQueue
无界Queue，阈值可以设定，内部是链表

##### ArrayBlockingQueue
有界Queue，内部是数组

##### DelayQueue
延时Queue，按照进入队列的等待时间从小到大进行排序，内部是优先级队列PriorityQueue

##### SynchronousQueue
queue大小永远为0，给另外一个线程传递信息，使用add方法会报错，只有调用put方法进行阻塞传递

##### TransferQueue
调用transfer方法向queue中装入数据阻塞等待别的线程来取，别人取完才继续执行
消费者没有东西拿的时候会放空篮子，等待生产者装

### Set

#### HashSet
内部使用了HashMap的Key，是唯一的

#### CopyOnWriteArraySet
写时复制，写的时候加锁，读的时候由于读的是复制前的表，不需要加锁，适用于写的不是很频繁，但是读很多的情况

## 多线程下常用的容器
ConcurrentHashMap
ConcurrentSkipListMap
ConcurrentSkipListSet
CopyOnWriteArrayList
CopyOnWriteArraySet
ConcurrentLinkedQueue
LinkedBlockingQueue
ArrayBlockingQueue
PriorityBlockingQueue

## 题目
1.Queue与List的区别？
Queue主要方法是add，offer，poll，peek，List的主要方法是remove，add
Queue的结构是先进先出的结构，向尾部写入，获取的时候获取头部结点的值，而List可以根据下标去获取值
