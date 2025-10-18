-- Create BigQuery table for weather data
-- This table is partitioned by date and clustered by city and country
-- for optimal query performance and cost reduction

CREATE TABLE IF NOT EXISTS `data-engineer-475516.weather_data.daily`
(
  -- Partition key
  date DATE NOT NULL OPTIONS(description="Date of the weather observation (partition key)"),

  -- Timestamp
  timestamp TIMESTAMP NOT NULL OPTIONS(description="Exact time of the observation (UTC)"),

  -- Location (clustering keys)
  city STRING NOT NULL OPTIONS(description="City name (clustering key)"),
  country STRING NOT NULL OPTIONS(description="Country code (ISO 3166, clustering key)"),
  latitude FLOAT64 NOT NULL OPTIONS(description="City latitude"),
  longitude FLOAT64 NOT NULL OPTIONS(description="City longitude"),

  -- Temperature measurements
  temperature_c FLOAT64 OPTIONS(description="Temperature in Celsius"),
  temperature_f FLOAT64 OPTIONS(description="Temperature in Fahrenheit (derived)"),
  feels_like_c FLOAT64 OPTIONS(description="Feels like temperature in Celsius"),
  temp_min_c FLOAT64 OPTIONS(description="Minimum temperature in Celsius"),
  temp_max_c FLOAT64 OPTIONS(description="Maximum temperature in Celsius"),

  -- Atmospheric conditions
  pressure_hpa INT64 OPTIONS(description="Atmospheric pressure in hPa"),
  humidity_percent INT64 OPTIONS(description="Humidity percentage"),
  visibility_m INT64 OPTIONS(description="Visibility in meters"),

  -- Wind
  wind_speed_ms FLOAT64 OPTIONS(description="Wind speed in meters/second"),
  wind_direction_deg INT64 OPTIONS(description="Wind direction in degrees"),

  -- Weather conditions
  clouds_percent INT64 OPTIONS(description="Cloudiness percentage"),
  weather_main STRING OPTIONS(description="Weather condition main category (Rain, Snow, Clear, etc.)"),
  weather_description STRING OPTIONS(description="Detailed weather description"),

  -- Sun times
  sunrise_timestamp TIMESTAMP OPTIONS(description="Sunrise time (UTC)"),
  sunset_timestamp TIMESTAMP OPTIONS(description="Sunset time (UTC)"),

  -- Metadata
  data_source STRING OPTIONS(description="Data source identifier (OpenWeather API)"),
  ingestion_timestamp TIMESTAMP NOT NULL OPTIONS(description="When the data was ingested into our pipeline")
)
PARTITION BY date
CLUSTER BY city, country
OPTIONS(
  description="Daily weather data from OpenWeather API",
  labels=[("project", "weather-etl"), ("env", "dev")]
);

-- Create a view for Celsius users
CREATE OR REPLACE VIEW `data-engineer-475516.weather_data.daily_celsius` AS
SELECT
  date,
  timestamp,
  city,
  country,
  latitude,
  longitude,
  temperature_c,
  feels_like_c,
  temp_min_c,
  temp_max_c,
  pressure_hpa,
  humidity_percent,
  visibility_m,
  wind_speed_ms,
  wind_direction_deg,
  clouds_percent,
  weather_main,
  weather_description,
  sunrise_timestamp,
  sunset_timestamp,
  ingestion_timestamp
FROM `data-engineer-475516.weather_data.daily`;

-- Create a view for Fahrenheit users
CREATE OR REPLACE VIEW `data-engineer-475516.weather_data.daily_fahrenheit` AS
SELECT
  date,
  timestamp,
  city,
  country,
  latitude,
  longitude,
  temperature_f,
  ROUND((feels_like_c * 9/5) + 32, 2) as feels_like_f,
  ROUND((temp_min_c * 9/5) + 32, 2) as temp_min_f,
  ROUND((temp_max_c * 9/5) + 32, 2) as temp_max_f,
  pressure_hpa,
  humidity_percent,
  visibility_m,
  ROUND(wind_speed_ms * 2.237, 2) as wind_speed_mph,  -- Convert to mph
  wind_direction_deg,
  clouds_percent,
  weather_main,
  weather_description,
  sunrise_timestamp,
  sunset_timestamp,
  ingestion_timestamp
FROM `data-engineer-475516.weather_data.daily`;
