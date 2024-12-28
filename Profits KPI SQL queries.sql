-- Gross profits kpi
-- Making profits trend line by adding column to monthly sales
-- Making profits column

ALTER TABLE monthly_sales
ADD gross_profits FLOAT;

ALTER TABLE monthly_sales
ADD expenses FLOAT;

CREATE TABLE expenses 
SELECT `Monthly expenses` as expenses
FROM store_data 
WHERE trim(`Monthly expenses`) <> '';

ALTER TABLE expenses
ADD COLUMN Month VARCHAR(20);

-- Add the new column for average profits
ALTER TABLE daily_sales 
ADD COLUMN avg_profits DECIMAL(10, 2);

-- Look at the foodstamp effect and compare monthly profits
-- Update the 'before EBT' and 'after EBT' periods with average profits

UPDATE daily_sales ds
SET ds.avg_profits = 
    CASE 
        WHEN ds.period = 'Before Food Stamps' THEN (
            SELECT AVG(ms.gross_profits)
            FROM monthly_sales ms
            WHERE ms.Month IN ('April', 'May', 'June', 'July', 'August')
        )
        WHEN ds.period = 'After Food Stamps' THEN (
            SELECT AVG(ms.gross_profits)
            FROM monthly_sales ms
            WHERE ms.Month IN ('September', 'October', 'November')
        )
    END;

UPDATE expenses
SET Month = 'April'
WHERE expenses = 3929.24;

UPDATE expenses
SET Month = 'May'
WHERE expenses = 6173.49;

UPDATE expenses
SET Month = 'June'
WHERE expenses = 4965.41;

UPDATE expenses
SET Month = 'July'
WHERE expenses = 7810.06;

UPDATE expenses
SET Month = 'September'
WHERE expenses = 7166.87;

UPDATE expenses
SET Month = 'October'
WHERE expenses = 10197.43;

UPDATE expenses
SET Month = 'November'
WHERE expenses = 7924.16;

INSERT INTO expenses (expenses, Month)
VALUES (7450.49, 'August');

CREATE TABLE monthly_expenses
SELECT *
FROM expenses
ORDER BY FIELD(Month, 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November');

UPDATE monthly_sales
SET expenses = (
    SELECT monthly_expenses.expenses
    FROM monthly_expenses
    WHERE monthly_expenses.Month = monthly_sales.Month
);

UPDATE monthly_sales
SET gross_profits = Sales - expenses;

-- Making profits growth rate trend line
-- Making profit growth rate column

CREATE TEMPORARY TABLE temp_profits AS
SELECT 
    ms.gross_profits,
    ms.Month,
    CASE 
        WHEN LAG(ms.gross_profits) OVER (ORDER BY mo.month_order) IS NULL THEN NULL
        ELSE ((ms.gross_profits - LAG(ms.gross_profits) OVER (ORDER BY mo.month_order)) / LAG(ms.gross_profits) OVER (ORDER BY mo.month_order)) * 100
    END AS profits_growth_rate
FROM 
    monthly_sales ms
JOIN 
    monthly_sales_ordered mo
ON 
    ms.Month = mo.Month;

UPDATE monthly_sales ms
JOIN temp_profits tg
ON ms.Month = tg.Month
SET ms.profits_growth = tg.profits_growth_rate;

-- 	Create database to upload to Tableau
CREATE DATABASE store_KPI;
USE store_kpi;
RENAME TABLE store.monthly_sales TO store_kpi.monthly_sales;
RENAME TABLE store.daily_sales TO store_kpi.daily_sales;
SHOW TABLES;