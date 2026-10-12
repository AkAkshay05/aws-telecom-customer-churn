# AWS Customer Churn Prediction and Analytics Solution

An end-to-end, cloud-native Data Science and Analytics project hosted on Amazon Web Services (AWS) using a 100,500-record Sri Lankan Telecom dataset (covering Dialog Axiata, SLT-Mobitel, and Hutch).

---

## 🏗 Architecture Overview

The system implements a production-ready, serverless data pipeline and machine learning workflow:
1. **Storage Tier (Amazon S3)**: Structured object storage partitioned into `raw/`, `processed/`, and `outputs/`.
2. **Ingestion & Automated Validation (AWS Lambda & CloudWatch)**: Event-driven trigger validates incoming CSV schema and tags objects as `Validated` without loading the entire payload into RAM.
3. **Data Science & ML (Amazon SageMaker)**: Jupyter Notebook (`ml.t3.medium`) conducting EDA, 4 key visualizations, preprocessing, and training two classification models (Random Forest & Logistic Regression).
4. **Serverless SQL Analytics (Amazon Athena)**: Direct in-place SQL querying across 100,500 subscriber records to evaluate business drivers of churn.
5. **Security & Governance (AWS IAM & Budgets)**: Least-privilege IAM roles and strict Free-Tier cost management.

![Architecture Diagram](screenshots/architecture_diagram.png)

---

## 📂 Repository Contents

- `AWS_Customer_Churn_Technical_Report.docx` - Complete, formatted 6–8 page academic technical report with 24 embedded screenshots and figures.
- `Technical_Report.md` - Markdown edition of the complete technical report.
- `lambda_validator.py` - AWS Lambda validation script triggered on S3 object creation.
- `churn_analysis_sagemaker.ipynb` - SageMaker Jupyter notebook with EDA, visualizations, preprocessing, and ML models.
- `athena_queries.sql` - Table schema DDL and 5 analytical business SQL queries.
- `screenshots/` - Directory containing all 24 AWS console and analysis verification screenshots.

---

## 📊 Key Results

| Metric | Random Forest | Logistic Regression |
|---|---|---|
| Accuracy | **94.06%** | 94.02% |
| Precision (Churn=1) | **100.0% (1.00)** | 0.0% (0.00) |
| Recall (Churn=1) | **0.58% (0.01)** | 0.0% (0.00) |
| F1-Score (Churn=1) | **0.012** | 0.000 |

**Top Empirical Churn Drivers (from Athena & SageMaker):**
1. **Unresolved Customer Complaints**: Unresolved network complaints multiply churn rate to **19.41%** (vs ~5.5% for resolved issues).
2. **Prepaid Recharge Inactivity**: Subscribers with declining reload patterns reaching 45+ days inactive exhibit a **15.36% churn rate**.
3. **Postpaid Late Fee Penalties**: Payment delinquency past 30 days accumulates 708 LKR late fees and accelerates churn to **6.84%**.
