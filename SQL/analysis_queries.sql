use credit_risk;

-- =========================================
-- 1. CREDIT HISTORY ANALYSIS
-- =========================================

Select
	Credit_History,
    COUNT(*) AS total_applicants,
    
    SUM(CASE
		WHEN Loan_Status = 'Y' THEN 1
        ELSE 0
	END) AS approved,
    
    ROUND(
		SUM(CASE
			WHEN Loan_Status = 'Y' THEN 1
            ELSE 0
		END) * 100.0 /COUNT(*),
	2) AS approval_rate

FROM loan_data
GROUP BY Credit_History;

-- =========================================
-- 2. INCOME GROUP ANALYSIS
-- =========================================

SELECT
    CASE
        WHEN CAST(ApplicantIncome AS UNSIGNED) < 2500 THEN 'Low Income'
        WHEN CAST(ApplicantIncome AS UNSIGNED) BETWEEN 2500 AND 6000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS income_group,

    COUNT(*) AS total,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,

    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS approval_rate

FROM loan_data
GROUP BY income_group
ORDER BY approval_rate DESC;

-- =========================================
-- 3. LOAN AMOUNT ANALYSIS
-- =========================================

SELECT
    CASE
        WHEN CAST(LoanAmount AS UNSIGNED) < 100 THEN 'Small Loan'
        WHEN CAST(LoanAmount AS UNSIGNED) BETWEEN 100 AND 200 THEN 'Medium Loan'
        ELSE 'Large Loan'
    END AS loan_size,

    COUNT(*) AS total,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,

    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS approval_rate

FROM loan_data
GROUP BY loan_size
ORDER BY approval_rate DESC;

-- =========================================
-- 4. RISK SEGMENTATION MODEL
-- =========================================

SELECT
    Loan_ID,
    Loan_Status,
    Credit_History,

    CASE
        WHEN CAST(ApplicantIncome AS UNSIGNED) < 2500 THEN 'Low Income'
        WHEN CAST(ApplicantIncome AS UNSIGNED) BETWEEN 2500 AND 6000 THEN 'Medium Income'
        ELSE 'High Income'
    END AS income_group,

    CASE
        WHEN CAST(LoanAmount AS UNSIGNED) < 100 THEN 'Small Loan'
        WHEN CAST(LoanAmount AS UNSIGNED) BETWEEN 100 AND 200 THEN 'Medium Loan'
        ELSE 'Large Loan'
    END AS loan_size,

    CASE
        -- HIGH RISK
        WHEN Credit_History = 0 THEN 'High Risk'
        WHEN (CAST(ApplicantIncome AS UNSIGNED) < 2500 AND CAST(LoanAmount AS UNSIGNED) > 200) THEN 'High Risk'

        -- LOW RISK
        WHEN Credit_History = 1
             AND (CAST(ApplicantIncome AS UNSIGNED) >= 2500)
             AND (CAST(LoanAmount AS UNSIGNED) <= 200)
        THEN 'Low Risk'

        -- MEDIUM RISK (everything else)
        ELSE 'Medium Risk'
    END AS risk_segment

FROM loan_data;

-- =========================================
-- 5. RISK SUMMARY (FOR POWER BI)
-- =========================================

SELECT
    risk_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(
        SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS approval_rate
FROM (
    SELECT
        Loan_ID,
        Loan_Status,
        Credit_History,

        CASE
            WHEN CAST(ApplicantIncome AS UNSIGNED) < 2500 THEN 'Low Income'
            WHEN CAST(ApplicantIncome AS UNSIGNED) BETWEEN 2500 AND 6000 THEN 'Medium Income'
            ELSE 'High Income'
        END AS income_group,

        CASE
            WHEN CAST(LoanAmount AS UNSIGNED) < 100 THEN 'Small Loan'
            WHEN CAST(LoanAmount AS UNSIGNED) BETWEEN 100 AND 200 THEN 'Medium Loan'
            ELSE 'Large Loan'
        END AS loan_size,

        CASE
            WHEN Credit_History = 0 THEN 'High Risk'
            WHEN (CAST(ApplicantIncome AS UNSIGNED) < 2500 AND CAST(LoanAmount AS UNSIGNED) > 200) THEN 'High Risk'
            WHEN Credit_History = 1
                 AND (CAST(ApplicantIncome AS UNSIGNED) >= 2500)
                 AND (CAST(LoanAmount AS UNSIGNED) <= 200)
            THEN 'Low Risk'
            ELSE 'Medium Risk'
        END AS risk_segment

    FROM loan_data
) AS t
GROUP BY risk_segment
ORDER BY approval_rate DESC;


