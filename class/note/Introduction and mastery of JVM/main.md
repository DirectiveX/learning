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
## 结构
**Magic Number**
魔数，用于判断文件是否损坏，在class文件中是cafe babe
**Minor Version**
小版本号
**Major Version**
大版本号
**constant_pool_count**
常量池大小
**constant_pool**
常量池具体实现
**access_flags**
修饰符