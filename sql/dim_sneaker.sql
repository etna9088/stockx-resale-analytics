CREATE OR REPLACE TABLE `sneaker-resale-analytics.stockx_resale.dim_sneaker` AS
SELECT DISTINCT
  sneaker_name,
  brand,
  retail_price,
  release_date,
  CASE
    WHEN LOWER(sneaker_name) LIKE '%jordan-1%'    THEN 'Air Jordan 1'
    WHEN LOWER(sneaker_name) LIKE '%air-force-1%' THEN 'Air Force 1'
    WHEN LOWER(sneaker_name) LIKE '%air-max-90%'  THEN 'Air Max 90'
    WHEN LOWER(sneaker_name) LIKE '%air-max-97%'  THEN 'Air Max 97'
    WHEN LOWER(sneaker_name) LIKE '%presto%'      THEN 'Air Presto'
    WHEN LOWER(sneaker_name) LIKE '%vapormax%'    THEN 'VaporMax'
    WHEN LOWER(sneaker_name) LIKE '%blazer%'      THEN 'Blazer Mid'
    WHEN LOWER(sneaker_name) LIKE '%hyperdunk%'   THEN 'React Hyperdunk'
    WHEN LOWER(sneaker_name) LIKE '%zoom-fly%'    THEN 'Zoom Fly'
    WHEN LOWER(sneaker_name) LIKE '%350%'
     AND LOWER(sneaker_name) LIKE '%v2%'          THEN 'Yeezy 350 V2'
    WHEN LOWER(sneaker_name) LIKE '%350%'         THEN 'Yeezy 350 V1'
    ELSE 'Other'
  END AS silhouette
FROM `sneaker-resale-analytics.stockx_resale.stg_sales`;