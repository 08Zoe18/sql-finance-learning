/*
============================================================
SQL 财务高级分析 - Day 8
包含：CASE 条件聚合、累计值、占比计算、临时表、查询优化
============================================================
*/

-- 1. 数据准备（如果已有表可跳过）
CREATE TABLE IF NOT EXISTS monthly_profit (
    月份 VARCHAR(10),
    收入 DECIMAL(10,2),
    成本 DECIMAL(10,2),
    管理费用 DECIMAL(10,2),
    财务费用 DECIMAL(10,2),
    利润 DECIMAL(10,2)
);

INSERT INTO monthly_profit VALUES
('1月', 100000, 60000, 15000, 500, 24500),
('2月', 120000, 72000, 16000, 600, 31400),
('3月', 130000, 78000, 15500, 550, 35950),
('4月', 140000, 84000, 16500, 700, 38800),
('5月', 150000, 90000, 17000, 650, 42350),
('6月', 160000, 96000, 17500, 800, 45700);

CREATE TABLE IF NOT EXISTS product_sales (
    月份 VARCHAR(10),
    产品ID INT,
    产品名称 VARCHAR(50),
    销售额 DECIMAL(10,2),
    成本 DECIMAL(10,2)
);

INSERT INTO product_sales VALUES
('1月', 1, '笔记本', 50000, 30000),
('1月', 2, '显示器', 30000, 18000),
('1月', 3, '键盘', 20000, 12000),
('2月', 1, '笔记本', 60000, 36000),
('2月', 2, '显示器', 40000, 24000),
('2月', 3, '键盘', 20000, 12000);

-- 2. CASE 条件聚合：计算各月期间费用
SELECT 
    月份,
    收入,
    成本,
    管理费用,
    财务费用,
    (管理费用 + 财务费用) AS 期间费用,
    利润
FROM monthly_profit;

-- 3. 累计值计算
SELECT 
    月份,
    收入,
    SUM(收入) OVER (ORDER BY 月份) AS 累计收入,
    利润,
    SUM(利润) OVER (ORDER BY 月份) AS 累计利润
FROM monthly_profit
ORDER BY 月份;

-- 4. 产品销售额占比
WITH monthly_total AS (
    SELECT 
        月份,
        SUM(销售额) AS 月总销售额
    FROM product_sales
    GROUP BY 月份
)
SELECT 
    ps.月份,
    ps.产品名称,
    ps.销售额,
    mt.月总销售额,
    ROUND(ps.销售额 / mt.月总销售额 * 100, 2) AS 销售额占比
FROM product_sales ps
JOIN monthly_total mt ON ps.月份 = mt.月份
ORDER BY ps.月份, ps.销售额 DESC;

-- 5. 使用临时表
CREATE TEMPORARY TABLE tmp_monthly_total AS
SELECT 
    月份,
    SUM(销售额) AS 月总销售额
FROM product_sales
GROUP BY 月份;

SELECT 
    ps.月份,
    ps.产品名称,
    ps.销售额,
    tmp.月总销售额,
    ROUND(ps.销售额 / tmp.月总销售额 * 100, 2) AS 占比
FROM product_sales ps
JOIN tmp_monthly_total tmp ON ps.月份 = tmp.月份;

-- 6. 综合练习：计算环比增长率和累计利润
WITH monthly AS (
    SELECT 
        月份,
        收入,
        成本,
        管理费用 + 财务费用 AS 期间费用,
        利润
    FROM monthly_profit
),
lagged AS (
    SELECT 
        月份,
        利润,
        LAG(利润, 1) OVER (ORDER BY 月份) AS 上月利润
    FROM monthly
)
SELECT 
    m.月份,
    m.收入,
    m.成本,
    m.期间费用,
    m.利润,
    l.上月利润,
    CASE 
        WHEN l.上月利润 IS NULL OR l.上月利润 = 0 THEN NULL
        ELSE ROUND((m.利润 - l.上月利润) / l.上月利润 * 100, 2)
    END AS 环比增长率,
    SUM(m.利润) OVER (ORDER BY m.月份) AS 累计利润
FROM monthly m
LEFT JOIN lagged l ON m.月份 = l.月份
ORDER BY m.月份;

-- 7. 索引建议
CREATE INDEX idx_product_sales_month ON product_sales(月份);
CREATE INDEX idx_product_sales_product ON product_sales(产品名称);

-- 8. 查看执行计划示例
EXPLAIN SELECT * FROM product_sales WHERE 月份 = '1月';