# hadoop_mr_example_tempreature

## 需求

现有如下数据集

2019-6-1 22:22:22	1	39
2019-5-21 22:22:22	3	33
2019-6-1 22:22:22	1	38
2019-6-2 22:22:22	2	31
2018-3-11 22:22:22	3	18
2018-4-23 22:22:22	1	22
1970-8-23 22:22:22	2	23
1970-8-8 22:22:22	1	32

字段的含义为 时间 地点 温度

我们要求求出每个月中温度最高的两天！

## 思路

MR玩的就是数据的key设计和value设计，有如下两种设计可以实现这个需求

1.把年月作为key，把日和温度作为值

2.把年月日温度作为key，无值

如果选取第一种，那么计算全部拉到reduce端进行处理，会非常耗费资源，产生随机读写，比较慢

所以我们选取第二种，第二种我们可以通过一些优化，例如排序（所以借助温度排序，还需要温度也作为key的一部分），最终简化计算

## 落地

```java
package com.hadoop.service.topn;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

import java.io.FileOutputStream;
import java.io.IOException;

public class TopN {

    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        //1.转换输入
        GenericOptionsParser genericOptionsParser = new GenericOptionsParser(args);
        String[] remainingArgs = genericOptionsParser.getRemainingArgs();

        //2.基础设施
        Configuration conf = new Configuration(true);
        //设置windows环境
        conf.set("mapreduce.app-submission.cross-platform","true");
        conf.set("mapreduce.framework.name","local");
        conf.set("fs.defaultFS","file:///");

        //打开任务
        Job job = Job.getInstance(conf, "topn");
        //解析输入
        Path inputPath = new Path(remainingArgs[0]);
        FileInputFormat.addInputPath(job, inputPath);
        //解析输出
        Path outputPath = new Path(remainingArgs[1]);
        if(outputPath.getFileSystem(conf).exists(outputPath))outputPath.getFileSystem(conf).delete(outputPath, true);
        FileOutputFormat.setOutputPath(job, outputPath);

        //3.mapper
        //设置输出的key
        job.setMapOutputKeyClass(TopNKey.class);
        //设置输出的value
        job.setMapOutputValueClass(IntWritable.class);
        //执行的mapper类
        job.setMapperClass(TopNMapper.class);
        //设置partitioner去分区，同一组key的数据落到同一个分区
        job.setPartitionerClass(TopNPartitioner.class);
        //设置sort，因为溢写的时候写入磁盘需要进行快速排序，需要比较器，默认比较器为从低到高，所以我们实现一个比较器从高到底来排序
        job.setSortComparatorClass(TopNSorter.class);

        //4.reduce
        //执行的reduce类
        job.setReducerClass(TopNReduce.class);
        //设置分组器，按照逻辑返回一组数据
        job.setGroupingComparatorClass(TopNGroupingComparator.class);

        //5.等待任务完成
        job.waitForCompletion(true);
    }

}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.WritableComparable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

public class TopNKey implements WritableComparable<TopNKey> {
    private Integer year;
    private Integer month;
    private Integer day;
    private Integer wd;

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMonth() {
        return month;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }

    public Integer getDay() {
        return day;
    }

    public void setDay(Integer day) {
        this.day = day;
    }

    public Integer getWd() {
        return wd;
    }

    public void setWd(Integer wd) {
        this.wd = wd;
    }

    public int compareTo(TopNKey o) {
        int i = this.year.compareTo(o.getYear());
        if(i != 0)return i;
        i = this.month.compareTo(o.getMonth());
        if(i != 0)return i;
        i = this.day.compareTo(o.getDay());
        if(i != 0)return i;
        return this.wd.compareTo(o.getWd());
    }

    public void write(DataOutput out) throws IOException {
        //实现write方法，当数据写入内存要用
        out.writeInt(this.year);
        out.writeInt(this.month);
        out.writeInt(this.day);
        out.writeInt(this.wd);
    }

    public void readFields(DataInput in) throws IOException {
        //实现readFields方法，当溢写时比较数据要用
        this.year = in.readInt();
        this.month = in.readInt();
        this.day = in.readInt();
        this.wd = in.readInt();
    }
}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class TopNMapper extends Mapper<LongWritable, Text,TopNKey, IntWritable> {

    //防止多次创建对象，并且源码可知，这样做不会产生数据覆盖问题，因为数据是序列化后存入到内存的
    private TopNKey topNKey = new TopNKey();
    private IntWritable value = new IntWritable();
    private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-M-d HH:mm:ss");

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        //value 就是 类似于 2019-6-1 22:22:22   1  39 的数据
        //切割value
        String[] split = value.toString().split("\t");
        LocalDate date = LocalDate.parse(split[0], formatter);
        this.topNKey.setYear(date.getYear());
        this.topNKey.setMonth(date.getMonth().getValue());
        this.topNKey.setDay(date.getDayOfMonth());
        this.topNKey.setWd(Integer.valueOf(split[2]));

        context.write(this.topNKey,this.value);
    }
}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Partitioner;

public class TopNPartitioner extends Partitioner<TopNKey, IntWritable> {
    //年月相同放入同一组
    @Override
    public int getPartition(TopNKey topNKey, IntWritable intWritable, int numPartitions) {
        return (topNKey.getYear() + topNKey.getMonth()) % numPartitions;
    }
}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;

public class TopNSorter extends WritableComparator {

    public TopNSorter() {
        super(TopNKey.class,true);
    }

    @Override
    public int compare(WritableComparable a, WritableComparable b) {
        TopNKey aT = (TopNKey)a;
        TopNKey bT = (TopNKey)b;

        int i = aT.getYear().compareTo(bT.getYear());
        if(i != 0)return i;
        i = aT.getMonth().compareTo(bT.getMonth());
        if(i != 0)return i;
        i = aT.getDay().compareTo(bT.getDay());
        if(i != 0)return i;
        return bT.getWd().compareTo(aT.getWd());
    }
}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class TopNReduce extends Reducer<TopNKey, IntWritable, Text, IntWritable> {
    private Text key = new Text();
    private IntWritable value = new IntWritable();
    
    @Override
    protected void reduce(TopNKey key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int flag = 0;
        int lastDay = -1;
        for (IntWritable value : values) {
            if (flag == 0) {
                this.key.set(key.getYear() + "-" + key.getMonth() + "-" + key.getDay());
                this.value.set(key.getWd());
                context.write(this.key, this.value);
                lastDay = key.getDay();
                flag ++;
            }else if (key.getDay() != lastDay){
                this.key.set(key.getYear() + "-" + key.getMonth() + "-" + key.getDay());
                this.value.set(key.getWd());
                context.write(this.key, this.value);
                lastDay = key.getDay();
                break;
            }
        }
    }
}
```

```java
package com.hadoop.service.topn;

import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;

public class TopNGroupingComparator extends WritableComparator {
    public TopNGroupingComparator() {
        super(TopNKey.class, true);
    }

    @Override
    public int compare(WritableComparable a, WritableComparable b) {
        TopNKey aT = (TopNKey) a;
        TopNKey bT = (TopNKey) b;

        return aT.getYear().compareTo(bT.getYear()) == 0 && aT.getMonth().compareTo(bT.getMonth()) == 0 ? 0 : 1;
    }
}
```

## 输出

1970-8-8	32
1970-8-23	23
2018-3-11	18
2018-4-23	22
2019-5-21	33
2019-6-1	39
2019-6-2	31

## 进阶

现在多加一个需求，需要把城市映射进来，传入一张映射表，输出为年月日 城市 温度

城市映射表

1 BeiJing
2 SuZhou
3 ShangHai

**解决**

由于数据集比较小，不需要去做join，直接把数据加载到内存中进行映射

加如下三步

主方法中

```java
//设置缓存
job.addCacheFile(new Path("E:\\input\\TopN\\locations.txt").toUri());
```

Mapper中

```java
private Map<String,String> locationMaps = new HashMap<>();

@Override
protected void setup(Context context) throws IOException, InterruptedException {
    URI[] cacheFiles = context.getCacheFiles();
    BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(cacheFiles[0].getPath())));
    String line = null;
    while (StringUtils.isNotEmpty(line = bufferedReader.readLine())){
        String[] split = line.split("\t");
        locationMaps.put(split[0],split[1]);
    }
}
```

key中以及调用的地方，包括reduce

```java
private String location;
```

**输出**

1970-8-8 BeiJing	32
1970-8-23 SuZhou	23
2018-3-11 ShangHai	18
2018-4-23 BeiJing	22
2019-5-21 ShangHai	33
2019-6-1 BeiJing	39
2019-6-2 SuZhou	31
