# 如何预防死锁

要预防死锁先得了解，死锁产生的条件

>1.请求与保持：线程请求到的资源，在等待的时候会保持，不会释放
2.不剥夺：线程占有资源在使用完之前，不会被其他线程剥夺
3.循环等待：多个线程间互相等待对方释放资源，形成循环
4.互斥条件：同一时刻只能由一个线程获取资源

以上是充分必要条件，所以只要打破其中一种就可以预防死锁

> 1.（最出名的就是使用银行家算法）（有一张资源分配表，对资源进行一个分配，不够的时候进行等待，保证分配资源后是一个安全状态（非死锁状态））（加分项，不是标准答案）
> 2.互斥条件无法打破，不考虑
> 3.打破请求与保持：通过资源一次性分配来打破，这样在允许过程中不会再因为需要新资源而产生等待了
> 4.打破不剥夺：在程序运行中，如果请求资源的时候不能立即获取，那么就放弃当前已经获取到的资源，让资源回归
> 5.打破循环等待条件：给资源编号，按照顺序分配资源

# 线程有哪些创建方式？
1.继承Thread类，实现run方法
2.实现runnable接口，实现run方法
3.实现callable接口，实现call方法，这边可以有返回值（返回类型为Future类型，一般我们用FutureTask去接收它，它实现自RunnableFuture接口，是一个组合接口，组合了Runnable和Future，这个类能够异步获取执行结果）（加分项）
4.使用线程池进行创建

# 描述一下线程安全活跃态问题，竞态条件
总：安全活跃态指死锁活锁和饥饿
分：
1.死锁就是指由于多个线程抢占互斥资源产生的循环等待的状态
2.活锁就是线程一直在执行，但是一直达不到结束条件，进而一直重复尝试（消息中间件的延时重试机制）（解决：等待一个随机时间）（扩展：raft协议，raft选主）
3.饥饿就是指一个线程由于一直被其他线程抢占资源，无法获取资源进行执行，导致饥饿（常见的情况是读写锁，读优先的情况下，读特别多，写线程就饥饿了）（解决，公平锁）（扩展：cpu调度规则，分为时间片调度算法和优先级调度算法）

竞态条件就是指多线程访问同一资源，对资源的访问顺序敏感，称为竞态条件（简单的说就是由于没有加锁，输出的时机不可预测，可能产生结果覆盖，并且结果也不可预测），导致竞态条件发生的代码区称作临界区，在临界区使用锁能够避免竞态条件

# java的wait和sleep有什么区别和联系
区别
1.关于锁方面，wait释放锁（因为锁是对象上的），sleep不释放锁（因为sleep是线程的东西，和锁没关系）
2.关于等待时间方面，sleep一定要写等待时间，wait不一定，随意
3.关于作用域方面，wait必须要在外面加synchronize锁，它与对象相关，所以是绑定在Object上的，sleep在任何线程中都可以使用，因为它是绑定在Thread类上的

联系：
都可以使线程进入Timed_Waiting状态，都可以写入等待时间，都会导致线程阻塞
如果被中断，那么都会抛出中断异常，都需要捕获异常（notify，notifyAll不需要捕获异常）

# 描述一下进程与线程区别？
1.进程是操作系统资源分配的最小单位，线程是cpu进行资源调度的最小单位
2.进程由多个线程组成，进程之间的资源不共享，所以进程间通讯需要依靠消息队列，管道，信号量进行通讯，而线程间资源共享，所以线程间的通讯方式通过共享变量，锁，不管是synchronize锁还是reentrant lock等，还有wait和notify，join的方式进行通讯

（装逼内容：在linux中，如果一个进程他需要开启一个子进程，会调用fork方法，而使用fork方法开启的子进程是数据隔离，写时复制的，所以数据不共享，linux内核中提供了另外一个方法叫做clone，clone会开辟一个共享资源的子进程，也就是线程，Linux的进程类叫做task_struct，没有线程类，这个类既做线程又做进程）

# 描述一下java线程的生命周期
总：java线程分为几种状态，NEW,RUNNABLE,WAITING,TIMED_WAITING,BLOCKED,TERMINATED
分：
1.NEW状态就是线程刚刚被创建的时候
2.线程调用了start方法，变成RUNNING状态，RUNNABLE状态中又分为Ready和Running，Ready是指正在等待cpu调度，Running是指已经获取了cpu的时间片，等到时间片用完又会变成Ready状态
3.线程调用了sleep方法或者带时间单位的wait，LockSupport.parkNanos方法，会进入TIMED_WAITING状态，等待时间结束或被唤醒转回RUNNABLE状态
4.线程调用了wait，lock，park方法进入WAITING状态，调用对应的唤醒方法进入RUNNABLE状态
5.线程由于争抢synchronize锁进入BLOCKED状态，争抢到了锁之后会回归RUNNABLE状态

（在linux内核中，线程只有三种状态，运行，阻塞，销毁，而java在与linux进行协调的时候，多规定了几个状态，java刚开始创建线程对象，此时linux中还没有创建线程，所以产生了NEW状态，等到linux中开辟了新线程，但是此时可能还未分得cpu时间片，所以产生了Ready状态，在进行阻塞的时候，分为IO阻塞和锁阻塞等，为了区分这些阻塞，把锁阻塞描述成BLOCKED，把其他阻塞描述成WAITING）

# 代码题，是否能够打印finish？
```java
public class TTT {
    static boolean a;

    public static void main(String[] args) throws InterruptedException {

        new Thread(()->{
            while (!a){

            }
            System.out.println("finish");
        }).start();
        Thread.sleep(2000);
        a = true;
	}
}
```
会，也不会
会的原因是在默认的编译器和解释器混合模式下，由于编译器的作用，进行了代码优化，所以判断只进行了一次，后面直接进入死循环
不会的原因是，如果采用纯解释执行模式，那么就不会产生编译器优化，也就不会产生问题了

而我们为什么用volatile也能解决这个问题，是因为编译器在对volatile字段进行处理时，不会进行优化，所以加了volatile也管用

# 程序开多少个线程合适
1.先用公式可以估计线程数量，是
线程数=cpu核心数\*（1+等待时间/计算时间）\* cpu利用率
即IO密集型的，那么设置为CPU核心数的2倍（一般折中处理）
CPU密集型的，设置为核心数，减少线程上下文切换
2.然后可以进行测试，慢慢调

# notify和notifyAll的区别
点出锁池和等待池的概念：
1.锁池（Entry Set）
> 锁池是指由于争抢synchronize的锁争抢失败，进入到锁池

2.等待池（Wait Set）
> 等待池是指调用了wait方法进入等待池，等待池中的线程不会参与锁竞争

notify是等待池中选一个去唤醒，notifyAll是唤醒所有等待池中的线程，这边的唤醒就是指将等待池中的线程放入锁池，然后所有线程开始抢锁，抢到锁的进行执行

# 描述一下synchronized和Lock的区别
1.synchronized可以锁的范围是方法和代码块，lock只能锁代码块
2.synchronizad它会让线程处于BLOCKED状态，而lock会让线程处于WAITING的状态
3.synchronized可以响应中断，lock无法响应中断，但是它有个方法叫lockInterruptly可以响应中断
4.synchronized是一个修饰符，而Lock是接口
5.synchronized是非公平锁，lock都可以
6.synchronized不能指定唤醒，lock可以通过Condition来实现指定唤醒

# Synchronized加在静态方法和普通方法上的区别

静态方法上锁的是当前类的class对象，普通方法锁的是当前对象

因为静态方法初始化的时候，当前实例对象并不存在，所以不可能加在实例对象上，只能加载对应的class上

## 静态变量存储在jvm的哪里？

存储在class的尾部，而class又存储在堆中，所以静态变量存储在堆内存中

# synchronized

是一种可重入非公平锁（指当前线程请求锁时如果已经持有该对象的锁，可继续获得锁，不然会导致死锁）。synchronized可以加在代码块上和方法上。synchronized表示当前代码块同时有且只有一条线程能够执行。当synchronized去请求获取对象锁时，检测当前对象上的monitor对象的计数是否为0，如果为0，就允许获得锁，否则检测当前线程是否已经持有当前对象的锁，如果已经持有，那么monitor计数再+1，否则进入等待。

synchronize在jdk1.6之前使用的是重量级锁，一直向操作系统申请锁，在jdk1.6之后实现了锁升级机制，在hotspot的实现代码中，锁升级的步骤是 无锁 到 偏向锁 到 自旋锁 到 重量级锁

偏向锁：在对象的对象头中保存了线程的id，如果下一次还是这个线程请求获取锁，那么就直接让这个线程运行，如果检测到其他线程访问，就进行锁撤销（其他机制去处理）

自旋锁：自旋等待其他线程释放锁，如果超过自旋次数（默认为10）或者自旋锁数量过多（超过cpu核心数的一半），就升级为重量级锁

重量级锁：向操作系统申请锁，进入等待队列等待获取锁（需要进行用户态与内核态的转换，速度较慢）

## 锁升级

初始状态是无锁的，当线程A调用时，产生偏向锁，用cas去替换mark word的线程id，然后当线程B来访问这个对象时，会产生两种情况，一种是线程A依然在使用锁，那么线程B就升级成为自旋锁，如果线程A不再需要使用锁，那么B就会将当前偏向锁撤销，然后再cas加偏向锁，自旋锁会先在栈中存储锁记录，里面存放了线程id，超过一定次数默认10次或者自旋锁数量过多就升级为重量级锁，会向操作系统申请锁，进入等待队列等待获取锁（需要进行用户态与内核态的转换，速度较慢）

# volatile

1.保证了线程之间的可见性
用总线嗅探和数据一致性协议来保证线程之间的可见性

总线嗅探：指cpu需要对高速缓存的数据进行有效性确认，监听总线上传播的数据进行，如果发现自己缓存行对应的地址被修改，就设置为Invalid，这样下次取数据的时候就会直接从主内存中获取

数据一致性协议：通常指的是MESI，M为Modified，E为Exclusive，S为Shared，I为Invalid，从硬件角度来说就是cpu在对自己的高速缓存区进行数据修改时，需要通知其他共享这个数据的cpu去修改数据的状态，保证数据的一致性

2.防止了代码重排序
通过内存屏障来防止代码的重排序
JMM中定义的内存屏障有两种，分别为Store Barrier和Load Barrier，StoreBarrier用于在存储数据之后立即刷新到内存，LoadBarrier用于无效高速缓存的数据，重新从主内存读取
JMM中的volatile内存屏障策略
在volatile写之前加入storestore
在volatile写之后加入storeload
在volatile读之后加入loadstore
在volatile读之后加入loadload

# CAS

compare and swap
主要实现的功能就是有一个期望值，和一个更新值，当我的期望值与我所访问的地址的值相等时，就用更新值去更新对应地址的值，如果不相等，就放弃更新
主要用CAS实现的类有AtomicXXX类

## CAS的ABA问题
就是指当t1线程去修改一个对象A时，时间片用尽，此时线程t2也用到当前的对象A，将当前对象A替换成对象B后进行了一系列操作，然后再把A放回去，结束线程t2，此时t1再去比较期望值A与地址中的A值，发现一样，仍然对A进行了更新操作，这就是ABA问题

## 如何解决ABA问题
可以通过使用AtomicStempReference类去包装对象，实际上就是用了一个版本号去标记对象是否为原版对象

# AQS

AQS是一个次级抽象类，它的父类抽象类是AbstractOwnerableSynchronizer, 父类抽象类中有个主要的属性用于记录当前占有锁的线程，用以实现可重入锁。
AQS是CLH锁的一种变体，CLH是一种基于单链表实现的公平自旋不可重入锁，它与CLH锁不同点在于，AQS使用了双向链表并且AQS的Node节点在自旋等待的时候，会调用LockSupport的park方法进行等待，在释放锁时会调用LockSupport的unpark方法对后继节点进行唤醒。
AQS的结构是双向链表+一个线程间可见的state属性，根据属性去判断当前锁是否被持有，通过CAS去操作state和双向链表的头尾节点
AQS的子类通过实现tryAcquire方法可以实现公平锁和非公平锁，在JDK1.9之后，AQS优化了指向头尾节点的指针，用VarHandle的CAS来操作对应的地址，直接操作二进制码，速度更加快
VarHandle就是一个指向地址的指针，提供了原子修改值的方法，并且能直接操作二进制码

# ReentrantLock

ReentrantLock是一种可重入的独占锁，ReentrantLock内部持有了AQS的锁的实现类，内部的Sync继承了AQS，然后NonFairSync和FairSync继承了Sync抽象类，实现了公平锁和非公平锁
非公平
NonFairSync的逻辑：
先判断当前线程是否能抢占到锁，如果可以抢占到就直接执行，不然就看看当前线程是否持有锁，如果持有就计数+1，如果不是当前线程正在持有就进入等待队列等待
FairSync的逻辑：
先判断当前队列中是否为空，如果为空就就抢占锁，如果不为空就看看是否是当前线程正在持有锁，如果是当前线程正在持有锁，就继续执行，不然就进入等待队列
Sync释放的时候会减少state，如果减到0就释放锁并且将独占锁的线程置为空，并且唤醒后继节点

# ThreadLocal

每个线程上都有一个threadLocals属性，维护了线程专属的本地变量，当使用set方法时，将ThreadLocal对象存入threadLocals属性中，取的时候从threadLocals中取
threadLocals是一个ThreadLocalMap对象，里面用数组存储了一组Entry对象，Entry中存储了具体值，get时通过当前对象的hash值去找到Entry的位置，返回对应的值
Entry是一个继承了弱引用的对象，它的key是一个弱引用，以达到一个防止内存泄露的效果，对于被回收的key而言，在ThreadLocalMap中就是一个老旧对象，在set的时候会替换这些key为null的Entry，get的时候也会清理这些key和value
即便这样，ThreadLocal依然存在内存泄漏问题，是由于value产生的内存泄露问题，如果当前Thread生命周期较长，它持有的threadLocals就不会被释放，导致虽然key为弱引用，但是value不是弱引用产生内存泄漏

具体应用：spring做事务进行线程隔离

# 强软弱虚

强引用永远不会被垃圾回收器处理
软引用当内存不够的时候会被垃圾回收器回收，做缓存用
弱引用是当它被垃圾回收器扫描到的时候被回收，一般用在容器，ThreadLocalMap中的Entry对象的key用的是软引用，弱引用通过get方法能获取对象
虚引用是随时会被回收，并且回收的时候会将引用放在队列中通知用户,虚引用通过get方法不能获取对象，是用来清理堆外内存（直接内存）（DirectByteBuffer）（用Unsafe去处理堆外内存 freeMemory）

# ForkJoinPool

ForkJoinPool基于工作-窃取理论来实现，通过将大任务分成一个个子任务进行执行，并将子任务汇总得出最终的结果。
ForkJoinPool通过继承自定义任务类型RecursionAction创建递归任务，分块执行，它的每个线程都维护了一个自己的任务队列，当有任务时执行队列中的任务，无任务时从别的线程任务队列尾部偷取一个进行执行，减小了其他线程的压力

# ThreadPool线程池

- 线程复用
- 控制最大并发数
- 管理线程

> 通过Executor框架实现，该框架中用到了Executor,ExecutorService这两个接口以及Executors,**ThreadPoolExecutor**这两个类

Executors中定义的线程池本质上都是ThreadPoolExecutor(前四个)

Executors中定义好的线程池类型

- ```java
  //固定大小的线程池，阻塞队列为LinkedBlockingQueue
  newFixedThreadPool(int nThreads)
  ```

- ```java
  //只有一个线程，阻塞队列为LinkedBlockingQueue
  newSingleThreadExecutor()
  ```

- ```java
  //可扩容的线程池，默认大小为0，最大线程数为Integer.MAX_VALUE 阻塞队列为SynchronousQueue
  newCachedThreadPool()
  ```

- ```java
  //创建定时或周期性任务执行线程池ScheduledThreadPoolExecutor
  newScheduledThreadPool()
  ```

- ```java
  //创建并行执行线程池ForkJoinPool
  newWorkStealingPool()
  ```

## ThreadPoolExecutor参数

- ```java
  public ThreadPoolExecutor(int corePoolSize,
                            int maximumPoolSize,
                            long keepAliveTime,
                            TimeUnit unit,
                            BlockingQueue<Runnable> workQueue,
                            ThreadFactory threadFactory,
                            RejectedExecutionHandler handler) {}
  ```

- corePoolSize ：常驻核心线程数

- maximumPoolSize ： 可容纳的最大线程数，最小为1

- keepAliveTime ：多余空闲线程的存活时间，当线程数超过常驻核心线程数，并且存活时间达到keepAliveTime 时，多余线程会被销毁，直到只剩下corePoolSize 个线程为止

- unit：keepAliveTime 的单位

- workQueue：任务队列，被提交但尚未被执行的任务

- threadFactory：生成线程池中工作线程的线程工厂，用于创建线程，一般默认的即可

- handler：拒绝策略，表示当队列满了，并且工作线程大于等于线程池的最大线程数（maximumPoolSize ）时如何来拒绝请求执行的Runnable的策略，默认拒绝策略会将多余的线程排除在队列之外并报错



## 工作原理

- 在创建了线程池之后，开始等待请求
- 当调用execute()方法添加一个请求任务时，线程池会进行如下判断：
  - 如果正在运行的线程数小于corePoolSize，会立即创建核心线程运行该任务
  - 如果正在运行的线程数大于corePoolSize，则将该任务放入等待队列
  - 如果队列满了并且正在运行的线程数量小于maximumPoolSize ，创建新的非核心线程来运行这个任务
  - 如果队列满了并且正在运行的线程数量大于maximumPoolSize，那么线程池会启动饱和拒绝策略来执行

- 当一个线程完成任务时，会从队列中取下一个任务来执行
- 当一个线程空闲并且超过一定时间keepAliveTime 时，线程会判断当前运行的线程数是否大于corePoolSize ，如果大于的话，该线程会被销毁，所有的线程完成任务之后，最终会收缩到corePoolSize 的大小



> 实际应用中不会使用Executors去创建，会自定义ThreadPoolExecutor，Executors中FixedThreadPool和SingleThreadExecutor默认的队列最大长度为Integer.MAX_VALUE，可能会堆积大量线程导致OOM
>
> CachedThreadPool和ScheduledThreadPool的最大线程数为Integer.MAX_VALUE，可能会创建大量线程导致OOM



## ThreadPoolExecutor拒绝策略，自定义策略实现RejectedExecutionHandler

- AbortPolicy(默认策略)：直接抛出RejectedExecutionException异常
- CallerRunsPolicy：调用者运行一种调节机制，该策略不会抛出任务，也不会抛出异常，而是将某些任务回退到调用者，从而降低新任务的流量
- DiscardPolicy：直接丢弃这个任务，不触发任何动作
- DiscardOldestPolicy：如果线程池未关闭，就弹出队列头部的元素，然后尝试执行当前任务

## 任务结束后会不会回收线程

线程分两种一种是核心线程一种是非核心线程，对于非核心线程，任务结束后经过一段时间，keepalivetime后会进行回收，如果是核心线程，有一个参数设置，如果设置了allowCoreThreadTimeout，那么和非核心线程一样等待keepalivetime的时间之后进行回收，如果没设置，就不回收

## 线程池线程存在哪

存在workers中，workers是一个HashSet集合

## cache线程池会不会销毁核心线程

不会，cached线程池根本没有核心线程，何来回收，只会回收非核心线程，默认是60s之后回收

## 线程池的状态

总：一共有五种，RUNNING,SHUTDOWN,STOP,TIDYING,TERMINATED

分：RUNNING：指线程池刚创建完毕，可以接收任务，可以执行任务

SHUTDOWN：表示不接受任务，但是执行任务

STOP：表示立即终止，不接受任务也不执行任务，中断正在处理的线程

TIDYING：中间状态，如果SHUTDOWN的队列为空且线程数为0或者STOP的线程数为0那么就进入TIDYING状态

TERMINATED：回调terminated方法，线程池终止状态

# G1和CMS的异同

相同：都是并发垃圾回收器

不同：G1采用的复制算法进行垃圾收集不会产生内存碎片化，但是CMS采用标记清除算法进行垃圾收集所以它会产生内存碎片化，G1可以预测停顿时间，他有一个CSet用来收集需要被回收的region，可以通过设置CSet的大小来预测停顿时间

# G1什么时候引发full GC

总：当G1的回收速度赶不上垃圾的生产速度的时候

分：有人调用了System.gc(),老年代可用空间不足（答多了有问题，建议少回答一点，G1这边full gc很坑）

# HashMap和HashTable不同

最大不同hashmap是线程不安全，HashTable线程安全，但是hashmap的key可以为null，HashTable的key不可以为null