# 🏭 Manufacturing Downtime & OEE Dashboard

**Tools:** Python · SQL · Power BI · DAX
**Domain:** Manufacturing / Industrial Analytics

---

## 📌 Project Overview

This project analyses manufacturing efficiency using the **OEE (Overall Equipment Effectiveness)** framework — the gold-standard KPI used across German manufacturing companies (Siemens, Bosch, BMW, Continental).

The dashboard enables operations managers to:
- Monitor real-time OEE across 7 machines and 3 shifts
- Identify top downtime causes and affected machines
- Track monthly OEE trends vs world-class benchmark (85%)
- Compare product defect rates and quality metrics

---

## 📊 Key Metrics

| Metric        | Formula                                      | World-Class |
|--------------|----------------------------------------------|-------------|
| Availability | Operating Time / Planned Time                | ≥ 90%       |
| Performance  | (Ideal Cycle × Total Parts) / Operating Time | ≥ 95%       |
| Quality      | Good Parts / Total Parts                     | ≥ 99%       |
| **OEE**      | Availability × Performance × Quality         | **≥ 85%**   |

---


## 💡 Key Insights (Sample)

- **WELD-01** consistently underperforms with OEE below 70% due to frequent unplanned breakdowns
- **Night shift** averages 5% lower OEE than morning shift across all machines
- **Tooling Change** is the #1 planned downtime driver; **Power Failure** causes the longest unplanned stoppages
- **Part-C** has the highest defect rate at ~4.2%

---

## 🛠 Tech Stack

| Tool     | Usage                                  |
|---------|----------------------------------------|
| Python  | Synthetic data generation (Pandas-free)|
| SQL     | Aggregations, star schema, ranking     |
| Power BI| Interactive dashboard with DAX measures|
| DAX     | KPI cards, time intelligence, MoM %   |

