# Apache Beam Environment - Setup Complete

## ✅ Installation Summary

Apache Beam environment with Python 3.11 is now fully configured and ready to use!

---

## Environment Details

**Python Version:** 3.11.11
**Virtual Environment:** `venv-beam/`
**Apache Beam Version:** 2.53.0
**Location:** `/home/rajan/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather/`

---

## Installed Packages

### Core
- ✅ **apache-beam 2.53.0** - Main Beam library
- ✅ **python-dotenv** - Environment configuration
- ✅ **requests** - HTTP client
- ✅ **pytest & pytest-cov** - Testing framework

### Google Cloud Integrations
- ✅ **google-cloud-storage 2.19.0** - Cloud Storage client
- ✅ **google-cloud-bigquery 3.38.0** - BigQuery client
- ✅ **google-cloud-pubsub 2.31.1** - Pub/Sub client
- ✅ **google-cloud-datastore 2.21.0** - Datastore client
- ✅ **google-cloud-bigtable 2.33.0** - Bigtable client
- ✅ **google-cloud-spanner 3.58.0** - Spanner client
- ✅ Plus 10+ additional GCP service integrations

---

## How to Use This Environment

### Activate the Environment

```bash
# Navigate to project directory
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Activate the Beam environment
source venv-beam/bin/activate

# Verify Python version
python --version
# Should show: Python 3.11.11
```

### Deactivate the Environment

```bash
deactivate
```

---

## Running the Beam Pipeline

### Option 1: Local Testing (DirectRunner)

Runs the pipeline on your local machine for testing:

```bash
# Activate environment
source venv-beam/bin/activate

# Set project ID
export PROJECT_ID=data-engineer-475516

# Run pipeline locally
python src/transformation/weather_pipeline.py \
    --input "gs://${PROJECT_ID}-weather-raw/raw/*/weather-*.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DirectRunner
```

**Pros:**
- ✅ Fast feedback
- ✅ Easy debugging
- ✅ No GCP costs

**Cons:**
- ❌ Runs on single machine
- ❌ Limited scalability

---

### Option 2: Cloud Dataflow (DataflowRunner)

Runs the pipeline as a managed Dataflow job on GCP:

```bash
# Activate environment
source venv-beam/bin/activate

# Set variables
export PROJECT_ID=data-engineer-475516
export REGION=us-central1

# Run on Dataflow
python src/transformation/weather_pipeline.py \
    --input "gs://${PROJECT_ID}-weather-raw/raw/*/weather-*.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DataflowRunner \
    --project ${PROJECT_ID} \
    --region ${REGION} \
    --temp_location "gs://${PROJECT_ID}-weather-temp/dataflow/temp" \
    --staging_location "gs://${PROJECT_ID}-weather-staging/dataflow/staging" \
    --service_account_email "dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --max_num_workers 2 \
    --machine_type n1-standard-1
```

**Pros:**
- ✅ Fully managed service
- ✅ Auto-scaling
- ✅ Production-ready

**Cons:**
- ❌ Takes 5-10 min to start
- ❌ ~$0.10 per run

---

## Testing the Pipeline

### Run Unit Tests

```bash
source venv-beam/bin/activate
pytest tests/test_pipeline.py -v
```

### Test with Sample Data

```bash
# Use the test data file
source venv-beam/bin/activate

python src/transformation/weather_pipeline.py \
    --input "data/test_weather.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DirectRunner
```

---

## Monitoring Dataflow Jobs

### List Running Jobs

```bash
gcloud dataflow jobs list --region=us-central1 --status=active
```

### View Job Details

```bash
gcloud dataflow jobs describe JOB_ID --region=us-central1
```

### View Job Logs

```bash
gcloud dataflow jobs show-logs JOB_ID --region=us-central1
```

### Open Dataflow Console

```bash
# Get job URL
echo "https://console.cloud.google.com/dataflow/jobs/${REGION}/JOB_ID"
```

---

## Troubleshooting

### Issue: Module not found

**Solution:**
```bash
# Make sure you're in the venv-beam environment
source venv-beam/bin/activate

# Check Python version
python --version  # Should be 3.11.11
```

### Issue: Authentication errors

**Solution:**
```bash
# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-keys/dev-sa-key.json

# Test auth
gcloud auth application-default print-access-token
```

### Issue: Dataflow job fails to start

**Solution:**
```bash
# Check quotas
gcloud compute project-info describe --project=${PROJECT_ID}

# Verify service account permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:dataflow-runner"
```

---

## Cost Estimates

### Local DirectRunner
- **Cost:** $0 (runs locally)
- **Speed:** Instant startup
- **Use for:** Testing, development

### Cloud Dataflow
- **Cost:** ~$0.10 per run (2 workers, 10 min)
- **Speed:** 5-10 min startup, then fast
- **Use for:** Production, large datasets

**Tip:** Use DirectRunner for testing, Dataflow for production!

---

## Next Steps

1. **Test locally** - Run with DirectRunner first
2. **Verify results** - Check BigQuery for data
3. **Deploy to Dataflow** - Test cloud deployment
4. **Create helper script** - Automate Dataflow jobs
5. **Schedule with Composer** - Automate daily runs

---

## Environment Comparison

| Feature | Main venv (Python 3.13) | Beam venv (Python 3.11) |
|---------|-------------------------|-------------------------|
| Python Version | 3.13.4 | 3.11.11 |
| Apache Beam | ❌ Not compatible | ✅ 2.53.0 |
| Use For | General development | Beam pipelines only |
| Activate | `source venv/bin/activate` | `source venv-beam/bin/activate` |

---

## Quick Reference Commands

```bash
# Activate Beam environment
source venv-beam/bin/activate

# Check Python version
python --version

# Check installed packages
pip list | grep -E "apache-beam|google-cloud"

# Run pipeline locally
python src/transformation/weather_pipeline.py \
    --input "data/test_weather.json" \
    --output "PROJECT:DATASET.TABLE" \
    --runner DirectRunner

# Run pipeline on Dataflow
python src/transformation/weather_pipeline.py \
    --input "gs://bucket/path/*.json" \
    --output "PROJECT:DATASET.TABLE" \
    --runner DataflowRunner \
    --project PROJECT_ID \
    --region REGION \
    --temp_location "gs://bucket/temp" \
    --staging_location "gs://bucket/staging"

# Deactivate environment
deactivate
```

---

## Support & Resources

- **Apache Beam Docs:** https://beam.apache.org/documentation/
- **Dataflow Guide:** https://cloud.google.com/dataflow/docs
- **Python SDK Reference:** https://beam.apache.org/releases/pydoc/current/

---

**Environment Status:** ✅ Ready for Development

Last Updated: 2025-01-19
