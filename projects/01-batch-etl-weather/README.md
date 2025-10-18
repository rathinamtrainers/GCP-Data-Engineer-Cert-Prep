# Project 1: Batch ETL Pipeline - Weather Data Warehouse

## Overview

Build a production-ready batch ETL pipeline that ingests weather data from an external API, stores it in Cloud Storage, transforms it with Apache Beam (Dataflow), loads it into BigQuery with proper partitioning, and schedules it with Cloud Composer (Airflow).

**Difficulty**: Beginner to Intermediate
**Duration**: 8-10 hours
**Cost**: $5-10 (mainly Composer environment)

## What You'll Build

```
OpenWeather API → Cloud Storage (Raw) → Dataflow → BigQuery (Partitioned) → Looker Studio
                                           ↑
                                    Cloud Composer (Scheduler)
```

### Components

1. **Data Ingestion** - Python script fetches weather data from OpenWeather API
2. **Data Lake** - Cloud Storage bucket stores raw JSON files
3. **Data Transformation** - Apache Beam pipeline (Dataflow) cleanses and transforms data
4. **Data Warehouse** - BigQuery table with date partitioning and city clustering
5. **Orchestration** - Cloud Composer DAG schedules the pipeline daily
6. **Visualization** - Looker Studio dashboard displays weather trends

## Learning Objectives

By completing this project, you will learn to:

### Technical Skills
- ✅ Fetch data from external REST APIs
- ✅ Store raw data in Cloud Storage (data lake pattern)
- ✅ Write Apache Beam pipelines for data transformation
- ✅ Deploy and run Dataflow jobs using gcloud CLI
- ✅ Design BigQuery tables with partitioning and clustering
- ✅ Load data into BigQuery from Dataflow
- ✅ Create and deploy Airflow DAGs in Cloud Composer
- ✅ Build dashboards in Looker Studio
- ✅ Implement error handling and logging
- ✅ Manage GCP resources cost-effectively

### Data Engineering Concepts
- ✅ Batch ETL vs ELT patterns
- ✅ Data lake architecture (raw → processed → curated)
- ✅ Schema design for analytics workloads
- ✅ Partitioning strategies for performance
- ✅ Workflow orchestration with DAGs
- ✅ Idempotency in data pipelines
- ✅ Data quality validation

## Certification Topics Covered

### Section 1: Designing Data Processing Systems (~22%)
- **1.2 Reliability and Fidelity**
  - Data preparation with Dataflow
  - Pipeline monitoring and orchestration
  - Data validation techniques

### Section 2: Ingesting and Processing Data (~25%)
- **2.1 Planning Data Pipelines**
  - Defining sources (API) and sinks (BigQuery)
  - Transformation logic design
  - Data encryption in transit and at rest
- **2.2 Building Pipelines**
  - Data cleansing strategies
  - Apache Beam programming model
  - Batch transformations
  - Service selection (Dataflow vs Dataproc)
- **2.3 Deploying and Operationalizing**
  - Cloud Composer (Airflow) DAGs
  - CI/CD concepts for data pipelines

### Section 3: Storing the Data (~20%)
- **3.1 Storage System Selection**
  - Cloud Storage for data lake
  - BigQuery for data warehouse
  - Storage lifecycle management
- **3.2 Data Warehouse (BigQuery)**
  - Data modeling (denormalized for analytics)
  - Partitioning by date
  - Clustering by city
  - Data access patterns

### Section 4: Preparing and Using Data for Analysis (~15%)
- **4.1 Data Visualization**
  - BI tool connections (Looker Studio)
  - Query optimization techniques

### Section 5: Maintaining and Automating Workloads (~18%)
- **5.1 Resource Optimization**
  - Cost minimization (ephemeral Dataflow, scheduled jobs)
- **5.4 Monitoring and Troubleshooting**
  - Cloud Logging for pipeline debugging

## Architecture

### Data Flow

```
┌─────────────────┐
│ OpenWeather API │
└────────┬────────┘
         │ HTTP GET (Python)
         ↓
┌─────────────────────────┐
│ Cloud Storage (Raw Zone)│
│ gs://bucket/raw/        │
│ YYYYMMDD/weather.json   │
└────────┬────────────────┘
         │ Read
         ↓
┌─────────────────────────┐
│ Apache Beam Pipeline    │
│ (Dataflow)              │
│ - Parse JSON            │
│ - Clean data            │
│ - Add derived fields    │
└────────┬────────────────┘
         │ Write
         ↓
┌─────────────────────────┐
│ BigQuery Table          │
│ weather_data.daily      │
│ Partitioned by date     │
│ Clustered by city       │
└─────────────────────────┘
         ↓
┌─────────────────────────┐
│ Looker Studio Dashboard │
│ - Temperature trends    │
│ - City comparisons      │
└─────────────────────────┘

         ↑ Scheduled by
┌─────────────────────────┐
│ Cloud Composer (Airflow)│
│ DAG: daily at 6am UTC   │
└─────────────────────────┘
```

### GCP Services Used

| Service | Purpose | Cost Impact |
|---------|---------|-------------|
| Cloud Storage | Raw data storage | $0.020/GB/month (minimal) |
| Dataflow | Data transformation | $0.056/vCPU-hour (~$0.50/day) |
| BigQuery | Data warehouse | $0.020/GB storage, $5/TB queries (free tier) |
| Cloud Composer | Orchestration | ~$300/month (we'll delete after learning) |
| Looker Studio | Visualization | Free |

**Total estimated cost**: $5-10 for this project (if you delete Composer after 1-2 days)

## Prerequisites

- ✅ Project 0 completed (GCP environment setup)
- ✅ Basic Python knowledge
- ✅ Basic SQL knowledge
- ✅ OpenWeather API key (free tier - sign up at https://openweathermap.org/api)

## Project Structure

```
01-batch-etl-weather/
├── README.md                          # This file
├── setup.sh                           # GCP resources setup
├── cleanup.sh                         # Resource cleanup
├── config/
│   ├── .env.template                 # Configuration template
│   └── pipeline-config.yaml          # Dataflow pipeline config
├── src/
│   ├── ingestion/
│   │   ├── fetch_weather.py          # API data fetcher
│   │   └── requirements.txt          # Python dependencies
│   ├── transformation/
│   │   ├── weather_pipeline.py       # Apache Beam pipeline
│   │   └── requirements.txt          # Beam dependencies
│   └── utils/
│       ├── bigquery_schema.py        # BigQuery schema definition
│       └── data_validator.py         # Data quality checks
├── dags/
│   └── weather_etl_dag.py            # Airflow DAG
├── sql/
│   ├── create_table.sql              # BigQuery DDL
│   └── sample_queries.sql            # Example analytics queries
├── tests/
│   └── test_pipeline.py              # Unit tests
└── docs/
    ├── architecture.md               # Detailed architecture
    ├── api-setup.md                  # OpenWeather API setup
    ├── troubleshooting.md            # Common issues
    └── lessons-learned.md            # Key takeaways
```

## Getting Started

### Step 1: Get OpenWeather API Key

1. Go to https://openweathermap.org/api
2. Sign up for free account
3. Navigate to API keys section
4. Copy your API key
5. Add to `.env` file

### Step 2: Run Setup Script

```bash
cd projects/01-batch-etl-weather
./setup.sh
```

This will:
- Create Cloud Storage buckets
- Create BigQuery dataset and table
- (Optional) Create Cloud Composer environment
- Configure IAM permissions

### Step 3: Test Data Ingestion

```bash
# Fetch weather data manually
python src/ingestion/fetch_weather.py

# Verify data in Cloud Storage
gsutil ls gs://YOUR_BUCKET/raw/$(date +%Y%m%d)/
```

### Step 4: Run Dataflow Pipeline

```bash
# Submit Dataflow job
gcloud dataflow jobs run weather-transform-$(date +%Y%m%d) \
    --gcs-location gs://dataflow-templates-us-central1/latest/Word_Count \
    --region us-central1 \
    --staging-location gs://YOUR_BUCKET/staging/ \
    --parameters ...
```

### Step 5: Query Data in BigQuery

```bash
# Run sample queries
bq query --use_legacy_sql=false < sql/sample_queries.sql
```

### Step 6: Create Looker Studio Dashboard

1. Go to https://lookerstudio.google.com/
2. Create new data source → BigQuery
3. Select your `weather_data.daily` table
4. Build visualizations

### Step 7: (Optional) Deploy Airflow DAG

```bash
# Upload DAG to Composer
gcloud composer environments storage dags import \
    --environment weather-composer \
    --location us-central1 \
    --source dags/weather_etl_dag.py
```

## Detailed Instructions

### Option 1: Step-by-Step Manual Execution

Follow [docs/step-by-step-guide.md](docs/step-by-step-guide.md) for detailed instructions on each component.

### Option 2: Automated Setup

Run `./setup.sh` to automate resource creation, then follow the testing steps.

## Key Concepts Explained

### 1. Batch ETL vs Streaming

**This project uses Batch ETL** because:
- Weather data doesn't change constantly
- Daily updates are sufficient for analysis
- Lower cost than streaming
- Simpler to implement and debug

**When to use streaming**: Real-time alerts, fraud detection, live dashboards

### 2. Data Lake Pattern (Raw → Processed → Curated)

**Raw Zone** (`gs://bucket/raw/YYYYMMDD/`):
- Original data from API (JSON)
- Never modified or deleted
- Enables reprocessing if needed

**Processed Zone** (BigQuery):
- Cleansed and transformed data
- Ready for analytics
- Partitioned and optimized

This pattern enables:
- Data lineage tracking
- Reprocessing historical data
- Debugging transformation logic

### 3. BigQuery Partitioning & Clustering

**Partitioning by `date`**:
- Splits table into daily chunks
- Queries scan only relevant partitions
- Reduces query cost and improves performance

**Clustering by `city`**:
- Sorts data within each partition by city
- Queries filtering by city are faster
- No additional cost

**Example**: Query for "London temperature last week"
- Scans only 7 partitions (days)
- Within those, only London data
- 100x faster than full table scan

### 4. Idempotency

**Idempotent pipeline** = Running it multiple times produces same result

Implementation:
- Use date partitions (overwrite mode)
- Unique file names (`YYYYMMDD-HHMMSS.json`)
- Deduplication in transformation

**Why it matters**: If pipeline fails halfway, you can re-run safely

### 5. Apache Beam Concepts

**PCollection** = Distributed dataset
**ParDo** = Transform each element
**GroupByKey** = Aggregate by key
**Window** = Time-based grouping (not used in batch)

**This pipeline**:
```python
(input | "Read JSON" >> beam.io.ReadFromText()
       | "Parse JSON" >> beam.Map(parse_json)
       | "Clean Data" >> beam.ParDo(CleanWeatherData())
       | "Write to BQ" >> beam.io.WriteToBigQuery())
```

## Testing & Validation

### Unit Tests

```bash
cd src/transformation
pytest tests/test_pipeline.py
```

### Integration Test (Small Dataset)

```bash
# Run pipeline on single day
python src/transformation/weather_pipeline.py \
    --input gs://bucket/raw/20250101/weather.json \
    --output PROJECT:DATASET.TABLE \
    --runner DirectRunner  # Local execution
```

### Data Quality Checks

```sql
-- Check for missing data
SELECT date, city, COUNT(*) as records
FROM weather_data.daily
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY date, city
HAVING records < 24;  -- Should have 24 hourly readings

-- Check for outliers
SELECT city, temperature_c
FROM weather_data.daily
WHERE temperature_c < -50 OR temperature_c > 60;
```

## Monitoring & Debugging

### View Dataflow Job Progress

```bash
# List running jobs
gcloud dataflow jobs list --region=us-central1 --status=active

# View job details
gcloud dataflow jobs describe JOB_ID --region=us-central1

# View logs
gcloud dataflow jobs show-logs JOB_ID --region=us-central1
```

### View Cloud Composer DAG Status

```bash
# Get Airflow web UI URL
gcloud composer environments describe weather-composer \
    --location us-central1 \
    --format="value(config.airflowUri)"
```

### BigQuery Query History

```bash
# View recent queries
bq ls -j -a -n 10

# View query details
bq show -j JOB_ID
```

## Cost Optimization Tips

1. **Delete Composer when not in use** - Costs ~$10/day
2. **Use Dataflow Shuffle service** - Reduces worker hours
3. **Set max workers** - Prevent runaway autoscaling
4. **Use preemptible workers** - 80% cost reduction (with retries)
5. **Partition expiration** - Delete old data automatically
6. **Query only needed columns** - Reduce scanning

**Example cost calculation**:
```
Daily pipeline run:
- Dataflow (2 workers × 10 min): $0.02
- BigQuery storage (1 GB): $0.02/month
- Cloud Storage (100 MB): $0.002/month
- Composer (if running): $10/day

Total without Composer: ~$0.50/month
Total with Composer: ~$300/month
```

**Recommendation**: Use cron job instead of Composer for cost-effective learning

## Common Issues & Solutions

### Issue: API rate limit exceeded
**Solution**:
- Use free tier wisely (60 calls/minute)
- Add delay between API calls
- Cache API responses

### Issue: Dataflow job fails with "No space left"
**Solution**:
- Increase disk size: `--disk_size_gb 50`
- Use streaming inserts for large datasets

### Issue: BigQuery schema mismatch
**Solution**:
- Use `--schema_update_option ALLOW_FIELD_ADDITION`
- Or recreate table with correct schema

### Issue: Composer environment creation timeout
**Solution**:
- Environment creation takes 20-30 minutes
- Check quotas: `gcloud compute project-info describe`

## Key Takeaways

After completing this project, you should understand:

✅ **When to use batch vs streaming** - Daily weather updates don't need real-time processing

✅ **Data lake importance** - Storing raw data enables reprocessing and debugging

✅ **BigQuery optimization** - Partitioning and clustering dramatically improve performance

✅ **Apache Beam abstraction** - Same code runs locally (DirectRunner) or on Dataflow

✅ **Airflow for orchestration** - DAGs define dependencies and schedules

✅ **Cost awareness** - Composer is expensive; consider alternatives for simple schedules

✅ **Idempotency** - Design pipelines to be safely re-runnable

✅ **Error handling** - Production pipelines need retry logic and alerts

## Next Steps

After completing this project:

1. **Enhance the pipeline**:
   - Add more cities
   - Ingest historical data (backfill)
   - Add weather forecasts
   - Implement SLA monitoring

2. **Proceed to Project 2**: Real-Time Streaming - IoT Sensor Analytics
   - Learn streaming concepts
   - Work with Pub/Sub
   - Handle late-arriving data

3. **Explore variations**:
   - Replace Dataflow with Dataproc (Spark)
   - Use Data Fusion for visual ETL
   - Add dbt for SQL-based transformations

## Resources

### OpenWeather API
- [API Documentation](https://openweathermap.org/api)
- [Free Tier Limits](https://openweathermap.org/price)

### Apache Beam
- [Beam Programming Guide](https://beam.apache.org/documentation/programming-guide/)
- [Beam Python SDK](https://beam.apache.org/documentation/sdks/python/)

### Cloud Composer
- [Composer Documentation](https://cloud.google.com/composer/docs)
- [Airflow DAG Tutorial](https://airflow.apache.org/docs/apache-airflow/stable/tutorial.html)

### BigQuery
- [Partitioning Guide](https://cloud.google.com/bigquery/docs/partitioned-tables)
- [Clustering Guide](https://cloud.google.com/bigquery/docs/clustered-tables)

---

**Estimated Time**: 8-10 hours
**Difficulty**: Beginner to Intermediate
**Cost**: $5-10 (delete Composer after learning!)

**Let's build your first production data pipeline! 🚀**
