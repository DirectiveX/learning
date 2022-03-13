# Spark

## 定义

用于计算的大数据框架，速度较快，内存计算

## vs Hadoop

hadoop的数据处理模型为一次性数据计算（框架在处理数据的时候会从存储设备中读取数据，进行逻辑操作，然后将处理的结果重新存储到介质中），不适合迭代式的数据处理，MapReduce的模式导致大量磁盘IO

spark的数据处理模型，将作业的处理结果存放入内存中，方便下次使用，速度较快

**根本差异**

Spark多个作业之间数据通讯基于内存，hadoop基于磁盘，对于选择上，需要具体问题具体分析，如果内存不够，只能使用MapReduce进行操作，各有利弊，并不能完全代替MapReduce

**spark core取代MP**

1.spark申请资源的时候是粗粒度申请资源

①先申请资源②task执行③等全部task执行完毕才关闭资源

而map reduce细粒度资源调度，为每个task分配资源并执行，然后关闭

2.不落磁盘，直接内存计算（cache persist）

内存计算 pipeline （链条）



**spark streaming取代storm**

## 核心模块

Spark SQL：操作结构化数据

Spark Streaming：流式数据

Spark MLlib：机器学习库

Spark Graphx：图形挖掘库

Apache Spark Core：spark核心，提供最基础的功能

# 快速上手

## 步骤

1.建立连接

2.操作业务

3.关闭连接
