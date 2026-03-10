# sql-finance-learning
# SQL 财务分析学习

本仓库用于记录 SQL 学习过程，目标：能从数据库取数分析。

## Day 1（2026.03.05）
- 安装 MySQL 8.0
- 配置系统 PATH，验证版本
- 成功登录 MySQL


## Day 2（2026.03.06）
- **练习内容**：
  - 在 `finance_learn` 数据库中练习基础查询：
    - `SELECT` 查看所有数据
    - `WHERE` 筛选金额 > 100 的记录
    - `ORDER BY` 按金额排序
    - 聚合函数 `SUM`、`COUNT` 的使用
- **练习文件**：
  - [Creat table.sql](./templates/sql_basics_template.sql) - 包含建表、插入、查询的完整模板
- **收获**：
  - 掌握 SQL 基础查询语法
  - 学会用 Workbench 执行和调试 SQL
  - 整理出可复用的模板文件
  - ## Day 3（2026.03.07）
- 学习内容：复杂销售数据多维分析（按产品类别、区域、客户类型等）
- 练习文件：[day3_sales_analysis.sql](./Day3_复习/day3_sales_analysis.sql)
- 收获：掌握 GROUP BY、HAVING、CASE 等语法，能独立完成财务常用查询。
## Day 4（2026.03.08）
- **学习内容**：多表连接（INNER JOIN、LEFT JOIN）、子查询（标量/相关）、视图
- **练习文件**：[day4_join_subquery.sql](./Day4/day4_join_subquery.sql)
- **核心收获**：
  - 理解 INNER JOIN 和 LEFT JOIN 的区别，能通过连接合并多张表获取完整信息
  - 掌握子查询的两种形式：标量子查询（返回单个值）和相关子查询（内外层关联）
  - 学会创建视图，将常用查询保存为虚拟表，简化后续操作
- **示例代码概览**：
  ```sql
  -- INNER JOIN 计算毛利
  SELECT s.*, p.单位成本, (s.单价 - p.单位成本) AS 单位毛利
  FROM sales s INNER JOIN products p ON s.产品名称 = p.产品名称;

  -- LEFT JOIN 检查数据缺失
  SELECT s.产品名称, p.供应商 FROM sales s LEFT JOIN products p ON s.产品名称 = p.产品名称;

  -- 子查询：高于平均值的记录
  SELECT * FROM sales WHERE 金额 > (SELECT AVG(金额) FROM sales);

  -- 相关子查询：每个类别最高金额
  SELECT * FROM sales s1 WHERE 金额 = (SELECT MAX(金额) FROM sales s2 WHERE s2.产品类别 = s1.产品类别);

  -- 创建视图
  CREATE VIEW 销售毛利视图 AS SELECT ...;
  ## Day 5（2026.03.09）
- 学习内容：窗口函数（ROW_NUMBER、RANK、DENSE_RANK、SUM OVER、AVG OVER、LAG）
- 练习文件：[day5_window_functions.sql](./Day5/day5_window_functions.sql)
- 核心收获：掌握排名、累计、移动平均、环比的计算方法，能进行更深入的财务数据分析
- ## Day 6（2026.03.10）
- **学习内容**：窗口函数进阶应用（分组内排名、累计求和、移动平均、环比同比、占比分析、帕累托分析）
- **练习文件**：[day6_window_functions_advanced.sql](./Day6/day6_window_functions_advanced.sql)
- **核心收获**：
  - 掌握在窗口函数中使用 PARTITION BY 进行分组内排名，找出各区域销售冠军
  - 学会用 LAG 计算环比和同比增长率，分析业务趋势
  - 能够计算累积占比（帕累托分析），识别贡献80%收入的少数关键产品
  - 综合运用 CTE 和窗口函数解决复杂财务分析问题（如销售员业绩排名前三的月份）
- **示例代码概览**：
  ```sql
  -- 分组内排名：各区域销售额最高的产品
  WITH 区域排名 AS (
      SELECT 销售区域, 产品名称, 金额,
             ROW_NUMBER() OVER (PARTITION BY 销售区域 ORDER BY 金额 DESC) AS 排名
      FROM sales
  )
  SELECT * FROM 区域排名 WHERE 排名 = 1;

  -- 环比计算：本月 vs 上月销售额
  SELECT 日期, 金额,
         LAG(金额,1) OVER (ORDER BY 日期) AS 上月金额,
         (金额 - LAG(金额,1) OVER (ORDER BY 日期)) / LAG(金额,1) OVER (ORDER BY 日期) * 100 AS 环比增长率
  FROM sales;

  -- 帕累托分析：产品类别销售额累计占比
  WITH 类别汇总 AS (
      SELECT 产品类别, SUM(金额) AS 类别销售额
      FROM sales GROUP BY 产品类别
  ), 排序 AS (
      SELECT 产品类别, 类别销售额,
             SUM(类别销售额) OVER (ORDER BY 类别销售额 DESC) AS 累计销售额,
             SUM(类别销售额) OVER () AS 总销售额
      FROM 类别汇总
  )
  SELECT 产品类别, 类别销售额, 累计销售额 / 总销售额 AS 累计占比
  FROM 排序 ORDER BY 类别销售额 DESC;
