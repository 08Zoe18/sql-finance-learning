/*
============================================================
SQL 窗口函数进阶练习 - Day 6
数据库：finance_learn
表名：sales（包含字段：日期, 产品名称, 金额, 销售区域, 销售员等）
说明：基于Day5的窗口函数基础，进行更深入的财务分析练习
============================================================
*/

-- 1. 复习基础：ROW_NUMBER 按金额排名（回顾）
SELECT 
    产品名称,
    金额,
    ROW_NUMBER() OVER (ORDER BY 金额 DESC) AS 金额排名
FROM sales;

-- 2. 分组内排名：找出每个销售区域销售额最高的产品
WITH 区域排名 AS (
    SELECT 
        销售区域,
        产品名称,
        金额,
        ROW_NUMBER() OVER (PARTITION BY 销售区域 ORDER BY 金额 DESC) AS 排名
    FROM sales
)
SELECT * FROM 区域排名 WHERE 排名 = 1;
-- 解释：先用CTE计算每个区域内按金额降序的排名，再筛选排名第一的行

-- 3. 累计求和：计算每月累计销售额（假设日期是完整的）
SELECT 
    日期,
    金额,
    SUM(金额) OVER (ORDER BY 日期) AS 累计销售额
FROM sales;
-- 财务意义：看销售额随时间的累积情况

-- 4. 移动平均：计算最近3笔订单的平均金额（用于平滑波动）
SELECT 
    日期,
    金额,
    AVG(金额) OVER (ORDER BY 日期 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 三笔移动平均
FROM sales;
-- 财务意义：消除短期波动，观察长期趋势

-- 5. 环比计算：本月 vs 上月销售额
SELECT 
    日期,
    金额,
    LAG(金额, 1) OVER (ORDER BY 日期) AS 上月金额,
    金额 - LAG(金额, 1) OVER (ORDER BY 日期) AS 环比增长额,
    (金额 - LAG(金额, 1) OVER (ORDER BY 日期)) / LAG(金额, 1) OVER (ORDER BY 日期) * 100 AS 环比增长率
FROM sales;
-- 财务意义：分析业务增长情况，增长率 = (本月-上月)/上月

-- 6. 同比计算：今年本月 vs 去年本月（假设有2025年和2026年数据）
-- 如果日期是完整日期格式，可以用 YEAR() 和 MONTH() 提取年份和月份
SELECT 
    YEAR(日期) AS 年份,
    MONTH(日期) AS 月份,
    SUM(金额) AS 月销售额,
    LAG(SUM(金额), 12) OVER (ORDER BY YEAR(日期), MONTH(日期)) AS 去年同月销售额,
    SUM(金额) - LAG(SUM(金额), 12) OVER (ORDER BY YEAR(日期), MONTH(日期)) AS 同比增长额,
    (SUM(金额) - LAG(SUM(金额), 12) OVER (ORDER BY YEAR(日期), MONTH(日期))) / LAG(SUM(金额), 12) OVER (ORDER BY YEAR(日期), MONTH(日期)) * 100 AS 同比增长率
FROM sales
GROUP BY YEAR(日期), MONTH(日期)
ORDER BY 年份, 月份;
-- 财务意义：分析跨年业务增长情况

-- 7. 找出每个销售员业绩排名前三的月份（复杂应用）
WITH 销售员月度业绩 AS (
    SELECT 
        销售员,
        DATE_FORMAT(日期, '%Y-%m') AS 月份,
        SUM(金额) AS 月销售额
    FROM sales
    GROUP BY 销售员, DATE_FORMAT(日期, '%Y-%m')
),
排名 AS (
    SELECT 
        销售员,
        月份,
        月销售额,
        ROW_NUMBER() OVER (PARTITION BY 销售员 ORDER BY 月销售额 DESC) AS 排名
    FROM 销售员月度业绩
)
SELECT * FROM 排名 WHERE 排名 <= 3;
-- 财务意义：销售员绩效分析，找出最佳月份

-- 8. 计算每个产品类别的销售额占比
SELECT 
    产品类别,
    SUM(金额) AS 类别销售额,
    SUM(金额) / SUM(SUM(金额)) OVER () AS 占比
FROM sales
GROUP BY 产品类别;
-- 财务意义：分析收入结构，哪个类别贡献最大

-- 9. 累积占比（帕累托分析）
WITH 类别汇总 AS (
    SELECT 
        产品类别,
        SUM(金额) AS 类别销售额
    FROM sales
    GROUP BY 产品类别
),
排序 AS (
    SELECT 
        产品类别,
        类别销售额,
        SUM(类别销售额) OVER (ORDER BY 类别销售额 DESC) AS 累计销售额,
        SUM(类别销售额) OVER () AS 总销售额
    FROM 类别汇总
)
SELECT 
    产品类别,
    类别销售额,
    累计销售额 / 总销售额 AS 累计占比
FROM 排序
ORDER BY 类别销售额 DESC;
-- 财务意义：找出贡献80%收入的少数关键产品（二八法则）

-- 注意事项：
-- 1. 如果表中没有足够的日期数据，可以先插入一些测试数据
-- 2. 部分查询用到 DATE_FORMAT、YEAR、MONTH 函数，根据数据库类型可能需要调整
-- 3. 使用前请确认列名与你的表一致