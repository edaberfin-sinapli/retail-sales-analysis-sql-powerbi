/* =========================================================
   01) RAW DATA & CLEANING (retail_analysis)
   ========================================================= */

CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

CREATE TABLE IF NOT EXISTS orders (
  Row_ID INT NOT NULL,
  Order_ID VARCHAR(30),
  Order_Date VARCHAR(20),
  Ship_Date VARCHAR(20),
  Ship_Mode VARCHAR(30),
  Customer_ID VARCHAR(20),
  Customer_Name VARCHAR(100),
  Segment VARCHAR(30),
  Country VARCHAR(50),
  City VARCHAR(50),
  State VARCHAR(50),
  Postal_Code VARCHAR(20),
  Region VARCHAR(30),
  Product_ID VARCHAR(30),
  Category VARCHAR(30),
  Sub_Category VARCHAR(30),
  Product_Name VARCHAR(255),
  Sales DECIMAL(10,2),
  Order_Date_Clean DATE,
  Ship_Date_Clean  DATE,
  PRIMARY KEY (Row_ID)
);

TRUNCATE TABLE orders;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore_fixed.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name,
 Segment, Country, City, State, Postal_Code, Region, Product_ID, Category,
 Sub_Category, Product_Name, Sales);

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET
  Order_Date_Clean =
    CASE
      WHEN Order_Date LIKE '%/%' THEN STR_TO_DATE(Order_Date, '%m/%d/%Y')
      WHEN Order_Date LIKE '%-%' THEN STR_TO_DATE(Order_Date, '%d-%m-%Y')
      ELSE NULL
    END,
  Ship_Date_Clean =
    CASE
      WHEN Ship_Date LIKE '%/%' THEN STR_TO_DATE(Ship_Date, '%m/%d/%Y')
      WHEN Ship_Date LIKE '%-%' THEN STR_TO_DATE(Ship_Date, '%d-%m-%Y')
      ELSE NULL
    END;

SET SQL_SAFE_UPDATES = 1;

SELECT
  SUM(Order_Date_Clean IS NULL) AS bad_order,
  SUM(Ship_Date_Clean IS NULL)  AS bad_ship
FROM retail_analysis.orders;

SELECT * FROM orders LIMIT 10;

/* =========================================================
   02) ANALYSIS VIEWS 
   ========================================================= */

-- TR: Aylık toplam satışları analiz amaçlı sunan yardımcı VIEW.
--     Raw veri korunur; bu VIEW analiz ve karşılaştırmalar için özet metrik sağlar.
--
-- EN: Supporting view for monthly total sales analysis.
--     Raw data is preserved; this view provides aggregated metrics for analysis and comparisons.

CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT
  CAST(DATE_FORMAT(Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
  SUM(Sales) AS total_sales
FROM orders
WHERE Order_Date_Clean IS NOT NULL
GROUP BY month_start;



-- TR: Bölge bazında aylık satışları analiz etmek için oluşturulmuş yardımcı VIEW.
--     Bu VIEW, satış artış ve düşüşlerinin bölgesel kaynaklarını analiz etmek için kullanılır.
--
-- EN: Supporting view for analyzing monthly sales by region.
--     This view is used to analyze regional drivers of sales increases and decreases.

CREATE OR REPLACE VIEW v_monthly_sales_by_region AS
SELECT
  CAST(DATE_FORMAT(Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
  Region,
  SUM(Sales) AS total_sales
FROM orders
WHERE Order_Date_Clean IS NOT NULL
GROUP BY month_start, Region;



-- TR: Müşteri segmenti bazında aylık satışları analiz etmek için oluşturulmuş yardımcı VIEW.
--     Toplam satış değişimlerinin segment kaynaklarını analiz etmek için kullanılır.
--
-- EN: Supporting view for analyzing monthly sales by customer segment.
--     Used to analyze segment-level drivers behind total sales changes.

CREATE OR REPLACE VIEW v_monthly_sales_by_segment AS
SELECT
  CAST(DATE_FORMAT(Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
  Segment,
  SUM(Sales) AS total_sales
FROM orders
WHERE Order_Date_Clean IS NOT NULL
GROUP BY month_start, Segment;



-- TR: Ürün kategorisi bazında aylık satışları analiz etmek için oluşturulmuş yardımcı VIEW.
--     Satış artış ve düşüşlerinin kategori kaynaklarını analiz etmek için kullanılır.
--
-- EN: Supporting view for analyzing monthly sales by product category.
--     Used to analyze category-level drivers behind sales changes.

CREATE OR REPLACE VIEW v_monthly_sales_by_category AS
SELECT
  CAST(DATE_FORMAT(Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
  Category,
  SUM(Sales) AS total_sales
FROM orders
WHERE Order_Date_Clean IS NOT NULL
GROUP BY month_start, Category;



/* =========================================================
   03) REPORTING LAYER (POWER BI)
   ========================================================= */

-- TR: Power BI'ın bağlanacağı raporlama katmanı için ayrı schema.
-- EN: Separate schema for reporting layer used by Power BI.
CREATE DATABASE IF NOT EXISTS retail_reporting;


-- TR: Çalışma bağlamını raporlama katmanına alırız (VIEW'ler burada oluşturulacak).
-- EN: Switch context to the reporting schema (views will be created here).
USE retail_reporting;


-- 1) Overall MoM

-- TR: Aylık toplam satış ve MoM (geçen aya göre değişim) metriklerini raporlama amacıyla sunan VIEW.
--     Power BI bu VIEW'i KPI kartları ve trend analizi için kullanır.
--
-- EN: Reporting view providing monthly total sales and MoM (month-over-month) metrics.
--     Power BI uses this view for KPI cards and trend analysis.
CREATE OR REPLACE VIEW v_monthly_sales_mom AS
WITH monthly_sales AS (
    SELECT
        CAST(DATE_FORMAT(o.Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
        SUM(o.Sales) AS total_sales
    FROM retail_analysis.orders o
    WHERE o.Order_Date_Clean IS NOT NULL
    GROUP BY month_start
)
SELECT
    month_start,
    total_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY month_start) AS mom_change,
    ROUND(
      (total_sales - LAG(total_sales) OVER (ORDER BY month_start))
      / NULLIF(LAG(total_sales) OVER (ORDER BY month_start), 0),
      4
    ) AS mom_change_pct
FROM monthly_sales
ORDER BY month_start;


-- 02) KPI (Last Month Only) - Single Row for Card Visuals
CREATE OR REPLACE VIEW v_mom_kpi_last_month AS
SELECT
  month_start,
  mom_change,
  mom_change_pct
FROM v_monthly_sales_mom
WHERE mom_change_pct IS NOT NULL
ORDER BY month_start DESC
LIMIT 1;


-- 03) Region driver

-- TR: Bölge bazında aylık satış ve MoM değişimini raporlama amacıyla sunan VIEW.
--     Power BI bu VIEW ile "düşüş/artış hangi bölgeden geliyor?" sorusunu cevaplar.
--
-- EN: Reporting view providing monthly sales and MoM changes by region.
--     Used to answer "which region drives the increase/decrease?"
CREATE OR REPLACE VIEW v_monthly_sales_region_mom AS
WITH regional_sales AS (
    SELECT
        CAST(DATE_FORMAT(o.Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
        o.Region,
        SUM(o.Sales) AS total_sales
    FROM retail_analysis.orders o
    WHERE o.Order_Date_Clean IS NOT NULL
    GROUP BY month_start, o.Region
)
SELECT
    month_start,
    Region,
    total_sales,
    total_sales - LAG(total_sales) OVER (PARTITION BY Region ORDER BY month_start) AS mom_change
FROM regional_sales
ORDER BY month_start, Region;


-- 04) Segment driver

-- TR: Segment bazında aylık satış ve MoM değişimini raporlama amacıyla sunan VIEW.
--     Power BI bu VIEW ile "değişim hangi müşteri segmentinden geliyor?" sorusunu cevaplar.
--
-- EN: Reporting view providing monthly sales and MoM changes by segment.
--     Used to answer "which customer segment drives the change?"
CREATE OR REPLACE VIEW v_monthly_sales_segment_mom AS
WITH segment_sales AS (
    SELECT
        CAST(DATE_FORMAT(o.Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
        o.Segment,
        SUM(o.Sales) AS total_sales
    FROM retail_analysis.orders o
    WHERE o.Order_Date_Clean IS NOT NULL
    GROUP BY month_start, o.Segment
)
SELECT
    month_start,
    Segment,
    total_sales,
    total_sales - LAG(total_sales) OVER (PARTITION BY Segment ORDER BY month_start) AS mom_change
FROM segment_sales
ORDER BY month_start, Segment;


-- 05) Category driver

-- TR: Kategori bazında aylık satış ve MoM değişimini raporlama amacıyla sunan VIEW.
--     Power BI bu VIEW ile "değişim hangi ürün kategorisinden geliyor?" sorusunu cevaplar.
--
-- EN: Reporting view providing monthly sales and MoM changes by category.
--     Used to answer "which product category drives the change?"
CREATE OR REPLACE VIEW v_monthly_sales_category_mom AS
WITH category_sales AS (
    SELECT
        CAST(DATE_FORMAT(o.Order_Date_Clean, '%Y-%m-01') AS DATE) AS month_start,
        o.Category,
        SUM(o.Sales) AS total_sales
    FROM retail_analysis.orders o
    WHERE o.Order_Date_Clean IS NOT NULL
    GROUP BY month_start, o.Category
)
SELECT
    month_start,
    Category,
    total_sales,
    total_sales - LAG(total_sales) OVER (PARTITION BY Category ORDER BY month_start) AS mom_change
FROM category_sales
ORDER BY month_start, Category;


/* =========================================================
   VALIDATION QUERIES (OPTIONAL)
   ========================================================= */

-- TR: Raporlama katmanındaki VIEW'lerin doğrulama amaçlı örnek sorguları.
-- EN: Sample queries for validating reporting layer views.

SELECT * FROM retail_reporting.v_monthly_sales_mom LIMIT 10;
SELECT * FROM retail_reporting.v_mom_kpi_last_month;
SELECT * FROM retail_reporting.v_monthly_sales_region_mom LIMIT 10;
SELECT * FROM retail_reporting.v_monthly_sales_segment_mom LIMIT 10;
SELECT * FROM retail_reporting.v_monthly_sales_category_mom LIMIT 10;



