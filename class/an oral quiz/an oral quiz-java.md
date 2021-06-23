# 聊一下java的集合类，以及在项目中如何运用的（引子问题）

总：

java的集合类分为两个接口Map和Collection，其中Collection又分为三种，List，Set和Queue

分：

对于Map，是一个键值对的结构，常用于存储缓存的时候。常用的子类的实现为HashMap和TreeMap，然后它们对应的并发容器为ConcurrentHashMap和ConcurrentSkipListMap

对于Collection中的List，常用来存放一组对象，其中对象可以重复。常用的实现类为ArrayList，它对应的并发容器是CopyOnWriteArrayList

对于Collection中的Set，常用来存放一组不重复对象，项目中常用于去重，获取唯一值。常用的实现类为HashSet和TreeSet，它们对应的并发容器分别是CopyOnWriteArraySet和ConcurrentSkipListSet

对于Collection中的Queue，是一个先进先出的队列，项目中常用的Queue为各种阻塞队列，线程池。子类实现有ArrayBlockingQueue，LinkedBlockingQueue，PriorityBlockingQueue，SynchronousQueue，LinkedTransferQueue，DelayQueue，对应的并发容器为ConcurrentLinkedQueue

# HashMap为什么要使用红黑树

老版的HashMap其实并没有使用红黑树，只是在后来jdk 1.8的时候做了改进，老版的HashMap使用的数据结构是数组+链表，新版改用数组+链表+红黑树

那么为什么要用红黑树呢，因为当产生hash冲突的时候，有可能由于hash算法做的不够好，产生大量hash冲突，而hashMap对Hash冲突的解决方案是使用链地址表，所以会不断的增加链表长度，导致后续的查询缓慢，所以在jdk1.8的时候加入了链表转红黑树的机制，当链表长度大于8并且总大小大于64时（6个会退回为链表结构）（为什么是8，是根据概率论的泊松分布计算出来的），就会进行红黑树的转化，红黑树在查找时的时间复杂度是O(logN)的，而链表是O（N）的，所以大大加快了查询速度
# 讲一下HashMap吧

先聊一下它的结构吧，在jdk1.7之前，它的结构是数据+链表，在jdk1.8之后，它的结构转化为了数组+链表+红黑树

然后一般讲hashmap的话会讲三个方法，put，get，resize

先讲get方法，当获取到一个key之后，先去计算key的hash，用高16位异或低16位进行运算，算出来之后通过与运算代替取模运算进行取模，然后可以找到对应的数组的位置，然后进行查找，如果当前位置上无值的话，那么返回null，如果当前位置上有值得话，那么就进行键的equals，如果相等，就返回值，如果不等，那就继续向后寻找，直到找到或者找不到，找到就返回值，找不到就返回空

然后讲讲put方法，put方法前面和get方法一样，通过计算key的hash值然后取模找到对应的数组位置，找到之后，进行比较，如果说当前key和位置上的key相等，那么就替换，如果不等，就向后寻找相等的，如果一直找不到，那就创建一个结点，放在链表或者红黑树的尾部

然后讲讲resize方法，和resize方法相关的两个参数为capacity和load factory，这两个参数相乘，就是我当前的阈值，如果说我加入新的结点之后，会大于这个阈值的话，那么我就要进行一个resize，并且重新计算对应的hash值，resize发生在两个阶段，一个是刚创建的时候，我要向里面放入值，需要进行初始化，按照用户输入的数值进行最接近的一个2的倍数的计算，然后初始化成那个大小，默认初始化大小为16，还有一个就是超出阈值的时候


# 集合类是怎么解决高并发中的问题？

(可以先说一下非安全的集合类：

HashMap,TreeMap，LinkedList，ArrayList，HashSet，TreeSet)

有几种解决方案：

1.最好的：直接使用java JUC包中对应的的并发集合类

> 常用的并发容器：
>
> ConcurrentHashMap
> ConcurrentSkipListMap
> ConcurrentSkipListSet
> CopyOnWriteArrayList
> CopyOnWriteArraySet
> ConcurrentLinkedQueue

2.加锁：自己加锁或者使用Collections提供的synchronizedCollection方法加锁(代理模式用SynchronizedCollection对象来代理集合,因为没有实现同一个接口,所以不能说是使用了装饰者模式),或者使用java提供的例如HashTable,Vetor这些性能不高的集合类

## ConcurrentHashMap与HashTable的区别

HashTable所有方法都是无脑上锁，性能较低，ConcurrentHashMap只对需要的方法进行上锁，并且上锁的方式jdk1.7以前是使用分段+CAS的方式,在1.8之后是使用synchronize+CAS的方式，性能优秀

## 讲一下CopyOnWriteArrayList和CopyOnWriteArraySet
都是使用的写时复制机制,用户读的时候可以并发读,写的时候也不影响其他线程读.写的时候复制一份新的,然后等写完了通过访问新的地址来访问新集合.一般用于读多写少的场景

实际上,CopyOnWriteArraySet底层使用CopyOnWriteArrayList实现,在存放的时候会调用CopyOnWriteArrayList的addIfAbsent的方法来确保加入的值都是不重复的

(只能保证数据最终一致性,不能保证实时的,原因是写时复制需要时间)

# 简述一下自定义异常的应用场景
1.有时候java描述的异常不是很精确,有些具体的业务逻辑异常是java中提供的普遍的无法描述的,需要使用自定义异常(比如说后台进行具体的业务分析的时候,某个关键字段出现错误,比如存钱的时候钱变成不合法的数的时候,数据库本身会报错,但是我们只能获取一个convert转换的异常,并不明确,说不定是别的字段报错,,在这边可以用自定义异常精确报错)

(2.挖坑,让甲方交钱,防止甲方找其他程序员进行维护,发源码的时候不把异常类型的源码发过去,也不把异常文档发过去,增加对方的维护成本,让对方无法找三方进行维护)

## 自定义异常的具体操作
继承Exception类或者RuntimeException类
定义构造方法
使用异常

# 描述一下Object类中的常用方法(引子问题)
有常用于描述对象字符串表达形式的toString方法(默认返回类全名+@+对象的hash码)
然后对象比较的equals方法和hashCode方法(重写equals方法必须重写hashCode方法,不然会产生以hashCode计算的容器如HashMap和HashSet还有HashTable功能失效)
配合synchronize锁一起使用的wait,notify,notifyAll方法
还有获取当前元数据指针的getClass方法
用于回收的finalize方法(对象被回收的时候会进行调用,可以在这边实现对象复活,jvm最多调用一次,然后标记这个对象的finalize方法已经执行过了,第二次就不执行了,手动调用无限制但是最好不要那么做)
用于拷贝的clone方法(实现的时候通过实现Cloneable接口实现浅拷贝,如果要实现深拷贝的话要自己重写clone方法)(clone方法与new一个对象复制属性的对比:clone效率高,直接复制一整段内存地址)

# 进程间通讯的方式
1.管道
2.信号量
3.消息队列
4.共享内存
5.套接字

# 线程间通讯的方式
由于多线程之间共享了内存空间，所以本身就是支持通讯的，主要是要解决线程并发通讯的问题，需要一些同步机制

1.共享变量volatile
2.加锁synchronize,wait,notify/LockSupport/CountDownLatch
3.join

## 为什么wait,notify必须要放在synchronize代码块中
wait,notify调用的时候必须拿到对象的监视器monitor对象,所以要加入synchronize,然后字节码中就会产生monitorenter指令,获取对应的monitor对象

# jdk1.8的新特性
1.lamda表达式(本质匿名内部类)
2.函数式接口(就是只有一个方法的接口)(函数式编程)
3.流式API Stream
4.方法引用,构造器引用(System.out::println,Class::new)
5.日期API(LocalDateTime,LocalDate,LocalTime,线程安全(和String一样,是不可变的,所以线程安全))
6.接口默认方法和静态方法
7.Optional 类

# jdk1.9的新特性(随便背两个)
1、目录结构(移除了jre的子目录)
2、JShell工具
3、模块化
4、多版本兼容Jar包
5、Interface的升级
6、钻石操作符的升级
7、异常处理try-with-resource升级
8、String底层存储结构更换(char[] 变 byte[])
9、Stream API 新方法的添加
10、引进HttpClient
11、垃圾收集器的优化(优化Parallel Old和ParNew)

# jdk10的新特性(随便背两个)
1、局部变量var
2、copyOf方法(java.util.List、java.util.Set、java.util.Map新增加了一个静态方法copyOf)
3、ByteArrayOutputStream改进
4、PrintStream、PrintWriter新增构造方法
5、Formatter、Scanner新增构造方法
6、垃圾收集器的优化(并行full gc)

# jdk11的新特性(随便背两个)
1、局部变量var增强
2、字符串自带方法增强
3、HttpClient加强方法
4、移除JavaEE模块和CORBA技术
5、引入Epsilon Debug垃圾收集器
6、引入ZGC
7、支持G1上的并行完全垃圾收集
8、完全支持Linux容器（包括Docker）

# jdk12的新特性(随便背两个)
1、Shenandoah低暂停时间垃圾收集器
2、Microbenchmark Suite(内置基准测试工具)
3、Switch表达式改进(少写了break代码)
4、JVM常量API
5、JDK12之G1的可流动混合收集(升级mixed GC)
6、核心库java.lang中支持Unicode11
7、安全库java.security,javax.net.ssl,org.ietf.jgss

# jdk13的新特性(随便背两个)
1、switch优化更新(可以有返回值)
2、文本块升级(三个引号描述文本块)
3、ZGC增强(取消使用未使用的内存)
4、重新实现旧版套接字API 
5、nio新方法

# jdk14的新特性(随便背两个)
1、Switch定版(最终版本)
2、垃圾回收器全面优化
3、NIO的Channel通道
4、Record记录类（预览版）
5、instanceof的模式匹配

# jdk15的新特性(随便背两个)
1、ZGC正式版本
2、Record(第二版)
3、密封类（预览版）(只允许被指定类扩展和实现)
4、Shenandoan正式版本

# jdk16的新特性(随便背两个)
1、Record(最终版)
2、Stream新增toList方法
3、instanceof的模式匹配(最终版本)
4、打包工具修改

# 总结一下,使用哪个版本(无正确答案)
我认为要使用的话,其实用JDK12就完全足够了,一个是jdk12发布也很久了,相对趋于稳定,并且jdk12最大的好处就是完成了G1的最终升级,几乎已经是最终版了,可以让GC的利用率达到最高,并且后面的版本加入的新特性如record和sealed密封类,感觉只是单纯的简化了代码,没有很大的必要去使用,越往后的版本,bug肯定越多

一句话,还是看项目用的内存大小和GC来选择

# 简述一下java面向对象的基本特征

总:封装,继承,多态

分:

封装是指封装对象,把多个属性封装成对应的类,隐藏实现细节,提供具体方法(这里可以扯六大设计原则中的 单一职责原则)

多态是指一种事物表现出的不同形态,具体表现为在java代码写出来的时候并不能确定运行结果,只有在运行过程中使用到具体的实例的时候才能够知道运行结果,也就是接口和抽象类(这里可以扯六大设计原则中的 依赖倒置原则和里氏替换原则,接口和抽象类甚至还能小带一下代理模式)(还可以提一嘴接口可以继承多个接口,打破了单继承)

继承就是用子类继承父类,由已知类生成扩展类,可以对父类进行扩展,使用父类的非私有属性和方法(这里可以扯设计模式中的桥接模式和装饰者模式,用组合替代继承,防止类爆炸)

# java中重写和重载的区别

总:重写是指重写父类方法,重载是指重载当前类中的方法

分:

重写的时候方法名一定要一样,传参一定要一样,返回值可以小于父类,抛出异常也要小于父类,修饰符大于父类

重载的话就是参数个数可以不一样,参数类型可以不一样,返回值可以不一样,修饰符可以不一样方法名一样

(目的区别:重载是为了方便使用和记忆,重写是因为父类无法使用)

# 怎样声明一个类不会被继承,什么场景下会使用

用final修饰的类不会被继承,为了安全可以使用final,String就不能被继承(如果String被继承了,可能会被继承然后重写方法,导致调用的时候调用到重写的方法,从而产生数据泄露等问题)

# java中的自增是线程安全的吗,如何实现线程安全的自增

不是,i ++ 动作分为三个步骤,第一步,取出i,第二步i + 1,第三步赋值,是个非原子操作,要实现线程安全,一般可以使用AtomicInteger等原子类,或者使用锁来实现

(连带回答:AtomicInteger底层使用Unsafe方法,使用到了CAS,CAS会产生的问题以及如何解决等)

# jdk1.8中的stream用过吗?详述一下stream的并行操作原理?

用过,stream经常用的就是list和map的stream流,用于进行一些简单的运算(reduce),计数(count),或者循环遍历(foreach),过滤(filter),映射(map),排序(sorted)等,如果数据较多还可以并行处理,使用parallel方法

stream的并行操作底层主要是用fork-join线程池来完成的,fork-join线程池使用的技术是work-stealing工作窃取技术,意思就是多个线程共同工作的时候,每个线程都有自己的一个工作队列,总有那么一两个牛逼的线程把自己的活先干完了,那么为了让线程充分利用,不要干等,就让这些线程去其他有任务的线程那边,从尾部偷取一个执行,加速运算,forkjoin把大任务分割成一个个子任务,进行多线程执行,然后汇总

## 项目中有用过fork-join吗?

有,我在往excel写入数据的时候,每一个record都填一行,而且数据很多,我就以500为一组分组,使用forkjoin线程池进行插入

# java中代理的实现方式?

总:java代理分为两大类,动态代理和静态代理

分:

静态代理:就是自己手写一个代理类来代理具体对象,参照SynchronizeCollection类

动态代理:

动态代理常用的还分两种,第一种:jdk动态代理,第二种cglib代理

jdk动态代理的底层实现是它创建了一个代理类继承了Proxy类,然后实现了对应的代理接口,代理了被代理类,所以必须要有interface才能够用jdk动态代理,并且只能读取到接口上的注解.然后创建代理对象,在程序运行过程中,实际调用的类是代理类,而不是被代理类(MyBatis中用到,Spring AOP用到)

cglib代理主要是子类代理,即创建一个当前被代理类的子类,所以被代理对象不能是final对象,不然会报exception,并且它可以读取到类上的注解.然后创建代理对象,在程序运行过程中,实际调用的类是代理类,而不是被代理类(Spring AOP用到)

(jdk动态代理和cglib动态代理底层都使用的ASM框架来动态生成类字节码,ASM未研究,太深了,再说下去就裂开了)

# java中有几种关键字，作用

1.private，私有
2.protect，保护
3.public，共有
4.abstract：抽象类
5.interface：接口
6.class：类
7.volatile：易失的
8.synchronize：锁
9.final：最终的
10.static：静态的
。。。

# final和finally
final修饰局部变量，final修饰参数列表，final修饰成员变量，final修饰类，final修饰方法
finally和final毫无关系，只不过是try catch捕获异常的时候需要最终处理的代码块，一半用于释放资源，避免在finally中进行return，会导致执行顺序错误

# 接口和抽象类
1.接口和抽象类都无法被实例化，都能有抽象方法

1.接口要被实现，抽象类要被继承
2.一个类可以实现多个接口，但只能继承一个抽象类
3.接口之间互相继承可以进行多继承（打破单继承问题）
4.接口中的方法都是public的，抽象类中可以有私有方法
5.接口中的成员变量都是公有的静态成员变量，抽象类中无限制
6.接口在jdk1.8之后允许default修饰的具体方法实现，抽象类中无限制
7.接口中不能定义构造方法，抽象类可以

# 说一说程序的设计原则和设计模式
设计原则：solid
s：单一职责原则：一个类尽量只封装属于自己要干的事，不要身兼数职
o：开闭原则：对扩展开放对修改关闭
l：迪米特法则：也称最少知识原则，就是一个类所接触的其他类越少越好
l：里氏替换原则：指所有的接口都可以用实现类去替换而且不报错
i：接口隔离原则：指接口暴露出来的方法尽量少而精不要多而广
d：依赖倒转原则：尽量依赖接口和抽象类，而不是直接依赖实现类

设计模式：
1.单例模式：永远只有一个实例
2.工厂方法模式：指使用工厂去创建对应产品，扩展点在产品上，可以方便的对产品进行扩展
3.抽象工厂模式：指使用工厂去创建产品族，扩展点在产品族上，要加入新产品是很困难的，影响较大
4.原型模式：指使用当前已有的对象作为模板对象，进行复制
5.享元模式：共享元数据
6.策略模式：根据传入的策略的不同，程序运行的行为也不同
7.构建者模式：创建复杂对象
8.门面模式：将一组类进行封装，封装成一个api类以提供给外界使用
9.装饰者模式：在一个已有类上进行功能的扩展，以组合代替继承，防止类爆炸
10.桥接模式：对一个类进行抽象和具体两个维度的划分，以组合代替继承，防止类爆炸
11.观察者模式：对事件进行监听并做出响应
12.适配器模式：将接口转化成为用户所能够使用的接口
。。。

# 代码块以及代码块和构造方法的执行顺序

静态代码块：在类加载的时候会执行
普通代码块：方法中的代码块
构造代码块：在对象初始化的时候会执行
同步代码块：同步的时候

# Mybatis的一级缓存

默认开启，查询都会存在sqlsession的一级缓存中，存的时候key为sql和参数还有一些其他信息如MapperId等，值为查询结果，如果中间有提交操作，就清空所有缓存，查的时候会先去缓存中查再去数据库查，结构是map

# Mybatis的二级缓存

默认不开启，二级缓存是namespace级别的，缓存在namespace中，存的时候key为sql和参数还有一些其他信息如MapperId等，二级缓存通过CacheExecutor去实现

# 什么是序列化？为什么要进行序列化？

序列化就是指对象可以转成二进制数据，然后有一个序列化码可以将对象进行反序列化读取

数据传输或者存储对象的时候要进行序列化，缓存的时候可以使用序列化

# java序列化中如果有些字段不想进行序列化怎么办

加transient

# StringBuffer和StringBuilder的区别，String为什么是不可变的

StringBuffer和StringBuilder都继承与AbstractStringBuilder类，StringBuilder线程不安全，StringBuffer线程安全，String被final修饰同时存储的数组也是final的，所以不可变

## 扩容机制

新容量=旧容量*2+2

# 运行时异常和受检异常

运行时异常就是RuntimeException的子类，受检异常是Exception中除RuntimeException的其他类，运行时异常不需要提前捕获，受检异常需要提前捕获

# JVM如何处理异常

一个方法中发生异常，会创建异常对象，并转交给JVM，JVM会查看是否可以处理异常（有无try catch）,如果有就处理，没有就交给默认异常处理器，默认异常处理器将异常信息打印到控制台并终止程序