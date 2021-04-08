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

### Launcher
Launcher中有ExtClassLoader和AppClassLoader
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

## lazyLoading
严格叫lazyInitializing，JVM并没有规定何时懒加载，只规定了何时初始化

## linking

## initializing