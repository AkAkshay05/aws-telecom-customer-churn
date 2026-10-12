# Group Demonstration Video: Complete Script & Step-by-Step Recording Guide

**Project**: AWS-Based Customer Churn Prediction and Analytics Solution  
**Target Duration**: 4–6 Minutes  
**Recommended Recording Tool**: OBS Studio, Loom, or Windows Game Bar (`Win + Alt + R`)

---

## 🎬 Video Overview & Timing Structure

| Segment | Duration | Screen to Show | Speaker / Focus |
|---|---|---|---|
| **Part 1: Introduction & Architecture** | 0:00 – 1:00 | Architecture Diagram (`architecture_diagram.png`) | Problem context & AWS services chosen |
| **Part 2: Storage & Ingestion (S3)** | 1:00 – 1:45 | AWS S3 Console | Bucket structure (`raw`, `processed`, `outputs`) & Object Tagging |
| **Part 3: Automation (Lambda & CloudWatch)** | 1:45 – 2:30 | AWS Lambda & CloudWatch Console | Event trigger, code overview & live execution logs |
| **Part 4: Data Science & ML (SageMaker)** | 2:30 – 3:45 | JupyterLab in SageMaker | EDA visualizations, Model evaluation (RF vs LR), & Feature Importance |
| **Part 5: SQL Analytics (Athena)** | 3:45 – 4:45 | Amazon Athena Query Editor | Running queries (e.g. Query 2 on complaints & Query 3 on recharge dormancy) |
| **Part 6: Business Recommendations & Wrap-Up** | 4:45 – 5:30 | Technical Report / Slides | 3 Actionable Recommendations & Cost/Security Summary |

---

## 📝 Spoken Script (Word-for-Word Guide)

### Part 1: Project Overview & Architecture (1:00 min)
> **What to show on screen**: Open `architecture_diagram.png` in full screen.
> 
> **What to say**:
> "Hello everyone. Welcome to our group demonstration of our AWS-based Customer Churn Prediction and Analytics Solution. 
> 
> In competitive telecommunications markets like Sri Lanka—with operators such as Dialog Axiata, SLT-Mobitel, and Hutch—over 80% of users are on prepaid plans, and switching costs are practically zero. Retaining existing subscribers is 5 to 7 times cheaper than acquiring new ones.
> 
> To solve this, our group engineered a serverless, end-to-end cloud pipeline on AWS. As you can see from our architecture diagram:
> - **Amazon S3** acts as our central tiered data lake.
> - **AWS Lambda** and **CloudWatch** automate ingestion and schema validation.
> - **Amazon SageMaker** handles exploratory data analysis and trains our machine learning models.
> - **Amazon Athena** executes serverless analytical queries over 100,000 customer records.
> 
> Let's look at the live implementation on AWS."

---

### Part 2: Cloud Storage Organization in Amazon S3 (0:45 min)
> **What to show on screen**: Switch to your browser tab showing the **Amazon S3 Console** for `telecom-churn-project`.
> 
> **What to say**:
> "Here in the Amazon S3 console, you can see our private bucket: `telecom-churn-project`, with public access completely blocked for security.
> 
> We organized our storage into three distinct prefixes:
> 1. `raw/`: Stores the original ingested customer dataset of 100,500 rows.
> 2. `processed/`: Contains the sanitized and feature-engineered dataset output by our machine learning pipeline.
> 3. `outputs/`: Holds Athena SQL query results and model evaluation artifacts.
> 
> Notice that when a file is uploaded to `raw/`, our automated pipeline tags it with `Status: Validated`, confirming it passed integrity checks."

---

### Part 3: Automated Ingestion & Validation (Lambda & CloudWatch) (0:45 min)
> **What to show on screen**: Switch to the **AWS Lambda Console** (`ValidateTelecomData`), then open **CloudWatch Logs**.
> 
> **What to say**:
> "To guarantee data quality before downstream processing, we deployed an event-driven AWS Lambda function called `ValidateTelecomData`.
> 
> Whenever a new CSV lands in the `raw/` folder, S3 automatically triggers this Lambda function. Rather than loading the entire 30 megabyte file into memory—which saves cost and compute—Lambda streams only the header block, validating all mandatory schema columns like `customer_id`, `operator`, `contract_type`, and `churned`.
> 
> Looking at our Amazon CloudWatch logs, we can observe the execution trace: the schema was verified in just under 120 milliseconds, the tag was applied, and zero errors were reported."

---

### Part 4: Data Science & Machine Learning in Amazon SageMaker (1:15 min)
> **What to show on screen**: Switch to **JupyterLab** or scroll through your executed notebook (`churn_analysis_sagemaker.ipynb`).
> 
> **What to say**:
> "Next, in Amazon SageMaker, we conducted our exploratory data analysis, data transformations, and machine learning modeling.
> 
> First, our EDA uncovered deliberate structural missingness that mirrors real telecom systems—such as recharge fields populated only for prepaid, and billing fields populated only for postpaid accounts.
> 
> We produced four key visualizations:
> 1. Target churn distribution confirming a realistic baseline churn rate of 5.98%.
> 2. Operator-level distributions across Dialog, Mobitel, and Hutch.
> 3. Contract type comparisons showing higher churn velocity in prepaid.
> 4. And a kernel density plot of Days Since Last Recharge, clearly illustrating a critical divergence after 30 to 45 days.
> 
> For modeling, we trained and evaluated two algorithms:
> - **Random Forest Classifier**: achieved **94.06% accuracy** and **100% precision** on churn predictions.
> - **Logistic Regression**: achieved 94.02% accuracy, but failed to capture the non-linear interaction terms of the minority churn class.
> 
> Our Random Forest feature importance ranked customer tenure, drop in usage velocity, low balance, and long recharge gaps as the top drivers of churn."

---

### Part 5: Serverless SQL Analytics with Amazon Athena (1:00 min)
> **What to show on screen**: Switch to the **Amazon Athena Query Editor** tab with your queries.
> 
> **What to say**:
> "Now moving to our analytics layer, we used Amazon Athena to query our dataset directly in S3 using serverless SQL.
> 
> Here is **Query 2**, examining customer complaints:
> Notice that for resolved complaints, churn remains around 5 to 6%. However, when complaints are unresolved and exceed 70 hours, churn spikes dramatically to **16% to 19.4%**—especially for network speed issues.
> 
> And in **Query 3**, analyzing recharge trends:
> Customers with declining reload patterns who reach 45+ days inactive exhibit a **15.36% churn rate**, compared to under 5% for active reloaders.
> 
> All query outputs are automatically saved back to our S3 `outputs/` folder with zero database infrastructure overhead."

---

### Part 6: Business Recommendations & Conclusion (0:45 min)
> **What to show on screen**: Show the **Technical Report** or GitHub repo README.
> 
> **What to say**:
> "Based on our machine learning and Athena analytics, we delivered three strategic business recommendations:
> 1. **Automated Pre-Dormancy Nudges**: Trigger automated SMS incentives at Day 20 of inactivity before subscribers hit the critical 45-day dormancy threshold.
> 2. **24-Hour Complaint SLA Escalation**: Automatically escalate open network and billing tickets at 24 hours to prevent the 3.5x churn spike seen in unresolved complaints.
> 3. **4G/5G Network Migration Incentives**: Provide free eSIM activation and device subsidies for legacy 2G/3G users who experience data performance bottlenecks.
> 
> In conclusion, our solution demonstrates a secure, cost-effective, and production-ready cloud architecture on AWS that turns raw telecom data into actionable retention strategies. Thank you!"

---

## 🛠 Pro Tips for Recording

1. **Browser Preparation**: Open your tabs in order beforehand:
   - Tab 1: Architecture Diagram image
   - Tab 2: S3 bucket (`telecom-churn-project`)
   - Tab 3: Lambda & CloudWatch Logs
   - Tab 4: SageMaker Notebook (already run with charts visible)
   - Tab 5: Athena Query Editor (showing Query 2 and 3 results)
   - Tab 6: GitHub Repository ([AkAkshay05/aws-telecom-customer-churn](https://github.com/AkAkshay05/aws-telecom-customer-churn))
2. **Smooth Transitions**: Use `Ctrl + Tab` to smoothly switch between tabs while talking.
3. **If Group Members Share Speaking**:
   - Member 1: Intro & Architecture (Part 1)
   - Member 2: S3 & Lambda Validation (Parts 2 & 3)
   - Member 3: SageMaker EDA & ML Models (Part 4)
   - Member 4: Athena SQL Analytics & Recommendations (Parts 5 & 6)
