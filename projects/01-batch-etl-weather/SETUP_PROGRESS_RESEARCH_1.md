# Project 1 Setup Progress - data-engineer-research-1

**Project**: Weather ETL Pipeline
**New GCP Project ID**: `data-engineer-research-1`
**Project Number**: `335415716363`
**Setup Date**: 2025-10-19
**Status**: In Progress - Step 9/11

---

## Setup Progress

### ✅ Step 1: Create GCP Project (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Project Details**:
- Project ID: `data-engineer-research-1`
- Project Number: `335415716363`
- Organization ID: `401231695336`
- Billing: Enabled
- Status: ACTIVE

**Verification**:
```bash
gcloud projects describe data-engineer-research-1
```

---

### ✅ Step 2: Enable Required APIs (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**APIs Enabled**:
1. ✅ Dataflow API (`dataflow.googleapis.com`)
2. ✅ BigQuery API (`bigquery.googleapis.com`)
3. ✅ Compute Engine API (`compute.googleapis.com`)
4. ✅ Cloud Storage API (`storage.googleapis.com`)

**Verification**:
```bash
gcloud services list --enabled --project=data-engineer-research-1 | grep -E "dataflow|bigquery|compute|storage"
```

---

### ✅ Step 3: Create Service Account (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Service Account Details**:
- Name: `dataflow-runner`
- Email: `dataflow-runner@data-engineer-research-1.iam.gserviceaccount.com`
- Display Name: Dataflow Runner Service Account

**IAM Roles Assigned**:
1. ✅ `roles/dataflow.worker` - Dataflow Worker
2. ✅ `roles/bigquery.dataEditor` - BigQuery Data Editor
3. ✅ `roles/storage.objectAdmin` - Storage Object Admin
4. ✅ `roles/bigquery.user` - BigQuery User (required for creating BigQuery jobs)

**Key File Downloaded**:
- Location: `/home/rajan/gcp-keys/data-engineer-research-1-d25e37a30533.json`
- Permissions: 644 (should be 600 for security)

**Verification**:
```bash
gcloud iam service-accounts describe dataflow-runner@data-engineer-research-1.iam.gserviceaccount.com
```

---

### ✅ Step 4: Create GCS Buckets (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Buckets Created**:

1. **Raw Data Bucket**
   - Name: `data-engineer-research-1-weather-raw`
   - Location: us-central1 (regional)
   - Storage Class: Standard
   - Purpose: Store raw weather JSON from OpenWeather API

2. **Temp Bucket**
   - Name: `data-engineer-research-1-weather-temp`
   - Location: us-central1 (regional)
   - Storage Class: Standard
   - Purpose: Dataflow temporary files and BigQuery staging

3. **Staging Bucket**
   - Name: `data-engineer-research-1-weather-staging`
   - Location: us-central1 (regional)
   - Storage Class: Standard
   - Purpose: Dataflow pipeline staging (code, dependencies)

**Verification**:
```bash
gsutil ls -p data-engineer-research-1
```

**Service Account Access**:
- ✅ Can read from buckets
- ✅ Can write to buckets
- ✅ Can delete from buckets
- ⚠️ Cannot list all buckets at project level (expected with Storage Object Admin role)

---

### ✅ Step 5: Create BigQuery Dataset and Table (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Dataset**:
- Project: `data-engineer-research-1`
- Dataset ID: `weather_data`
- Location: `US` (multi-region)
- Default table expiration: Never

**Table**:
- Table ID: `daily`
- Full name: `data-engineer-research-1:weather_data.daily`
- Type: Native table
- **Partitioning**: ✅ DAY partitioning on `date` field

**Schema** (14 fields):
```
city: STRING (REQUIRED)
country: STRING (REQUIRED)
latitude: FLOAT (REQUIRED)
longitude: FLOAT (REQUIRED)
temperature_celsius: FLOAT (NULLABLE)
feels_like_celsius: FLOAT (NULLABLE)
humidity_percent: INTEGER (NULLABLE)
pressure_hpa: INTEGER (NULLABLE)
weather_condition: STRING (NULLABLE)
weather_description: STRING (NULLABLE)
wind_speed_mps: FLOAT (NULLABLE)
clouds_percent: INTEGER (NULLABLE)
timestamp: TIMESTAMP (REQUIRED)
date: DATE (REQUIRED) ← PARTITION KEY
```

**Verification**:
```bash
bq show --format=prettyjson data-engineer-research-1:weather_data.daily
```

---

### ✅ Step 6: Set Up Local Development Environment (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Python Environment**:
- Python Version: `3.11.11`
- Virtual Environment: `venv-beam-demo-1`
- Location: `/home/rajan/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather/venv-beam-demo-1`

**Packages Installed**:
- ✅ Apache Beam: `2.52.0` (with GCP support)
- ✅ google-cloud-storage: `2.19.0`
- ✅ google-cloud-bigquery: `3.38.0`
- ✅ requests: `2.32.5`
- ✅ python-dotenv: `1.1.1`

**Activation Command**:
```bash
source venv-beam-demo-1/bin/activate
```

**Verification**:
```bash
python -c "import apache_beam as beam; print(f'Apache Beam: {beam.__version__}')"
python -c "from google.cloud import storage, bigquery; print('GCP libraries: OK')"
```

---

### ✅ Step 7: Configure Service Account Credentials (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**Credentials Configuration**:
- Service Account Key: `/home/rajan/gcp-keys/data-engineer-research-1-d25e37a30533.json`
- Environment Variable: `GOOGLE_APPLICATION_CREDENTIALS`

**Activation**:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/data-engineer-research-1-d25e37a30533.json
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
```

**Access Verified**:
- ✅ BigQuery: Can list datasets
- ✅ GCS Read: Can read from all 3 buckets
- ✅ GCS Write: Can write to buckets
- ✅ GCS Delete: Can delete from buckets

---

### ✅ Step 8: Get OpenWeather API Key and Fetch Data (COMPLETE)

**Status**: Complete
**Date**: 2025-10-19

**OpenWeather API**:
- API Key: `83a2fb662aa9f537528e59a40225f0fa` (stored in `.env`)
- Account: Registered and activated
- Plan: Free tier (60 calls/minute)

**Configuration Files Updated**:
1. `.env` (root directory)
2. `config/.env` (main config file)

**Environment Variables**:
```bash
OPENWEATHER_API_KEY=83a2fb662aa9f537528e59a40225f0fa
GCP_PROJECT_ID=data-engineer-research-1
GCS_RAW_BUCKET=data-engineer-research-1-weather-raw
RAW_BUCKET=data-engineer-research-1-weather-raw
```

**Weather Data Fetched**:
- Date: 2025-10-19
- Cities Attempted: 5 (London, Paris, NewYork, Tokyo, Sydney)
- Cities Succeeded: 4 (London, Paris, Tokyo, Sydney)
- Cities Failed: 1 (NewYork - should be "New York" with space)

**Data Uploaded to GCS**:
- ✅ File: `gs://data-engineer-research-1-weather-raw/raw/20251019/weather-20251019-143359.json`
- Size: 3.7 KiB (3,792 bytes)
- Records: 4 weather observations

**Verification**:
```bash
gsutil ls -lh gs://data-engineer-research-1-weather-raw/raw/20251019/
```

---

### ⏳ Step 9: Run Dataflow Pipeline (IN PROGRESS)

**Status**: Pending
**Next Action**: Run Apache Beam pipeline with DirectRunner

**Pipeline Command**:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/data-engineer-research-1-d25e37a30533.json
source venv-beam-demo-1/bin/activate

python src/transformation/weather_pipeline.py \
    --input "gs://data-engineer-research-1-weather-raw/raw/*/weather-*.json" \
    --output "data-engineer-research-1:weather_data.daily" \
    --runner DirectRunner \
    --project data-engineer-research-1 \
    --temp_location "gs://data-engineer-research-1-weather-temp/beam/temp"
```

**Expected Results**:
- Read 4 weather records from GCS
- Transform data (Kelvin to Celsius conversion)
- Add partition date field
- Load to BigQuery table `weather_data.daily`

**Verification** (after completion):
```bash
bq query --project_id=data-engineer-research-1 \
  "SELECT city, temperature_celsius, date FROM weather_data.daily ORDER BY date DESC LIMIT 10"
```

---

### ⏳ Step 10: Verify Data in BigQuery (PENDING)

**Status**: Not Started
**Prerequisites**: Step 9 must complete

**Verification Queries**:

1. **Count Records**:
```sql
SELECT COUNT(*) as total_records
FROM `data-engineer-research-1.weather_data.daily`
```

2. **View Sample Data**:
```sql
SELECT
  city,
  country,
  temperature_celsius,
  weather_description,
  date,
  timestamp
FROM `data-engineer-research-1.weather_data.daily`
ORDER BY timestamp DESC
LIMIT 10
```

3. **Check Partitioning**:
```sql
SELECT
  date,
  COUNT(*) as records_per_day
FROM `data-engineer-research-1.weather_data.daily`
GROUP BY date
ORDER BY date DESC
```

---

### ⏳ Step 11: Cleanup Resources (PENDING)

**Status**: Not Started
**When**: After project completion and learning

**Resources to Delete**:

1. **BigQuery**:
   ```bash
   bq rm -r -f -d data-engineer-research-1:weather_data
   ```

2. **GCS Buckets**:
   ```bash
   gsutil -m rm -r gs://data-engineer-research-1-weather-raw
   gsutil -m rm -r gs://data-engineer-research-1-weather-temp
   gsutil -m rm -r gs://data-engineer-research-1-weather-staging
   ```

3. **Service Account**:
   ```bash
   gcloud iam service-accounts delete dataflow-runner@data-engineer-research-1.iam.gserviceaccount.com --project data-engineer-research-1
   ```

4. **Service Account Key**:
   ```bash
   rm /home/rajan/gcp-keys/data-engineer-research-1-d25e37a30533.json
   ```

**Note**: GCP Project itself (`data-engineer-research-1`) may be kept for other certification projects.

---

## Key Differences from Original Project

| Resource | Original Project (475516) | New Project (research-1) |
|----------|--------------------------|-------------------------|
| **Project ID** | data-engineer-475516 | data-engineer-research-1 |
| **Project Number** | (not tracked) | 335415716363 |
| **Service Account** | dataflow-runner@...475516 | dataflow-runner@...research-1 |
| **Raw Bucket** | ...475516-weather-raw | ...research-1-weather-raw |
| **Temp Bucket** | ...475516-weather-temp | ...research-1-weather-temp |
| **Staging Bucket** | ...475516-weather-staging | ...research-1-weather-staging |
| **Virtual Env** | venv-beam | venv-beam-demo-1 |
| **Key File** | dev-sa-key.json | ...research-1-d25e37a30533.json |

---

## Issues Resolved

### 1. Configuration File Location
**Problem**: Script was reading from `config/.env` but user updated root `.env`
**Solution**: Copied root `.env` to `config/.env` with correct bucket names

### 2. Missing RAW_BUCKET Variable
**Problem**: Script expected `RAW_BUCKET` but `.env` had `GCS_RAW_BUCKET`
**Solution**: Added `RAW_BUCKET` variable to `.env` file

### 3. City Name Error
**Problem**: "NewYork" (no space) failed API call
**Expected**: "New York" (with space)
**Status**: Not fixed yet - can be updated in config if needed

---

## Environment Variables Summary

**Current Configuration** (from `config/.env`):

```bash
# OpenWeather API
OPENWEATHER_API_KEY=83a2fb662aa9f537528e59a40225f0fa

# GCP Project
GCP_PROJECT_ID=data-engineer-research-1
GCP_REGION=us-central1
GCP_ZONE=us-central1-a

# GCS Buckets
RAW_BUCKET=data-engineer-research-1-weather-raw
STAGING_BUCKET=data-engineer-research-1-weather-staging
TEMP_BUCKET=data-engineer-research-1-weather-temp
GCS_RAW_BUCKET=data-engineer-research-1-weather-raw

# BigQuery
BIGQUERY_DATASET=weather_data
BIGQUERY_TABLE=daily
BIGQUERY_LOCATION=US

# Dataflow
DATAFLOW_STAGING_LOCATION=gs://data-engineer-research-1-weather-staging/dataflow/staging
DATAFLOW_TEMP_LOCATION=gs://data-engineer-research-1-weather-temp/dataflow/temp
DATAFLOW_SERVICE_ACCOUNT=dataflow-runner@data-engineer-research-1.iam.gserviceaccount.com
```

---

## Next Steps

1. ⏳ **Run Dataflow Pipeline** (Step 9)
   - Execute Apache Beam pipeline with DirectRunner
   - Transform weather data
   - Load to BigQuery

2. ⏳ **Verify BigQuery Data** (Step 10)
   - Query the data
   - Check partitioning
   - Validate transformations

3. ⏳ **Optional: Deploy to Dataflow** (Advanced)
   - Run with DataflowRunner on GCP
   - Monitor job execution
   - Review costs

4. ⏳ **Cleanup** (Step 11)
   - Delete all resources
   - Document costs incurred
   - Preserve learning materials

---

## Cost Tracking

**Estimated Costs** (as of 2025-10-19):

| Resource | Usage | Estimated Cost |
|----------|-------|----------------|
| GCS Storage | ~4 KB | $0.00 (negligible) |
| BigQuery Storage | 0 rows (pending) | $0.00 |
| BigQuery Queries | 0 queries | $0.00 |
| Dataflow | Not used yet | $0.00 |
| API Calls | 5 calls | $0.00 (free tier) |
| **Total** | | **~$0.00** |

**Note**: Using DirectRunner keeps costs near $0. DataflowRunner would add ~$0.05-0.10 per run.

---

## References

- **Original Setup Guide**: `SETUP_FROM_SCRATCH.md`
- **Original Project Cleanup**: `CLEANUP_COMPLETE.md`
- **Project Summary**: `PROJECT_SUMMARY.md`
- **Environment Config**: `config/.env`

---

**Last Updated**: 2025-10-19
**Current Step**: 9/11 (Run Dataflow Pipeline)
**Next Action**: Execute pipeline with DirectRunner
