# Quick Reference Guide - Weather ETL Pipeline

## 📋 Essential Commands

### 1. Environment Setup

```bash
# Navigate to project
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Activate Python 3.11 environment
source venv-beam/bin/activate

# Set GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
```

---

## 🚀 Run Dataflow Pipeline

### Option 1: Helper Script (Easiest)

```bash
bash run_dataflow_job.sh
```

### Option 2: Manual Command

```bash
JOB_NAME="weather-transform-$(date +%Y%m%d-%H%M%S)"

python src/transformation/weather_pipeline.py \
    --input "gs://data-engineer-475516-weather-raw/raw/*/weather-*.json" \
    --output "data-engineer-475516:weather_data.daily" \
    --runner DataflowRunner \
    --project data-engineer-475516 \
    --region us-central1 \
    --temp_location "gs://data-engineer-475516-weather-temp/dataflow/temp" \
    --staging_location "gs://data-engineer-475516-weather-staging/dataflow/staging" \
    --service_account_email "dataflow-runner@data-engineer-475516.iam.gserviceaccount.com" \
    --max_num_workers 2 \
    --num_workers 1 \
    --machine_type n1-standard-1 \
    --disk_size_gb 30 \
    --job_name "${JOB_NAME}" \
    --setup_file ./setup.py
```

### Option 3: Local Testing (DirectRunner)

```bash
python src/transformation/weather_pipeline.py \
    --input "gs://data-engineer-475516-weather-raw/raw/*/weather-*.json" \
    --output "data-engineer-475516:weather_data.daily" \
    --runner DirectRunner \
    --temp_location "gs://data-engineer-475516-weather-temp/beam-temp"
```

---

## 📊 BigQuery Queries

### Count Total Records

```bash
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) as total FROM \`data-engineer-475516.weather_data.daily\`"
```

### View Sample Data

```bash
bq query --use_legacy_sql=false \
  "SELECT
    city,
    country,
    temperature_c,
    weather_main,
    timestamp
   FROM \`data-engineer-475516.weather_data.daily\`
   ORDER BY city
   LIMIT 10"
```

### Check Latest Records by Date

```bash
bq query --use_legacy_sql=false \
  "SELECT
    date,
    COUNT(*) as record_count,
    COUNT(DISTINCT city) as unique_cities
   FROM \`data-engineer-475516.weather_data.daily\`
   GROUP BY date
   ORDER BY date DESC
   LIMIT 7"
```

### Temperature Analysis

```bash
bq query --use_legacy_sql=false \
  "SELECT
    city,
    ROUND(AVG(temperature_c), 1) as avg_temp_c,
    ROUND(MIN(temperature_c), 1) as min_temp_c,
    ROUND(MAX(temperature_c), 1) as max_temp_c,
    COUNT(*) as readings
   FROM \`data-engineer-475516.weather_data.daily\`
   GROUP BY city
   ORDER BY avg_temp_c DESC"
```

---

## 🔍 Monitor Dataflow Jobs

### List Active Jobs

```bash
gcloud dataflow jobs list \
    --region=us-central1 \
    --status=active \
    --project=data-engineer-475516
```

### List Recent Jobs (All Statuses)

```bash
gcloud dataflow jobs list \
    --region=us-central1 \
    --limit=10 \
    --project=data-engineer-475516
```

### Describe Specific Job

```bash
# Replace <JOB_ID> with your actual job ID
gcloud dataflow jobs describe <JOB_ID> \
    --region=us-central1 \
    --project=data-engineer-475516
```

### View Job Logs

```bash
gcloud dataflow jobs show-logs <JOB_ID> \
    --region=us-central1 \
    --project=data-engineer-475516
```

### Cancel a Running Job

```bash
gcloud dataflow jobs cancel <JOB_ID> \
    --region=us-central1 \
    --project=data-engineer-475516
```

---

## 📁 Cloud Storage Operations

### List Raw Data Files

```bash
gsutil ls -lh gs://data-engineer-475516-weather-raw/raw/*/
```

### View File Contents

```bash
gsutil cat gs://data-engineer-475516-weather-raw/raw/20251018/weather-*.json | jq
```

### Check Bucket Sizes

```bash
gsutil du -sh gs://data-engineer-475516-weather-raw
gsutil du -sh gs://data-engineer-475516-weather-staging
gsutil du -sh gs://data-engineer-475516-weather-temp
```

---

## 🧪 Testing & Validation

### Run Unit Tests

```bash
# Activate venv
source venv-beam/bin/activate

# Run tests with coverage
pytest tests/test_pipeline.py --cov=src --cov-report=term-missing
```

### Validate Data Quality

```bash
python src/utils/data_validator.py
```

---

## 🛠️ Troubleshooting

### Check Python Version

```bash
python --version  # Should show 3.11.11
```

### Verify GCP Credentials

```bash
gcloud auth list
gcloud config list project
```

### Check Service Account Permissions

```bash
gcloud projects get-iam-policy data-engineer-475516 \
    --flatten="bindings[].members" \
    --filter="bindings.members:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com"
```

### View Cloud Logging for Dataflow

```bash
gcloud logging read \
    "resource.type=dataflow_step AND resource.labels.job_id=<JOB_ID>" \
    --limit=50 \
    --project=data-engineer-475516 \
    --format="table(timestamp,textPayload)"
```

---

## 📚 Documentation Files

- **[README.md](README.md)** - Complete project documentation
- **[BEAM_PIPELINE_SUCCESS.md](BEAM_PIPELINE_SUCCESS.md)** - Beam pipeline implementation guide
- **[DATAFLOW_DEPLOYMENT_SUCCESS.md](DATAFLOW_DEPLOYMENT_SUCCESS.md)** - Comprehensive deployment guide with all issues/solutions
- **[BEAM_ENVIRONMENT_SETUP.md](BEAM_ENVIRONMENT_SETUP.md)** - Python 3.11 environment setup guide

---

## 🌐 Useful URLs

### GCP Console Links

- **Dataflow Jobs**: https://console.cloud.google.com/dataflow/jobs?project=data-engineer-475516
- **BigQuery Console**: https://console.cloud.google.com/bigquery?project=data-engineer-475516
- **Cloud Storage**: https://console.cloud.google.com/storage/browser?project=data-engineer-475516
- **Cloud Logging**: https://console.cloud.google.com/logs?project=data-engineer-475516

### Last Successful Job

- **Job ID**: `2025-10-18_13_02_44-17948874085318719194`
- **Status**: ✅ JOB_STATE_DONE
- **Console**: https://console.cloud.google.com/dataflow/jobs/us-central1/2025-10-18_13_02_44-17948874085318719194?project=data-engineer-475516

---

## 💰 Cost Management

### Check Current Costs

```bash
# View Dataflow job costs
gcloud dataflow jobs list \
    --region=us-central1 \
    --format="table(id,name,createTime,state)" \
    --project=data-engineer-475516

# Estimate: ~$0.05-0.10 per Dataflow run
```

### Cleanup Resources

```bash
# Delete old Dataflow staging files (>7 days)
gsutil -m rm -r gs://data-engineer-475516-weather-staging/dataflow/**

# Delete temp files
gsutil -m rm -r gs://data-engineer-475516-weather-temp/**
```

---

## 🎯 Project Status

### ✅ Completed
- [x] Python 3.11 environment setup
- [x] Apache Beam pipeline implementation
- [x] Local testing (DirectRunner)
- [x] Production Dataflow deployment
- [x] BigQuery table with 18 weather records
- [x] Helper scripts (run_dataflow_job.sh)

### ⏳ In Progress
- [ ] Cloud Composer setup
- [ ] Airflow DAG deployment
- [ ] Daily scheduling

### 📅 Pending
- [ ] Looker Studio dashboard
- [ ] Historical data backfill
- [ ] Alert configuration

---

**Last Updated**: 2025-10-19
**Pipeline Version**: 1.0
**Status**: ✅ Fully Operational (Dataflow)
