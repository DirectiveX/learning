# AWS

## 云计算

### 模型

![yunjisuan](picture/yunjisuan.png)

IAAS：基础设施即服务（机器）

> 基础设施即服务有时缩写为 IaaS，包含云 IT 的基本构建块，通常提供对联网功能、计算机（虚拟或专用硬件）以及数据存储空间的访问。基础设施即服务提供最高等级的灵活性和对 IT 资源的管理控制，其机制与现今众多 IT 部门和开发人员所熟悉的现有 IT 资源最为接近。

PAAS：平台即服务（机器+操作系统+运行库+数据库）

> 平台即服务消除了组织对底层基础设施（一般是硬件和操作系统）的管理需要，让您可以将更多精力放在应用程序的部署和管理上面。这有助于提高效率，因为您不用操心资源购置、容量规划、软件维护、补丁安装或与应用程序运行有关的任何无差别的繁重工作。

SAAS：软件即服务（机器+操作系统+运行库+数据库+软件）

> 软件即服务提供了一种完善的产品，其运行和管理皆由服务提供商负责。人们通常所说的软件即服务指的是终端用户应用程序。使用 SaaS 产品时，服务的维护和底层基础设施的管理都不用您操心，您只需要考虑怎样使用 SaaS 软件就可以了。SaaS 的常见应用是基于 Web 的电子邮件，在这种应用场景中，您可以收发电子邮件而不用管理电子邮件产品的功能添加，也不需要维护电子邮件程序运行所在的服务器和操作系统。

## Route53

使用Route53后会将查询转到最近的服务器位置，Route53服务器帮助返回IP地址，使浏览器能够加载网站或应用程序

**优势**

Route53有遍布全球的DNS服务器，可以自动扩展处理DNS查询中的大量数据或者峰值

**使用步骤**

1.购买Route53域名
2.创建托管区域
3.主机区域创建记录（类似于host）
4.使用AWS IAM（Identity and Access Management），控制访问权限
5.别名映射

**配置route53**
用AWS Console 或者 API 或SDK来配置DNS

1.配置管理区域，添加健康检查

![route53_1](picture\route53_1.png)


2.创建故障转移用的DNS记录（一主多从）

![route53_2](picture/route53_2.png)

![route53_2](picture/route53_3.png)

![route53_2](picture/route53_4.png)

![route53_2](picture/route53_5.png)

3.使用web服务器的ip地址为域创建DNS记录

![route53_6](picture/route53_6.png)

![route53_6](picture/route53_7.png)

![route53_6](picture/route53_8.png)

4.创建健康检查

![route53_13](picture/route53_13.png)

![route53_13](picture/route53_14.png)

![route53_13](picture/route53_15.png)

![route53_13](picture/route53_16.png)

![route53_13](picture/route53_17.png)

5.配置故障转移（服务降级）

![route53_18](picture/route53_18.png)

![route53_19](picture/route53_19.png)

![route53_20](picture/route53_20.png)

![route53_21](picture/route53_21.png)

![route53_22](picture/route53_22.png)

![route53_23](picture/route53_23.png)

