# Retail Sales Analysis (SQL + Power BI)

End-to-end sales analysis project using SQL for data preparation and reporting,
and Power BI for executive-level dashboards.

---

## Project Workflow
1. Raw retail sales data cleaned and standardized using SQL
2. Monthly and KPI-focused reporting views created
3. Views consumed in Power BI to build two analytical dashboards

---

## Power BI Dashboards

### 1️⃣ Sales Performance Overview
This dashboard provides a high-level view of overall sales performance over time,
focusing on monthly trends and key KPIs.

**Key Insights:**
- Sales show noticeable volatility across months, indicating seasonal or campaign-driven effects.
- The latest month experienced a significant negative month-over-month change (**-35.27%**),
  despite a positive long-term upward trend.
- Peak monthly sales occurred toward the end of the year, suggesting stronger Q4 performance.
- Month-over-month changes highlight sharp increases and drops, emphasizing the importance of
  monitoring short-term sales dynamics.

**Included Visuals:**
- Monthly sales trend
- Month-over-month sales change
- KPI cards for latest month sales and MoM %

---

### 2️⃣ Sales Breakdown Overview
This dashboard analyzes the distribution of sales for the **top-performing month**.

**Key Insights:**
- **November** stands out as the highest-performing month with approximately **$88K** in total sales.
- The **East region** leads regional performance, contributing the largest share of sales.
- **Technology** is the top-performing product category, followed by Furniture and Office Supplies.
- The **Consumer segment** accounts for over half of total sales, making it the primary revenue driver.

**Included Visuals:**
- Sales by region (top-performing month)
- Sales by category (top-performing month)
- Sales by segment distribution

> All visuals represent the distribution of total sales for the month with the highest overall performance.

---

## Data Source
- Dataset: Retail Sales Dataset (2015–2018)
- Source: Kaggle
- The dataset is included in this repository and used as the input for SQL-based analysis.

---

## Repository Structure
- `data/` – raw retail sales dataset  
- `sql/` – SQL scripts for data cleaning and reporting views  
- `powerbi/` – Power BI dashboard screenshots  
