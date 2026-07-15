-- validation.sql — run after staging/dim/fact are built; all checks passed 2026-07-13
-- Reference numbers from independent Python (pandas) profile of the raw CSV.

-- Check 1: row count survives the pipeline. Expect 99,956. PASSED
SELECT COUNT(*) FROM `sneaker-resale-analytics.stockx_resale.fact_sales`;

-- Check 2: TRIM + silhouette parser worked. Expect exactly 2 brands, 50 models
-- total, 11 silhouettes, zero rows in 'Other'. PASSED
SELECT brand, silhouette, COUNT(*) AS models
FROM `sneaker-resale-analytics.stockx_resale.dim_sneaker`
GROUP BY brand, silhouette ORDER BY brand, silhouette;

-- Check 3: source completeness — no missing prices or dates arrived from the CSV
-- (days_since_release audits both order_date and release_date at once).
-- Expect 0 / 0 / 0. PASSED
SELECT COUNTIF(sale_price IS NULL) AS bad_prices,
       COUNTIF(order_date IS NULL) AS bad_dates,
       COUNTIF(days_since_release IS NULL) AS bad_release
FROM `sneaker-resale-analytics.stockx_resale.fact_sales`;

-- Check 4: reconcile against the Python profile. Expect ~0.6% below retail,
-- ~$20.85M retail value, ~$44.64M resale value.
-- PASSED: 0.56 / 20.85 / 44.64
SELECT ROUND(100 * COUNTIF(gross_spread < 0) / COUNT(*), 2) AS pct_below_retail,
       ROUND(SUM(retail_price) / 1e6, 2) AS retail_value_m,
       ROUND(SUM(sale_price)  / 1e6, 2)  AS resale_value_m
FROM `sneaker-resale-analytics.stockx_resale.fact_sales`;

-- Check 5: brand whitespace defect — bracket test on RAW data (pre-TRIM).
-- Result 2026-07-13: '[ Yeezy]' on ALL 72,162 Yeezy rows — uniform leading-space
-- defect. Confirms TRIM(Brand) in staging is necessary, not decorative.
SELECT CONCAT('[', Brand, ']') AS brand_bracketed, COUNT(*) AS rows_
FROM `sneaker-resale-analytics.stockx_resale.raw_sales`
GROUP BY Brand;