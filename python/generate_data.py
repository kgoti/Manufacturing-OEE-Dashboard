"""
Manufacturing OEE Dataset Generator
Generates realistic factory data: machines, shifts, downtime events, production output
"""

import csv
import random
from datetime import datetime, timedelta

random.seed(42)

MACHINES     = ["CNC-01", "CNC-02", "LATHE-01", "LATHE-02", "PRESS-01", "WELD-01", "WELD-02"]
SHIFTS       = ["Morning", "Afternoon", "Night"]
DOWNTIME_REASONS = [
    "Planned Maintenance", "Unplanned Breakdown", "Material Shortage",
    "Operator Absence", "Quality Rejection", "Tooling Change", "Power Failure"
]
PRODUCTS     = ["Part-A", "Part-B", "Part-C", "Part-D"]

# ── 1. production_log.csv ────────────────────────────────────────────────────
start_date = datetime(2023, 1, 1)
rows = []
log_id = 1

for day_offset in range(365):
    date = start_date + timedelta(days=day_offset)
    for machine in MACHINES:
        for shift in SHIFTS:
            planned_time   = 480  # minutes per shift
            downtime       = random.randint(0, 120)
            operating_time = planned_time - downtime
            ideal_cycle    = round(random.uniform(1.5, 3.0), 2)  # minutes per part
            total_parts    = int(operating_time / ideal_cycle * random.uniform(0.75, 1.0))
            good_parts     = int(total_parts * random.uniform(0.88, 0.99))
            defective      = total_parts - good_parts

            availability   = round(operating_time / planned_time, 4) if planned_time > 0 else 0
            performance    = round((ideal_cycle * total_parts) / operating_time, 4) if operating_time > 0 else 0
            quality        = round(good_parts / total_parts, 4) if total_parts > 0 else 0
            oee            = round(availability * performance * quality, 4)

            rows.append([
                log_id, date.strftime("%Y-%m-%d"), machine,
                random.choice(PRODUCTS), shift,
                planned_time, downtime, operating_time,
                ideal_cycle, total_parts, good_parts, defective,
                availability, performance, quality, oee
            ])
            log_id += 1

with open("/home/claude/projects/1_manufacturing_oee/data/production_log.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "log_id","date","machine_id","product","shift",
        "planned_time_min","downtime_min","operating_time_min",
        "ideal_cycle_time","total_parts","good_parts","defective_parts",
        "availability","performance","quality","oee"
    ])
    writer.writerows(rows)

print(f"production_log.csv → {len(rows)} rows")

# ── 2. downtime_events.csv ───────────────────────────────────────────────────
downtime_rows = []
event_id = 1
for day_offset in range(365):
    date = start_date + timedelta(days=day_offset)
    for machine in random.sample(MACHINES, k=random.randint(1, 4)):
        num_events = random.randint(0, 3)
        for _ in range(num_events):
            duration = random.randint(5, 90)
            downtime_rows.append([
                event_id, date.strftime("%Y-%m-%d"), machine,
                random.choice(SHIFTS), random.choice(DOWNTIME_REASONS), duration
            ])
            event_id += 1

with open("/home/claude/projects/1_manufacturing_oee/data/downtime_events.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["event_id","date","machine_id","shift","reason","duration_min"])
    writer.writerows(downtime_rows)

print(f"downtime_events.csv → {len(downtime_rows)} rows")

# ── 3. machines.csv ──────────────────────────────────────────────────────────
machine_rows = [
    ["CNC-01",   "CNC Milling",  "Hall A", 2018, "Siemens"],
    ["CNC-02",   "CNC Milling",  "Hall A", 2020, "Siemens"],
    ["LATHE-01", "Lathe",        "Hall B", 2016, "Mazak"],
    ["LATHE-02", "Lathe",        "Hall B", 2019, "Mazak"],
    ["PRESS-01", "Hydraulic Press","Hall C",2017, "Schuler"],
    ["WELD-01",  "Welding",      "Hall C", 2021, "KUKA"],
    ["WELD-02",  "Welding",      "Hall D", 2022, "KUKA"],
]
with open("/home/claude/projects/1_manufacturing_oee/data/machines.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["machine_id","machine_type","location","year_installed","manufacturer"])
    writer.writerows(machine_rows)

print("machines.csv → 7 rows")
print("\nAll datasets generated successfully.")
