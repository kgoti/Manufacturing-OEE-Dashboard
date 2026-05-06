# Power BI Setup Guide – Manufacturing OEE Dashboard

## Data Import Steps

1. Open Power BI Desktop
2. Home → Get Data → Text/CSV
3. Import in this order:
   - `data/machines.csv`
   - `data/production_log.csv`
   - `data/downtime_events.csv`

## Relationships (Model View)

| From Table       | From Column | To Table    | To Column  | Cardinality |
|-----------------|-------------|-------------|------------|-------------|
| production_log  | machine_id  | machines    | machine_id | Many-to-One |
| downtime_events | machine_id  | machines    | machine_id | Many-to-One |
| production_log  | date        | dim_date*   | date       | Many-to-One |

*Create dim_date as a calculated table (see below)

## DAX Measures

### Core KPIs

```dax
-- Average OEE %
Avg OEE % =
AVERAGE(production_log[oee]) * 100

-- Average Availability %
Avg Availability % =
AVERAGE(production_log[availability]) * 100

-- Average Performance %
Avg Performance % =
AVERAGE(production_log[performance]) * 100

-- Average Quality %
Avg Quality % =
AVERAGE(production_log[quality]) * 100

-- Total Good Parts
Total Good Parts =
SUM(production_log[good_parts])

-- Total Defective Parts
Total Defective Parts =
SUM(production_log[defective_parts])

-- Defect Rate %
Defect Rate % =
DIVIDE(
    SUM(production_log[defective_parts]),
    SUM(production_log[total_parts])
) * 100

-- Total Downtime (hours)
Total Downtime Hours =
DIVIDE(SUM(production_log[downtime_min]), 60)
```

### Time Intelligence

```dax
-- OEE Month-over-Month Change
OEE MoM Change % =
VAR CurrentOEE = CALCULATE([Avg OEE %], DATESMTD(dim_date[date]))
VAR PrevOEE    = CALCULATE([Avg OEE %], DATEADD(DATESMTD(dim_date[date]), -1, MONTH))
RETURN
DIVIDE(CurrentOEE - PrevOEE, PrevOEE) * 100

-- Rolling 30-Day OEE
OEE Rolling 30D =
CALCULATE(
    [Avg OEE %],
    DATESINPERIOD(dim_date[date], LASTDATE(dim_date[date]), -30, DAY)
)

-- Gap to World-Class Benchmark (85%)
Gap to Benchmark =
85 - [Avg OEE %]
```

### Date Dimension (Calculated Table)

```dax
dim_date =
ADDCOLUMNS(
    CALENDAR(DATE(2023,1,1), DATE(2023,12,31)),
    "Year",        YEAR([Date]),
    "Month",       MONTH([Date]),
    "Month Name",  FORMAT([Date], "MMMM"),
    "Quarter",     "Q" & QUARTER([Date]),
    "Week Number", WEEKNUM([Date]),
    "Day Name",    FORMAT([Date], "DDDD"),
    "Is Weekend",  IF(WEEKDAY([Date],2) >= 6, "Weekend", "Weekday")
)
```

## Recommended Visuals

| Visual                         | Fields                                      |
|-------------------------------|---------------------------------------------|
| KPI Cards (4x)                | Avg OEE %, Availability %, Performance %, Quality % |
| Line Chart – OEE Trend        | X: Month, Y: Avg OEE %, benchmark line at 85% |
| Bar Chart – OEE by Machine    | X: machine_id, Y: Avg OEE %                |
| Donut – Downtime by Reason    | Legend: reason, Values: total_duration_min  |
| Matrix – Machine × Shift OEE  | Rows: machine_id, Cols: shift, Values: OEE  |
| Gauge – Overall OEE           | Value: Avg OEE %, Target: 85               |

## Colour Theme (German Industrial Style)
- Primary:   #1F4E79 (dark blue)
- Accent:    #E74C3C (red for below-benchmark)
- Good:      #27AE60 (green for above-benchmark)
- Neutral:   #BDC3C7
