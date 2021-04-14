# MySQL

## MySQL服务架构
![MySQL服务架构](picture/MySQL服务架构.png)

client发送请求到server，server的连接器处理请求，解析器解析SQL，优化器优化SQL，执行器执行SQL。最后到达存储引擎，不同存放位置，不同文件格式。

ps：在老版本还会有缓存器存储缓存

## 优化
基于规则的优化(RBO)regular based optimise
基于成本的优化(CBO)cost based optimise

## 步骤
**开启追踪时间，精确到小数点6位**
设置profiles属性：set profiling=1;
查看时间：show profiles;
查看时间细节：show profile;