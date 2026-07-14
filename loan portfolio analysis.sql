-- ============================================================
-- PROJECT: TheLook Fintech Loan Portfolio Analysis
-- BY EXCEL
-- PURPOSE: ETL, Data Modeling, and Risk Analytics
-- ============================================================



-- ============================================================
-- PHASE 1: DATA INGESTION & MODELING
-- ============================================================

-- Metric: Regional Classification Import
-- Purpose: Load state-to-region mapping data from Cloud Storage to enable
-- geographic risk analysis across the loan portfolio.
LOAD DATA OVERWRITE fintech.state_region
(
    state_region STRING,
    subregion STRING,
    region STRING
)
FROM FILES (
    format = 'CSV',
    uris = ['gs://[thelink]/state_region_mapping/state_region_*.csv']
);



-- Metric: Loans Joined to Region
-- Purpose: Map every loan to its geographic region for risk diversification analysis.
SELECT
    lo.loan_id,
    lo.loan_amount,
    sr.region
FROM fintech.loan lo
INNER JOIN fintech.state_region sr
    ON lo.state = sr.state;



-- Metric: Materialized Loan-Region Table
-- Purpose: Persist the loan-region mapping as a table for downstream reporting
-- and to avoid re-joining on every query.
CREATE OR REPLACE TABLE fintech.loan_with_region AS
SELECT
    lo.loan_id,
    lo.loan_amount,
    sr.region
FROM fintech.loan lo
INNER JOIN fintech.state_region sr
    ON lo.state = sr.state;



-- Metric: Loan Purpose Extraction
-- Purpose: Parse the nested application_record struct to isolate stated
-- borrower intent for each loan.
SELECT
    loan_id,
    application.purpose
FROM fintech.loan;


-- Metric: Deduplicated Loan Purposes
-- Purpose: Build a clean "golden record" of unique loan purpose categories
-- for accurate reporting on borrower motivations.
CREATE TABLE fintech.loan_purposes AS
SELECT DISTINCT application.purpose
FROM fintech.loan;



-- ============================================================
-- PHASE 2: PORTFOLIO & RISK ANALYTICS
-- ============================================================

-- Metric: Annual Funding Volume
-- Purpose: Track total capital funded per year to establish historical
-- cash flow and liquidity trends.
SELECT
    issue_year,
    SUM(loan_amount) AS total_amount
FROM fintech.loan
GROUP BY issue_year;


-- Metric: Annual Loan Volume (Materialized)
-- Purpose: Store yearly loan counts as a table to support time-series
-- trend analysis in the Looker dashboard.
CREATE TABLE fintech.loan_count_by_year AS
SELECT
    issue_year,
    COUNT(loan_id) AS loan_count
FROM fintech.loan
GROUP BY issue_year;


-- Metric: Delinquency Rate by Region
-- Purpose: Identify geographic clusters with high default risk to inform
-- future credit policies.
SELECT
    sr.region,
    COUNT(lo.loan_id) AS total_loans,
    ROUND(
        COUNTIF(lo.loan_status IN ('Default', 'Late')) / COUNT(lo.loan_id) * 100, 2) AS delinquency_rate_percentage
FROM fintech.loan lo
JOIN fintech.state_region sr
    ON lo.state = sr.state
GROUP BY 1
ORDER BY delinquency_rate_percentage DESC;


-- Metric: Average Debt-to-Income Ratio (DTI) by Loan Purpose
-- Purpose: Assess whether certain loan categories (e.g. Small Business vs.
-- Debt Consolidation) carry higher debt burdens relative to borrower income.
SELECT
    application.purpose,
    ROUND(AVG(loan_amount / annual_income), 4) AS avg_dti_ratio,
    ROUND(MAX(loan_amount / annual_income), 4) AS max_dti_ratio
FROM fintech.loan
GROUP BY 1
ORDER BY avg_dti_ratio DESC;


-- Metric: Month-over-Month Funding Growth
-- Purpose: Track the momentum of capital disbursement to ensure liquidity
-- supply keeps pace with scaling targets.
SELECT
    FORMAT_DATE('%Y-%m', issue_date) AS month,
    SUM(loan_amount) AS monthly_volume,
    LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) AS previous_month_volume,
    ROUND(
        (SUM(loan_amount) - LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)))
        / LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) * 100,
        2
    ) AS mom_growth_percentage
FROM fintech.loan
GROUP BY 1
ORDER BY 1;

