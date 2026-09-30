---
title: burp学习路径-SQL
date: 2026-09-30
categories:
  - SQL注入基础
tags:
  - SQL注入
  - Burp Suite
description: 记录 burp平台实验学习

---

# 一 、基本注入方式

1.确定列数

union  select 只能接受__相同数据类型__，__相同列数__。由此可以利用报错信息判断列数  `' UNION SELECT NULL,NULL...`,也可以用`order by 1,2,..`判断。

2.确定每列数据类型

确定列的数量后，可以对每个列进行测试。通过在每列依次放入数据来探测`' UNION SELECT 'a',NULL,NULL,NULL--`,将字符a放入不同列进行测验，如果列中数据类型和测试字符a的字符串数据不兼容，则会产生报错:`Conversion failed when converting the varchar value 'a' to data type int.`      根据每列的数据类型注入获取更多数据。
> 注意
>
> 在某些情况下，上述中的查询可能只返回一列。这种情况可以通过连接多个值，将多个值一起检索到这一列中。可以添加分隔符来区分组合后的值。
> 在_MYSQL_中可利用`CONCAT()`，` 'union select 1,concat("username",'~',"password") from users --+'`;
> 在 _Oracle_中用`'UNION SELECT username || '~' || password FROM users--`,输出结果将以~隔开

![image-20260930163232297](D:\Blog\su-security-blog\source\images\image-20260930163232297.png)

# 获取数据库信息

可以通过注入特定于数据库提供商的查询来识别数据库类型和版本，看看哪个查询有效。以下是一些用于确定常用数据库类型的版本查询：

| 数据库类型       | QUERY                   |
| ---------------- | ----------------------- |
| Microsoft, MySQL | SELECT @@version        |
| Oracle           | SELECT * FROM v$version |
| PostgreSQL       | SELECT version()        |

具体根据[注入方式](#一、基本注入方式)

还可以利用`information_schema.tables`查询数据库中的表名`SELECT * FROM information_schema.tables` 此代码会返回数据库中所有表，假如返回了`Users`,`Products`,`feedbook`三个表格，那么我们可以利用`SELECT * FROM information_schema.columns WHERE table_name = 'Users'`查`User`表中的列，将会返回所有列以及数据类型。

- 查表名

  ![image-20260930170203188](D:\Blog\su-security-blog\source\images\image-20260930170203188.png)

- 爆列名![image-20260930173006789](D:\Blog\su-security-blog\source\images\image-20260930173006789.png)

- 爆账密码![image-20260930173133443](D:\Blog\su-security-blog\source\images\image-20260930173133443.png)

# 盲注

当HTTP 响应中不包含相关 SQL 查询的结果或任何数据库错误的详细信息时，许多技术，例如 UNION 攻击，对盲注 SQL 注入漏洞无效。因为union注入依赖返回错误信息。此时，采用盲注
