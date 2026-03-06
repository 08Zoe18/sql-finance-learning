-- =====================================================
-- 建表模板（复制后修改表名、列名、数据类型即可）
-- =====================================================

-- 1. 先选择要操作的数据库（请替换为你的数据库名）
USE your_database_name;

-- 2. 如果表已存在，先删除（可选，谨慎使用）
-- DROP TABLE IF EXISTS your_table_name;

-- 3. 创建新表
CREATE TABLE your_table_name (
    id INT AUTO_INCREMENT PRIMARY KEY,        -- 自增主键
    column1 VARCHAR(50),                       -- 文本列（可修改长度）
    column2 DECIMAL(10,2),                      -- 金额/数字列
    column3 DATE,                               -- 日期列
    -- 在这里继续添加其他列...
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 自动记录创建时间（可选）
);


-- =====================================================
-- 插入数据模板（复制后修改表名和列名，用具体值替换占位符）
-- =====================================================

USE your_database_name;

-- 单行插入示例
INSERT INTO your_table_name (column1, column2, column3)
VALUES ('value1', 123.45, '2026-01-01');

-- 多行插入示例（推荐）
INSERT INTO your_table_name (column1, column2, column3) VALUES
('value1', 123.45, '2026-01-01'),
('value2', 678.90, '2026-02-01'),
('value3', 111.22, '2026-03-01');
-- 继续添加更多行...

-- =====================================================
-- 常用查询语句集（包含注释，可直接套用语法）
-- =====================================================

USE your_database_name;

-- 1. 查询所有列
SELECT * FROM your_table_name;

-- 2. 查询特定列
SELECT column1, column2 FROM your_table_name;

-- 3. 按条件筛选
SELECT * FROM your_table_name WHERE column2 > 100;  -- 修改条件和数值
SELECT * FROM your_table_name WHERE column1 = '某个值';  -- 字符串条件

-- 4. 排序
SELECT * FROM your_table_name ORDER BY column2 DESC;  -- 降序
SELECT * FROM your_table_name ORDER BY column3 ASC;   -- 升序

-- 5. 聚合统计
SELECT COUNT(*) FROM your_table_name;                -- 总行数
SELECT SUM(column2) FROM your_table_name;            -- 总和
SELECT AVG(column2) FROM your_table_name;            -- 平均值
SELECT MAX(column2) FROM your_table_name;            -- 最大值
SELECT MIN(column2) FROM your_table_name;            -- 最小值

-- 6. 分组统计
SELECT column1, SUM(column2) FROM your_table_name GROUP BY column1;




-- =====================================================
-- 今天的练习数据（仅供参考，实际使用时替换）
-- =====================================================

USE finance_learn;

INSERT INTO sales (product_name, amount, sale_date) VALUES
('笔记本', 25.00, '2026-03-01'),
('笔', 5.50, '2026-03-01'),
('显示器', 1200.00, '2026-03-02'),
('键盘', 300.00, '2026-03-02'),
('文件夹', 15.00, '2026-03-03');