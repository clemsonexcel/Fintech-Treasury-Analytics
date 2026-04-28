# Automating Loan Health Monitoring on GCP

Loan Portfolio & Treasury Performance for TheLook Fintech.

The Problem: TheLook Fintech needed a scalable way to track loan health and treasury growth to support their rapid scaling initiative.

The Solution: Developed a cloud-based end-to-end pipeline using BigQuery for data engineering and Looker Enterprose for self-service business intelligence.


## The Tehnical Stack
- Data Warehouse: Google BigQuery (SQL)
- BI & Visualization: Looker Enterprise
- Cloud Infrastructure: Google Cloud Platform (GCP)
- Methodology: ETL (Extract, Transform, Load), Data Modeling, and Stakeholder Reporting.


# The Data Journey

## Phase 1: Data Engineering & Warehousing (Big Query)

The Treasury department required a centralized data warehouse to monitor three critical pillars of their scaling strategy:

1. **Cash Flow Predictability:** Monitoring monthly and annual loan funding volumes.
2. **Risk Diversification:** Tracking geographic loan distribution to avoid regional over-reliance.
3. **Borrower Intent:** Identifying the primary reasons for loan applications to predict repayment health.

### Key Technical Tasks
I transformed raw, disconnected data into an analysis-ready environment through the following steps:

- **Cloud Data Ingestion:** Scaled the dataset by importing regional classification data from GCP Cloud Storage via CSV, enabling location-based analytics.

- **Data Enrichment & Modeling:** Used CTEs and JOINs to merge customer profiles with loan records and the new regional data, materializing a unified loan_region table, enabling risk-concentration analysis by territory.

- **Parsing Complex Structures:** Navigated BigQuery Records (Structs) using dot notation to extract granular data from the application_record column.

- **Data Integrity & Deduplication:** Cleaned the extracted metadata to create a "Golden Record" of unique loan purposes, ensuring reporting in the BI layer would be accurate and free of noise.

- **Time-Series Aggregation:** Developed foundational queries to group loan counts by issue_year, providing the historical context needed for cash flow forecasting.

_SQL Snippets_

- The "Impact" Query: Annual Funding Velocity. This query goes beyond the basic count to show the actual capital (Cash Flow) moving out of the business.

```SQL
SELECT 
    EXTRACT(YEAR FROM issue_date) AS funding_year,
    COUNT(loan_id) AS total_loans_issued,
    ROUND(SUM(loan_amount), 2) AS total_capital_funded
FROM 
    `thelook_fintech.loans`
GROUP BY 1
ORDER BY 1 DESC;
```

- Query to count loans issued each year
```SQL
CREATE TABLE fintech.loan_count_by_year AS
SELECT issue_year, count(loan_id) AS loan_count
FROM fintech.loan
GROUP BY issue_year;
```

## Phase 2: Analytics & Activation (Looker)

The objective here was to translate the warehouse data into a High-Fidelity Executive Dashboard (Loan Insights) that allows the Treasury team to proactively monitor portfolio health and trigger intervention when risk thresholds are crossed.

### Key Technical Tasks (The "How")
1. **Dynamic Performance Monitoring:** Engineered a "Single Value" KPI to track the total outstanding loan balance. Implemented Conditional Formatting to trigger a red visual alert if the volume exceeded $3.0M, providing an instant visual cue for capital ceiling risks.

2. **Portfolio Distribution Analysis:**

  - **Status Composition:** Created a Pie Chart visualization to analyze the percentage of loans by status, enabling the team to see the ratio of active vs. delinquent accounts at a glance.

  - **Geographic Density:** Developed a Horizontal Bar Chart to rank outstanding loan counts by state, identifying high-concentration areas where the company might be over-leveraged.

3. **High-Value Client Segmentation:** Structured a "Top 10" data table focusing on customer liquidity (Annual Income) and debt cost (Interest Rates) to monitor the profiles of the company's most significant borrowers.

4. **Data Activation & Automation:**  Implemented Auto-Refresh logic tailored to the data's "velocity."
    - Set the Capital KPI to refresh hourly for real-time liquidity monitoring.
    - Set the Customer & State tables to refresh daily for long-term trend alignment.

5. **UI/UX Design:** Applied a cohesive color palette and arranged the layout for a "logical read," ensuring the most critical risk metrics are positioned at the top of the dashboard for immediate stakeholder impact.

### Strategic Impact (The "Results")
The "Loan Insights" dashboard successfully addressed four critical business inquiries:

- **Liquidity:** Quantified the total outstanding exposure in real-time.
- **Health:** Visualized the percentage of "Healthy" vs. "At-Risk" loan statuses.
- **Geography:** Ranked states by loan volume to manage regional economic exposure.
- **Targeting:** Identified the highest-income homeowners to assess the quality of the collateralized portfolio.


![image](images/dashboard-screenshot.png)
_Figure 1: Loan Insights Dashboard. Note the red conditional formatting on the 'Total Outstanding' metric, triggered by the $3M risk threshold._

## Future Considerations
- Implement a Linear Regression model to predict future loan defaults based on the annual_income and loan_amount
