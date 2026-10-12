-- ====================================================================
-- AWS ATHENA SQL ANALYTICAL QUERIES
-- Project: Telecom Customer Churn Prediction and Analytics Solution
-- Dataset: Sri Lankan Telecom Synthetic Dataset (100k records)
-- ====================================================================

-- STEP 1: CREATE EXTERNAL TABLE IN ATHENA
-- Replace 'your-bucket-name' with your actual S3 bucket name.
-- You can point this to your raw or processed dataset location.
CREATE EXTERNAL TABLE IF NOT EXISTS telecom_data (
  customer_id STRING,
  operator STRING,
  contract_type STRING,
  region STRING,
  tenure_days INT,
  signup_date STRING,
  kyc_verified BOOLEAN,
  id_type STRING,
  age_bracket STRING,
  device_type STRING,
  device_brand STRING,
  device_financed BOOLEAN,
  sim_type STRING,
  sim_swap_count INT,
  customer_segment STRING,
  loyalty_tier STRING,
  is_active BOOLEAN,
  plan_name STRING,
  monthly_price_lkr DOUBLE,
  data_allowance_gb DOUBLE,
  voice_allowance_mins INT,
  sms_allowance INT,
  plan_category STRING,
  plan_duration_type STRING,
  bundled_apps STRING,
  subscription_activated_at STRING,
  plan_changes_count INT,
  auto_renew BOOLEAN,
  days_since_last_recharge DOUBLE,
  last_recharge_date STRING,
  last_bill_date STRING,
  recharge_amount_lkr DOUBLE,
  recharge_amount_3mo_avg_lkr DOUBLE,
  recharge_trend STRING,
  bill_amount_lkr DOUBLE,
  payment_method STRING,
  balance_after_lkr DOUBLE,
  overdue_days DOUBLE,
  late_fee_lkr DOUBLE,
  data_used_mb DOUBLE,
  data_used_since_activation_mb DOUBLE,
  primary_network_type STRING,
  voice_minutes_used DOUBLE,
  sms_count INT,
  roaming_flag BOOLEAN,
  has_support_contact_30d BOOLEAN,
  is_complaint BOOLEAN,
  complaint_type STRING,
  complaint_text STRING,
  complaint_resolved BOOLEAN,
  resolution_time_hours DOUBLE,
  satisfaction_score DOUBLE,
  escalated BOOLEAN,
  churned BOOLEAN
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://your-bucket-name/raw/'
TBLPROPERTIES ('skip.header.line.count'='1');


-- ====================================================================
-- QUERY 1: Operator-Level Market Share and Churn Rate Comparison
-- Purpose: Evaluates retention efficiency across Dialog, SLT-Mobitel, and Hutch.
-- ====================================================================
SELECT 
    operator,
    COUNT(*) AS total_subscribers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS market_share_percentage,
    SUM(CASE WHEN churned = TRUE THEN 1 ELSE 0 END) AS total_churned,
    ROUND(SUM(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM telecom_data
GROUP BY operator
ORDER BY total_subscribers DESC;


-- ====================================================================
-- QUERY 2: Impact of Customer Complaints & Resolution Status on Churn
-- Purpose: Quantifies how unresolved complaints spike churn compared to resolved cases.
-- Grounding: Verifies TARP / SQM benchmarks (FCR and resolution impact).
-- ====================================================================
SELECT 
    complaint_type,
    complaint_resolved,
    COUNT(*) AS complaint_count,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours,
    ROUND(SUM(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM telecom_data
WHERE is_complaint = TRUE
GROUP BY complaint_type, complaint_resolved
ORDER BY complaint_type, complaint_resolved DESC;


-- ====================================================================
-- QUERY 3: Prepaid Inactivity & Recharge Trend Churn Risk Analysis
-- Purpose: Validates the SyriaTel finding where recharge gap and declining reloads predict churn.
-- ====================================================================
SELECT 
    recharge_trend,
    CASE 
        WHEN days_since_last_recharge <= 15 THEN '0-15 Days (Active)'
        WHEN days_since_last_recharge <= 30 THEN '16-30 Days (At-Risk)'
        WHEN days_since_last_recharge <= 45 THEN '31-45 Days (Dormant)'
        ELSE '45+ Days (Critical Inactive)'
    END AS recharge_gap_bucket,
    COUNT(*) AS subscriber_count,
    ROUND(AVG(balance_after_lkr), 2) AS avg_balance_lkr,
    ROUND(SUM(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM telecom_data
WHERE contract_type = 'prepaid'
GROUP BY 
    recharge_trend,
    CASE 
        WHEN days_since_last_recharge <= 15 THEN '0-15 Days (Active)'
        WHEN days_since_last_recharge <= 30 THEN '16-30 Days (At-Risk)'
        WHEN days_since_last_recharge <= 45 THEN '31-45 Days (Dormant)'
        ELSE '45+ Days (Critical Inactive)'
    END
ORDER BY recharge_trend, churn_rate_pct DESC;


-- ====================================================================
-- QUERY 4: Postpaid Billing Delinquency vs Churn
-- Purpose: Analyzes how overdue days and late fees impact customer drop-off.
-- ====================================================================
SELECT 
    CASE 
        WHEN overdue_days = 0 THEN '0 Days (On-Time)'
        WHEN overdue_days <= 15 THEN '1-15 Days Overdue'
        WHEN overdue_days <= 30 THEN '16-30 Days Overdue'
        ELSE '30+ Days Overdue (Severe Delinquent)'
    END AS overdue_category,
    COUNT(*) AS postpaid_subscribers,
    ROUND(AVG(bill_amount_lkr), 2) AS avg_monthly_bill,
    ROUND(AVG(late_fee_lkr), 2) AS avg_late_fee,
    ROUND(SUM(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM telecom_data
WHERE contract_type = 'postpaid'
GROUP BY 
    CASE 
        WHEN overdue_days = 0 THEN '0 Days (On-Time)'
        WHEN overdue_days <= 15 THEN '1-15 Days Overdue'
        WHEN overdue_days <= 30 THEN '16-30 Days Overdue'
        ELSE '30+ Days Overdue (Severe Delinquent)'
    END
ORDER BY churn_rate_pct ASC;


-- ====================================================================
-- QUERY 5: Network Technology & Data Usage vs Churn by Customer Segment
-- Purpose: Identifies high-value corporate/business users stuck on older networks (2G/3G) prone to churn.
-- ====================================================================
SELECT 
    customer_segment,
    primary_network_type,
    COUNT(*) AS customer_count,
    ROUND(AVG(data_used_mb) / 1024.0, 2) AS avg_data_used_gb,
    ROUND(SUM(CASE WHEN churned = TRUE THEN 1.0 ELSE 0.0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM telecom_data
GROUP BY customer_segment, primary_network_type
ORDER BY customer_segment, churn_rate_pct DESC;
