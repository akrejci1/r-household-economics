# Econometric Analysis of Household Work and Wages

This project focuses on analyzing household time allocation, wage determinants, gender wage discrimination, and the factors influencing homeownership. The analysis applies various econometric techniques, including multiple linear regression, log-linear models, Linear Probability Models (LPM), and Logistic Regression (Logit).

## Project Description

The analysis uses a dataset of households to explore microeconomic behaviors. It tests theoretical assumptions about how families allocate time to housework based on employment and wealth, examines nonlinear returns to education in the labor market, and assesses gender discrimination. 

## Key Findings

1. **Time Allocation for Housework:** Employment significantly reduces time spent on housework, with female employment having a stronger negative effect than male employment. Homeownership and the presence of young children significantly increase housework time.
2. **Wealth Effects:** Non-labor income decreases housework time primarily for non-homeowners. Homeownership eliminates this effect, showing complex interactions between wealth, assets, and education.
3. **Wage Determinants:** Education significantly increases male wages, but the returns are nonlinear. While tertiary education provides a higher premium, the wage premium for secondary education grows faster with age (experience).
4. **Wage Discrimination:** Using a pooled dataset of men and women, joint hypothesis testing revealed significant gender wage discrimination. The model also identified selection bias in labor market participation, as imputed wages for non-workers were higher than actual wages.
5. **Homeownership:** A Logit model revealed that the probability of owning a home follows an inverted-U shape concerning age (peaking around 55-57 years). Larger household sizes increase the probability of ownership, while higher non-labor income slightly decreases it.

## Methodologies Applied

* Ordinary Least Squares (OLS) regression.
* Robust standard errors (HC3) to correct for detected heteroskedasticity.
* Log-log transformations for elasticity interpretation.
* Joint hypothesis testing (F-tests) to handle structural multicollinearity.
* Linear Probability Model (LPM) and Logit modeling with Average Marginal Effects (AME).
* Diagnostic testing: Breusch-Pagan, Jarque-Bera, Ramsey RESET, and VIF.

## How to Run

1. Download the R script and the `kk2003.xlsx` dataset.
2. Ensure both files are located in the same working directory.
3. Install the required R packages if they are not already installed on your system.
4. Run the script using RStudio or standard R environment.

## Technologies

* R
* `readxl` (Data import)
* `lmtest` (Diagnostic testing)
* `car` (Hypothesis testing)
* `sandwich` (Robust covariance matrix estimators)
* `tseries` (Time series and normality tests)
* `mfx` (Marginal effects for discrete choice models)
