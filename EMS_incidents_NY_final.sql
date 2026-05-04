-- ============================================
-- PROJECT: EMS Incident Analysis NYC 2024
-- Author: Ivan
-- Date: April 2026
-- Dataset: 968,560 rows (partial 2024 data)
-- ============================================


-- ============================================
-- 1. TABLE CREATION
-- ============================================

-- 1.1 Create a table with 31 columns
CREATE TABLE ems_incidents_2024 (
    cad_incident_id                 BIGINT,
    incident_datetime               TIMESTAMP,
    initial_call_type               VARCHAR(100),
    initial_severity_level_code     SMALLINT,
    final_call_type                 VARCHAR(100),
    final_severity_level_code       SMALLINT,
    first_assignment_datetime       TIMESTAMP,
    valid_dispatch_rspns_time_indc  VARCHAR(10),
    dispatch_response_seconds_qy    INTEGER,
    first_activation_datetime       TIMESTAMP,
    first_on_scene_datetime         TIMESTAMP,
    valid_incident_rspns_time_indc  VARCHAR(10),
    incident_response_seconds_qy    NUMERIC(10,2),
    incident_travel_tm_seconds_qy   NUMERIC(10,2),
    first_to_hosp_datetime          TIMESTAMP,        -- 37.5% NULL
    first_hosp_arrival_datetime     TIMESTAMP,        -- 37.8% NULL
    incident_close_datetime         TIMESTAMP,
    held_indicator                  VARCHAR(10),
    incident_disposition_code       VARCHAR(20),
    borough                         VARCHAR(50),
    incident_dispatch_area          VARCHAR(20),
    zipcode                         NUMERIC(5,0),
    policeprecinct                  NUMERIC(5,0),
    citycouncildistrict             NUMERIC(5,0),
    communitydistrict               NUMERIC(5,0),
    communityschooldistrict         NUMERIC(5,0),
    congressionaldistrict           NUMERIC(5,0),
    reopen_indicator                VARCHAR(10),
    special_event_indicator         VARCHAR(10),
    standby_indicator               VARCHAR(10),
    transfer_indicator              VARCHAR(10)
);

-- ============================================
-- 2. DATA CLEANING
-- ============================================

-- 2.1 Check total rows
SELECT COUNT(*) AS total_rows
FROM ems_incidents_2024;

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

-- 2.3 Check for duplicate incidents
SELECT 
    cad_incident_id,
    COUNT(*) AS occurrences
FROM ems_incidents_2024
GROUP BY cad_incident_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 2.4 Check for invalid response times (negative or zero)
SELECT COUNT(*) AS invalid_response_times
FROM ems_incidents_2024
WHERE dispatch_response_seconds_qy <= 0;

-- 2.5 Check for invalid dates
-- (dates outside 2024 range)
SELECT COUNT(*) AS invalid_dates
FROM ems_incidents_2024
WHERE incident_datetime < '2024-01-01'
OR incident_datetime > '2024-12-31';

-- 2.6 Check distinct boroughs
-- (detect any typos or unexpected values)
SELECT DISTINCT borough
FROM ems_incidents_2024
ORDER BY borough;

-- 2.7 Check distinct severity levels
SELECT DISTINCT final_severity_level_code
FROM ems_incidents_2024
ORDER BY final_severity_level_code;

-- 2.8 Check for unusually high response times
-- (more than 1 hour = 3600 seconds is suspicious)
SELECT COUNT(*) AS suspicious_response_times
FROM ems_incidents_2024
WHERE dispatch_response_seconds_qy > 3600;

-- 2.9 Check incidents where close time 
-- is before incident start time
SELECT COUNT(*) AS invalid_time_sequence
FROM ems_incidents_2024
WHERE incident_close_datetime < incident_datetime;

-- 2.10 Summary of data quality
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT cad_incident_id) AS unique_incidents,
    MIN(incident_datetime) AS earliest_date,
    MAX(incident_datetime) AS latest_date,
    COUNT(CASE WHEN borough IS NULL THEN 1 END) AS missing_borough,
    COUNT(CASE WHEN dispatch_response_seconds_qy <= 0 THEN 1 END) AS invalid_response_times
FROM ems_incidents_2024;

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

-- 3.3 Top call type per borough
SELECT borough, initial_call_type, COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY borough, initial_call_type
ORDER BY borough, total DESC;

-- ============================================
-- 4. INCIDENT DATETIME ANALYSIS
-- ============================================

-- 4.1 Date range of the dataset
SELECT 
    MIN(incident_datetime) AS earliest_incident,
    MAX(incident_datetime) AS latest_incident
FROM ems_incidents_2024;

-- 4.2 Total incidents per month
SELECT 
    EXTRACT(MONTH FROM incident_datetime) AS month,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY month
ORDER BY month;

-- 4.3 Busiest days of the week
SELECT 
    TO_CHAR(incident_datetime, 'Day') AS day_of_week,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY day_of_week
ORDER BY total_incidents DESC;

-- 4.4 Busiest hours of the day
SELECT 
    EXTRACT(HOUR FROM incident_datetime) AS hour,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY hour
ORDER BY total_incidents DESC;

-- 4.5 Busiest hour per borough
SELECT 
    borough,
    EXTRACT(hour FROM incident_datetime) AS hour,
    COUNT(*) AS total_incidents
FROM ems_incidents_2024
GROUP BY borough, hour
ORDER BY borough, total_incidents DESC;

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

-- 5.2 Top 10 most common final call types
SELECT 
    final_call_type,
    COUNT(*) AS total
FROM ems_incidents_2024
GROUP BY final_call_type
ORDER BY total DESC
LIMIT 10;

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

-- 7.2 Rank call types by frequency per borough
SELECT 
    borough,
    initial_call_type,
    COUNT(*) AS total,
    RANK() OVER (PARTITION BY borough ORDER BY COUNT(*) DESC) AS rank
FROM ems_incidents_2024
GROUP BY borough, initial_call_type
ORDER BY borough, rank;

-- 7.3 Rank boroughs by fastest average response time
SELECT 
    borough,
    ROUND(AVG(dispatch_response_seconds_qy), 2) AS avg_response_seconds,
    RANK() OVER (ORDER BY AVG(dispatch_response_seconds_qy) ASC) AS rank
FROM ems_incidents_2024
GROUP BY borough;

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





