# Project 1: Batch ETL Weather Pipeline - Status

**Status**: Infrastructure and Documentation Complete ✅
**Next Step**: Implement Python scripts

---

## ✅ Completed

### Documentation
- [x] **README.md** - Comprehensive project guide with learning objectives
- [x] **setup.sh** - Complete GCP resource setup script
- [x] **cleanup.sh** - Resource cleanup script
- [x] **PROJECT_STATUS.md** - This file

### Configuration
- [x] **config/.env.template** - Configuration template with all variables
- [x] **sql/schema.json** - BigQuery table schema (23 fields)
- [x] **sql/create_table.sql** - SQL DDL for table creation
- [x] **sql/sample_queries.sql** - 50+ example analytics queries

### Requirements Files
- [x] **src/ingestion/requirements.txt** - Python dependencies for data fetching
- [x] **src/transformation/requirements.txt** - Apache Beam dependencies

---

## 📝 To Be Implemented (Python Code)

The following Python scripts need to be created. I've documented what each should do:

### 1. Data Ingestion Script
**File**: `src/ingestion/fetch_weather.py`

**Purpose**: Fetch weather data from OpenWeather API and upload to Cloud Storage

**What it should do**:
```python
# 1. Load configuration from .env
# 2. For each city in CITIES list:
#    - Call OpenWeather API: GET /data/2.5/weather?q={city}&appid={API_KEY}
#    - Handle rate limiting (60 calls/minute free tier)
#    - Retry on failures (max 3 retries)
# 3. Save raw JSON to Cloud Storage:
#    - Path: gs://bucket/raw/YYYYMMDD/weather-{timestamp}.json
#    - Format: One JSON file with array of city data
# 4. Log results and errors
```

**Key functions needed**:
- `load_config()` - Load from .env
- `fetch_city_weather(city, api_key)` - Call API
- `upload_to_gcs(data, bucket, path)` - Upload to Cloud Storage
- `main()` - Orchestrate the process

**Example API response structure**:
```json
{
  "coord": {"lon": -0.1257, "lat": 51.5085},
  "weather": [{"id": 800, "main": "Clear", "description": "clear sky"}],
  "main": {
    "temp": 280.32,  // Kelvin
    "feels_like": 278.99,
    "temp_min": 279.15,
    "temp_max": 281.15,
    "pressure": 1023,
    "humidity": 72
  },
  "wind": {"speed": 4.1, "deg": 80},
  "clouds": {"all": 0},
  "sys": {"sunrise": 1605163200, "sunset": 1605194400},
  "name": "London"
}
```

---

### 2. Apache Beam Dataflow Pipeline
**File**: `src/transformation/weather_pipeline.py`

**Purpose**: Transform raw JSON into structured BigQuery records

**Pipeline steps**:
```python
# Input: gs://bucket/raw/YYYYMMDD/*.json
# Output: BigQuery table weather_data.daily

# 1. Read JSON files from Cloud Storage
# 2. Parse JSON and extract fields
# 3. Data transformations:
#    - Convert Kelvin to Celsius: (K - 273.15)
#    - Calculate Fahrenheit: (C * 9/5) + 32
#    - Convert Unix timestamps to TIMESTAMP
#    - Add ingestion_timestamp (current time)
#    - Extract date from timestamp
# 4. Data validation:
#    - Check temperature is reasonable (-50 to 60°C)
#    - Check humidity is 0-100%
#    - Ensure required fields are present
# 5. Write to BigQuery with WRITE_TRUNCATE (idempotent)
```

**Apache Beam structure**:
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

class ParseWeatherData(beam.DoFn):
    def process(self, element):
        # Parse JSON
        # Transform fields
        # Yield dict matching BigQuery schema

def run():
    pipeline_options = PipelineOptions(
        runner='DataflowRunner',
        project='data-engineer-475516',
        region='us-central1',
        temp_location='gs://bucket/temp',
        staging_location='gs://bucket/staging'
    )

    with beam.Pipeline(options=pipeline_options) as p:
        (p
         | 'Read JSON' >> beam.io.ReadFromText('gs://bucket/raw/*/*.json')
         | 'Parse' >> beam.ParDo(ParseWeatherData())
         | 'Write to BQ' >> beam.io.WriteToBigQuery(
             'project:dataset.table',
             schema=BIGQUERY_SCHEMA,
             write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE
         ))
```

---

### 3. Airflow DAG (Optional - For Cloud Composer)
**File**: `dags/weather_etl_dag.py`

**Purpose**: Orchestrate daily pipeline execution

**DAG structure**:
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.dataflow import DataflowCreatePythonJobOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-engineer',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'weather_etl_daily',
    default_args=default_args,
    description='Daily weather data ETL pipeline',
    schedule_interval='0 6 * * *',  # 6am UTC daily
    catchup=False,
)

# Task 1: Fetch data from API
fetch_task = PythonOperator(
    task_id='fetch_weather_data',
    python_callable=fetch_and_upload,
    dag=dag,
)

# Task 2: Run Dataflow pipeline
transform_task = DataflowCreatePythonJobOperator(
    task_id='transform_weather_data',
    py_file='gs://bucket/pipelines/weather_pipeline.py',
    job_name='weather-transform-{{ ds_nodash }}',
    dag=dag,
)

# Dependencies
fetch_task >> transform_task
```

---

## 🚀 Quick Start Guide

### Step 1: Setup GCP Resources

```bash
cd projects/01-batch-etl-weather

# Run setup script
./setup.sh

# Get OpenWeather API key from https://openweathermap.org/api
# Edit config/.env and add your API key
nano config/.env
```

### Step 2: Manual Testing (Recommended First)

**Test Data Ingestion**:
```bash
# Option A: Use curl to test API
curl "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY"

# Option B: Implement and run fetch_weather.py
cd src/ingestion
python fetch_weather.py

# Verify data in Cloud Storage
gsutil ls gs://data-engineer-475516-weather-raw/raw/
```

**Test BigQuery Table Creation**:
```bash
# Create table using bq CLI
bq mk --table \
  --time_partitioning_field date \
  --clustering_fields city,country \
  data-engineer-475516:weather_data.daily \
  sql/schema.json

# Or use SQL
bq query --use_legacy_sql=false < sql/create_table.sql
```

**Test Data Loading (Simple)**:
```bash
# Option 1: Load directly to BigQuery (skip Dataflow for now)
# Create a simple Python script to:
# 1. Read JSON from GCS
# 2. Transform to match schema
# 3. Use BigQuery Python client to insert rows

# Option 2: Use bq load command
bq load \
  --source_format=NEWLINE_DELIMITED_JSON \
  --autodetect \
  weather_data.daily \
  gs://data-engineer-475516-weather-raw/raw/*/weather-*.json
```

### Step 3: Implement Dataflow Pipeline

```bash
cd src/transformation

# Install dependencies
pip install -r requirements.txt

# Test locally first (DirectRunner)
python weather_pipeline.py \
  --input gs://bucket/raw/20250118/*.json \
  --output PROJECT:DATASET.TABLE \
  --runner DirectRunner

# Run on Dataflow
python weather_pipeline.py \
  --input gs://bucket/raw/20250118/*.json \
  --output data-engineer-475516:weather_data.daily \
  --runner DataflowRunner \
  --project data-engineer-475516 \
  --region us-central1 \
  --temp_location gs://data-engineer-475516-weather-temp/dataflow/temp \
  --staging_location gs://data-engineer-475516-weather-staging/dataflow/staging
```

### Step 4: Query Data

```bash
# Run sample queries
bq query --use_legacy_sql=false < sql/sample_queries.sql

# Or query interactively
bq query --use_legacy_sql=false \
  'SELECT city, AVG(temperature_c) as avg_temp
   FROM `data-engineer-475516.weather_data.daily`
   WHERE date >= CURRENT_DATE() - 7
   GROUP BY city'
```

### Step 5: Visualize (Looker Studio)

1. Go to https://lookerstudio.google.com/
2. Create new report
3. Add data source → BigQuery
4. Select `weather_data.daily` table
5. Create visualizations:
   - Line chart: Temperature over time by city
   - Bar chart: Average humidity by city
   - Map: Cities with temperature heatmap
   - Table: Recent weather conditions

---

## 💡 Implementation Tips

### For fetch_weather.py:

**Libraries to use**:
```python
import requests  # For API calls
from google.cloud import storage  # For GCS upload
from dotenv import load_dotenv  # For config
import json
import os
from datetime import datetime
import time
```

**Error handling**:
```python
try:
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    data = response.json()
except requests.exceptions.RequestException as e:
    logger.error(f"API call failed: {e}")
    # Retry with backoff
```

### For weather_pipeline.py:

**Schema matching**:
```python
# BigQuery expects this structure:
{
    'date': '2025-01-18',  # DATE
    'timestamp': '2025-01-18T12:00:00',  # TIMESTAMP
    'city': 'London',
    'country': 'GB',
    'temperature_c': 15.5,  # Convert from Kelvin
    'temperature_f': 59.9,  # Derived
    # ... all 23 fields
}
```

**Temperature conversion**:
```python
def kelvin_to_celsius(k):
    return round(k - 273.15, 2)

def celsius_to_fahrenheit(c):
    return round((c * 9/5) + 32, 2)
```

---

## 📚 Learning Path

### Beginner Approach (Recommended):
1. ✅ Run setup.sh (Done - infrastructure ready)
2. Manually fetch data with curl
3. Manually create BigQuery table
4. Use `bq load` to load JSON (skip Dataflow initially)
5. Run sample queries
6. Then implement Python scripts
7. Finally add Dataflow

### Advanced Approach:
1. ✅ Run setup.sh (Done)
2. Implement all Python scripts
3. Run end-to-end pipeline
4. Deploy to Composer
5. Schedule daily runs

---

## 🎯 Success Criteria

You'll know the project is complete when you can:

- [ ] Fetch weather data for multiple cities via API
- [ ] Store raw JSON in Cloud Storage
- [ ] Transform and load data into BigQuery
- [ ] Query the data with SQL
- [ ] Visualize trends in Looker Studio
- [ ] (Optional) Schedule with Airflow/Composer
- [ ] Clean up all resources with cleanup.sh

---

## 📖 Key Concepts Demonstrated

This project teaches:
- ✅ **Batch ETL pattern** - Extract → Transform → Load
- ✅ **Data Lake** - Raw zone in Cloud Storage
- ✅ **Data Warehouse** - Structured data in BigQuery
- ✅ **Partitioning** - By date for performance
- ✅ **Clustering** - By city for query optimization
- ✅ **Apache Beam** - Portable data processing
- ✅ **Dataflow** - Serverless Apache Beam execution
- ✅ **Idempotency** - Safe to re-run pipelines
- ✅ **Schema design** - Optimized for analytics

---

## 📞 Next Steps

**You can now**:

1. **Run the setup** and create infrastructure
2. **Start simple** - Use curl and bq CLI
3. **Graduate to Python** - Implement scripts
4. **Add Dataflow** - Learn Apache Beam
5. **Proceed to Project 2** - Real-time streaming!

**Need help?**
- Review README.md for detailed guidance
- Check sample_queries.sql for query examples
- Reference Project 0 docs for gcloud commands

---

**Project Status**: Ready to implement! 🚀
**Estimated Time**: 8-10 hours
**Learning Value**: HIGH - Core data engineering skills
