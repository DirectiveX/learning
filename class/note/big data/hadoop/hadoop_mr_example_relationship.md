# hadoop_mr_example_relationship

## 需求

给你一组数据，需要求出推荐的联系人的分数，间接联系人越多，分数越高

## 数据

马老师 一名老师 刚老师 周老师
一名老师 马老师 刚老师
刚老师 马老师 一名老师 六哥 七哥
周老师 马老师 六哥
六哥 刚老师 周老师
七哥 刚老师 八哥
八哥 七哥

## 描述

数据描述了直接关系，第一个人与其他人相互之间是好友

## 分析

最终的输出需要的是 用户1 - 用户2 分数

我们需要计算当前用户有简介关系的那批人，相互之间的得分，所以我们需要Map后获得一个间接关系表，我们给关系打一个tag，0表示直接关系，1表示间接关系

## 实现

```java
package com.hadoop.service.p2p;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.IOException;

public class P2P {
    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        GenericOptionsParser genericOptionsParser = new GenericOptionsParser(args);
        String[] remainingArgs = genericOptionsParser.getRemainingArgs();

        Configuration configuration = new Configuration(true);
        configuration.set("mapreduce.app-submission.cross-platform","true");

        Job job = Job.getInstance(configuration, "p2p");
        Path inputPath = new Path(args[0]);
        Path outputPath = new Path(args[1]);
        if(outputPath.getFileSystem(configuration).exists(outputPath))outputPath.getFileSystem(configuration).delete(outputPath, true);
        FileInputFormat.addInputPath(job,inputPath);
        FileOutputFormat.setOutputPath(job, outputPath);

        job.setJar("E:\\workspace\\target\\hadoop_training-1.0-SNAPSHOT.jar");

        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setMapperClass(P2PMapper.class);

        job.setReducerClass(P2PReducer.class);

        job.waitForCompletion(true);
    }
}
```

```java
package com.hadoop.service.p2p;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class P2PMapper extends Mapper<LongWritable, Text,Text, IntWritable> {
    private Text key = new Text();
    private IntWritable value = new IntWritable();


    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String[] s = value.toString().split(" ");
        String p1 = s[0];
        for (int i = 1;i < s.length;i ++){
            this.key.set(combinePerson(p1,s[i]));
            this.value.set(0);
            context.write(this.key,this.value);
            for(int j = i + 1;j < s.length;j ++){
                this.key.set(combinePerson(s[i],s[j]));
                this.value.set(1);
                context.write(this.key,this.value);
            }
        }
    }

    private String combinePerson(String p1,String p2){
        if(p1.compareTo(p2) > 0){
            return p1 + " - " + p2;
        }else{
            return p2 + " - " + p1;
        }
    }
}
```

```java
package com.hadoop.service.p2p;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class P2PReducer extends Reducer<Text,IntWritable,Text,IntWritable> {
    private Text key = new Text();
    private IntWritable value = new IntWritable();

    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int sum = 0;
        boolean flag = true;
        for(IntWritable i: values){
            if(i.get() == 0){
                flag = false;
                break;
            }
            sum += i.get();
        }

        if(flag){
            this.key.set(key);
            this.value.set(sum);
            context.write(this.key,this.value);
        }
    }
}
```

## 输出

七哥 - 一名老师	1
六哥 - 一名老师	1
六哥 - 七哥	1
刚老师 - 八哥	1
周老师 - 一名老师	1
周老师 - 刚老师	2
马老师 - 七哥	1
马老师 - 六哥	2
