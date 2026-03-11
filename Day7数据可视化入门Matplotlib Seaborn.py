/*
============================================================
SQL 复杂查询与财务分析应用 - Day 7
数据库：finance_learn
包含：CTE多步分析、占比累计、同比环比、移动平均、索引建议
============================================================
*/

-- 1. 数据准备（如果数据不足，可执行以下插入）
INSERT INTO sales (日期, 产品名称, 金额, 销售区域, 销售员) VALUES
('2026-03-01', '笔记本', 25000, '华东', '张三'),
('2026-03-02', '显示器', 6000, '华南', '李四'),
('2026-03-03', '键盘', 3000, '华北', '王五'),
('2026-03-04', '笔记本', 20000, '华东', '张三'),
('2026-03-05', '显示器', 8000, '华南', '李四'),
('2026-03-06', '键盘', 2500, '华北', '王五'),
('2026-03-07', '鼠标', 1500, '华东', '赵六'),
('2026-03-08', '鼠标', 2000, '华南', '赵六');

-- 2. 使用 CTE 计算各产品类别销售额、占比、累计占比、排名
WITH category_sales AS (
    SELECT 
        p.产品类别,
        SUM(s.金额) AS 总销售额
    FROM sales s
    LEFT JOIN products p ON s.产品名称 = p.产品名称
    GROUP BY p.产品类别
),
total_sales AS (
    SELECT SUM(总销售额) AS 全部销售额 FROM category_sales
)
SELECT 
    cs.产品类别,
    cs.总销售额,
    ROUND(cs.总销售额 / ts.全部销售额 * 100, 2) AS 占比百分比,
    ROUND(SUM(cs.总销售额) OVER (ORDER BY cs.总销售额 DESC) / ts.全部销售额 * 100, 2) AS 累计占比百分比,
    RANK() OVER (ORDER BY cs.总销售额 DESC) AS 排名
FROM category_sales cs
CROSS JOIN total_sales ts
ORDER BY 排名;

-- 3. 按月统计销售额，计算环比和同比（需跨年数据，若无则只计算环比）
WITH monthly_sales AS (
    SELECT 
        YEAR(日期) AS 年份,
        MONTH(日期) AS 月份,
        SUM(金额) AS 月销售额
    FROM sales
    GROUP BY YEAR(日期), MONTH(日期)
)
SELECT 
    年份,
    月份,
    月销售额,
    LAG(月销售额, 1) OVER (PARTITION BY 年份 ORDER BY 月份) AS 上月销售额,
    ROUND((月销售额 - LAG(月销售额, 1) OVER (PARTITION BY 年份 ORDER BY 月份)) / LAG(月销售额, 1) OVER (PARTITION BY 年份 ORDER BY 月份) * 100, 2) AS 环比增长率,
    LAG(月销售额, 12) OVER (ORDER BY 年份, 月份) AS 去年同月销售额,
    ROUND((月销售额 - LAG(月销售额, 12) OVER (ORDER BY 年份, 月份)) / LAG(月销售额, 12) OVER (ORDER BY 年份, 月份) * 100, 2) AS 同比增长率
FROM monthly_sales
ORDER BY 年份, 月份;

-- 4. 计算3个月移动平均
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(日期, '%Y-%m') AS 年月,
        SUM(金额) AS 月销售额
    FROM sales
    GROUP BY DATE_FORMAT(日期, '%Y-%m')
)
SELECT 
    年月,
    月销售额,
    ROUND(AVG(月销售额) OVER (ORDER BY 年月 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS 3月移动平均
FROM monthly_sales
ORDER BY 年月;

-- 5. 索引建议（根据实际查询创建）
-- CREATE INDEX idx_sales_date ON sales(日期);
-- CREATE INDEX idx_sales_product ON sales(产品名称);
-- CREATE INDEX idx_products_name ON products(产品名称);

-- 6. 查看执行计划示例
-- EXPLAIN SELECT * FROM sales WHERE 日期 BETWEEN '2026-03-01' AND '2026-03-31';