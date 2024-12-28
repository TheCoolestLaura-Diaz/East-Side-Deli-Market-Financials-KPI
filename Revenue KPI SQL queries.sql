-- revenue growth kpi
-- monthly gross revenue trend line
-- making new table of month and total net sales

CREATE TABLE april_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '04/01' AND '05/01';

CREATE TABLE monthly_sales
SELECT SUM(`Net Sales`) AS Sales
FROM store.april_sales;

ALTER TABLE monthly_sales
ADD COLUMN Month VARCHAR(20);

UPDATE monthly_sales
SET Month = 'April'
WHERE Month IS NULL;

CREATE TABLE may_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '05/01' AND '06/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'May'
From may_sales;

CREATE TABLE june_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '06/01' AND '07/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'June'
From june_sales;

CREATE TABLE july_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '07/01' AND '08/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'July'
From july_sales;

CREATE TABLE aug_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '08/01' AND '09/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'August'
From aug_sales;

CREATE TABLE sept_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '09/01' AND '10/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'September'
From sept_sales;

CREATE TABLE oct_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '10/01' AND '11/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'October'
From oct_sales;

CREATE TABLE nov_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '11/01' AND '12/01';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'November'
From nov_sales;

CREATE TABLE dec_sales
AS
SELECT Date, `Net Sales`
FROM store_data
WHERE Date
BETWEEN '12/01' AND '12/15';

INSERT INTO monthly_sales (Sales, Month)
SELECT SUM(`Net Sales`), 'December'
From dec_sales;

ALTER TABLE monthly_sales
ADD revenue_growth_rate FLOAT;

-- Calculating growth rate 
-- Because the months are texts, make table to numerize months

CREATE TABLE monthly_sales_ordered AS
SELECT 
    Sales, 
    Month, 
    CASE 
        WHEN Month = 'April' THEN 1
        WHEN Month = 'May' THEN 2
        WHEN Month = 'June' THEN 3
        WHEN Month = 'July' THEN 4
        WHEN Month = 'August' THEN 5
        WHEN Month = 'September' THEN 6
        WHEN Month = 'October' THEN 7
        WHEN Month = 'November' THEN 8
        WHEN Month = 'December' THEN 9
    END AS month_order
FROM monthly_sales;

-- Creating a temp table with growth rate column just to be safe :)

CREATE TEMPORARY TABLE temp_sales AS
SELECT 
    ms.Sales,
    ms.Month,
    CASE 
        WHEN LAG(ms.Sales) OVER (ORDER BY mo.month_order) IS NULL THEN NULL
        ELSE ((ms.Sales - LAG(ms.Sales) OVER (ORDER BY mo.month_order)) / LAG(ms.Sales) OVER (ORDER BY mo.month_order)) * 100
    END AS revenue_growth_rate
FROM 
    monthly_sales ms
JOIN 
    monthly_sales_ordered mo
ON 
    ms.Month = mo.Month;

-- Overwriting monthly_sales with temp_sales

DELETE FROM monthly_sales;

INSERT INTO monthly_sales (Sales, Month, revenue_growth_rate)
SELECT Sales, Month, revenue_growth_rate
FROM temp_sales;

-- Looking at how foodstamps affected daily sales
-- Making a table of two columns, Period and average sales

CREATE TABLE daily_sales
AS
SELECT 
    CASE 
        WHEN Date < '08/31/2024' THEN 'Before Food Stamps'
        ELSE 'After Food Stamps'
    END AS period,
    AVG(`Net Sales`) AS avg_sales
FROM store_data
GROUP BY 
    CASE 
        WHEN Date < '08/31/2024' THEN 'Before Food Stamps'
        ELSE 'After Food Stamps'
    END;
