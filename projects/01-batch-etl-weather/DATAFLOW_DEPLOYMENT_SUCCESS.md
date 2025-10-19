# ✅ Google Cloud Dataflow - Successfully Deployed!

## Summary

The Apache Beam pipeline has been successfully deployed to Google Cloud Dataflow and completed a production run, processing weather data from Cloud Storage to BigQuery!

---

## 🎉 Deployment Results

### Dataflow Job Details
- **Job ID**: `2025-10-18_13_02_44-17948874085318719194`
- **Status**: ✅ **JOB_STATE_DONE** (Successfully Completed)
- **Date**: October 19, 2025
- **Duration**: ~3.5 minutes
- **Worker Configuration**: 1-2 workers, n1-standard-1 machines
- **Region**: us-central1

### Console URL
https://console.cloud.google.com/dataflow/jobs/us-central1/2025-10-18_13_02_44-17948874085318719194?project=data-engineer-475516

### Processing Results
- **Files Processed**: 2 JSON files from GCS
- **Records Loaded**: 18 weather observations
- **Cities**: 9 unique locations
- **Date Range**: 2025-10-18
- **Validation**: 100% success rate (0 invalid records)
- **BigQuery Table**: `data-engineer-475516.weather_data.daily`

---

## Issues Resolved

### 1. setup.py Package Configuration ✅

**Problem**: Dataflow workers couldn't import custom modules (`utils`, `transformation`)
```
ModuleNotFoundError: No module named 'utils'
```

**Root Cause**: `setuptools.find_packages()` didn't specify the `src/` directory structure

**Solution**: Updated `setup.py`
```python
setuptools.setup(
    name='weather-pipeline',
    version='1.0.0',
    packages=setuptools.find_packages(where='src'),  # ← Added
    package_dir={'': 'src'},                          # ← Added
    install_requires=REQUIRED_PACKAGES,
)
```

**Verification**:
```bash
python -c "import setuptools; print(setuptools.find_packages(where='src'))"
# Output: ['transformation', 'ingestion', 'utils']
```

---

### 2. BigQuery IAM Permissions ✅

**Problem**: Dataflow workers couldn't create BigQuery load jobs
```
HttpError 403: User does not have bigquery.jobs.create permission
```

**Solution**: Granted necessary IAM roles to `dataflow-runner` service account

```bash
# Grant BigQuery Data Editor role (read/write data)
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

# Grant BigQuery Job User role (create jobs)
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"
```

---

### 3. Service Account Impersonation ✅

**Problem**: Dev service account couldn't impersonate Dataflow service account
```
HttpError 403: Current user cannot act as service account dataflow-runner@...
```

**Solution**: Granted Service Account User role

```bash
gcloud iam service-accounts add-iam-policy-binding \
    dataflow-runner@data-engineer-475516.iam.gserviceaccount.com \
    --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"
```

---

### 4. Job Name Validation ✅

**Problem**: Shell command substitution not executing in parameter
```
ValueError: Invalid job_name (weather-transform-$(date +%Y%m%d-%H%M%S))
```

**Solution**: Generate job name in shell variable first

```bash
# WRONG - command not evaluated
--job_name "weather-transform-$(date +%Y%m%d-%H%M%S)"

# CORRECT - evaluate in variable first
JOB_NAME="weather-transform-$(date +%Y%m%d-%H%M%S)"
python src/transformation/weather_pipeline.py --job_name "${JOB_NAME}"
```

---

## Deployment Command

### Successful Dataflow Submission

```bash
# Set environment
export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
source venv-beam/bin/activate

# Generate unique job name
JOB_NAME="weather-transform-$(date +%Y%m%d-%H%M%S)"

# Submit to Dataflow
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

---

## Helper Script Created

**File**: `run_dataflow_job.sh`

Simplifies job submission with predefined configuration:

```bash
#!/bin/bash
# Submit Dataflow job with all parameters
bash run_dataflow_job.sh
```

**Features**:
- Auto-generates unique job names
- Sets all required environment variables
- Configures worker pools and machine types
- Provides console URLs for monitoring

---

## Data Verification

### BigQuery Record Count

```sql
SELECT
    COUNT(*) as total_records,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    COUNT(DISTINCT city) as unique_cities
FROM `data-engineer-475516.weather_data.daily`
```

**Results**:
| total_records | earliest_date | latest_date | unique_cities |
|---------------|---------------|-------------|---------------|
| 18            | 2025-10-18    | 2025-10-18  | 9             |

### Sample Data

```sql
SELECT city, country, temperature_c, weather_main, timestamp
FROM `data-engineer-475516.weather_data.daily`
ORDER BY city
LIMIT 5
```

| City      | Country | Temp (°C) | Weather | Timestamp           |
|-----------|---------|-----------|---------|---------------------|
| Berlin    | DE      | 6.7       | Clear   | 2025-10-18 18:12:00 |
| Dubai     | AE      | 31.0      | Clear   | 2025-10-18 18:12:00 |
| London    | GB      | 12.7      | Clouds  | 2025-10-18 18:20:00 |
| Mumbai    | IN      | 30.0      | Smoke   | 2025-10-18 18:08:00 |
| Paris     | FR      | 13.1      | Clear   | 2025-10-18 18:19:00 |

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Dataflow Pipeline Flow                   │
└─────────────────────────────────────────────────────────────┘

  GCS Files (JSON Arrays)
         ↓
   [CreateFilePaths]
         ↓
   ReadJSONArray DoFn ← Custom implementation for JSON arrays
         ↓
   ParseWeatherData DoFn ← Kelvin → Celsius/Fahrenheit
         ↓
   ValidateWeatherData DoFn ← Quality checks (temp, humidity, pressure)
         ↓
   WriteToBigQuery ← FILE_LOADS method with staging
         ↓
   BigQuery Table (weather_data.daily)
    - Partitioned by: date
    - Clustered by: city, country
```

---

## Performance Metrics

### Dataflow Job Performance

| Metric                  | Value              |
|-------------------------|--------------------|
| **Total Duration**      | ~3.5 minutes       |
| **Startup Time**        | ~1 minute          |
| **Processing Time**     | ~2.5 minutes       |
| **Workers Used**        | 1-2 (auto-scaled)  |
| **Machine Type**        | n1-standard-1      |
| **Records/Second**      | ~0.12 (small dataset) |

### Cost Estimate

**Dataflow Job Cost**: ~$0.05-0.10 per run
- Worker hours: ~0.1 hours × 1-2 workers
- Machine type: n1-standard-1 ($0.0475/hour)
- Storage I/O: Negligible for small dataset

---

## Comparison: DirectRunner vs DataflowRunner

| Feature           | DirectRunner (Local)     | DataflowRunner (Cloud)      |
|-------------------|--------------------------|----------------------------|
| **Execution**     | Single local machine     | Distributed cloud workers  |
| **Startup Time**  | ~2 seconds              | ~1 minute                  |
| **Processing**    | ~5 seconds              | ~2.5 minutes               |
| **Total Time**    | ~7 seconds              | ~3.5 minutes               |
| **Cost**          | $0                      | ~$0.05-0.10                |
| **Scalability**   | Limited by local resources | Auto-scaling to 100s of workers |
| **Best For**      | Development/testing      | Production workloads       |

**Recommendation**: Use DirectRunner for testing, DataflowRunner for production

---

## Key Learnings

### 1. Composer 2.X Flags Changed
- ❌ `--python-version` not supported (Python version tied to image)
- ❌ `--node-count` not supported (auto-scales based on size)
- ✅ Use `--environment-size` (small/medium/large)

### 2. Service Account Permissions Required
For Dataflow workers to function properly:
- `bigquery.dataEditor` - Read/write BigQuery data
- `bigquery.jobUser` - Create BigQuery jobs
- `storage.objectAdmin` - Read/write GCS objects
- `dataflow.worker` - Execute as Dataflow worker
- `iam.serviceAccountUser` - Impersonate service account

### 3. setup.py Package Discovery
When using custom package structure (`src/` directory):
```python
packages=setuptools.find_packages(where='src')
package_dir={'': 'src'}
```

### 4. Shell Variable Expansion
Command substitution in parameters requires pre-evaluation:
```bash
# Generate first, then use
JOB_NAME="job-$(date +%Y%m%d-%H%M%S)"
--job_name "${JOB_NAME}"
```

---

## Files Modified/Created

### Modified Files
1. **setup.py** - Fixed package discovery for `src/` structure
2. **BEAM_PIPELINE_SUCCESS.md** - Updated with Dataflow success

### Created Files
1. **run_dataflow_job.sh** - Helper script for Dataflow submission
2. **DATAFLOW_DEPLOYMENT_SUCCESS.md** - This documentation

---

## Next Steps

### ✅ Phase 1 Complete: Apache Beam/Dataflow
- [x] Python 3.11 environment setup
- [x] Local pipeline testing (DirectRunner)
- [x] Dataflow deployment (DataflowRunner)
- [x] Helper scripts creation

### ⏳ Phase 2 In Progress: Cloud Composer
- [ ] Create Composer environment (~20-30 min)
- [ ] Upload DAG and scripts
- [ ] Test DAG execution
- [ ] Schedule daily runs

### ⏳ Phase 3 Pending: Looker Studio
- [ ] Create dashboard
- [ ] Add visualizations
- [ ] Share access

---

## Monitoring & Operations

### Check Job Status

```bash
# List recent jobs
gcloud dataflow jobs list \
    --region=us-central1 \
    --status=active \
    --project=data-engineer-475516

# Describe specific job
gcloud dataflow jobs describe <JOB_ID> \
    --region=us-central1 \
    --format=json
```

### View Logs

```bash
# Cloud Logging
gcloud logging read \
    "resource.type=dataflow_step AND resource.labels.job_id=<JOB_ID>" \
    --limit=50 \
    --project=data-engineer-475516
```

### Cancel Job

```bash
gcloud dataflow jobs cancel <JOB_ID> \
    --region=us-central1
```

---

**Status**: ✅ **FULLY OPERATIONAL**
**Date**: October 19, 2025
**Pipeline Version**: 1.0
**Next Task**: Complete Cloud Composer setup for orchestration
