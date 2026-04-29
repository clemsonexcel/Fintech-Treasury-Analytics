# Automating Loan Health Monitoring on GCP

Loan Portfolio & Treasury Performance for TheLook Fintech.

- The Problem: TheLook Fintech needed a scalable way to track loan health and treasury growth to support their rapid scaling initiative.
- The Solution: Developed a cloud-based end-to-end pipeline using **BigQuery** for data engineering and **Looker Enterprise** for self-service business intelligence.

## The Technical Stack
- Data Warehouse: Google BigQuery (SQL)
- BI & Visualization: Looker Enterprise
- Cloud Infrastructure: Google Cloud Platform (GCP)
- Methodology: ETL (Extract, Transform, Load), Schema Design, Data Modeling, and Stakeholder Reporting.

# The Data Journey

## Phase 1: Data Engineering & Warehousing (Big Query)

The Treasury department required a centralized data warehouse to monitor three critical pillars: Cash Flow Predictability, Risk Diversification, and Borrower Intent. I transformed raw, disconnected data into an analysis-ready environment through the following steps:

- **Cloud Data Ingestion (Geographic Risk):** Imported regional classification data from GCP Cloud Storage via CSV. By joining this with the core loans table, I created a unified view that maps every dollar issued to a specific region, allowing Treasury to prevent regional over-reliance.

- **Data Enrichment & Modeling (Growth & Cash Flow):** Used CTEs and JOINs to merge customer profiles with loan records. I materialized these into a `loan_with_region` table and developed foundational aggregations (e.g., `loan_count_by_year`) to provide the historical context needed for cash flow forecasting.

- **Parsing Complex Structures (Borrower Intent):** Utilized dot notation to navigate BigQuery Records (Structs), extracting nested data from the application_record column to isolate the specific purpose of each loan. This transformed semi-structured metadata into a clean, queryable field for analyzing borrower motivations.

- **Data Integrity & Deduplication:** Cleaned the extracted metadata to create a "Golden Record" of unique loan purposes. This standardized the categories, enabling accurate reporting on whether inventory, expansion, or other factors drive borrowing.


_SQL Snippets_
1. Annual Funding Velocity
   
_Calculates total funded capital by year to track historical cash flow and liquidity trends._
```SQL
SELECT 
    EXTRACT(YEAR FROM issue_date) AS funding_year,
    COUNT(loan_id) AS total_loans_issued,
    SUM(loan_amount) AS total_capital_funded
FROM 
    fintech.loan
GROUP BY 1
ORDER BY 1 DESC;
```

2. Table Materialization: Annual Loan Volume
   
_Groups loan counts by year to build the foundation for time-series trend analysis._
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

4. **Data Activation & Automation:**  Implemented Auto-Refresh logic tailored to the data velocity.
    - Low-Latency Monitoring: Set the Capital KPI to refresh hourly for immediate visibility into liquidity changes.
    - Trend Alignment: Set the Customer & State tables to refresh daily to optimize compute resources while maintaining up-to-date reporting.

5. **UI/UX Design:** Applied a cohesive color palette and arranged the layout for a "logical read," ensuring the most critical risk metrics are positioned at the top of the dashboard for immediate stakeholder impact.


### Strategic Impact (The "Results")
The "Loan Insights" dashboard successfully addressed four critical business inquiries:

- **Liquidity:** Quantified the total outstanding exposure in real-time.
- **Health:** Visualized the percentage of "Healthy" vs. "At-Risk" loan statuses.
- **Geography:** Ranked states by loan volume to manage regional economic exposure.
- **Targeting:** Identified the highest-income homeowners to assess the quality of the collateralized portfolio.


![image](images/dashboard-screenshot.jpeg)
_Loan Insights Dashboard. Note the red conditional formatting on the 'Total Outstanding' metric, triggered by the $3M risk threshold._

## Future Considerations
- Predictive Risk Modeling: Implement a Logistic Regression model to classify the probability of loan default based on debt-to-income ratios and employment history. 

- Customer Segmentation (RFM): Transition from general portfolio monitoring to a behavioral analysis framework (Recency, Frequency, Monetary) to identify high-value borrowers and at-risk segments.

- Automated Anomaly Detection: Configure Looker Alerts using standard deviation thresholds to automatically notify stakeholders of unusual spikes in loan applications or sudden drops in repayment volume. 
