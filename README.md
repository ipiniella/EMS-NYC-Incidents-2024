# 🚑 EMS Incident Analysis — NYC 2024

A data analysis project exploring New York City Emergency Medical Services (EMS) incident data for 2024, using PostgreSQL and pgAdmin.

---

## 📌 Project Overview

This project analyzes **968,560 EMS incidents** across New York City to uncover patterns in emergency call types, response times, hospital transport rates, and borough-level performance.

---

## 🛠️ Tools Used

- **PostgreSQL** — Database management and querying
- **pgAdmin** — Query development and database exploration

---

## 📁 Project Structure

```
ems-nyc-2024/
├── EMS_incidents_NY_final.sql     -- All queries (cleaning, exploration, analysis)
└── README.md
```

---

## 🗂️ Query Sections

The `.sql` file is organized into **8 sections:**

| # | Section | Description |
|---|---|---|
| 1 | Table Creation | Creates the `ems_incidents_2024` table with 31 columns |
| 2 | Data Cleaning | Checks for NULLs, duplicates, invalid dates and response times |
| 3 | Data Exploration | Overview of call types and borough distribution |
| 4 | Incident Datetime Analysis | Monthly, weekly, daily and hourly trends |
| 5 | Call Types & Severity | Most common call types and severity levels by borough |
| 6 | Hospital Transport Rates | Transport rates by borough and severity level |
| 7 | Ranking | Boroughs ranked by incidents, response time and call frequency |
| 8 | Views | Reusable views for monthly and borough summaries |

---

## 🔍 Key Questions Explored

- Which boroughs had the highest number of EMS incidents?
- What were the busiest hours and days for emergency calls?
- What are the most common initial and final call types?
- How often did the initial call type change by the time the incident closed?
- What percentage of incidents resulted in hospital transport?
- Which boroughs had the fastest average response times?

---

## 📊 Dataset

- **Source:** https://data.cityofnewyork.us/Public-Safety/EMS-Incident-Dispatch-Data/76xm-jjuj/about_data
- **Year:** 2024 (partial)
- **Rows:** 968,560 incidents
- **Columns:** 31 fields including timestamps, borough, severity, call types, and transport info

---

## 👤 Author

**Ivan**
Aspiring Data Analyst
[GitHub Profile](https://github.com/ipiniella)
