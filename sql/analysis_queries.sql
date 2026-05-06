-- ============================================================
-- Project 1: Manufacturing OEE Dashboard
-- SQL Analysis Queries
-- ============================================================

-- 1. Overall OEE Summary by Machine
SELECT
    machine_id,
    COUNT(*)                          AS total_shifts,
    ROUND(AVG(availability)  * 100, 2) AS avg_availability_pct,
    ROUND(AVG(performance)   * 100, 2) AS avg_performance_pct,
    ROUND(AVG(quality)       * 100, 2) AS avg_quality_pct,
    ROUND(AVG(oee)           * 100, 2) AS avg_oee_pct,
    SUM(good_parts)                   AS total_good_parts,
    SUM(defective_parts)              AS total_defective_parts,
    SUM(downtime_min)                 AS total_downtime_min
FROM production_log
GROUP BY machine_id
ORDER BY avg_oee_pct DESC;

-- 2. Monthly OEE Trend (for Power BI time-series)
SELECT
    DATE_FORMAT(date, '%Y-%m')        AS month,
    machine_id,
    ROUND(AVG(oee) * 100, 2)          AS avg_oee_pct,
    ROUND(AVG(availability) * 100, 2) AS avg_availability_pct,
    ROUND(AVG(performance)  * 100, 2) AS avg_performance_pct,
    ROUND(AVG(quality)      * 100, 2) AS avg_quality_pct,
    SUM(downtime_min)                 AS total_downtime_min
FROM production_log
GROUP BY DATE_FORMAT(date, '%Y-%m'), machine_id
ORDER BY month, machine_id;

-- 3. OEE by Shift
SELECT
    shift,
    ROUND(AVG(oee)          * 100, 2) AS avg_oee_pct,
    ROUND(AVG(availability) * 100, 2) AS avg_availability_pct,
    ROUND(AVG(performance)  * 100, 2) AS avg_performance_pct,
    ROUND(AVG(quality)      * 100, 2) AS avg_quality_pct,
    SUM(downtime_min)                 AS total_downtime_min
FROM production_log
GROUP BY shift
ORDER BY avg_oee_pct DESC;

-- 4. Top Downtime Reasons
SELECT
    reason,
    COUNT(*)            AS occurrences,
    SUM(duration_min)   AS total_duration_min,
    ROUND(AVG(duration_min), 1) AS avg_duration_min
FROM downtime_events
GROUP BY reason
ORDER BY total_duration_min DESC;

-- 5. Downtime by Machine and Reason (heatmap base)
SELECT
    machine_id,
    reason,
    COUNT(*)          AS occurrences,
    SUM(duration_min) AS total_duration_min
FROM downtime_events
GROUP BY machine_id, reason
ORDER BY machine_id, total_duration_min DESC;

-- 6. Weekly OEE vs World-Class Benchmark (85%)
SELECT
    YEARWEEK(date, 1)            AS year_week,
    ROUND(AVG(oee) * 100, 2)    AS avg_oee_pct,
    85.0                         AS world_class_benchmark,
    ROUND(AVG(oee) * 100 - 85, 2) AS gap_to_benchmark
FROM production_log
GROUP BY YEARWEEK(date, 1)
ORDER BY year_week;

-- 7. Machine Performance Ranking (for leaderboard visual)
SELECT
    p.machine_id,
    m.machine_type,
    m.location,
    m.manufacturer,
    ROUND(AVG(p.oee) * 100, 2)         AS avg_oee_pct,
    SUM(p.good_parts)                  AS total_good_parts,
    SUM(p.downtime_min)                AS total_downtime_min,
    RANK() OVER (ORDER BY AVG(p.oee) DESC) AS oee_rank
FROM production_log p
JOIN machines m ON p.machine_id = m.machine_id
GROUP BY p.machine_id, m.machine_type, m.location, m.manufacturer
ORDER BY oee_rank;

-- 8. Defect Rate by Product
SELECT
    product,
    SUM(total_parts)                                AS total_produced,
    SUM(defective_parts)                            AS total_defective,
    ROUND(SUM(defective_parts)/SUM(total_parts)*100, 2) AS defect_rate_pct
FROM production_log
GROUP BY product
ORDER BY defect_rate_pct DESC;

-- 9. Create Star Schema Views for Power BI

-- Fact Table View
CREATE OR REPLACE VIEW fact_production AS
SELECT
    log_id,
    date,
    machine_id,
    product,
    shift,
    planned_time_min,
    downtime_min,
    operating_time_min,
    total_parts,
    good_parts,
    defective_parts,
    availability,
    performance,
    quality,
    oee
FROM production_log;

-- Date Dimension View
CREATE OR REPLACE VIEW dim_date AS
SELECT DISTINCT
    date,
    YEAR(date)                          AS year,
    QUARTER(date)                       AS quarter,
    MONTH(date)                         AS month,
    MONTHNAME(date)                     AS month_name,
    WEEK(date, 1)                       AS week_number,
    DAYOFWEEK(date)                     AS day_of_week,
    DAYNAME(date)                       AS day_name,
    CASE WHEN DAYOFWEEK(date) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS day_type
FROM production_log;
