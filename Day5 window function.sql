/*
============================================================
SQL 窗口函数（Window Functions）学习笔记 - Day 5
数据库：finance_learn
表名：sales（假设包含字段：日期, 产品名称, 金额, 销售区域, 销售员等）
说明：本脚本包含常用窗口函数的示例代码及详细注释，
      使用时请根据实际表结构和列名进行调整。
============================================================
*/

-- 1. 窗口函数基本语法
-- 窗口函数可以在不改变行数的情况下，对每一行计算基于分组或排序的聚合值
-- 语法：
--   窗口函数() OVER (
--       PARTITION BY 分组列   -- 可选，用于分组
--       ORDER BY 排序列       -- 可选，用于排序
--       窗口范围              -- 可选，如 ROWS BETWEEN ...
--    ) AS 别名
-- 常用窗口函数：ROW_NUMBER, RANK, DENSE_RANK, SUM, AVG, LAG, LEAD 等

-- 2. ROW_NUMBER() - 给每一行分配唯一的连续排名（无并列）
-- 作用：按金额从高到低排序，生成唯一排名
SELECT 
    产品名称,
    金额,
    ROW_NUMBER() OVER (ORDER BY 金额 DESC) AS 金额排名
FROM sales;
-- 解释：
--   - ORDER BY 金额 DESC：按金额降序排序
--   - ROW_NUMBER()：为每一行分配一个递增的整数，即使金额相同也会强制分出先后
-- 适用场景：需要唯一排名时，如“取销售额前三名”且希望只有三个名字（无并列）

-- 3. RANK() 和 DENSE_RANK() - 允许并列的排名
SELECT 
    产品名称,
    金额,
    RANK() OVER (ORDER BY 金额 DESC) AS 排名_跳跃,
    DENSE_RANK() OVER (ORDER BY 金额 DESC) AS 排名_连续
FROM sales;
-- 解释：
--   - RANK()：相同值并列，但会跳过后续排名（如 1,1,3）
--   - DENSE_RANK()：相同值并列，不跳过排名（如 1,1,2）
-- 适用场景：需要处理并列排名时，例如“利润榜允许并列”

-- 4. 分组内排名（PARTITION BY）
-- 作用：在每个销售区域内独立排名
SELECT 
    销售区域,
    产品名称,
    金额,
    ROW_NUMBER() OVER (PARTITION BY 销售区域 ORDER BY 金额 DESC) AS 区域内排名
FROM sales;
-- 解释：
--   - PARTITION BY 销售区域：将数据按销售区域分组，每组内独立排序
--   - ORDER BY 金额 DESC：每组内按金额降序
-- 适用场景：找出每个区域销售额最高的产品、每个部门业绩最好的员工等

-- 5. 累计求和（SUM OVER）
-- 作用：按日期顺序计算累计销售额
SELECT 
    日期,
    金额,
    SUM(金额) OVER (ORDER BY 日期) AS 累计销售额
FROM sales;
-- 解释：
--   - SUM(金额) OVER (ORDER BY 日期)：按日期升序，累计到当前行的金额总和
--   - 相当于计算“截至今日的销售总额”
-- 适用场景：月度累计、年度累计分析，观察增长趋势

-- 6. 移动平均（AVG OVER）
-- 作用：计算最近三行的平均金额（3日移动平均）
SELECT 
    日期,
    金额,
    AVG(金额) OVER (ORDER BY 日期 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS 3日移动平均
FROM sales;
-- 解释：
--   - ROWS BETWEEN 2 PRECEDING AND CURRENT ROW：窗口范围包括当前行及前2行
--   - 移动平均常用于平滑数据波动，观察长期趋势
-- 可选其他窗口：ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING（前后一行）等

-- 7. 环比计算（LAG函数）
-- 作用：获取上一行的金额，计算环比增长额和增长率
SELECT 
    日期,
    金额,
    LAG(金额, 1) OVER (ORDER BY 日期) AS 上月金额,
    金额 - LAG(金额, 1) OVER (ORDER BY 日期) AS 环比增长额,
    (金额 - LAG(金额, 1) OVER (ORDER BY 日期)) / LAG(金额, 1) OVER (ORDER BY 日期) AS 环比增长率
FROM sales;
-- 解释：
--   - LAG(金额, 1)：取按日期排序后上一行的金额
--   - 第一行因为没有上一行，LAG返回NULL，导致后续计算也为NULL
--   - 可以用 COALESCE 或 IFNULL 处理NULL值
-- 适用场景：财务同比/环比分析，如“本月销售额比上月增长多少”

-- 8. 分组取TOP N（结合CTE和ROW_NUMBER）
-- 作用：找出每个销售区域内金额最高的记录
WITH ranked AS (
    SELECT 
        销售区域,
        产品名称,
        金额,
        ROW_NUMBER() OVER (PARTITION BY 销售区域 ORDER BY 金额 DESC) AS rn
    FROM sales
)
SELECT * FROM ranked WHERE rn = 1;
-- 解释：
--   - CTE（公用表表达式）先计算每个区域内的排名
--   - 外层查询筛选排名为1的行，得到每个区域的最高金额记录
--   - 如需取前3名，改为 WHERE rn <= 3
-- 适用场景：各类分组Top N分析，如“各区域销售额前三的产品”

-- 9. 补充练习：如果数据量少，可以插入一些测试数据
-- 取消注释执行以下插入语句（根据实际表结构调整列名）
/*
INSERT INTO sales (日期, 产品名称, 金额, 销售区域) VALUES
('2026-03-10', '耳机', 8000, '华东'),
('2026-03-11', '耳机', 8500, '华南'),
('2026-03-12', '平板', 7000, '华东'),
('2026-03-13', '平板', 7200, '华北');
*/

-- 注意事项：
--   - 所有窗口函数中的 ORDER BY 必须明确指定排序字段
--   - PARTITION BY 可选，如果不加则在整个结果集上排序
--   - 窗口函数只能用在 SELECT 和 ORDER BY 子句中，不能用于 WHERE、GROUP BY
--   - 如果出现错误，请检查字段名是否正确、数据类型是否匹配