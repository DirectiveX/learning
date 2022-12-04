# Elastic Stack

## 简介

elastic search是在DBEngines上常年霸榜搜索引擎第一位的搜索引擎，它可以做到在超大数据量前提下的毫秒级搜索，并且开源免费，Shay Banon说过，任何应用都离不开搜索，那便是elastic search存在的意义

Elastic Stack是一套以Elastic search为核心的技术栈，从刚开始的Elastic search，到后来的Elastic search + Logstash + Kibana三剑客，到现在的四大金刚（Beats）

Elasticsearch: 基于Json的分布式搜索和分析引擎（不是单纯的搜索引擎）

Logstash: 动态数据收集管道

Kibana：数据可视化界面

Beats：轻量级数据采集器

### Elasticsearch

特点：分布式，高可用，高性能，弹性

### Logstash

以插件形式来维护输入输出，并且经过过滤器，对不同的数据进行动态转化和解析的数据收集管道

官方支持200多种输出插件，社区更多

过滤的功能：

1.利用Grok（插件）从数据中抽出结构化数据

2.从IP地址破译出地理坐标

3.将PII数据匿名化，排除敏感字段

4.简化整体处理，不受数据源与架构影响（解耦）

基于JVM

### Kibana

数据可视化，管理和监控

### Beats

轻量级日志采集器，基于Golang语言开发的

1.对服务器占用资源极低

2.即插即用

3.可扩展（开源，可以自己开发）

## 安装

查看es的[support matrix](https://www.elastic.co/cn/support/matrix)进行安装

由于安全策略问题，es自己创建了对应的用户，以便启动es，启动的时候需要切换到该用户，查看当前系统的用户vim /etc/passwd

检查es是否启动成功curl --cacert $ES_HOME/config/certs/http_ca.crt -u elastic

es配置（记得修改yml配置，特别是数据目录和日志目录）

https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html

打开kibana（用于监控）http://localhost:5601/

安装elasticsearch-head插件查看集群状态 https://github.com/mobz/elasticsearch-head http://localhost:9100/

查看健康检查状态

http://localhost:9201/_cat/health?v

http://localhost:9201/_cluster/health

- **cluster_name** elasticsearch
- **status **green //当结点状态为绿色，表示所有分片都可用，黄色表示replica分片不可用，所有primary可用，红色表示primary不可用，集群不可用
- **timed_out ** false
- **number_of_nodes** 9
- **number_of_data_nodes** 9
- **active_primary_shards ** 8
- **active_shards** 16
- **relocating_shards ** 0
- **initializing_shards** 0
- **unassigned_shards** 0 //初始创建分片的时候分片状态
- **delayed_unassigned_shards** 0
- **number_of_pending_tasks** 0
- **number_of_in_flight_fetch** 0
- **task_max_waiting_in_queue_millis** 0
- **active_shards_percent_as_number** 100

## 索引和文档

type在7.x之后弱化，8.x之后删除，只有_doc类型，在7之前，每个文档有自己的的类型

## Mapping

**映射方式**

dynamic mapping 动态映射

explicit mapping 显示映射

### 数据类型

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/mapping-types.html

### 映射参数

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/mapping-params.html

### 元数据

_source提速操作

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/mapping-source-field.html

## 查询

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl.html

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-your-data.html

**聚合查询**

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-aggregations-pipeline.html

**批量id查询**

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/docs-multi-get.html

```json
GET product/_mget
{
  "ids":[1,2,3]
}
```

## IK 分词器

用于中文的切词，里面有很多常用的词库和停用词，在config目录下面

https://github.com/medcl/elasticsearch-analysis-ik

main 常用语

preposition 语气词

quantifier 度量单位

stopword 停用词

suffix 地区后缀等

surname 百家姓

带extra的是扩展

ik分词有两种模式

Analyzer: `ik_smart` , `ik_max_word` , Tokenizer: `ik_smart` , `ik_max_word`

ik_max_word: 会将文本做最细粒度的拆分，比如会将“中华人民共和国国歌”拆分为“中华人民共和国,中华人民,中华,华人,人民共和国,人民,人,民,共和国,共和,和,国国,国歌”，会穷尽各种可能的组合，适合 Term Query；

ik_smart: 会做最粗粒度的拆分，比如会将“中华人民共和国国歌”拆分为“中华人民共和国,国歌”，适合 Phrase 查询。

### 自定义停用词

配置 IKAnalyzer.cfg.xml 

\<entry key="ext_dict">\</entry>

\<entry key="ext_stopwords">\</entry>

**注意**

1.文件需要utf-8编码

2.中文注释部分删除

### 热更新

配置 IKAnalyzer.cfg.xml 

\<entry key="remote_ext_dict">words_location\</entry>

\<entry key="remote_ext_stopwords">words_location\</entry> 

自己做一个服务

目前该插件支持热更新 IK 分词，通过上文在 IK 配置文件中提到的如下配置

```
 	<!--用户可以在这里配置远程扩展字典 -->
	<entry key="remote_ext_dict">location</entry>
 	<!--用户可以在这里配置远程扩展停止词字典-->
	<entry key="remote_ext_stopwords">location</entry>
```

其中 `location` 是指一个 url，比如 `http://yoursite.com/getCustomDict`，该请求只需满足以下两点即可完成分词热更新。

1. 该 http 请求需要返回两个头部(header)，一个是 `Last-Modified`，一个是 `ETag`，这两者都是字符串类型，只要有一个发生变化，该插件就会去抓取新的分词进而更新词库。
2. 该 http 请求返回的内容格式是一行一个分词，换行符用 `\n` 即可。

满足上面两点要求就可以实现热更新分词了，不需要重启 ES 实例。

可以将需自动更新的热词放在一个 UTF-8 编码的 .txt 文件里，放在 nginx 或其他简易 http server 下，当 .txt 文件修改时，http server 会在客户端请求该文件时自动返回相应的 Last-Modified 和 ETag。可以另外做一个工具来从业务系统提取相关词汇，并更新这个 .txt 文件。

```java
@RestController
public class AController {
    @GetMapping("/listHeaders")
    public String getWords(HttpServletResponse response, Integer isStop) {
        File file = null;
        if(isStop == 0){
           file = new File("D:\\elasticsearch-8.1.0\\plugins\\ik\\config\\custom\\extends.dic") ;
        }else{
            file = new File("D:\\elasticsearch-8.1.0\\plugins\\ik\\config\\custom\\stopwords.dic") ;
        }
        response.setHeader("Last-Modified", String.valueOf(file.lastModified()));
        response.setHeader("ETag",String.valueOf(file.lastModified()));
        StringBuilder stringBuilder = new StringBuilder();
        try(BufferedReader bufferedReader=new BufferedReader(new FileReader(file));){
            String s = null;
            while (!StringUtils.isEmpty(s = bufferedReader.readLine())){
                stringBuilder.append(s).append("\n");
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }
}
```

**也可以连接数据库进行更新**

修改源码内加载远程词库的功能，也可以写一个服务，实现接口

## 统计

### 先聚合后查询

post_filter

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/filter-search-results.html
### 取消查询条件

通过重置上下文的条件来取消前置查询条件

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-aggregations-bucket-global-aggregation.html

```json
GET product/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "price": {
              "gte": 4000
            }
          }
        }
      ]
    }
  },
  "aggs": {
    "res": {
      "global": {},
      "aggs": {
        "rwe": {
          "terms": {
            "field": "tags.keyword",
            "size": 30
          }
        }
      }
    }
  },
  "post_filter": {
    "term": {
      "tags.keyword": "公交卡"
    }
  }
}
```

filter可以在聚合中使用，与主query共同作用

### 聚合排序

\_key（按键）,\__count（按数量）

也可以按照聚合之后的数据进行排序，如下

```json
GET product/_search
{
  "size": 0,
  "aggs": {
    "lv_agg": {
      "terms": {
        "field": "lv.keyword",
        "size": 30,
        "order": {
          "price_stats.min": "asc"
        }
      },
      "aggs": {
        "price_stats": {
          "stats": {
            "field": "price"
          }
        }
      }
    }
  }
}
```

### 常用的聚合查询

直方图 https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-aggregations-bucket-datehistogram-aggregation.html

```json
POST /product/_search?size=0
{
  "aggs": {
    "sales_over_time": {
      "date_histogram": {
        "field": "createtime",
        "calendar_interval": "year",
        "missing": "19999"
      }
    }
  }
}
```

百分比（饼图）https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-aggregations-metrics-percentile-aggregation.html

给出的数据是个近似值，而不是精确值，使用的 TDigest 算法

```json
//根据范围算百分比
GET product/_search
{
  "size": 0,
  "aggs": {
    "load_time_ranks": {
      "percentile_ranks": {
        "field": "price",
        "values": [
          1000
          ]
      }
    }
  }
}
//按百分比算值
GET product/_search
{
  "size": 0,
  "aggs": {
    "load_time_outlier": {
      "percentiles": {
        "field": "createtime"
      }
    }
  }
}
```

## 脚本

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/modules-scripting.html

常用脚本mustuche，painless，expression

脚本能够帮助我们处理更多的场景，但是会花费更多的资源，在执行脚本查询时，脚本是会被编译的，所以为了性能考虑，如果是可变参数，最好参数能够通过params传递进去

### 脚本upsert

如果不存在就插入，如果存在就更新

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/docs-update.html

```json
POST product/_update/16
{
  "script": {
    "source": "ctx._source.price += 100"
  }, 
  "upsert": {
    "price":45555
  }
}
```

### 脚本实现增删改查

```json
//删除
POST product/_update/16
{
  "script": {
    "source": "ctx.op='delete'"
  }
}
//查询
GET product/_search
{
  "script_fields": {
    "sss": {
      "script":{
       "source": "[doc['price'].value *0.9,doc['price'].value *0.8]"
      }
    }
  }
}
```

### 全局脚本

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/create-stored-script-api.html

### 正则匹配

https://www.elastic.co/guide/en/elasticsearch/painless/8.1/painless-regexes.html

```json
POST product/_update/1
{
  "script": {
    "source": """
    if(ctx._source.name ==~ /小米.*/){
      ctx._source.price +=100
    }else{
      ctx.op='noop'
    }
    """
  }
}
```

## 批量操作

文档四种操作类型分别为create，delete，index，update

批量更新时过滤掉正确的返回，只返回错误的部分 ?filter_path=items.*.error

https://www.elastic.co/guide/en/elasticsearch/reference/8.5/docs-bulk.html

```json
POST /my_index/_bulk
{ "index": { "_id": "1"} }
{ "text": "my english" }
{ "index": { "_id": "2"} }
{ "text": "my english is good" }
{ "index": { "_id": "3"} }
{ "text": "my chinese is good" }
{ "index": { "_id": "4"} }
{ "text": "my japanese is nice" }
{ "index": { "_id": "5"} }
{ "text": "my disk is full" }
```

## 其他词项级别查询

### 前缀查询

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl-prefix-query.html

这个匹配的时候会分词，和match类似，基于分词之后的数据做前缀匹配

- 前缀搜索匹配的是term，而不是field。
- 前缀搜索的性能很差
- 前缀搜索没有缓存
- 前缀搜索尽可能把前缀长度设置的更长

```json
GET my_index/_search
{
  "query": {
    "prefix": {
      "text": {
        "value": "ja"
      }
    }
  }
}
```

优化点就是可以提前生成前缀索引

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/index-prefixes.html

会依次建立对应字段的倒排索引，空间换时间

### 通配符查询

这个匹配的时候会分词，和match类似，基于分词之后的数据做前缀匹配

```json
GET my_index/_search
{
  "query": {
    "wildcard": {
      "text": {
        "value": "ja*p*"
      }
    }
  }
}
```

### 正则查询

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl-regexp-query.html

es正则语法

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/regexp-syntax.html#regexp-optional-operators

```json
GET my_index/_search
{
  "query": {
    "regexp": {
      "text": {
        "value": "japa.*e*"
      }
    }
  }
}
```

### 模糊查询

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl-fuzzy-query.html

可以做错误修正，控制这个的关键属性是fuzziness，使用的距离为[Levenshtein Edit Distance](https://en.wikipedia.org/wiki/Levenshtein_distance)，transpositions属性代表是否使用优化后的莱温斯坦距离，默认true表示使用，位置交换只占一个长度

```json
GET my_index/_search
{
  "query": {
    "fuzzy": {
      "text": {
        "value": "japansee",
        "fuzziness": 1,
        "transpositions":false //这样会导致查询不到，因为经典莱温斯坦距离交换距离视为2
      }
    }
  }
}
```

### 短语前缀查询

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl-match-query-phrase-prefix.html

短语匹配的扩展版，支持最后一个单词进行模糊查询

```json
GET my_index/_search
{
  "query": {
    "match_phrase_prefix": {
      "text":{
        "query": "english go",
        "max_expansions": 1,
        "slop":1
      }
    }
  }
}
```

重要属性 max_expansions 最大的扩展词个数，也就是指ES每个lucene实例给的候选集，是基于分片层面上的

slop 允许短语间的词项(term)间隔：slop 参数告诉 match_phrase 查询词条相隔多远时仍然能将文档视为匹配 什么是相隔多远？ 意思是说为了让查询和文档匹配你需要移动词条多少次？

https://www.elastic.co/cn/blog/found-fuzzy-search

### 前缀，中缀，后缀搜索的优化方案

使用ngram和edge-ngram，用空间换时间，这两种方式需要提前定义好Mapping（属于analyzer解析器的范畴）

ngram和edge-ngram共同点在于可以把词更细粒度的做倒排索引，把一个英语单词分词多个词

ngram和edge-ngram区别就在于edge-ngram只会对前面边缘做倒排索引，所以只能完成前缀匹配，但是效率比match phrase prefix要好很多

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/analysis-edgengram-tokenizer.html

```json
POST _analyze
{
  "tokenizer": "edge_ngram",
  "text": "Quick Fox"
}

POST _analyze
{
  "tokenizer": "standard",
  "filter": ["edge_ngram"], 
  "text": "Quick Fox"
}

POST _analyze
{
  "tokenizer": "ngram",
  "text": "Quick Fox"
}

POST _analyze
{
  "tokenizer": "standard",
  "filter": ["ngram"], 
  "text": "Quick Fox"
}
```

tokenizer是针对整个句子的，会把空格也算进去，而filter是专门针对词项的，只会在词项中做文章

## 智能推荐

利用suggester完成只能推荐

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-suggesters.html#completion-suggester

智能推荐分为四种，Term suggestion，Phase suggestion，Compelete suggestion，Context suggestion

1，2对中文的处理有些许问题，中文处理常用3，4结合使用

### Term **suggestion**

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/search-suggesters.html#completion-suggester

先分词，再进行推荐

```json
POST news/_search
{
  "query": {
    "match": {
      "title": "baoqiang"
    }
  },
  "suggest": {
    "my-suggestion": {
      "text": "biaoqiang bough",
      "term": {
        "suggest_mode": "missing",
        "size":3,
        "max_edits":1,
        "min_doc_freq":0,
        "field": "title"
      }
    }
  }
}
```

size为最大的返回数量

min_doc_freq为最大文档数量

suggest_mode为模式，missing表示如果词项在索引中存在，就不返回推荐，always表示无论啥时候都推荐（不包括查询的词项），popular表示返回比当前查询的词文档数对应更多的建议词

max_edits 最大修改距离，默认2

默认使用internal模式：性能更高的 damerau_levenshtein 距离

有点小bug，有时候即使距离符合，仍然没有返回值

## Phrase suggestion

句子推荐，和term不同会按照给的词的上下文进行推荐，特殊点在于在进行推荐时要先把对应的mapping做好，原理就是使用了shingle的词项过滤器，这个过滤器，默认shingle的大小1永远存在

```json
POST test/_search
{
  "suggest": {
    "text": "lucee elasticsear",
    "my_suggest_phrase": {
      "phrase": {
        "field": "title.trigram",
        "size": 10,
        "gram_size": 3,
        "direct_generator": [ {
          "field": "title.trigram",
          "suggest_mode": "always"
        } ],
        "highlight": {
          "pre_tag": "<em>",
          "post_tag": "</em>"
        }
      }
    }
  }
}
```

direct_generator：候选生成器生成对应的修正项

confidence：表示置信度，只有高的部分被返回

## Completion suggestion

自动补全，自动完成，主要使用前缀，正则和模糊匹配，是一种准确率较高的常用补全方式，前缀不分词

实现上它和前面两个Suggester采用了不同的数据结构，索引并非通过倒排来完成，而是将analyze过的数据编码成FST和索引一起存放。对于一个open状态的索引，FST会被ES整个装载到内存里的，进行前缀查找速度极快。但是FST只能用于前缀查找

自动补全时，模糊和前缀都只支持前缀

```json
POST suggest_carinfo/_search
{
   "suggest": {
    "my-suggest": {
      "prefix": "nir",      
      "completion": {         
          "field": "title.suggest",
          "fuzzy":{
            "fuzziness":2
          }
      }
    }
  }
}
```

- completion：es的一种特有类型，专门为suggest提供，基于内存，性能很高。
- prefix query：基于前缀查询的搜索提示，是最常用的一种搜索推荐查询。
  - prefix：客户端搜索词
  - field：建议词字段
  - size：需要返回的建议词数量（默认5）
  - skip_duplicates：是否过滤掉重复建议，默认false
- fuzzy query
  -  fuzziness：允许的偏移量，默认auto
  -  transpositions：如果设置为true，则换位计为一次更改而不是两次更改，默认为true。
  -  min_length：返回模糊建议之前的最小输入长度，默认 3
  -  prefix_length：输入的最小长度（不检查模糊替代项）默认为 1
  -  unicode_aware：如果为true，则所有度量（如模糊编辑距离，换位和长度）均以Unicode代码点而不是以字节为单位。这比原始字节略慢，因此默认情况下将其设置为false。
- regex query：可以用正则表示前缀，不建议使用

## Context suggestion

联合completion suggestion获得更大的性能提升，辅助过滤

- contexts：上下文对象，可以定义多个
  - name：`context`的名字，用于区分同一个索引中不同的`context`对象。需要在查询的时候指定当前name
  - type：`context`对象的类型，目前支持两种：category和geo，分别用于对suggest  item分类和指定地理位置。
  - boost：权重值，用于提升排名
- path：如果没有path，相当于在PUT数据的时候需要指定context.name字段，如果在Mapping中指定了path，在PUT数据的时候就不需要了，因为Mapping是一次性的，而PUT数据是频繁操作，这样就简化了代码。

```json
PUT place
{
  "mappings": {
    "properties": {
      "suggest": {
        "type": "completion",
        "contexts": [
          {                                 
            "name": "place_type",
            "type": "category",
            "path": "type"
          },
          {                                 
            "name": "location",
            "type": "geo",
            "precision": 4
          }
        ]
      }
    }
  }
}

PUT place/_doc/1
{
  "suggest": {
    "input": [
      "timmy's",
      "starbucks",
      "dunkin donuts"
    ]
  },
  "type": [
    "cafe",
    "food"
  ]
}
PUT place/_doc/2
{
  "suggest": [
    "monkey",
    "timmy's",
    "Lamborghini"
  ],
  "type": [
    "money"
  ]
}

POST place/_search?pretty
{
  "suggest": {
    "place_suggestion": {
      "prefix": "mon",
      "completion": {
        "field": "suggest",
        "size": 10,
        "contexts": {
          "place_type": [ "cafe", "money" ]
        }
      }
    }
  }
}
```

## 数据类型
### 嵌套类型

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/nested.html

常用于省市区，里面有个score_mode可以修改评分模式

```json
GET area/_search
{
  "query": {
    "bool": {
      "should": [
        {
          "nested": {
            "path": "province.cities",
            "query": {
              "term": {
                "province.cities.name": "北京市"
              }
            }
          }
        },
        {
          "nested": {
            "path": "province.cities.district",
            "query": {
              "term": {
                "province.cities.district.name": "淇滨区"
              }
            }
          }
        }
      ]
    }
  }
}
```

### join类型

特殊类型：有一些注意点，不常用，使用has_parent和has_child会触发global ordinals，影响查询性能，除非实体中映射数量远超另一个，可以试着使用

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/parent-join.html

https://www.elastic.co/guide/en/elasticsearch/reference/8.1/query-dsl-has-parent-query.html

注意：建立子数据时，路由是强制的，子必须与父在同一个分片上

```json
# 查找父级部门下的所有人
GET msb_depart/_search
{
  "query": {
    "parent_id": { 
      "type": "employee",
      "id": "2"
    }
  }
}

# 查找哪个部门下面的人
GET msb_depart/_search
{
  "query": {
    "has_parent": {
      "parent_type": "depart",
      "query": {
        "term": {
          "name.keyword": {
            "value": "咨询部"
          }
        }
      }
    }
  }
}

# 查找拥有某个员工的部门
GET msb_depart/_search
{
  "query": {
    "has_child": {
      "type": "employee",
      "query": {
        "term": {
          "name.keyword": {
            "value":"周老师"
          }
        }
      }
    }
  }
}
```

