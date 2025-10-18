# GCP Environment Setup - Complete Summary

**Project**: data-engineer-475516
**Date**: 2025-10-18
**Status**: ✅ COMPLETED SUCCESSFULLY

---

## What Was Accomplished

### ✅ APIs Enabled (18 total)

**Core Infrastructure:**
```bash
gcloud services enable compute.googleapis.com iam.googleapis.com cloudresourcemanager.googleapis.com
```
- Compute Engine API (for VMs, networking)
- IAM API (for service accounts, permissions)
- Cloud Resource Manager API (for project management)

**Data Processing:**
```bash
gcloud services enable pubsub.googleapis.com dataflow.googleapis.com composer.googleapis.com dataproc.googleapis.com datafusion.googleapis.com
```
- Pub/Sub (messaging, streaming)
- Dataflow (Apache Beam pipelines)
- Cloud Composer (Apache Airflow orchestration)
- Dataproc (managed Spark/Hadoop)
- Data Fusion (visual ETL)

**Databases:**
```bash
gcloud services enable sqladmin.googleapis.com spanner.googleapis.com bigtable.googleapis.com
```
- Cloud SQL (MySQL/PostgreSQL/SQL Server)
- Spanner (globally distributed relational)
- Bigtable (NoSQL wide-column)

**Data Governance & Security:**
```bash
gcloud services enable datacatalog.googleapis.com dlp.googleapis.com cloudkms.googleapis.com
```
- Data Catalog (metadata management)
- DLP (Data Loss Prevention - PII detection)
- Cloud KMS (Key Management Service - encryption)

**Already Enabled:**
- BigQuery (data warehouse)
- Cloud Storage (object storage)
- Logging & Monitoring
- Dataform, Dataplex, Analytics Hub

---

### ✅ Service Accounts Created (3 total)

**1. Development Service Account**
```bash
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for local development and testing"
```
- Email: `dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com`
- Purpose: Running code locally, testing pipelines
- Roles granted:
  - `roles/bigquery.admin` - Full BigQuery access
  - `roles/storage.admin` - Full Cloud Storage access
  - `roles/pubsub.editor` - Create/delete topics/subscriptions
  - `roles/dataflow.developer` - Submit Dataflow jobs

**2. Dataflow Service Account**
```bash
gcloud iam service-accounts create dataflow-runner \
    --display-name="Dataflow Job Runner" \
    --description="Service account for running Dataflow pipelines"
```
- Email: `dataflow-runner@data-engineer-475516.iam.gserviceaccount.com`
- Purpose: Dataflow worker VMs run as this account
- Roles granted:
  - `roles/dataflow.worker` - Execute pipeline code
  - `roles/storage.objectAdmin` - Read/write Cloud Storage objects

**3. Composer Service Account**
```bash
gcloud iam service-accounts create composer-orchestrator \
    --display-name="Cloud Composer Orchestrator" \
    --description="Service account for Cloud Composer environments"
```
- Email: `composer-orchestrator@data-engineer-475516.iam.gserviceaccount.com`
- Purpose: Cloud Composer (Airflow) DAG execution
- (Roles will be granted when we create Composer environment)

---

### ✅ Configuration Set

**Default Region & Zone:**
```bash
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

**Service Account Key Created:**
```bash
gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
    --iam-account=dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
```
- Location: `/home/rajan/gcp-keys/dev-sa-key.json`
- Permissions: 600 (owner read/write only)
- Key ID: `9dd417efd57d7d5aaa48bf8f5a0ccd510e29d852`

**Environment Variables:**
```bash
# Added to ~/.bashrc
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"
```

**.env File Created:**
Location: `projects/00-gcp-environment-setup/config/.env`
```bash
GCP_PROJECT_ID=data-engineer-475516
GCP_PROJECT_NUMBER=434782524071
GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
GCP_REGION=us-central1
GCP_ZONE=us-central1-a
```

---

### ✅ Python Environment

**Virtual Environment:**
```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
python3 -m venv venv
source venv/bin/activate
```

**Packages Installed:**
```bash
pip install google-cloud-bigquery google-cloud-storage google-cloud-pubsub python-dotenv
```

Key packages:
- `google-cloud-bigquery==3.38.0` - BigQuery client library
- `google-cloud-storage==3.4.1` - Cloud Storage client library
- `google-cloud-pubsub==2.31.1` - Pub/Sub client library
- `python-dotenv==1.1.1` - Load environment variables from .env files

Plus ~30 dependencies (google-auth, grpcio, protobuf, etc.)

---

### ✅ Connection Test Results

**Test Script:**
```python
from google.cloud import bigquery, storage, pubsub_v1

project_id = "data-engineer-475516"

# Test BigQuery
bq_client = bigquery.Client(project=project_id)
query = "SELECT 1 as test"
result = list(bq_client.query(query).result())
# ✓ BigQuery connection successful

# Test Cloud Storage
storage_client = storage.Client(project=project_id)
buckets = list(storage_client.list_buckets(max_results=1))
# ✓ Cloud Storage connection successful (found 0 buckets)

# Test Pub/Sub
publisher = pubsub_v1.PublisherClient()
project_path = f"projects/{project_id}"
topics = list(publisher.list_topics(request={"project": project_path}))
# ✓ Pub/Sub connection successful (found 0 topics)
```

**Result:** ✅ All 3 services accessible

---

## How to Use This Setup

### 1. Activate Python Environment

Every time you work on the project:

```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
source venv/bin/activate
```

You'll see `(venv)` in your prompt.

### 2. Set Environment Variables

Either reload your shell:
```bash
source ~/.bashrc
```

Or export manually:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"
export GCP_PROJECT_ID="data-engineer-475516"
```

### 3. Test Connection Anytime

```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
source venv/bin/activate
python << 'EOF'
from google.cloud import bigquery
client = bigquery.Client(project="data-engineer-475516")
print("✓ Connected to BigQuery")
EOF
```

---

## Quick Reference Commands

### Check Configuration
```bash
# View project details
gcloud projects describe data-engineer-475516

# List enabled APIs
gcloud services list --enabled | grep -E "(bigquery|storage|pubsub|dataflow)"

# List service accounts
gcloud iam service-accounts list

# View IAM policy
gcloud projects get-iam-policy data-engineer-475516 \
    --filter="bindings.members:dev-data-engineer"

# Check current config
gcloud config list
```

### Python Environment
```bash
# Activate venv
source ~/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/bin/activate

# List installed packages
pip list | grep google-cloud

# Install additional packages
pip install package-name

# Deactivate venv
deactivate
```

### Working with BigQuery
```bash
# List datasets
bq ls --project_id=data-engineer-475516

# Create dataset
bq mk --project_id=data-engineer-475516 --location=US my_dataset

# Run query
bq query --project_id=data-engineer-475516 --use_legacy_sql=false \
    'SELECT 1 as test'
```

### Working with Cloud Storage
```bash
# List buckets
gsutil ls -p data-engineer-475516

# Create bucket
gsutil mb -p data-engineer-475516 -l us-central1 gs://data-engineer-475516-data

# Upload file
gsutil cp file.txt gs://data-engineer-475516-data/

# Download file
gsutil cp gs://data-engineer-475516-data/file.txt .
```

### Working with Pub/Sub
```bash
# Create topic
gcloud pubsub topics create test-topic --project=data-engineer-475516

# List topics
gcloud pubsub topics list --project=data-engineer-475516

# Publish message
gcloud pubsub topics publish test-topic \
    --message="Hello World" \
    --project=data-engineer-475516

# Create subscription
gcloud pubsub subscriptions create test-sub \
    --topic=test-topic \
    --project=data-engineer-475516

# Pull messages
gcloud pubsub subscriptions pull test-sub \
    --auto-ack \
    --project=data-engineer-475516
```

---

## Files Created

```
~/.bashrc
└── Added: export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"

~/gcp-keys/
└── dev-sa-key.json                                   # Service account key (600 permissions)

~/research/gcp/GCP-Data-Engineer-Cert-Prep/
├── venv/                                             # Python virtual environment
├── projects/00-gcp-environment-setup/
│   ├── README.md                                     # Project overview
│   ├── QUICKSTART.md                                 # Quick start guide
│   ├── setup-existing-project.sh                     # Automated setup script
│   ├── SETUP_EXECUTION_LOG.md                        # Detailed command reference
│   ├── SETUP_SUMMARY.md                              # This file
│   ├── setup.sh                                      # General setup reference
│   ├── cleanup.sh                                    # Resource cleanup
│   ├── commands.md                                   # Comprehensive CLI docs
│   ├── config/
│   │   ├── .env.template                            # Configuration template
│   │   └── .env                                     # Your configuration (DO NOT COMMIT)
│   └── src/
│       ├── requirements.txt                          # Python dependencies
│       └── test_connection.py                        # Connection test script
```

---

## Security Reminders

1. ✅ Service account key has 600 permissions (owner only)
2. ✅ Key file is in ~/gcp-keys (not in project directory)
3. ✅ .env file is in .gitignore (won't be committed to git)
4. ⚠️  NEVER commit service account keys to version control
5. ⚠️  Rotate keys every 90 days
6. ⚠️  Delete keys when no longer needed

---

## Cost Tracking

**Current costs:** $0.00

**Free tier used so far:**
- BigQuery: 1 query (SELECT 1) - negligible
- Cloud Storage: 0 GB stored
- Pub/Sub: 0 messages

**Services enabled but not used yet:**
- Dataflow, Composer, Dataproc, etc. (no cost until we use them)

**Set up billing alerts:**
1. Go to: https://console.cloud.google.com/billing
2. Select your billing account
3. Click "Budgets & alerts"
4. Create budget: $50/month
5. Set alerts at: 50%, 90%, 100%

---

## Next Steps

### Option 1: Start Project 1 (Recommended)
```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
# (Project 1 will be created when you're ready)
```

**Project 1:** Batch ETL Pipeline - Weather Data Warehouse
- Ingest from OpenWeather API
- Store in Cloud Storage
- Transform with Dataflow
- Load into BigQuery
- Schedule with Composer
- Visualize with Looker Studio

### Option 2: Explore GCP Services Manually

**Create your first BigQuery dataset:**
```bash
bq mk --project_id=data-engineer-475516 --location=US learning_dataset
```

**Create your first Cloud Storage bucket:**
```bash
gsutil mb -p data-engineer-475516 -l us-central1 gs://data-engineer-475516-learning
```

**Create your first Pub/Sub topic:**
```bash
gcloud pubsub topics create my-first-topic --project=data-engineer-475516
```

### Option 3: Install Additional Python Packages

For the full set of GCP libraries:
```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
source venv/bin/activate
pip install apache-beam[gcp] pandas numpy pyarrow
```

---

## Troubleshooting

### Issue: Virtual environment not activating
```bash
# On Linux/Mac
source ~/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/bin/activate

# On Windows (Git Bash/WSL)
source ~/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/Scripts/activate
```

### Issue: "Permission denied" errors
```bash
# Check IAM roles
gcloud projects get-iam-policy data-engineer-475516 \
    --flatten="bindings[].members" \
    --filter="bindings.members:dev-data-engineer"

# Verify service account key is set
echo $GOOGLE_APPLICATION_CREDENTIALS
# Should output: /home/rajan/gcp-keys/dev-sa-key.json
```

### Issue: "API not enabled" errors
```bash
# Enable the API
gcloud services enable SERVICE_NAME.googleapis.com --project=data-engineer-475516

# Example for Dataflow
gcloud services enable dataflow.googleapis.com --project=data-engineer-475516
```

### Issue: Python import errors
```bash
# Make sure venv is activated
which python
# Should output: /home/rajan/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/bin/python

# Reinstall package
pip install --force-reinstall google-cloud-bigquery
```

---

## Documentation References

**Created Documentation:**
- [README.md](README.md) - Project overview
- [QUICKSTART.md](QUICKSTART.md) - Quick start for existing projects
- [SETUP_EXECUTION_LOG.md](SETUP_EXECUTION_LOG.md) - Detailed command explanations
- [SETUP_SUMMARY.md](SETUP_SUMMARY.md) - This summary
- [commands.md](commands.md) - Comprehensive gcloud CLI reference

**Official GCP Documentation:**
- [gcloud CLI](https://cloud.google.com/sdk/gcloud/reference)
- [IAM](https://cloud.google.com/iam/docs)
- [BigQuery](https://cloud.google.com/bigquery/docs)
- [Cloud Storage](https://cloud.google.com/storage/docs)
- [Pub/Sub](https://cloud.google.com/pubsub/docs)
- [Dataflow](https://cloud.google.com/dataflow/docs)

---

## Certification Exam Mapping

**This setup covers:**
- ✅ Section 1.1: Security and Compliance (IAM, service accounts)
- ✅ Section 1.3: Flexibility and Portability (project organization)
- ✅ Section 5.1: Resource Optimization (cost management awareness)
- ✅ Section 5.4: Monitoring and Troubleshooting (logging enabled)

**Still to learn in future projects:**
- Section 1.2: Reliability and Fidelity (data pipelines)
- Section 1.4: Data Migrations (transfer services)
- Section 2: Ingesting and Processing Data (all pipeline topics)
- Section 3: Storing the Data (data modeling, optimization)
- Section 4: Preparing and Using Data for Analysis (BI, ML)
- Section 5.5: Failure Mitigation (DR, multi-region)

---

## Success Checklist

- [x] GCP project created and active
- [x] Billing enabled
- [x] 18+ APIs enabled
- [x] 3 service accounts created
- [x] IAM roles granted correctly
- [x] Service account key created and secured
- [x] Environment variables configured
- [x] Python virtual environment set up
- [x] GCP Python libraries installed
- [x] Connection to BigQuery tested ✅
- [x] Connection to Cloud Storage tested ✅
- [x] Connection to Pub/Sub tested ✅
- [x] Documentation created
- [ ] Proceed to Project 1

---

**Setup completed:** 2025-10-18
**Total setup time:** ~15 minutes
**Status:** ✅ READY FOR PROJECT 1

**Your GCP Data Engineering journey starts now! 🚀**
