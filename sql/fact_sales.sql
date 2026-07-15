CREATE OR REPLACE TABLE `sneaker-resale-analytics.stockx_resale.fact_sales` AS
SELECT
  order_date,
  sneaker_name,          -- foreign key to dim_sneaker
  shoe_size,
  buyer_region,
  sale_price,
  retail_price,          -- cost basis lives on the row: every premium calc needs it
  sale_price - retail_price AS gross_spread,
  DATE_DIFF(order_date, release_date, DAY) AS days_since_release,
  CASE
    WHEN DATE_DIFF(order_date, release_date, DAY) < 0    THEN '0. Pre-release'
    WHEN DATE_DIFF(order_date, release_date, DAY) <= 30  THEN '1. 0–30 days'
    WHEN DATE_DIFF(order_date, release_date, DAY) <= 90  THEN '2. 31–90 days'
    WHEN DATE_DIFF(order_date, release_date, DAY) <= 180 THEN '3. 91–180 days'
    WHEN DATE_DIFF(order_date, release_date, DAY) <= 365 THEN '4. 181–365 days'
    ELSE '5. 1 year+'
  END AS release_window
FROM `sneaker-resale-analytics.stockx_resale.stg_sales`;