# DAX Measures & Calculated Columns — stockx-resale-analytics

All measures live on `fact_sales`. Reconciliation record at the bottom.

---

## Measures

### Sales Volume
```dax
Sales Volume = COUNTROWS(fact_sales)
```
Transaction count in the current filter context. Format: whole number, thousands separator.

### Total Spread $
```dax
Total Spread $ = SUM(fact_sales[gross_spread])
```
Aggregate (sale − retail) dollars over retail. Format: currency, 0 decimals.

### Median Resale Premium %
```dax
Median Resale Premium % =
MEDIANX(
    fact_sales,
    DIVIDE(fact_sales[sale_price] - fact_sales[retail_price], fact_sales[retail_price])
)
```
Per-transaction markup over retail, then the median. Median (not mean) because sale prices are heavily right-skewed. Format: percentage, 1 decimal.

### Net Premium After Fees %
```dax
Net Premium After Fees % =
MEDIANX(
    fact_sales,
    DIVIDE(fact_sales[sale_price] * 0.875 - fact_sales[retail_price], fact_sales[retail_price])
)
```
Same as above with the seller keeping 87.5% of sale price — a disclosed assumption of ~12.5% StockX seller fees (9.5% transaction + 3% payment processing, 2017–2019 fee schedule, known from firsthand payout records). Format: percentage, 1 decimal.

### Below Retail %
```dax
Below Retail % =
DIVIDE(
    CALCULATE(COUNTROWS(fact_sales), fact_sales[gross_spread] < 0),
    COUNTROWS(fact_sales)
)
```
Share of transactions that closed under retail. Format: percentage, 2 decimals.

### Price Volatility (CV)
```dax
Price Volatility (CV) =
DIVIDE(
    STDEVX.P(fact_sales, fact_sales[sale_price]),
    AVERAGEX(fact_sales, fact_sales[sale_price])
)
```
Coefficient of variation: stdev ÷ mean of sale prices. Dividing by the mean cancels dollar units so a $250 and a $1,500 model are comparable; raw stdev would just re-rank by price level. Meaningful per-model (stability map), not all-market. Format: decimal, 2 places.

### Premium P25 / Premium P75
```dax
Premium P25 =
PERCENTILEX.INC(
    fact_sales,
    DIVIDE(fact_sales[sale_price] - fact_sales[retail_price], fact_sales[retail_price]),
    0.25
)
```
(P75 identical with 0.75.) Bracket the middle half of premium outcomes; used in decay-curve tooltips. Format: percentage, 1 decimal.

---

## Calculated columns (on fact_sales)

```dax
Release Window = MID(fact_sales[release_window], 4, LEN(fact_sales[release_window]) - 3)
Release Window Sort = VALUE(LEFT(fact_sales[release_window], 1))
```
The SQL `release_window` carries numeric prefixes ("1. 0–30 days") as a sort crutch. These strip the prefix for display and keep the order via Sort by Column (`Release Window` sorted by `Release Window Sort`).

---

## Reconciliation record — 2026-07-13/14, all PASSED

Measures verified against an independent Python (pandas) profile of the raw CSV, on unfiltered and brand-filtered cards:

| Measure / cut | Power BI | Python reference |
|---|---|---|
| Sales Volume | 99,956 | 99,956 |
| Total Spread $ | $23.79M | $23.79M |
| Below Retail % | 0.56% | 0.56% |
| Median Resale Premium % (all) | 70.5% | 70.5% |
| … brand = Off-White | 268.4% | 268.4% |
| … brand = Yeezy | 43.6% | 43.6% |
| Decay curve (6 buckets × 2 brands) | matched | matched (e.g., OW 1yr+ 578.1%, Yeezy 1yr+ 30.9%) |
| Slicer spot-check: Air Jordan 1 by bucket | 337.6 / 316.3 / 400.0 / 384.2 / 436.8 / 1189.5 | identical |

Note: an earlier draft guide estimated the all-market median at ~61%; the model's 70.5% was confirmed correct by re-profiling — the estimate was the error. Kept here as evidence the reconciliation gate works in both directions.
