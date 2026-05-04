
-- ============================================
-- 2. DATA CLEANING
-- ============================================

-- 2.1 Check total rows
SELECT COUNT(*) AS total_rows
FROM ems_incidents_2024;
968560

-- 2.2 Check for NULL values in each column
SELECT
    COUNT(*) - COUNT(cad_incident_id) AS cad_incident_id_nulls,
    COUNT(*) - COUNT(incident_datetime) AS incident_datetime_nulls,
    COUNT(*) - COUNT(initial_call_type) AS initial_call_type_nulls,
    COUNT(*) - COUNT(final_call_type) AS final_call_type_nulls,
    COUNT(*) - COUNT(borough) AS borough_nulls,
    COUNT(*) - COUNT(dispatch_response_seconds_qy) AS dispatch_response_nulls,
    COUNT(*) - COUNT(first_to_hosp_datetime) AS first_to_hosp_nulls,
    COUNT(*) - COUNT(first_hosp_arrival_datetime) AS first_hosp_arrival_nulls
FROM ems_incidents_2024;
0

-- 2.3 Check for duplicate incidents
SELECT 
    cad_incident_id,
    COUNT(*) AS occurrences
FROM ems_incidents_2024
GROUP BY cad_incident_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
0

-- 2.4 Check for invalid response times (negative or zero)
SELECT COUNT(*) AS invalid_response_times
FROM ems_incidents_2024
WHERE dispatch_response_seconds_qy <= 0;
6458

-- 2.5 Check for invalid dates
-- (dates outside 2024 range)
SELECT COUNT(*) AS invalid_dates
FROM ems_incidents_2024
WHERE incident_datetime < '2024-01-01'
OR incident_datetime > '2024-12-31';
2534

-- 2.6 Check distinct boroughs
-- (detect any typos or unexpected values)
SELECT DISTINCT borough
FROM ems_incidents_2024
ORDER BY borough;
"BRONX"
"BROOKLYN"
"MANHATTAN"
"QUEENS"
"RICHMOND / STATEN ISLAND"

-- 2.7 Check distinct severity levels
SELECT DISTINCT final_severity_level_code
FROM ems_incidents_2024
ORDER BY final_severity_level_code;

-- 2.8 Check for unusually high response times
-- (more than 1 hour = 3600 seconds is suspicious)
SELECT COUNT(*) AS suspicious_response_times
FROM ems_incidents_2024
WHERE dispatch_response_seconds_qy > 3600;
7427

-- 2.9 Check incidents where close time 
-- is before incident start time
SELECT COUNT(*) AS invalid_time_sequence
FROM ems_incidents_2024
WHERE incident_close_datetime < incident_datetime;
3

-- 2.10 Summary of data quality
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT cad_incident_id) AS unique_incidents,
    MIN(incident_datetime) AS earliest_date,
    MAX(incident_datetime) AS latest_date,
    COUNT(CASE WHEN borough IS NULL THEN 1 END) AS missing_borough,
    COUNT(CASE WHEN dispatch_response_seconds_qy <= 0 THEN 1 END) AS invalid_response_times
FROM ems_incidents_2024;
968560	968560	"2024-01-01 00:00:14"	"2024-12-31 23:59:50"	0	6458

-- ============================================
-- 3. DATA EXPLORATION
-- ============================================

-- 3.1 Table View
SELECT * FROM ems_incidents_2024
Limit 10;


-- 3.2 Top 10 most common call types
SELECT initial_call_type, COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY initial_call_type
ORDER BY total DESC
LIMIT 10;
"SICK"	130812
"INJURY"	100013
"CARDBR"	89102
"CARD"	61519
"UNKNOW"	61256
"ABDPN"	59416
"DIFFBR"	51573
"UNC"	48825
"DRUG"	46612
"INJMAJ"	42330

-- 3.3 Top call type per borough
SELECT borough, initial_call_type, COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY borough, initial_call_type
ORDER BY borough, total DESC;
"BRONX"	"SICK"	31557
"BRONX"	"CARDBR"	25197
"BRONX"	"INJURY"	22080
"BRONX"	"ABDPN"	16651
"BRONX"	"CARD"	14425

-- ============================================
-- 4. INCIDENT DATETIME ANALYSIS
-- ============================================

-- 4.1 Date range of the dataset
SELECT 
    MIN(incident_datetime) AS earliest_incident,
    MAX(incident_datetime) AS latest_incident
FROM ems_incidents_2024;
"2024-01-01 00:00:14"	"2024-12-31 23:59:50"

-- 4.2 Total incidents per month
SELECT 
    EXTRACT(MONTH FROM incident_datetime) AS month,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY month
ORDER BY month;
1	85222
2	77121
3	80759
4	78056
5	82547
6	80828
7	81554
8	78830
9	77269
10	82925
11	78396
12	85053

-- 4.3 Busiest days of the week
SELECT 
    TO_CHAR(incident_datetime, 'Day') AS day_of_week,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY day_of_week
ORDER BY total_incidents DESC;
"Monday   "	145588
"Tuesday  "	143212
"Wednesday"	140365
"Friday   "	139990
"Thursday "	138572
"Saturday "	131502
"Sunday   "	129331

-- 4.4 Busiest hours of the day
SELECT 
    EXTRACT(HOUR FROM incident_datetime) AS hour,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY hour
ORDER BY total_incidents DESC;
11	52556
12	52516
10	52366
13	51773
14	51142
15	49841
16	48661
9	47848
19	47502
17	46958
18	46819
20	46582
21	45092
22	41863
8	38779
23	36493
0	34448
1	30800
7	29411
2	26774
3	23911
6	23295
4	22177
5	20953

-- 4.5 Busiest hour per borough
SELECT 
    borough,
    EXTRACT(hour FROM incident_datetime) AS hour,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY borough, hour
ORDER BY borough, total_incidents DESC;
"BROOKLYN"	12	14906
"BROOKLYN"	10	14807
"BROOKLYN"	11	14804
"BROOKLYN"	13	14628
"BROOKLYN"	14	14396

-- 4.6 Incidents per week
SELECT 
    DATE_TRUNC('week', incident_datetime) AS week,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY week
ORDER BY week;

-- ============================================
-- 5. CALL TYPES AND SEVERITY ANALYSIS
-- ============================================

-- 5.1 Top 10 most common initial call types
SELECT 
    initial_call_type,
    COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY initial_call_type
ORDER BY total DESC
LIMIT 10;
"SICK"	130812
"INJURY"	100013
"CARDBR"	89102
"CARD"	61519
"UNKNOW"	61256
"ABDPN"	59416
"DIFFBR"	51573
"UNC"	48825
"DRUG"	46612
"INJMAJ"	42330

-- 5.2 Top 10 most common final call types
SELECT 
    final_call_type,
    COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY final_call_type
ORDER BY total DESC
LIMIT 10;
"SICK"	140020
"INJURY"	92936
"CARDBR"	90358
"CARD"	65282
"ABDPN"	59683
"DRUG"	54634
"DIFFBR"	51413
"INJMAJ"	48000
"UNC"	46441
"UNKNOW"	43819

-- 5.3 Incidents by severity level
SELECT 
    final_severity_level_code,
    COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY final_severity_level_code
ORDER BY final_severity_level_code;

-- 5.4 Severity level per borough
SELECT 
    borough,
    final_severity_level_code,
    COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY borough, final_severity_level_code
ORDER BY borough, final_severity_level_code;

-- 5.5 Did the initial call type match the final call type?
SELECT
    COUNT(*) AS total_incidents,
    SUM(CASE WHEN initial_call_type = final_call_type THEN 1 ELSE 0 END) AS matched,
    SUM(CASE WHEN initial_call_type != final_call_type THEN 1 ELSE 0 END) AS changed,
    ROUND(SUM(CASE WHEN initial_call_type = final_call_type THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_matched
FROM ems_incidents_2024;

-- ============================================
-- 6. HOSPITAL TRANSPORT RATES
-- ============================================

-- 6.1 Overall hospital transport rate
SELECT
    COUNT(*) AS total_incidents,
    COUNT(first_to_hosp_datetime) AS transported,
    COUNT(*) - COUNT(first_to_hosp_datetime) AS not_transported,
    ROUND(COUNT(first_to_hosp_datetime) * 100.0 / COUNT(*), 2) AS pct_transported
FROM ems_incidents_2024;

-- 6.2 Hospital transport rate per borough
SELECT
    borough,
    COUNT(*) AS total_incidents,
    COUNT(first_to_hosp_datetime) AS transported,
    ROUND(COUNT(first_to_hosp_datetime) * 100.0 / COUNT(*), 2) AS pct_transported
FROM ems_incidents_2024
GROUP BY borough
ORDER BY pct_transported DESC;
"BRONX"	228838	228838	100.00
"BROOKLYN"	273151	273151	100.00
"MANHATTAN"	221268	221268	100.00
"QUEENS"	202731	202731	100.00
"RICHMOND / STATEN ISLAND"	42572	42572	100.00

-- 6.3 Hospital transport rate per severity level
SELECT
    final_severity_level_code,
    COUNT(*) AS total_incidents,
    COUNT(first_to_hosp_datetime) AS transported,
    ROUND(COUNT(first_to_hosp_datetime) * 100.0 / COUNT(*), 2) AS pct_transported
FROM ems_incidents_2024
GROUP BY final_severity_level_code
ORDER BY final_severity_level_code;

-- 6.4 Average time from incident to hospital arrival
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (first_hosp_arrival_datetime - incident_datetime)) / 60), 2) AS avg_minutes_to_hospital
FROM ems_incidents_2024
WHERE first_hosp_arrival_datetime IS NOT NULL;
50.19

-- ============================================
-- 7. RANK
-- ============================================

-- 7.1 Rank boroughs by total incidents
SELECT 
    borough,
    COUNT(*) AS total_incidents,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
FROM ems_incidents_2024
GROUP BY borough;
"BROOKLYN"	273151	1
"BRONX"	228838	2
"MANHATTAN"	221268	3
"QUEENS"	202731	4
"RICHMOND / STATEN ISLAND"	42572	5

-- 7.2 Rank call types by frequency per borough
SELECT 
    borough,
    initial_call_type,
    COUNT(*) AS total,
    RANK() OVER (PARTITION BY borough ORDER BY COUNT(*) DESC) AS rank
FROM ems_incidents_2024
GROUP BY borough, initial_call_type
ORDER BY borough, rank;
"MANHATTAN"	"SICK"	29621	1
"MANHATTAN"	"INJURY"	24344	2
"MANHATTAN"	"CARDBR"	17807	3
"MANHATTAN"	"CARD"	15430	4
"MANHATTAN"	"UNKNOW"	14908	5
"MANHATTAN"	"UNC"	13411	6
"MANHATTAN"	"DRUG"	13315	7
"MANHATTAN"	"ABDPN"	11561	8
"MANHATTAN"	"INJMAJ"	11389	9
"MANHATTAN"	"DIFFBR"	10457	10

-- 7.3 Rank boroughs by fastest average response time
SELECT 
    borough,
    ROUND(AVG(dispatch_response_seconds_qy), 2) AS avg_response_seconds,
    RANK() OVER (ORDER BY AVG(dispatch_response_seconds_qy) ASC) AS rank
FROM ems_incidents_2024
GROUP BY borough;
"RICHMOND / STATEN ISLAND"	46.42	1
"QUEENS"	85.07	2
"BROOKLYN"	109.53	3
"MANHATTAN"	264.09	4
"BRONX"	276.60	5

-- ============================================
-- 8. VIEWS
-- ============================================

-- 8.1 View for monthly incident summary
CREATE VIEW monthly_incidents AS
SELECT 
    EXTRACT(MONTH FROM incident_datetime) AS month,
    TO_CHAR(incident_datetime, 'Month') AS month_name,
    COUNT(*) AS total_incidents,
    COUNT(first_to_hosp_datetime) AS transported
FROM ems_incidents_2024
GROUP BY month, month_name
ORDER BY month;

SELECT * FROM monthly_incidents;

-- 8.2 View for borough summary
CREATE VIEW borough_summary AS
SELECT 
    borough,
    COUNT(*) AS total_incidents,
    ROUND(AVG(dispatch_response_seconds_qy), 2) AS avg_response_seconds,
    COUNT(first_to_hosp_datetime) AS transported,
    ROUND(COUNT(first_to_hosp_datetime) * 100.0 / COUNT(*), 2) AS pct_transported
FROM ems_incidents_2024
GROUP BY borough;

SELECT * FROM borough_summary;