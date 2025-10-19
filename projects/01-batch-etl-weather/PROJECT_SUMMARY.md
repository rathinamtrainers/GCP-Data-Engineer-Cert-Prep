# Project 1: Weather ETL Pipeline - Complete Summary

## 📊 Executive Summary

A production-ready batch ETL pipeline that extracts weather data from OpenWeather API, stores it in Google Cloud Storage, transforms it using Apache Beam/Dataflow, and loads it into BigQuery with optimal partitioning and clustering.

**Current Status**: ✅ Phase 1 (Dataflow) Complete | ⏳ Phase 2 (Composer) In Progress

---

## 🎯 Project Goals

1. **Build a scalable data pipeline** using Google Cloud Platform services
2. **Learn Apache Beam** for data transformation at scale
3. **Deploy to Dataflow** for distributed processing
4. **Orchestrate with Airflow** (Cloud Composer) for daily automation
5. **Visualize data** in Looker Studio dashboards
6. **Apply GCP Data Engineer certification concepts** in a real project

---

## 🏗️ Architecture

```
┌─────────────────┐
│ OpenWeather API │ (External data source)
└────────┬────────┘
         │ HTTP GET
         ↓
┌─────────────────────────┐
│ Cloud Storage (Raw)     │ Data Lake - Raw Zone
│ gs://...-raw/YYYYMMDD/  │
└────────┬────────────────┘
         │ Read JSON Arrays
         ↓
┌─────────────────────────┐
│ Apache Beam Pipeline    │ Transformation Layer
│ (Dataflow Workers)      │
│ • ReadJSONArray         │
│ • ParseWeatherData      │
│ • ValidateWeatherData   │
│ • WriteToBigQuery       │
└────────┬────────────────┘
         │ FILE_LOADS
         ↓
┌─────────────────────────┐
│ BigQuery Table          │ Data Warehouse
│ weather_data.daily      │
│ • Partitioned by date   │
│ • Clustered by city     │
└────────┬────────────────┘
         │ Queries
         ↓
┌─────────────────────────┐
│ Looker Studio Dashboard │ Visualization Layer
│ • Temperature trends    │
│ • City comparisons      │
└─────────────────────────┘

         ↑ Scheduled by
┌─────────────────────────┐
│ Cloud Composer (Airflow)│ Orchestration Layer
│ DAG: 6:00 AM UTC daily  │
└─────────────────────────┘
```

---

## ✅ What's Working

### Phase 1: Apache Beam/Dataflow - COMPLETE ✅

**Achievements**:
- ✅ Python 3.11 environment set up with pyenv
- ✅ Custom `ReadJSONArray` DoFn for JSON array files
- ✅ Temperature conversion (Kelvin → Celsius → Fahrenheit)
- ✅ Data quality validation (temperature, humidity, pressure ranges)
- ✅ Local testing with DirectRunner (0 cost, fast iteration)
- ✅ Production deployment to Dataflow
- ✅ BigQuery table with 18 weather records loaded
- ✅ Helper script (`run_dataflow_job.sh`) for easy deployment

**Last Successful Run**:
```
Job ID: 2025-10-18_13_02_44-17948874085318719194
Status: ✅ JOB_STATE_DONE
Records: 18 weather observations (9 cities)
Duration: ~3.5 minutes
Cost: ~$0.05-0.10
Console: https://console.cloud.google.com/dataflow/jobs/us-central1/2025-10-18_13_02_44-17948874085318719194?project=data-engineer-475516
```

**Key Code Components**:

1. **Custom JSON Array Reader** (`src/transformation/weather_pipeline.py:50-79`)
   - Handles JSON arrays (not line-delimited JSON)
   - Reads entire file and yields individual records

2. **Data Transformation** (`src/transformation/weather_pipeline.py:81-176`)
   - Parses OpenWeather API response
   - Converts Kelvin to Celsius and Fahrenheit
   - Extracts 20+ weather metrics

3. **Data Validation** (`src/transformation/weather_pipeline.py:177-206`)
   - Temperature range: -50°C to 60°C
   - Humidity: 0-100%
   - Pressure: 800-1100 hPa
   - Beam metrics tracking

4. **Package Configuration** (`setup.py`)
   - Fixed for `src/` directory structure
   - `find_packages(where='src')`
   - `package_dir={'': 'src'}`

**Issues Resolved**:
- ❌ → ✅ Python 3.13 incompatibility (switched to 3.11)
- ❌ → ✅ JSON array parsing (created custom DoFn)
- ❌ → ✅ setup.py package discovery (added `where='src'`)
- ❌ → ✅ BigQuery IAM permissions (granted `dataEditor` + `jobUser`)
- ❌ → ✅ Service account impersonation (granted `serviceAccountUser`)
- ❌ → ✅ Job name validation (pre-generated in shell variable)

📖 **Full Details**: [DATAFLOW_DEPLOYMENT_SUCCESS.md](DATAFLOW_DEPLOYMENT_SUCCESS.md)

---

## ⏳ In Progress

### Phase 2: Cloud Composer - IN PROGRESS ⏳

**Current Status**: Troubleshooting IAM permissions

**Issue**: Cloud Composer Service Agent missing required role
- **Service Account**: `service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com`
- **Required Role**: `roles/composer.ServiceAgentV2Ext`
- **Error**: `FAILED_PRECONDITION: missing permissions: iam.serviceAccounts.getIamPolicy, iam.serviceAccounts.setIamPolicy`

**Next Steps**:
1. Grant `roles/composer.ServiceAgentV2Ext` to Service Agent
2. Retry environment creation (~20-30 min)
3. Upload DAG to Composer
4. Test DAG execution
5. Configure daily schedule (6:00 AM UTC)

**Learnings So Far**:
- ❌ Composer 2.X doesn't support `--python-version` flag (tied to image)
- ❌ Composer 2.X doesn't support `--node-count` flag (auto-scales)
- ✅ Composer 2.X requires explicit `--service-account` parameter
- ⏳ Composer 2.X Service Agent needs `composer.ServiceAgentV2Ext` role

📖 **Full Details**: [COMPOSER_SETUP_ISSUES.md](COMPOSER_SETUP_ISSUES.md)

---

## 📅 Pending

### Phase 3: Looker Studio Dashboard - PENDING 📅

**Planned Features**:
- Temperature trends over time
- City-by-city comparisons
- Weather condition distribution
- Min/max temperature ranges
- Real-time data refresh from BigQuery

**Data Source**: `data-engineer-475516.weather_data.daily`

---

## 📂 Project Files

### Documentation

| File | Purpose |
|------|---------|
| **README.md** | Complete project documentation |
| **PROJECT_SUMMARY.md** | This file - high-level overview |
| **QUICK_REFERENCE.md** | Essential commands and queries |
| **DATAFLOW_DEPLOYMENT_SUCCESS.md** | Comprehensive Dataflow deployment guide |
| **BEAM_PIPELINE_SUCCESS.md** | Beam pipeline implementation details |
| **BEAM_ENVIRONMENT_SETUP.md** | Python 3.11 environment setup |
| **COMPOSER_SETUP_ISSUES.md** | Cloud Composer troubleshooting |

### Code

| File | Purpose |
|------|---------|
| **src/transformation/weather_pipeline.py** | Apache Beam pipeline (main) |
| **src/ingestion/fetch_weather.py** | OpenWeather API fetcher |
| **src/utils/data_validator.py** | Data quality validation |
| **src/utils/bigquery_schema.py** | BigQuery table schema |
| **dags/weather_etl_dag.py** | Airflow DAG for orchestration |
| **setup.py** | Package configuration for Dataflow |
| **run_dataflow_job.sh** | Helper script for job submission |

### Configuration

| File | Purpose |
|------|---------|
| **config/.env.template** | Environment variables template |
| **config/pipeline-config.yaml** | Dataflow configuration |
| **.python-version** | pyenv Python 3.11.11 marker |
| **venv-beam/** | Python 3.11 virtual environment |

---

## 💡 Key Technical Decisions

### 1. Why Python 3.11?

**Issue**: Apache Beam 2.53.0 doesn't support Python 3.13
**Solution**: Used pyenv to install Python 3.11.11
**Trade-off**: Separate environment needed, but ensures compatibility

### 2. Why Custom ReadJSONArray DoFn?

**Issue**: Weather files are JSON arrays `[{...}, {...}]`, not line-delimited JSON
**Built-in Solution**: `ReadFromText` reads line-by-line (doesn't work)
**Custom Solution**: Read entire file, parse JSON, yield individual records
**Trade-off**: Slightly more memory usage, but handles our data format correctly

### 3. Why DirectRunner First?

**Benefit**: Fast feedback loop (7 seconds vs 3.5 minutes)
**Cost**: $0 (runs locally)
**Use Case**: Development, testing, debugging transformations
**When to Switch**: Production workloads, large datasets (>1 GB), need for scaling

### 4. Why BigQuery Partitioning by Date?

**Performance**: Queries scan only relevant date partitions
**Cost**: Reduces data scanned (lower query costs)
**Example**: Query last 7 days → scans 7 partitions instead of full table
**Trade-off**: None (partitioning is free in BigQuery)

### 5. Why Clustering by City?

**Performance**: Data sorted within partitions by city
**Use Case**: Queries filtering by specific cities are faster
**Example**: "Show London temperature last week"
**Trade-off**: None (clustering is free, applied automatically)

---

## 📊 Performance & Cost

### Dataflow Job Performance

| Metric | Value |
|--------|-------|
| **Startup Time** | ~1 minute |
| **Processing Time** | ~2.5 minutes |
| **Total Duration** | ~3.5 minutes |
| **Workers Used** | 1-2 (auto-scaled) |
| **Machine Type** | n1-standard-1 |
| **Records Processed** | 18 |
| **Data Size** | ~50 KB |

### Cost Breakdown

| Service | Cost per Run | Monthly (Daily Runs) |
|---------|--------------|----------------------|
| **Dataflow** | $0.05-0.10 | $1.50-3.00 |
| **BigQuery Storage** | Negligible | $0.02 |
| **Cloud Storage** | Negligible | $0.002 |
| **Cloud Composer** | N/A (pending) | ~$300 |

**Total without Composer**: ~$2-3/month
**Total with Composer**: ~$300-303/month

**Cost Optimization**:
- Delete Composer after learning (saves $10/day)
- Use scheduled Cloud Functions instead (~$0.10/month)
- Or use cron job on a VM (~$5/month)

---

## 🎓 Certification Topics Covered

### Section 1: Designing Data Processing Systems (~22%)
- ✅ **1.2 Reliability and Fidelity**
  - Data preparation with Dataflow
  - Pipeline monitoring and error handling
  - Data validation techniques

### Section 2: Ingesting and Processing Data (~25%)
- ✅ **2.1 Planning Data Pipelines**
  - Defining sources (API) and sinks (BigQuery)
  - Transformation logic design
  - Data encryption (in transit via HTTPS, at rest in GCS/BQ)
- ✅ **2.2 Building Pipelines**
  - Data cleansing strategies
  - Apache Beam programming model (DoFn, PCollection)
  - Batch transformations
  - Service selection (Dataflow vs Dataproc)
- ⏳ **2.3 Deploying and Operationalizing**
  - Cloud Composer (Airflow) DAGs
  - CI/CD concepts for data pipelines

### Section 3: Storing the Data (~20%)
- ✅ **3.1 Storage System Selection**
  - Cloud Storage for data lake (raw zone)
  - BigQuery for data warehouse (processed zone)
  - Storage lifecycle management
- ✅ **3.2 Data Warehouse (BigQuery)**
  - Data modeling (denormalized for analytics)
  - Partitioning by date
  - Clustering by city
  - Data access patterns

### Section 4: Preparing and Using Data for Analysis (~15%)
- 📅 **4.1 Data Visualization**
  - BI tool connections (Looker Studio)
  - Query optimization techniques

### Section 5: Maintaining and Automating Workloads (~18%)
- ✅ **5.1 Resource Optimization**
  - Cost minimization (ephemeral Dataflow, scheduled jobs)
- ✅ **5.4 Monitoring and Troubleshooting**
  - Cloud Logging for pipeline debugging
  - Dataflow job monitoring

---

## 🚀 Quick Start Commands

### Run Dataflow Pipeline

```bash
# Option 1: Use helper script
bash run_dataflow_job.sh

# Option 2: Manual command
source venv-beam/bin/activate
export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
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
    --machine_type n1-standard-1 \
    --job_name "${JOB_NAME}" \
    --setup_file ./setup.py
```

### Query BigQuery

```bash
# Count records
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) FROM \`data-engineer-475516.weather_data.daily\`"

# View data
bq query --use_legacy_sql=false \
  "SELECT city, temperature_c, weather_main
   FROM \`data-engineer-475516.weather_data.daily\`
   ORDER BY city LIMIT 10"
```

📖 **More Commands**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## 🔧 Environment Setup

### Requirements

- **Python 3.11.11** (via pyenv)
- **GCP Project** with billing enabled
- **Service Account** with required permissions
- **OpenWeather API Key** (free tier)

### Setup Steps

```bash
# 1. Install Python 3.11
pyenv install 3.11.11
pyenv local 3.11.11

# 2. Create virtual environment
python -m venv venv-beam
source venv-beam/bin/activate

# 3. Install dependencies
pip install 'apache-beam[gcp]==2.53.0'

# 4. Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/key.json

# 5. Run pipeline
bash run_dataflow_job.sh
```

📖 **Full Setup**: [BEAM_ENVIRONMENT_SETUP.md](BEAM_ENVIRONMENT_SETUP.md)

---

## 📈 Project Roadmap

### ✅ Completed (Phase 1)
- [x] Project planning and architecture design
- [x] Python 3.11 environment setup
- [x] Apache Beam pipeline development
- [x] Custom JSON array reader
- [x] Data transformation logic
- [x] Data quality validation
- [x] Local testing (DirectRunner)
- [x] BigQuery table design
- [x] IAM permissions configuration
- [x] Dataflow deployment
- [x] Production job execution
- [x] Helper scripts creation
- [x] Comprehensive documentation

### ⏳ In Progress (Phase 2)
- [ ] Cloud Composer IAM configuration
- [ ] Composer environment creation
- [ ] DAG upload and testing
- [ ] Daily schedule configuration

### 📅 Planned (Phase 3+)
- [ ] Looker Studio dashboard
- [ ] Historical data backfill
- [ ] Alert configuration (email/Slack)
- [ ] CI/CD pipeline setup
- [ ] Cost optimization review
- [ ] Performance tuning
- [ ] Additional cities/data sources

---

## 🎯 Success Metrics

### Technical Metrics
- ✅ Pipeline successfully processes 100% of records (18/18)
- ✅ Zero data quality issues (0 invalid records)
- ✅ Job completion time < 5 minutes
- ✅ Cost per run < $0.10
- ⏳ Daily automation working (pending Composer)

### Learning Metrics
- ✅ Hands-on experience with 6 GCP services
- ✅ Deep understanding of Apache Beam
- ✅ Production pipeline deployment
- ✅ Troubleshooting and problem-solving skills
- ✅ IAM and security best practices
- ⏳ Airflow/orchestration experience (pending)

---

## 🔗 Useful Links

### GCP Console
- [Dataflow Jobs](https://console.cloud.google.com/dataflow/jobs?project=data-engineer-475516)
- [BigQuery Tables](https://console.cloud.google.com/bigquery?project=data-engineer-475516)
- [Cloud Storage](https://console.cloud.google.com/storage/browser?project=data-engineer-475516)
- [Cloud Logging](https://console.cloud.google.com/logs?project=data-engineer-475516)

### Documentation
- [Apache Beam Python SDK](https://beam.apache.org/documentation/sdks/python/)
- [Cloud Dataflow](https://cloud.google.com/dataflow/docs)
- [BigQuery](https://cloud.google.com/bigquery/docs)
- [Cloud Composer](https://cloud.google.com/composer/docs)

---

## 👥 Contributors

- **Primary Developer**: Data Engineering Team
- **Documentation**: Complete and up-to-date as of 2025-10-19
- **Status**: Production-ready (Phase 1), Active development (Phase 2)

---

**Last Updated**: 2025-10-19
**Pipeline Version**: 1.0
**Status**: ✅ Phase 1 Complete | ⏳ Phase 2 In Progress
