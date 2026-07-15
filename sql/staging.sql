CREATE OR REPLACE VIEW `sneaker-resale-analytics.stockx_resale.stg_sales` AS
SELECT
  `Order Date`                     AS order_date,
  TRIM(Brand)                      AS brand,
  `Sneaker Name`                   AS sneaker_name,
  CAST(`Sale Price`  AS NUMERIC)   AS sale_price,
  CAST(`Retail Price` AS NUMERIC)  AS retail_price,
  `Release Date`                   AS release_date,
  `Shoe Size`                      AS shoe_size,
  `Buyer Region`                   AS buyer_region
FROM `sneaker-resale-analytics.stockx_resale.raw_sales`;