# 📊 SQL Case Study: Credit Card Default Analysis

> **Big 4 DA Portfolio — Project 2**
> Platform: Google BigQuery | Language: SQL | Dataset: Public BigQuery Dataset

---

## 📌 Project Overview

This project is a complete end-to-end SQL case study analyzing **credit card default behavior** using the publicly available UCI Taiwan Credit Card Default dataset hosted on Google BigQuery.

The goal is to uncover patterns that help financial institutions identify **high-risk customers before they default** — a core use case in banking analytics and a frequent topic in Big 4 Data Analyst interviews.

This case study demonstrates SQL proficiency progressing from basic aggregations → intermediate segmentation → advanced window functions and CTE-based risk modeling.

---

## 🎯 Business Objective

> *Can we identify which customers are most likely to default on their credit card payment next month, using historical payment behavior, credit utilization, and demographic data?*

---

## 📁 Dataset Details

| Property | Value |
|---|---|
| **BigQuery Path** | `bigquery-public-data.ml_datasets.credit_card_default` |
| **Origin** | UCI Machine Learning Repository — Taiwan, 2005 |
| **Total Records** | ~30,000 customers |
| **Target Variable** | `default_payment_next_month` (STRING: `'1'` = defaulted, `'0'` = did not default) |

### 🗂️ Column Reference (Verified via INFORMATION_SCHEMA)

| Column | Data Type | Description |
|---|---|---|
| `id` | FLOAT64 | Unique customer ID |
| `limit_balance` | FLOAT64 | Credit limit amount (NT Dollar) |
| `sex` | STRING | Customer gender |
| `education_level` | STRING | Graduate / University / High School / Others |
| `marital_status` | STRING | Married / Single / Others |
| `age` | FLOAT64 | Age in years |
| `pay_0` | FLOAT64 | Repayment status — September (latest) |
| `pay_2` | FLOAT64 | Repayment status — August |
| `pay_3` | FLOAT64 | Repayment status — July |
| `pay_4` | FLOAT64 | Repayment status — June |
| `pay_5` | STRING | Repayment status — May |
| `pay_6` | STRING | Repayment status — April |
| `bill_amt_1` | FLOAT64 | Bill statement — September |
| `bill_amt_2` | FLOAT64 | Bill statement — August |
| `bill_amt_3` | FLOAT64 | Bill statement — July |
| `bill_amt_4` | FLOAT64 | Bill statement — June |
| `bill_amt_5` | FLOAT64 | Bill statement — May |
| `bill_amt_6` | FLOAT64 | Bill statement — April |
| `pay_amt_1` | FLOAT64 | Amount paid — September |
| `pay_amt_2` | FLOAT64 | Amount paid — August |
| `pay_amt_3` | FLOAT64 | Amount paid — July |
| `pay_amt_4` | FLOAT64 | Amount paid — June |
| `pay_amt_5` | FLOAT64 | Amount paid — May |
| `pay_amt_6` | FLOAT64 | Amount paid — April |
| `default_payment_next_month` | STRING | **Target**: `'1'` = Default, `'0'` = No Default |

> **Pay status values:** `-1` = paid on time, `1` = 1 month delay, `2` = 2 months delay, and so on.

---

## 🛠️ BigQuery Setup Instructions

### Step 1: Open Google BigQuery
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your Google account
3. Create a new project (e.g., `credit-default-analysis`)
4. From the left menu, open **BigQuery**

### Step 2: Access the Public Dataset
1. In the BigQuery Explorer panel, click **"+ ADD DATA"**
2. Select **"Star a project by name"**
3. Type: `bigquery-public-data` and click **Star**
4. Navigate to: `bigquery-public-data` → `ml_datasets` → `credit_card_default`

### Step 3: Verify Columns (Optional but Recommended)
```sql
SELECT column_name, data_type
FROM `bigquery-public-data.ml_datasets`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'credit_card_default';
```

### Step 4: Run the Queries
1. Open a new **SQL Editor** tab in BigQuery
2. Copy any query from `all_15_queries.sql`
3. Paste and click **Run**

> 💡 **Free Tier:** Google BigQuery provides **1 TB free processing per month**. This entire case study uses well under that limit — runs completely free.

---

## 📋 Query Index

### 🟢 Basic Queries — Q1 to Q5
*Concepts: COUNT, AVG, SUM, GROUP BY, ORDER BY, LIMIT*

| # | Title | Business Question |
|---|---|---|
| Q1 | Total Record Count | How large is this dataset? |
| Q2 | Default vs Non-Default Distribution | What is the overall default rate? |
| Q3 | Customers by Education Level | What is the education profile of customers? |
| Q4 | Average Credit Limit by Gender | Is there a gender-based credit gap? |
| Q5 | Top 10 Customers by Credit Limit | Who are our highest-value customers? |

---

### 🟡 Intermediate Queries — Q6 to Q10
*Concepts: CASE WHEN, bucketing, filtering, multi-column aggregation*

| # | Title | Business Question |
|---|---|---|
| Q6 | Default Rate by Education Level | Does education affect default risk? |
| Q7 | Avg Bill & Payment by Default Status | How do defaulters spend vs repay? |
| Q8 | Age Group Segmentation + Default Rate | Which age groups are riskiest? |
| Q9 | Credit Limit Bands + Default Rate | Does higher credit limit mean lower risk? |
| Q10 | Chronic Late Payers Identification | How many customers have repeated late payments? |

---

### 🔴 Advanced Queries — Q11 to Q15
*Concepts: CTEs, Window Functions, RANK(), QUALIFY, SAFE_DIVIDE, Risk Modeling*

| # | Title | Business Question |
|---|---|---|
| Q11 | Cumulative 6-Month Bill Burden | What is the total bill load per customer? |
| Q12 | RANK() Within Education Group | Who are the top credit holders per education category? |
| Q13 | Credit Utilization Ratio Analysis (CTE) | Does high utilization predict default? |
| Q14 | Payment Delay × Gender Cohort | Does payment delay impact differ by gender? |
| Q15 | Composite Risk Scoring Model | Can we build a rule-based risk tier for each customer? |

---

## 🔍 Key Findings

- Roughly **22% of customers defaulted** in the following month
- Customers with **2+ months of payment delay** had dramatically higher default rates
- **Low credit limit holders** defaulted more frequently than high limit holders
- **High credit utilization (>70%)** was strongly associated with default risk
- The **composite risk scoring model (Q15)** successfully stratified customers into High / Medium / Low risk tiers with meaningfully different actual default rates — validating the rule-based approach

---

## 💡 SQL Concepts Demonstrated

| Concept | Queries Used In |
|---|---|
| `COUNT`, `AVG`, `SUM`, `ROUND` | Q1 – Q5 |
| `GROUP BY`, `ORDER BY` | Q2 – Q9 |
| `CASE WHEN` bucketing | Q8, Q9, Q13, Q15 |
| `CAST(STRING AS INT64)` | Q6, Q7, Q8, Q9, Q10, Q13, Q14, Q15 |
| `SAFE_DIVIDE()` — BigQuery native | Q13, Q15 |
| Common Table Expressions (`WITH`) | Q13, Q15 |
| Window Function — `RANK() OVER (PARTITION BY ... ORDER BY ...)` | Q12 |
| `QUALIFY` clause — BigQuery native | Q12 |
| Composite feature engineering / scoring | Q15 |
| `INFORMATION_SCHEMA` for schema inspection | Setup step |

---


## 👤 Author

**Shrushti Wakchaure**
Aspiring Big 4 Data Analyst | Python • SQL • Power BI

---

## 📜 License

This project uses a publicly available dataset from Google BigQuery Public Data.
All SQL queries are original work created for portfolio and learning purposes.
