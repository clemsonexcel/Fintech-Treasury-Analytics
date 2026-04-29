-- ============================================================
-- PROJECT: TheLook Fintech Loan Portfolio Analysis
-- BY EXCEL
-- PURPOSE: ETL, Data Modeling, and Risk Analytics
-- ============================================================



-- CSV Integration: The query that joined your newly imported state_region table with the loans table.
-- query that loads the location csv into the fintech data 
LOAD DATA OVERWRITE fintech.state_region
(
state_region string,
subregion string,
region string
    )
FROM FILES (
format = 'CSV',
uris = ['gs://sureskills..thelink .../state_region_mapping/state_region_*.csv']);

-- query to get loans and the regions
SELECT lo.loan_id,
        lo.loan_amount,
        sr.region 
FROM fintech.loan lo 
INNER JOIN fintech.state_region sr 
ON lo.state = sr.state;


-- create a table of loans and regions
CREATE OR REPLACE TABLE fintech.loan_with_region AS 
SELECT lo.loan_id,
        lo.loan_amount,
        sr.region 
FROM fintech.loan lo 
INNER JOIN fintech.state_region sr 
ON lo.state = sr.state;


-- Struct Parsing: The query using dot notation to extract purpose from the application_record.
SELECT loan_id, application.purpose
FROM fintech.loan;


-- Deduplication: The SELECT DISTINCT query that created your clean list of loan purposes.
CREATE TABLE fintech.loan_purposes AS
SELECT DISTINCT application.purpose
FROM fintech.loan;


-- Regional Distribution

--   Regional Distribution: A query counting loans and summing amounts by Region and State.

-- query to get the total loan issued each year 
SELECT issue_year, sum(loan_amount) AS total_amount
FROM fintech.loan 
GROUP BY issue_year;


-- Loan Count by Year: Your CREATE TABLE query for historical volume.
-- create table for number of loans issused each year 
CREATE TABLE fintech.loan_count_by_year AS
SELECT issue_year, count(loan_id) AS loan_count 
FROM fintech.loan
GROUP BY issue_year;


-- Metric: Delinquency Rate by Region
-- Purpose: Identify geographic clusters with high default risk to inform future credit policies.

SELECT 
    sr.region,
    COUNT(lo.loan_id) AS total_loans,
    ROUND(COUNTIF(lo.loan_status = 'Default' OR lo.loan_status = 'Late') / COUNT(lo.loan_id) * 100, 2) AS delinquency_rate_percentage
FROM 
    fintech.loan lo
JOIN 
    fintech.state_region sr ON lo.state = sr.state
GROUP BY 1
ORDER BY delinquency_rate_percentage DESC;


-- BORROWER PROFILING
-- Metric: Average Debt-to-Income Ratio (DTI) by Loan Purpose
-- Purpose: Assess if certain loan categories (e.g., Small Business vs. Debt Consolidation) carry higher debt burdens.

SELECT 
    application.purpose,
    ROUND(AVG(loan_amount / annual_income), 4) AS avg_dti_ratio,
    ROUND(MAX(loan_amount / annual_income), 4) AS max_dti_ratio
FROM 
    fintech.loan
GROUP BY 1
ORDER BY avg_dti_ratio DESC;
--What it shows: Are people with lower incomes taking out huge loans?


-- TIME-SERIES ANALYSIS
-- Metric: Month-over-Month Funding Growth
-- Purpose: Track the momentum of capital disbursement to ensure liquidity matches scaling targets.

SELECT 
    FORMAT_DATE('%Y-%m', issue_date) AS month,
    SUM(loan_amount) AS monthly_volume,
    LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) AS previous_month_volume,
    ROUND((SUM(loan_amount) - LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date))) / 
          LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) * 100, 2) AS mom_growth_percentage
FROM fintech.loan
GROUP BY 1
ORDER BY 1;


    LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) AS previous_month_volume,
    ROUND((SUM(loan_amount) - LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date))) / 
          LAG(SUM(loan_amount)) OVER (ORDER BY FORMAT_DATE('%Y-%m', issue_date)) * 100, 2) AS mom_growth_percentage
FROM fintech.loan
GROUP BY 1 -- Add this to group by the month
ORDER BY 1;
