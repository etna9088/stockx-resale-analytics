# Data Dictionary — StockX 2019 Data Contest Dataset

**Source:** Released publicly by StockX for their 2019 Data Contest; redistributed on Kaggle:
https://www.kaggle.com/datasets/hudsonstuck/stockx-data-contest
**Grain:** one row = one completed resale transaction on StockX.
**Rows:** 99,956 · **Window:** orders Sept 1, 2017 – Feb 13, 2019 · **Scope:** Nike x Off-White and adidas Yeezy collaborations only (50 models).

---

## Raw file columns (`StockX-Data-Contest-2019.csv`)

| Column | Format in CSV | Type after BigQuery load | Example | Range / values | Notes |
|---|---|---|---|---|---|
| Order Date | text, M/D/YY | DATE | `9/1/17` | 2017-09-01 → 2019-02-13 | Date the resale transaction closed |
| Brand | text | STRING | ` Yeezy` | 2 values | **Defect:** every Yeezy row (72,162) carries a leading space — see Known defects |
| Sneaker Name | text, hyphenated | STRING | `Adidas-Yeezy-Boost-350-V2-Beluga` | 50 distinct | **Defect:** inconsistent capitalization (`Adidas-` vs `adidas-`) on 3 models |
| Sale Price | text, `$` + commas | INTEGER | `$1,097` | $186 → $4,050 | Price the buyer paid (whole dollars in this dataset) |
| Retail Price | text, `$` | INTEGER | `$220` | 8 values: $130–$250 | Original retail = the reseller's cost basis |
| Release Date | text, M/D/YY | DATE | `9/24/16` | 2015-06-27 → 2019-02-07 | Official retail release; precedes order date except for pre-release sales |
| Shoe Size | numeric | FLOAT | `11.0` | 3.5 → 17.0 (26 distinct, half sizes) | US men's sizing |
| Buyer Region | text | STRING | `California` | 51 values | US states + DC; excluded from analysis scope (volume tracks population) |

## Fields derived in the pipeline (not in the raw file)

| Field | Where created | Definition |
|---|---|---|
| `gross_spread` | fact_sales (SQL) | Sale Price − Retail Price, per transaction |
| `days_since_release` | fact_sales (SQL) | DATE_DIFF(order, release); negative = pre-release sale |
| `release_window` | fact_sales (SQL) | Bucketed timing: Pre-release / 0–30 / 31–90 / 91–180 / 181–365 / 1 year+ |
| `silhouette` | dim_sneaker (SQL) | Product family parsed from Sneaker Name via case-insensitive pattern matching (11 families, e.g. Air Jordan 1, Yeezy 350 V2) |
| `Release Window` + sort key | Power BI (DAX columns) | Display copy of release_window with sort prefix stripped |

## Known defects (all evidenced in `sql/validation.sql`)

1. **Brand whitespace (uniform):** `' Yeezy'` with a leading space on all 72,162 Yeezy rows. Groupings look normal, but any `brand = 'Yeezy'` equality filter or join silently returns zero rows. Fixed with `TRIM()` in the staging view; confirmed via bracket test on the raw table (2 distinct values, both bracketed forms recorded).
2. **Model-name case inconsistency:** 3 of 50 models begin lowercase `adidas-`. Harmless for brand grouping (separate column) but breaks case-sensitive pattern matching; silhouette parsing therefore matches on `LOWER(sneaker_name)`.
3. **Prices and dates stored as text** in the CSV (`$1,097`, `9/1/17`). Handled at load: BigQuery schema auto-detection typed them as INTEGER/DATE.

## Not present in this dataset (analysis limitations)

No marketplace fees (modeled as a disclosed 12.5% seller-fee assumption), no seller identifiers, no inventory/stock levels, no order or basket structure (each row is an independent sale). Data ends Feb 2019 — findings describe market patterns of that era, not current prices.
