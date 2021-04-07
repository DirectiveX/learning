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