# JVM

## jvm是什么
java virtual machine，是一种规范，jvm主要由三大块组成
1.类加载子系统
2.运行时方法区
3.执行引擎

## 常用的JVM
常用的JVM有
HotSpot
老版的Jrockit
TaobaoVM
MicroSoft VM
LiquidVM

## JDK,JRE,JVM
JRE由JVM和核心类库构成
JDK由JRE和开发者工具构成

# Class文件
是一种二进制字节流

## 结构
**Magic Number - u4**
魔数，用于判断文件是否损坏，在class文件中是cafe babe（唯一标识符）
**Minor Version**
小版本号
**Major Version**
大版本号
**constant_pool_count - u2**
常量池大小，因为是无符号2字节，所以是16位，所以大小为65535
包含的信息：
标志tag
索引
类型

**constant_pool**
常量池具体实现，编号从1开始，所以常量池的数量是constant_pool_count - 1
**access_flags - u2**
修饰符
public 0x0001
final    0x0010
interface 0x0200
abstract  0x0400
annotation 0x2000
enum 0x4000
ACC_SYNTHETIC 0x1000，编译器生成
ACC_SUPER 0x0020，该标志位必须为真，JDK1.0.2之后编译的class均为真

全部属性相与就能得到最终的修饰符
**this_class - u2**
当前类名（指向常量池中的内容）
**super_class - u2**
父类名（指向常量池中的内容）
**interfaces_count - u2**
实现了几个接口
**interfaces**
具体实现的接口
**fields_count**
有几个属性

描述符索引
B - byte
C - char
D - double
F -float
I - int
J - long
S - short
Z - boolean
V - void
L - Object
数组[
**fields**
具体属性
**methods_count**
有几个方法
**methods**
具体方法
**attributes_count - u2**
几个附加属性
**attributes**
具体附加属性

## 观察bytecode的方式
1.javap -v [path]
2.JClassLib - IDEA插件

# 类加载器
## 加载过程
1.loading
2.linking
  1.verification
    检查加载到内存中的字节码的正确性(是否有CAFE BABE)
  2.preparation
    将类中的静态成员变量赋默认值
  3.resolution
    将符号引用解析为直接访问的地址
3.initializing

## loading
### ClassLoader
![调用loadclass后](picture/调用loadclass后.png)
加载的时候实际上不仅将字节码原封不动放入内存外，还生成了一个Class类对象（metaspace中）指向那块内存区域，然后其他对象通过Class类对象去访问字节码文件

通过类的getClassLoader()方法可以获取对应的类加载
（1）启动类加载器（BootStrap ClassLoader）：用来加载java核心类，加载lib/rt.jar,lib/resources.jar等核心类。get的时候为null因为是C++实现的。
（2）扩展类加载器（Extension ClassLoader）：用来加载外部引入的jar包，即ext包下的jar。
（3）应用类加载器（Application ClassLoader）：用来加载应用程序内自己写的类，用户路径（classpath）下的类。

classLoader源码：
findCache -> parent.loadClass -> findClass
#### 双亲委派机制
![picture/双亲委派.png](picture\双亲委派.png)

千万注意双亲委派并不是继承关系，父加载器并不是父类。
每个classloader都有一个缓存，缓存着已经加载过的类，当接收到加载类的请求时，先去缓存中查询，找到就返回，找不到就去父加载器找，直到找到最顶层的bootstrap，如果bootstrap还找不到，就让Ext去加载，如果Ext加载成功，就返回，如果加载失败，让App去找，直到找到最先进来的那个类加载器，如果最终加载失败抛出ClassNotFoundException

总结：自底向上依次进行缓存查询，自顶向下依次尝试加载类

**为什么要有双亲委派机制**
为了安全，保证java的核心类库不被偷偷摸摸的改写，加载一个奇奇怪怪的类进去
如果没有双亲委派机制，就可以偷偷自定义一个和java核心类库中一模一样的类，然后覆盖原始类，打成jar包给客户使用的时候可以获取一些不正当的信息

### Launcher(1.8)/ClassLoaders(11)
Launcher/ClassLoaders中有ExtClassLoader和AppClassLoader
里面指定了
BootStrapClassLoader加载sun.boot.class.path
ExtClassLoader加载java.ext.dirs
AppClassLoader加载java.class.path

### 如何加载一个类
调用类加载器的loadClass方法

什么时候需要加载一个类？热部署

### 自定义类加载器（模板方法模式）
继承ClassLoader实现findClass方法，用defineClass转化成内存对象

#### 可以实现加密
防止别人用其他的classloader来load你的类

### 混合模式
解释器（bytecode intepreter）+及时编译器（JIT）

混合使用解释器 + 热点代码编译
起始阶段采用解释执行
热点代码检测：
  多次被调用的方法（方法计数器：监测方法执行频率）
  多次被调用的循环（回边计数器：检测循环执行频率）
  进行编译，编译成本地（native）代码

--Xmixed 默认为混合模式
--Xint 使用纯解释模式，启动快执行慢
--Xcomp 使用纯编译，启动慢执行快
--XX:CompileThreshold=10000

### lazyLoading
严格叫lazyInitializing，JVM并没有规定何时懒加载，只规定了何时初始化

### question
1.如何自定义父加载器？
ClassLoader构造方法中调用父类构造方法，默认的是通过无参构造方法创建的AppClassLoader

2.如何打破双亲委派机制？
因为双亲委派机制实质是模板方法的设计模式，它的loadclass方法中调用了父加载器并且loadclass方法是非final的，可以通过重写loadclass方法去打破双亲委派机制

3.何时打破？
Tomcat热部署，热启动的时候，需要加载同一类库的不同版本，如果使用双亲委派就无法加载,在加载前就已经从缓存中取出了
```java
    static class ClassL extends ClassLoader{
        @Override
        public Class<?> loadClass(String name) throws ClassNotFoundException {
            Class<?> ret = null;
            String path = "D:/Spring/untitled/target/classes/" + name.replace('.', '/').concat(".class");
            File file = new File(path);
            if(!file.exists())
                return super.loadClass(name);
            try {
                InputStream inputStream = new FileInputStream(file);
                byte [] b = new byte[inputStream.available()];
                inputStream.read(b);
                ret = defineClass(name,b,0,b.length);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return ret;
        }
    }
```

## linking and initializing
### question
1.DCL（Double Check Loading）中已经有了synchronized锁为什么要加volatile？
因为synchronized只能保证线程互斥，而DCL中生成单例对象时，有一个new对象然后赋值给属性的一个过程，这一过程并不是原子操作，它分为三步，第一步分配空间给对象赋默认值，第二步进行初始化，第三步将引用指向初始化好的对象，如果线程一创建对象时发生了指令重排序，刚好执行了13步，还没执行第二步，线程二过来检测发现属性已经不为空了，就直接返回了，此时返回的对象是半初始化对象，属性全是默认值，还没进行初始化的赋值，所以要加volatile

# JMM
## 存储器的层次结构
CPU内部
L0:寄存器
L1:高速缓存
L2:高速缓存

CPU共享
L3:高速缓存
L4:主存
L5:磁盘
L6: 远程文件存储

## 多线程一致性的硬件支持
老CPU实现通过总线锁

现代CPU使用 总线锁(缓存锁无法处理)+缓存锁保证硬件的缓存一致性
新型CPU使用各种协议保证数据一致性
像MESI（Intel）,MSI,MOSI等
缓存锁实现之一
M(Modified):有效数据，和主存数据不一致，数据存在CPU本地缓存
E(Exclusive):有效数据，CPU独享，数据存在CPU本地缓存
S(Shared):有效数据，CPU共享，和主存数据一致，数据存在CPU本地缓存
I(Invalid):无效数据，被其他CPU修改

## 缓存行
一个缓存行为64字节

利用缓存行做的优化，消除伪共享
```java
//Disrupter
    public static final long INITIAL_CURSOR_VALUE = Sequence.INITIAL_VALUE;
    protected long p1, p2, p3, p4, p5, p6, p7;
```
### question
1.伪共享？
位于同一缓存行的两个不同数据，被两个不同CPU锁定，产生互相影响的伪共享问题
解决：使用缓存行对齐，@Contended注解

## 指令重排
### 乱序问题
为了加快CPU运行速度，CPU会对指令进行优化，乱序执行，读指令的同时执行其他不影响当前指令的指令，写指令的同时进行合并写（WriteCombiningBuffer）（写入L2时可能由于新来的指令改变了写入L2的值，所以将两条指令合并计算最后结果写入）
两条指令无依赖关系，会乱序执行

### 合并写缓存
速度快于L1缓存，不过缓存只有4字节，非常珍贵

### 硬件级别下保证有序
**CPU内存屏障x86**
sfence(save fence):在sfence之前的写操作必须在之后的写操作前完成
lfence(load fence):在lfence前的读操作必须在lfence后的读操作前完成
mfence(memory fence):在mfence前的读写必须在mfence后的读写操作前完成

原子指令，如x86上的lock指令，锁定内存区域
**java内存屏障规范**
LoadLoad屏障：
对于语句 Load1;LoadLoad;Load2
Load1要在Load2前被读取
StoreStore屏障：
对于语句 Store1;StoreStore;Store2
Store1要在Store2执行前被刷新回内存
LoadStore屏障：
对于语句 Load1;LoadStore;Store2
Load1要在Store2前被读取
StoreLoad屏障：
对于语句 Store1;StoreLoad;Load2
Store1要在Load2前刷新回内存

### volatile实现细节
1.字节码
access_flag:ACC_VOLATILE
2.JVM
StoreStore
volatile 写
StoreLoad

LoadLoad
volatile 读
LoadStore

3.硬件
windows使用lock指令去实现（每个系统具体实现都不一样）

### synchronized实现细节
1.字节码
ACC_SYNCHRONIZED

monitorenter/monitorexit

2.JVM
锁升级