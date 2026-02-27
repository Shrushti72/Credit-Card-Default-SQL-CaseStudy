
## SQL Case Study: Credit Card Default Analysis
SELECT column_name, data_type
FROM `bigquery-public-data.ml_datasets`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'credit_card_default';


-- Dataset: bigquery-public-data.ml_datasets.credit_card_default

SELECT * 
FROM `bigquery-public-data.ml_datasets.credit_card_default`
LIMIT 5;


## SECTION 1: BASIC QUERIES (Q1–Q5)

# 1. Total number of records in the dataset
--  How large is this dataset?
SELECT 
  COUNT(*) AS total_records 
FROM `bigquery-public-data.ml_datasets.credit_card_default`;


# 2. Count of defaulters vs non-defaulters with percentage
--  What is the overall default rate?
SELECT default_payment_next_month,
  COUNT(*) AS count,
  ROUND(COUNT(*)*100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY default_payment_next_month
ORDER BY default_payment_next_month;


# 3.  Distribution of customers by education level
--  What is the education profile of our customers?
SELECT education_level,
  COUNT(*) AS customer_count
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY education_level
ORDER BY customer_count DESC;


# 4. Average credit limit by gender
--  Is there a gender-based difference in credit limits?
SELECT sex,
  ROUND(AVG(limit_balance), 2) AS Credit_Avg_Limit,
  COUNT(*) AS customer_count
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY sex
ORDER BY sex;


# 5. Top 10 customers with highest credit limits
--  Who are our highest-value customers?
SELECT 
  id,
  sex,
  limit_balance,
  education_level,
  age,
  default_payment_next_month
FROM `bigquery-public-data.ml_datasets.credit_card_default`
ORDER BY limit_balance  DESC
LIMIT 10;


##  SECTION 2: INTERMEDIATE QUERIES (Q6–Q10)

# 6. Default rate by education level
--  Does education level affect likelihood of default?
SELECT education_level,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64))*100.0 / COUNT(*), 2) AS default_rate_pct
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY education_level
ORDER BY default_rate_pct DESC;


# 7. Average bill amounts and payment amounts by default status
--  How do spending and repayment patterns differ?
SELECT default_payment_next_month,
  ROUND(AVG(bill_amt_1), 2) AS avg_bill_month1,
  ROUND(AVG(bill_amt_2), 2) AS avg_bill_month2,
  ROUND(AVG(pay_amt_1), 2) AS avg_paid_month1,
  ROUND(AVG(pay_amt_2), 2) AS avg_paid_month2
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY default_payment_next_month
ORDER BY default_payment_next_month;


# 8. Age group segmentation and default rate
--  Which age groups have the highest default risk?
SELECT 
  CASE
    WHEN age<25 THEN 'under 25'
    WHEN age BETWEEN 25 AND 34 THEN '25-34'
    WHEN age BETWEEN 35 AND 44 THEN '35-44'
    WHEN age BETWEEN 45 AND 54 THEN '45-54'
    ELSE '55 and above'
  END AS age_group,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64))*100.0 / COUNT(*), 2) AS default_rate_pct
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY age_group
ORDER BY default_rate_pct DESC;


# 9. Credit limit buckets and default rates
--  Does a higher credit limit mean lower default risk?
SELECT 
  CASE
    WHEN limit_balance < 50000 THEN 'low (<50k)'
    WHEN limit_balance BETWEEN 50000 AND 150000 THEN 'medium (50k-150k)'
    WHEN limit_balance BETWEEN 150001 AND 300000 THEN 'high (150k-300k)'
    ELSE 'vwey high (>300k)'
  END AS credit_limit_band,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64))*100.0 / COUNT(*), 2) AS default_rate_pct
FROM `bigquery-public-data.ml_datasets.credit_card_default`
GROUP BY credit_limit_band
ORDER BY default_rate_pct DESC;


# 10. Customers who consistently delayed payments across 4 months
--  How many customers have a chronic late payment pattern?
SELECT 
  COUNT(*) AS chronic_late_Players,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64))*100.0 / COUNT(*), 2) AS default_rate_pct
FROM `bigquery-public-data.ml_datasets.credit_card_default`
WHERE
  pay_0>=2
  AND pay_2>=2
  AND pay_3>=2
  AND pay_4>=2;



## SECTION 3: ADVANCED QUERIES (Q11–Q15)

# 11. Cumulative bill burden per customer over 6 months
--  What is the total bill load each customer carries?
SELECT 
  id,
  limit_balance,
  default_payment_next_month,
  ROUND(bill_amt_1, 2) AS bill_month1,
  ROUND(bill_amt_1 + bill_amt_2, 2) AS cumulative_m2,
  ROUND(bill_amt_1 + bill_amt_2 + bill_amt_3, 2) AS cumulative_m3,
  ROUND(bill_amt_1 + bill_amt_2 + bill_amt_3 + bill_amt_4 + bill_amt_5 + bill_amt_6, 2) AS total_6month_bill
FROM `bigquery-public-data.ml_datasets.credit_card_default`
ORDER BY total_6month_bill 
LIMIT 20;


# 12. 
-- Q12: RANK customers by credit limit within each education group
--  Who are the top credit holders in each education category?
SELECT 
  id,
  education_level,
  limit_balance,
  default_payment_next_month,
  RANK() OVER (PARTITION BY education_level ORDER BY limit_balance DESC) AS rank_within_education
FROM `bigquery-public-data.ml_datasets.credit_card_default`
QUALIFY 
  RANK() OVER (PARTITION BY education_level ORDER BY limit_balance DESC) <=5
ORDER BY
  education_level, rank_within_education;


# 13. Credit utilization ratio analysis using CTE
--  Do customers with high credit utilization default more?
WITH utilization_cte AS (
  SELECT
    id,
    limit_balance,
    bill_amt_1,
    default_payment_next_month,
    ROUND(SAFE_DIVIDE(bill_amt_1, limit_balance) * 100, 2) AS utilization_pct,
    CASE
      WHEN SAFE_DIVIDE(bill_amt_1, limit_balance) < 0.3 THEN 'Low (<30%)'
      WHEN SAFE_DIVIDE(bill_amt_1, limit_balance) BETWEEN 0.3 AND 0.7 THEN 'Medium (30-70%)'
      ELSE 'High (>70%)'
    END AS utilization_band
  FROM
    `bigquery-public-data.ml_datasets.credit_card_default`
)
SELECT
  utilization_band,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64)) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM
  utilization_cte
GROUP BY
  utilization_band
ORDER BY
  default_rate_pct DESC;


# 14. Payment delay vs Default rate, segmented by gender
--  Does payment delay impact differ between genders?
SELECT
  sex,
  CAST(pay_0 AS INT64) AS payment_status_sep,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64)) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM
  `bigquery-public-data.ml_datasets.credit_card_default`
WHERE
  pay_0 BETWEEN -1 AND 8
GROUP BY
  sex, payment_status_sep
ORDER BY
  sex, payment_status_sep;


# 15. Composite Risk Scoring Model
--  Can we build a rule-based risk tier for each customer?
WITH risk_score_cte AS (
  SELECT
    id,
    limit_balance,
    age,
    education_level,
    sex,
    default_payment_next_month,
    -- Score 1: Recent payment delays (pay_0, pay_2, pay_3 are FLOAT64)
    (CASE WHEN pay_0 >= 2 THEN 2 ELSE 0 END
     + CASE WHEN pay_2 >= 2 THEN 1 ELSE 0 END
     + CASE WHEN pay_3 >= 2 THEN 1 ELSE 0 END) AS payment_delay_score,
    -- Score 2: High credit utilization in latest month
    (CASE WHEN SAFE_DIVIDE(bill_amt_1, limit_balance) > 0.8 THEN 2 ELSE 0 END) AS utilization_score,
    -- Score 3: Very low repayment relative to bill
    (CASE WHEN bill_amt_1 > 0 AND SAFE_DIVIDE(pay_amt_1, bill_amt_1) < 0.1 THEN 2 ELSE 0 END) AS low_repayment_score
  FROM
    `bigquery-public-data.ml_datasets.credit_card_default`
),
scored AS (
  SELECT
    *,
    payment_delay_score + utilization_score + low_repayment_score AS total_risk_score,
    CASE
      WHEN payment_delay_score + utilization_score + low_repayment_score >= 5 THEN 'high Risk'
      WHEN payment_delay_score + utilization_score + low_repayment_score BETWEEN 3 AND 4 THEN 'medium Risk'
      ELSE 'low Risk'
    END AS risk_tier
  FROM
    risk_score_cte
)
SELECT
  risk_tier,
  COUNT(*) AS total_customers,
  SUM(CAST(default_payment_next_month AS INT64)) AS actual_defaulters,
  ROUND(SUM(CAST(default_payment_next_month AS INT64)) * 100.0 / COUNT(*), 2) AS actual_default_rate_pct
FROM
  scored
GROUP BY
  risk_tier
ORDER BY
  actual_default_rate_pct DESC;














