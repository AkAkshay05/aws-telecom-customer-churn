# AWS Cloud Architecture Diagram

```mermaid
flowchart TD
    subgraph Data_Ingestion_and_Storage["1. Storage & Ingestion Layer (Amazon S3)"]
        UserUpload["Telecom Operator / User"] -->|Uploads Raw CSV| S3Raw["s3://telecom-churn-project/raw/<br>lk_telecom_synthetic_100k.csv"]
        S3Processed["s3://telecom-churn-project/processed/<br>cleaned_telecom_data.csv"]
        S3Outputs["s3://telecom-churn-project/outputs/<br>Athena Results & ML Artifacts"]
    end

    subgraph Automation_and_Monitoring["2. Automated Validation & Monitoring Layer"]
        S3Raw -->|S3 Event Notification: ObjectCreated| Lambda["AWS Lambda<br>(ValidateTelecomData)"]
        Lambda -->|Validates Schema & Tags File| S3Raw
        Lambda -->|Streams Execution & Audit Logs| CloudWatch["Amazon CloudWatch Logs"]
    end

    subgraph Data_Science_and_ML["3. Data Science & Machine Learning Layer"]
        SageMaker["Amazon SageMaker Notebook<br>(ml.t3.medium)"]
        S3Raw -->|Loads Raw Data for EDA| SageMaker
        SageMaker -->|Data Cleaning, Preprocessing & Feature Engineering| SageMaker
        SageMaker -->|Model 1: Random Forest<br>Model 2: Logistic Regression| SageMaker
        SageMaker -->|Writes Cleaned Dataset| S3Processed
    end

    subgraph Cloud_Analytics["4. Serverless Cloud Analytics Layer"]
        Athena["Amazon Athena<br>(Serverless SQL Query Engine)"]
        Athena -->|External Table Queries| S3Raw
        Athena -->|Stores Query Results| S3Outputs
        BusinessUser["Data Analyst / Business Stakeholder"] -->|Executes Analytical Queries| Athena
    end

    subgraph Governance_and_Security["5. Security & Cost Optimization Layer"]
        IAM["AWS IAM (Roles & Policies)<br>Principle of Least Privilege"] -.-> Lambda
        IAM -.-> SageMaker
        IAM -.-> Athena
        CostMgmt["AWS Cost Explorer & Budgets<br>Free Tier Monitoring"] -.-> Data_Ingestion_and_Storage
        CostMgmt -.-> Data_Science_and_ML
    end

    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff;
    classDef storage fill:#3F8624,stroke:#232F3E,stroke-width:2px,color:#fff;
    classDef compute fill:#D05C17,stroke:#232F3E,stroke-width:2px,color:#fff;
    classDef analytics fill:#8C4FFF,stroke:#232F3E,stroke-width:2px,color:#fff;

    class S3Raw,S3Processed,S3Outputs storage;
    class Lambda,SageMaker compute;
    class Athena analytics;
    class CloudWatch,IAM,CostMgmt aws;
```

---

## Architecture Flow Summary

1. **Ingestion & Validation**:
   - Customer dataset is ingested into `s3://telecom-churn-project/raw/`.
   - S3 triggers an asynchronous **AWS Lambda** function.
   - The Lambda function validates schema integrity without loading the entire 100k-row payload into memory, logging errors/success to **Amazon CloudWatch** and tagging the object with `Status=Validated`.

2. **Data Science & ML Pipeline**:
   - **Amazon SageMaker** pulls the validated data.
   - Exploratory Data Analysis (EDA) and data transformations are executed.
   - Two ML classification models (**Random Forest** and **Logistic Regression**) are trained, evaluated, and compared on classification metrics (Accuracy, Precision, Recall, F1).
   - Cleaned, normalized data is written back to `s3://telecom-churn-project/processed/`.

3. **Serverless Analytical SQL**:
   - **Amazon Athena** connects to the dataset using AWS Glue / external schema.
   - 5 business-critical SQL queries evaluate churn drivers: complaint resolution times, recharge inactivity gaps, overdue billing patterns, and operator market shares.
   - Query outputs are persisted in `s3://telecom-churn-project/outputs/`.

4. **Security & Cost Governance**:
   - **AWS IAM** strictly controls access across S3, Lambda, and SageMaker.
   - Zero-cost / Free Tier architectural boundaries are enforced: serverless compute (Lambda, Athena) and on-demand ML notebook lifecycle management.
