# DataX

DataX 是阿里云 [DataWorks数据集成](https://www.aliyun.com/product/bigdata/ide) 的开源版本，在阿里巴巴集团内被广泛使用的离线数据同步工具/平台。DataX 实现了包括 MySQL、Oracle、OceanBase、SqlServer、Postgre、HDFS、Hive、ADS、HBase、TableStore(OTS)、MaxCompute(ODPS)、Hologres、DRDS 等各种异构数据源之间高效的数据同步功能。

[官网](https://github.com/alibaba/DataX)

[github](https://github.com/alibaba/DataX/blob/master/introduction.md)

## 使用

**注意**

dataX github写了支持python3，实际不支持，切换到2.7再使用

python {YOUR_DATAX_HOME}/bin/datax.py {YOUR_DATAX_HOME}/job/job.json

- 配置示例：从stream读取数据并打印到控制台

  - 第一步、创建作业的配置文件（json格式）

    可以通过命令查看配置模板： python datax.py -r {YOUR_READER} -w {YOUR_WRITER}

    ```
    $ cd  {YOUR_DATAX_HOME}/bin
    $  python datax.py -r streamreader -w streamwriter
    DataX (UNKNOWN_DATAX_VERSION), From Alibaba !
    Copyright (C) 2010-2015, Alibaba Group. All Rights Reserved.
    Please refer to the streamreader document:
        https://github.com/alibaba/DataX/blob/master/streamreader/doc/streamreader.md 
    
    Please refer to the streamwriter document:
         https://github.com/alibaba/DataX/blob/master/streamwriter/doc/streamwriter.md 
     
    Please save the following configuration as a json file and  use
         python {DATAX_HOME}/bin/datax.py {JSON_FILE_NAME}.json 
    to run the job.
    
    {
        "job": {
            "content": [
                {
                    "reader": {
                        "name": "streamreader", 
                        "parameter": {
                            "column": [], 
                            "sliceRecordCount": ""
                        }
                    }, 
                    "writer": {
                        "name": "streamwriter", 
                        "parameter": {
                            "encoding": "", 
                            "print": true
                        }
                    }
                }
            ], 
            "setting": {
                "speed": {
                    "channel": ""
                }
            }
        }
    }
    ```

    根据模板配置json如下：

    ```
    #stream2stream.json
    {
      "job": {
        "content": [
          {
            "reader": {
              "name": "streamreader",
              "parameter": {
                "sliceRecordCount": 10,
                "column": [
                  {
                    "type": "long",
                    "value": "10"
                  },
                  {
                    "type": "string",
                    "value": "hello，你好，世界-DataX"
                  }
                ]
              }
            },
            "writer": {
              "name": "streamwriter",
              "parameter": {
                "encoding": "UTF-8",
                "print": true
              }
            }
          }
        ],
        "setting": {
          "speed": {
            "channel": 5
           }
        }
      }
    }
    ```

  - 第二步：启动DataX

    ```
    $ cd {YOUR_DATAX_DIR_BIN}
    $ python datax.py ./stream2stream.json 
    ```

    同步结束，显示日志如下：

    ```
    ...
    2015-12-17 11:20:25.263 [job-0] INFO  JobContainer - 
    任务启动时刻                    : 2015-12-17 11:20:15
    任务结束时刻                    : 2015-12-17 11:20:25
    任务总计耗时                    :                 10s
    任务平均流量                    :              205B/s
    记录写入速度                    :              5rec/s
    读出记录总数                    :                  50
    读写失败总数                    :                   0
    ```

## Hive 到 Mysql

[DataX HdfsReader](https://github.com/alibaba/DataX/blob/master/hdfsreader/doc/hdfsreader.md)

[DataX MysqlWriter](https://github.com/alibaba/DataX/blob/master/mysqlwriter/doc/mysqlwriter.md)

```json
{
    "job": {
        "setting": {
            "speed": {
                "channel": 3
            }
        },
        "content": [
            {
                "reader": {
                    "name": "hdfsreader",
                    "parameter": {
                        "path": "/user/root/hive_remote/test.db/person/*",
                        "defaultFS": "hdfs://node01:8020",
                        "column": [
                               {
                                "index": 0,
                                "type": "long"
                               },
                               {
                                "index": 1,
                                "type": "string"
                               },
                               {
                                "index": 2,
                                "type": "string"
                               },
                               {
                                "index": 3,
                                "type": "string"
                               },
                               {
                                "type": "string",
                                "value": "from dataX"
                               }
                        ],
                        "fileType": "text",
                        "encoding": "UTF-8",
                        "fieldDelimiter": "\t"
                    }
                },
				"writer": {
                    "name": "mysqlwriter",
                    "parameter": {
                        "writeMode": "insert",
                        "username": "root",
                        "password": "123456",
                        "column": [
                            "id",
                            "name",
                            "hobbies",
                            "address",
                            "src"
                        ],
                        "preSql": [
                            "delete from test"
                        ],
                        "connection": [
                            {
                                "jdbcUrl": "jdbc:mysql://node01:3306/test?useUnicode=true&characterEncoding=utf-8",
                                "table": [
                                    "test"
                                ]
                            }
                        ]
                    }
                }
            }
        ]
    }
}
```

```mysql
ALTER TABLE test CONVERT TO CHARACTER SET utf8; -- 解决中文输入报错问题
```

## 架构

![datax_framework_new](https://cloud.githubusercontent.com/assets/1067175/17879884/ec7e36f4-6927-11e6-8f5f-ffc43d6a468b.png)

dataX采用插件+框架方式进行构建，Reader转化数据成dataX内部类型通过Framework转化后再通过Write进行输出

![datax_arch](https://cloud.githubusercontent.com/assets/1067175/17850849/aa6c95a8-6891-11e6-94b7-39f0ab5af3b4.png)

能够实现单机多线程

通过job模块根据需要处理的数据通过split进行分片，分成一定数量的task，成为运行的最小单元，根据并发通过schedule模块进行整合把task组合成一组taskgroup，每个taskgroup负责一部分并发，单个任务执行的时候，每个线程都会开启reader-》channel-》writer的任务流进行转换，job会进行监控，等待多个taskgroup完成并退出，返回0，或者异常退出返回非0

## 排错

由于dataX运行过程中会产生临时文件，运行错误后文件未删除会导致报错，需要删除所有符合条件的临时文件

````shell
find . -name "._*" -exec rm {} \;
````