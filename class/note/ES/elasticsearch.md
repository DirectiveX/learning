# Elasticsearch

Elasticsearch -> MySQL

Index(倒排索引) -> Database

Type -> Table

Document -> Row

Fleids -> Column

## 请求

PUT http://localhost:9200/shopping 创建shopping索引

GET http://localhost:9200/shopping 获取索引信息

GET http://localhost:9200/_cat/indices?v 查找es索引信息

DELETE http://localhost:9200/shopping 删除shopping索引

DELETE http://localhost:9200/shopping/_doc/{id} 删除shopping中某个文当数据

POST http://localhost:9200/shopping/_doc 添加/修改全量文档数据

> POST http://localhost:9200/shopping/_doc/{id} 可以自定义id

POST http://localhost:9200/shopping/_create 添加文档数据

POST http://localhost:9200/shopping/_update 修改部分文档数据

GET http://localhost:9200/shopping/_doc/1001 通过id去查询

GET http://localhost:9200/shopping/_search 全部查询

### 查询操作

**请求路径查询**

GET http://localhost:9200/shopping/_search?q=name:shijiahao

**请求体查询**

POST http://localhost:9200/shopping/_search

```json
{
    "query":{
        "match":{
            "name":"shijiahao"
        }
    }
}
```

POST http://localhost:9200/shopping/_search 全量查询

```json
{
    "query":{
        "match_all":{
        }
    }
}
```

POST http://localhost:9200/shopping/_search 分页查询

```json
{
    "query":{
        "match_all":{
        }
    },
    "from": 0,
    "size": 2
}
```

POST http://localhost:9200/shopping/_search 分页查询指定返回字段

```json
{
    "query":{
        "match_all":{
        }
    },
    "from": 0,
    "size": 2,
    "_source":["name"]
}
```

POST http://localhost:9200/shopping/_search 排序字段

```json
{
    "query":{
        "match_all":{
        }
    },
    "from": 0,
    "size": 2,
    "_source":["name","age"],
    "sort":{
        "age":{
            "order":"asc"
        }
    }
}
```

**多条件查询**

POST http://localhost:9200/shopping/_search 同时成立

```json
{
    "query" : {
        "bool" : {
            "must": [
                {
                    "match":{
                        "age": 18
                    }
                },
                {
                    "match":{
                        "name": "shijiahao"
                    }
                }
            ]
		}
    }
}
```

POST http://localhost:9200/shopping/_search 任意成立就显示

```json
{
    "query" : {
        "bool" : {
            "should": [
                {
                    "match":{
                        "age": 18
                    }
                },
                {
                    "match":{
                        "name": "shijiahao"
                    }
                }
            ]
		}
    }
}
```

POST http://localhost:9200/shopping/_search 范围查询

```json
{
    "query" : {
        "bool" : {
            "should": [
                {
                    "match":{
                        "age": 18
                    }
                },
                {
                    "match":{
                        "name": "shijiahao"
                    }
                }
            ],
            "filter" : {
                "range" : {
                    "age": {
                        "gt": 19
                    }
                }
            }
		}
    }
}
```

POST http://localhost:9200/shopping/_search 完全匹配并高亮显示

```json
{
    "query" : {
        "match_phrase": {
            "name" : "shijiahao"
        }
    },
    "highlight": {
        "fields" : {
            "name" : {}
        }
    }
}
```

**聚合操作**

POST http://localhost:9200/shopping/_search 分组操作

```json
{
    "aggs" : { // 聚合操作
        "age_group": {
            "terms":{ //名称，平均值函数avg
                "field" : "age" //分组字段
            }
        }
    },
    "size": 0
}
```

**分词(映射关系)查询**

```json
{
    "properties" : {
        "name": {
            "type" : "text",  //具有分词效果，keyword不具有分词效果
            "index" : true  //为false就不能被查询
        }
    }
}
```

## java操作

```xml
 <dependencies>
        <dependency>
            <groupId>org.elasticsearch.client</groupId>
            <artifactId>transport</artifactId>
            <version>7.8.0</version>
        </dependency>

        <dependency>
            <groupId>org.elasticsearch.client</groupId>
            <artifactId>elasticsearch-rest-high-level-client</artifactId>
            <version>7.8.0</version>
        </dependency>
    </dependencies>
```

**创建索引**

```java
//连接和关闭        
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

        // 创建索引
        CreateIndexRequest request = new CreateIndexRequest("user");
        CreateIndexResponse createIndexResponse = restHighLevelClient.indices().create(request, RequestOptions.DEFAULT);
        //响应
        boolean acknowledged = createIndexResponse.isAcknowledged();
        System.out.println("返回的值 " + acknowledged);

        restHighLevelClient.close();
```

**查询**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

        // 创建索引
        GetIndexRequest request = new GetIndexRequest("user");
        GetIndexResponse getIndexResponse = restHighLevelClient.indices().get(request, RequestOptions.DEFAULT);
        // 数据
        System.out.println(getIndexResponse.getAliases());
        System.out.println(getIndexResponse.getMappings());
        System.out.println(getIndexResponse.getSettings());

        restHighLevelClient.close();
```

**删除**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 删除索引
    DeleteIndexRequest request = new DeleteIndexRequest("user");
    AcknowledgedResponse delete = restHighLevelClient.indices().delete(request, RequestOptions.DEFAULT);
    // 响应
    System.out.println(delete.isAcknowledged());

    restHighLevelClient.close();
```

**添加（全量数据更新）数据**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 创建doc准备插入
    IndexRequest request = new IndexRequest("user");
    request.id("1001");
    User user = new User();
    user.setAge(30);
    user.setName("zhangsan");
    user.setSex("男");

    Gson gson = new Gson();
    String userJson = gson.toJson(user);
    request.source(userJson, XContentType.JSON);

    IndexResponse response = restHighLevelClient.index(request, RequestOptions.DEFAULT);
    //响应数据
    System.out.println(response.getIndex());
    System.out.println(response.getId());
    System.out.println(response.getResult());

    restHighLevelClient.close();
```

**更新（部分数据更新）数据**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 创建doc准备插入
    UpdateRequest request = new UpdateRequest();
    request.id("1001");
    request.index("user");
    User user = new User();
    user.setAge(25);
    user.setName("lisi");

    Gson gson = new Gson();
    String userJson = gson.toJson(user);
    request.doc(userJson, XContentType.JSON);

//        request.doc(XContentType.JSON,"sex","nan");
    UpdateResponse response = restHighLevelClient.update(request, RequestOptions.DEFAULT);
    //响应数据
    System.out.println(response.getIndex());
    System.out.println(response.getId());
    System.out.println(response.getResult());

    restHighLevelClient.close();
```

**查询数据**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

// 创建doc准备查询
GetRequest request = new GetRequest();
request.index("user").id("1001");
GetResponse response = restHighLevelClient.get(request, RequestOptions.DEFAULT);
//响应数据
System.out.println(response.getIndex());
System.out.println(response.getId());
System.out.println(response.getSourceAsString());

restHighLevelClient.close();
```

**删除数据**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 准备删除
    DeleteRequest request = new DeleteRequest();
    request.index("user").id("1001");
    DeleteResponse delete = restHighLevelClient.delete(request, RequestOptions.DEFAULT);
    //响应数据
    System.out.println(delete.getIndex());
    System.out.println(delete.getId());

    restHighLevelClient.close();
```

**批量插入数据**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 创建doc准备查询
    BulkRequest bulkRequest = new BulkRequest();
    IndexRequest indexRequest = new IndexRequest("user");
    IndexRequest indexRequest1 = new IndexRequest("user");
    indexRequest.id("1001");
    indexRequest1.id("1002");
    indexRequest.source(XContentType.JSON,"name","zhangsan","age","18");
    indexRequest1.source(XContentType.JSON,"name","lisi","age","66");

    bulkRequest.add(indexRequest);
    bulkRequest.add(indexRequest1);
    BulkResponse bulk = restHighLevelClient.bulk(bulkRequest, RequestOptions.DEFAULT);
    //响应数据
    System.out.println(bulk.getItems());
v
    restHighLevelClient.close();
```

**批量删除**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost",9200)));

    // 创建doc准备查询
    BulkRequest bulkRequest = new BulkRequest();
    DeleteRequest indexRequest = new DeleteRequest("user");
    DeleteRequest indexRequest1 = new DeleteRequest("user");
    indexRequest.id("1001");
    indexRequest1.id("1002");

    bulkRequest.add(indexRequest);
    bulkRequest.add(indexRequest1);
    BulkResponse bulk = restHighLevelClient.bulk(bulkRequest, RequestOptions.DEFAULT);
    //响应数据
    System.out.println(bulk.getItems());

    restHighLevelClient.close();
```

**参数查询**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));
SearchRequest searchRequest = new SearchRequest();
searchRequest.indices("user");
SearchSourceBuilder age =new SearchSourceBuilder().query(QueryBuilders.matchAllQuery()); //全量查询
searchRequest.source(age);

SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
for (SearchHit searchHit : search.getHits()) {
    System.out.println(searchHit.getSourceAsString());
}
restHighLevelClient.close();
```

**条件查询**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

SearchRequest searchRequest = new SearchRequest();
searchRequest.indices("user");
SearchSourceBuilder age = new SearchSourceBuilder().query(QueryBuilders.termQuery("name", "zhangsan"));//条件查询
searchRequest.source(age);

SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
for (SearchHit searchHit : search.getHits()) {
    System.out.println(searchHit.getSourceAsString());
}

restHighLevelClient.close();
```

**分页查询 + 排序**

```java
 RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

        SearchRequest searchRequest = new SearchRequest();
        searchRequest.indices("user");
        SearchSourceBuilder builder = new SearchSourceBuilder().query(QueryBuilders.matchAllQuery());
        builder.from(0); //分页
        builder.size(2);
        builder.sort("age", SortOrder.ASC); //排序
        builder.fetchSource(new String[]{"name"},new String[]{"sex"}); //选择/排除字段
        searchRequest.source(builder);

        SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
        for (SearchHit searchHit : search.getHits()) {
            System.out.println(searchHit.getSourceAsString());
        }

        restHighLevelClient.close();
```



**组合条件查询**

```java
        RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

        SearchRequest searchRequest = new SearchRequest();
        searchRequest.indices("user");
        BoolQueryBuilder boolQueryBuilder = QueryBuilders.boolQuery();
//        boolQueryBuilder.must().add(QueryBuilders.matchQuery("age",11));
//        boolQueryBuilder.must().add(QueryBuilders.matchQuery("name","zhaoliu"));
//        boolQueryBuilder.mustNot().add(QueryBuilders.matchQuery("sex","男"));
        boolQueryBuilder.should().add(QueryBuilders.matchQuery("age","18"));
        boolQueryBuilder.should().add(QueryBuilders.matchQuery("age","11"));
        SearchSourceBuilder builder = new SearchSourceBuilder().query(boolQueryBuilder);
        searchRequest.source(builder);

        SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
        for (SearchHit searchHit : search.getHits()) {
            System.out.println(searchHit.getSourceAsString());
        }

        restHighLevelClient.close();
```

**范围查询**

```java
RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

        SearchRequest searchRequest = new SearchRequest();
        searchRequest.indices("user");
        RangeQueryBuilder age = QueryBuilders.rangeQuery("age");
        age.gt(18);
        SearchSourceBuilder builder = new SearchSourceBuilder().query(age);
        searchRequest.source(builder);

        SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
        for (SearchHit searchHit : search.getHits()) {
            System.out.println(searchHit.getSourceAsString());
        }

        restHighLevelClient.close();
```

**模糊查询**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));
    
    SearchRequest searchRequest = new SearchRequest();
    searchRequest.indices("user");
    FuzzyQueryBuilder fuzziness = QueryBuilders.fuzzyQuery("name", "wang").fuzziness(Fuzziness.TWO); // 模糊查询
    SearchSourceBuilder builder = new SearchSourceBuilder().query(fuzziness);
    searchRequest.source(builder);

    SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
    for (SearchHit searchHit : search.getHits()) {
        System.out.println(searchHit.getSourceAsString());
    }

    restHighLevelClient.close();
```

**高亮查询**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

    SearchRequest searchRequest = new SearchRequest();
    searchRequest.indices("user");
    TermsQueryBuilder termsQueryBuilder = QueryBuilders.termsQuery("name", "wangwu");
    SearchSourceBuilder builder = new SearchSourceBuilder().query(termsQueryBuilder);
    builder.highlighter(new HighlightBuilder().field("name").preTags("<font color='red'>").postTags("</font>"));// 高亮查询
    searchRequest.source(builder);

    SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
    for (SearchHit searchHit : search.getHits()) {
        System.out.println(searchHit.getSourceAsString());
        System.out.println(searchHit.getHighlightFields());
    }

    restHighLevelClient.close();
```

**聚合查询**

```java
    RestHighLevelClient restHighLevelClient = new RestHighLevelClient(RestClient.builder(new HttpHost("localhost", 9200)));

    SearchRequest searchRequest = new SearchRequest();
    searchRequest.indices("user");
    AvgAggregationBuilder age = AggregationBuilders.avg("avgAge").field("age");
    SearchSourceBuilder builder = new SearchSourceBuilder().aggregation(age);
    searchRequest.source(builder);

    SearchResponse search = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

    Avg age1 = search.getAggregations().get("avgAge");
    System.out.println(age1.getValue());
    restHighLevelClient.close();
```

# 集群

