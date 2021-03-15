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
![image](C:\Users\28267\Desktop\笔记\picture\线程状态转化图.png)

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

