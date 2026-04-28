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

-- same query
SELECT 
    EXTRACT(YEAR FROM issue_date) AS Year,
    COUNT(loan_id) AS Total_Loans,
    SUM(loan_amount) AS Total_Funded_Amount -- This is the 'Cash Out'
FROM 
    `your_project.fintech.loans`
GROUP BY 1
ORDER BY 1 DESC;


-- number of loans issued each year
CREATE TABLE fintech.loan_count_by_year AS
SELECT issue_year, count(loan_id) AS loan_count
FROM fintech.loan
GROUP BY issue_year;

