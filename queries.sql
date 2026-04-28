-- Annual funding volume
-- he "Impact" Query: Annual Funding Velocity. This query goes beyond the basic count to show the actual capital (Cash Flow) moving out of the business.

SELECT 
    EXTRACT(YEAR FROM issue_date) AS funding_year,
    COUNT(loan_id) AS total_loans_issued,
    ROUND(SUM(loan_amount), 2) AS total_capital_funded
FROM 
    `thelook_fintech.loans`
GROUP BY 1
ORDER BY 1 DESC;



-- number of loans issued each year
CREATE TABLE fintech.loan_count_by_year AS
SELECT issue_year, count(loan_id) AS loan_count
FROM fintech.loan
GROUP BY issue_year;
   
-- ============================================================
-- PROJECT: TheLook Fintech Loan Portfolio Analysis
-- BY EXCEL 
-- PURPOSE: ETL, Data Modeling, and Risk Analytics
-- ============================================================

-- DATA ENGINEERING & CLEANING
-- Extracting nested purpose data and deduplicating
CREATE OR REPLACE TABLE fintech.loan_purposes AS ...

    CSV Integration: The query that joined your newly imported state_region table with the loans table.



JSON/Struct Parsing: The query using dot notation to extract purpose from the application_record.

Deduplication: The SELECT DISTINCT query that created your clean list of loan purposes.

-- BUSINESS INTELLIGENCE QUERIES
-- Calculating Geographic Risk by State/Region
SELECT ... FROM loan_region ...
       Regional Distribution: A query counting loans and summing amounts by Region and State.

Loan Count by Year: Your CREATE TABLE query for historical volume.



-- ADVANCED ANALYTICS (BONUS)
-- Calculating Debt-to-Income Ratio to assess borrower health
SELECT ...

  Metric 1: Average Loan Utilization (The "Affordability" Check)

What it shows: Are people with lower incomes taking out huge loans?

Query: SELECT income_bracket, AVG(loan_amount/annual_income) as debt_to_income_ratio...

Metric 2: Regional Default Risk Concentration

What it shows: Which region has the highest percentage of "Late" or "Defaulted" loans?

Query: A query that calculates (Count of Late Loans / Total Loans) * 100 grouped by Region.

Metric 3: Seasonality Analysis

What it shows: Are more loans taken out in Q4 versus Q1?

Query: Use EXTRACT(MONTH FROM issue_date) to see if there is a "peak" borrowing season.

    /*- other queries to add in my sql script

-The "Fintech Specialty" Query:
A query that calculates the Average Annual Income vs. Average Loan Amount per region. This shows you're thinking about "Affordability" metrics.

The "Math Background" Query:
A query using EXTRACT to see which Month or Quarter has the highest loan volume. This shows you can handle time-series trends.
*/
