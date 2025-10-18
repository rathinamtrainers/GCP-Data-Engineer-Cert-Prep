-- Sample Analytics Queries for Weather Data
-- These queries demonstrate BigQuery features and common analytics patterns

-- ============================================================================
-- 1. Basic Queries - Exploring the Data
-- ============================================================================

-- View recent weather data
SELECT
  date,
  city,
  country,
  temperature_c,
  weather_main,
  weather_description
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY date DESC, city
LIMIT 100;

-- Count records per city
SELECT
  city,
  country,
  COUNT(*) as total_records,
  MIN(date) as first_record,
  MAX(date) as last_record
FROM `data-engineer-475516.weather_data.daily`
GROUP BY city, country
ORDER BY total_records DESC;

-- ============================================================================
-- 2. Temperature Analysis
-- ============================================================================

-- Average temperature by city (last 30 days)
SELECT
  city,
  country,
  ROUND(AVG(temperature_c), 2) as avg_temp_c,
  ROUND(MIN(temperature_c), 2) as min_temp_c,
  ROUND(MAX(temperature_c), 2) as max_temp_c,
  ROUND(STDDEV(temperature_c), 2) as temp_stddev
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city, country
ORDER BY avg_temp_c DESC;

-- Hottest and coldest days
SELECT
  'Hottest' as category,
  date,
  city,
  temperature_c,
  humidity_percent,
  weather_description
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
ORDER BY temperature_c DESC
LIMIT 10

UNION ALL

SELECT
  'Coldest' as category,
  date,
  city,
  temperature_c,
  humidity_percent,
  weather_description
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
ORDER BY temperature_c ASC
LIMIT 10;

-- Temperature trend over time (7-day moving average)
SELECT
  city,
  date,
  temperature_c,
  AVG(temperature_c) OVER (
    PARTITION BY city
    ORDER BY date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) as temp_7day_avg
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
ORDER BY city, date;

-- ============================================================================
-- 3. Weather Conditions Analysis
-- ============================================================================

-- Most common weather conditions by city
SELECT
  city,
  weather_main,
  COUNT(*) as occurrences,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY city), 2) as percentage
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city, weather_main
ORDER BY city, occurrences DESC;

-- Rainy days analysis
SELECT
  city,
  COUNT(CASE WHEN weather_main = 'Rain' THEN 1 END) as rainy_days,
  COUNT(*) as total_days,
  ROUND(COUNT(CASE WHEN weather_main = 'Rain' THEN 1 END) * 100.0 / COUNT(*), 2) as rain_percentage
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city
ORDER BY rain_percentage DESC;

-- ============================================================================
-- 4. Wind and Atmospheric Conditions
-- ============================================================================

-- Windiest cities
SELECT
  city,
  ROUND(AVG(wind_speed_ms), 2) as avg_wind_speed_ms,
  ROUND(MAX(wind_speed_ms), 2) as max_wind_speed_ms,
  ROUND(AVG(wind_speed_ms * 2.237), 2) as avg_wind_speed_mph
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city
ORDER BY avg_wind_speed_ms DESC;

-- Humidity analysis
SELECT
  city,
  ROUND(AVG(humidity_percent), 2) as avg_humidity,
  MIN(humidity_percent) as min_humidity,
  MAX(humidity_percent) as max_humidity
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city
ORDER BY avg_humidity DESC;

-- ============================================================================
-- 5. Time-Based Analysis
-- ============================================================================

-- Temperature by day of week
SELECT
  EXTRACT(DAYOFWEEK FROM date) as day_of_week,
  FORMAT_DATE('%A', date) as day_name,
  city,
  ROUND(AVG(temperature_c), 2) as avg_temp_c
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY day_of_week, day_name, city
ORDER BY city, day_of_week;

-- Sunrise and sunset duration
SELECT
  city,
  date,
  sunrise_timestamp,
  sunset_timestamp,
  TIMESTAMP_DIFF(sunset_timestamp, sunrise_timestamp, HOUR) as daylight_hours
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND sunrise_timestamp IS NOT NULL
  AND sunset_timestamp IS NOT NULL
ORDER BY city, date;

-- ============================================================================
-- 6. Comparative Analysis
-- ============================================================================

-- City comparison (same date)
SELECT
  date,
  MAX(CASE WHEN city = 'London' THEN temperature_c END) as london_temp,
  MAX(CASE WHEN city = 'Paris' THEN temperature_c END) as paris_temp,
  MAX(CASE WHEN city = 'NewYork' THEN temperature_c END) as newyork_temp,
  MAX(CASE WHEN city = 'Tokyo' THEN temperature_c END) as tokyo_temp,
  MAX(CASE WHEN city = 'Sydney' THEN temperature_c END) as sydney_temp
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
GROUP BY date
ORDER BY date DESC;

-- Temperature range (difference between min and max)
SELECT
  city,
  date,
  temp_min_c,
  temp_max_c,
  ROUND(temp_max_c - temp_min_c, 2) as temp_range_c
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY temp_range_c DESC
LIMIT 20;

-- ============================================================================
-- 7. Data Quality Checks
-- ============================================================================

-- Check for missing data
SELECT
  date,
  city,
  CASE WHEN temperature_c IS NULL THEN 'Missing temp' END as issue1,
  CASE WHEN humidity_percent IS NULL THEN 'Missing humidity' END as issue2,
  CASE WHEN weather_main IS NULL THEN 'Missing weather' END as issue3
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND (temperature_c IS NULL
    OR humidity_percent IS NULL
    OR weather_main IS NULL)
ORDER BY date DESC;

-- Check for outliers (temperatures outside reasonable range)
SELECT
  date,
  city,
  temperature_c,
  'Suspicious temperature' as issue
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND (temperature_c < -50 OR temperature_c > 60)
ORDER BY date DESC;

-- Record count by date (should have consistent counts)
SELECT
  date,
  COUNT(*) as total_records,
  COUNT(DISTINCT city) as unique_cities
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY date
ORDER BY date DESC;

-- ============================================================================
-- 8. Partitioning Efficiency Test
-- ============================================================================

-- Query scanning only specific partitions (efficient)
-- This should process minimal data due to partition pruning
SELECT
  city,
  AVG(temperature_c) as avg_temp
FROM `data-engineer-475516.weather_data.daily`
WHERE date = CURRENT_DATE()  -- Scans only 1 partition
GROUP BY city;

-- Query with clustering benefit (efficient)
-- Clustering by city makes this very fast
SELECT *
FROM `data-engineer-475516.weather_data.daily`
WHERE city = 'London'  -- Benefits from clustering
  AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY date DESC;

-- ============================================================================
-- 9. Advanced Analytics
-- ============================================================================

-- Correlation between humidity and temperature
SELECT
  city,
  CORR(temperature_c, humidity_percent) as temp_humidity_correlation,
  CORR(temperature_c, wind_speed_ms) as temp_wind_correlation
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY city
HAVING COUNT(*) > 20;  -- Need sufficient data points

-- Rank cities by temperature (window function)
SELECT
  date,
  city,
  temperature_c,
  RANK() OVER (PARTITION BY date ORDER BY temperature_c DESC) as temp_rank
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
ORDER BY date DESC, temp_rank;

-- ============================================================================
-- 10. Export-Ready Queries (for Looker Studio)
-- ============================================================================

-- Daily summary for dashboards
SELECT
  date,
  city,
  country,
  ROUND(AVG(temperature_c), 1) as avg_temp_c,
  ROUND(MIN(temperature_c), 1) as min_temp_c,
  ROUND(MAX(temperature_c), 1) as max_temp_c,
  ROUND(AVG(humidity_percent), 0) as avg_humidity,
  MODE(weather_main) as most_common_weather
FROM `data-engineer-475516.weather_data.daily`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY date, city, country
ORDER BY date DESC, city;
