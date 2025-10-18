# Quick Start Guide - Existing GCP Project

This guide is for users who already have:
- ✓ gcloud CLI installed
- ✓ Authenticated with GCP
- ✓ A GCP project created

**Your Project**: `data-engineer-475516`
**Your Account**: `rajan@rathinamtrainers.com`

## Current Status Check

Let's verify what you already have and complete the remaining setup.

### Step 1: Verify Current Configuration

```bash
# Check your current configuration
gcloud config list

# Verify you're authenticated
gcloud auth list

# Check your project details
gcloud projects describe data-engineer-475516
```

### Step 2: Verify Billing

**Important**: Make sure billing is enabled for your project.

```bash
# Check billing status
gcloud billing projects describe data-engineer-475516

# If billing is not enabled, list your billing accounts
gcloud billing accounts list

# Link billing account (replace BILLING_ACCOUNT_ID with your actual ID)
# gcloud billing projects link data-engineer-475516 \
#     --billing-account=BILLING_ACCOUNT_ID
```

### Step 3: Enable Required APIs

Enable the essential APIs for data engineering projects:

```bash
# Enable core APIs
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable logging.googleapis.com

# Enable data engineering APIs
gcloud services enable storage.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable composer.googleapis.com

# Verify enabled APIs
gcloud services list --enabled
```

### Step 4: Set Default Region and Zone

Choose a region close to you:

```bash
# For US users
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# For Europe users
# gcloud config set compute/region europe-west1
# gcloud config set compute/zone europe-west1-b

# For Asia users
# gcloud config set compute/region asia-southeast1
# gcloud config set compute/zone asia-southeast1-a
```

### Step 5: Create Service Accounts

Create service accounts for different purposes:

```bash
# Development service account
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for local development and testing"

# Dataflow service account
gcloud iam service-accounts create dataflow-runner \
    --display-name="Dataflow Job Runner" \
    --description="Service account for running Dataflow pipelines"

# Composer service account
gcloud iam service-accounts create composer-orchestrator \
    --display-name="Cloud Composer Orchestrator" \
    --description="Service account for Cloud Composer environments"

# Verify service accounts were created
gcloud iam service-accounts list
```

### Step 6: Grant IAM Roles

Grant necessary permissions to the service accounts:

```bash
# Set project ID variable
export PROJECT_ID="data-engineer-475516"

# Grant roles to dev service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/pubsub.editor"

# Grant roles to Dataflow service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/dataflow.worker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

# Verify IAM policies
gcloud projects get-iam-policy $PROJECT_ID
```

### Step 7: Create Service Account Key

Create a key for local development:

```bash
# Create directory for keys
mkdir -p ~/gcp-keys

# Create key for dev service account
gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
    --iam-account=dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com

# Set file permissions (Linux/Mac)
chmod 600 ~/gcp-keys/dev-sa-key.json

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"

# Make it permanent by adding to your shell config
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"' >> ~/.bashrc
# Or for zsh users:
# echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"' >> ~/.zshrc
```

### Step 8: Set Up Environment Variables

Create your local configuration:

```bash
# Navigate to project directory
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/00-gcp-environment-setup/config

# Copy the template
cp .env.template .env

# Edit the .env file
nano .env
# or
vim .env
```

Update `.env` with your values:
```bash
GCP_PROJECT_ID=data-engineer-475516
GCP_PROJECT_NUMBER=<your-project-number>
GCP_REGION=us-central1
GCP_ZONE=us-central1-a
GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
BIGQUERY_DATASET=dev_dataset
GCS_BUCKET_NAME=data-engineer-475516-data
```

### Step 9: Set Up Python Environment

```bash
# Navigate to project root
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r projects/00-gcp-environment-setup/src/requirements.txt
```

### Step 10: Test Your Setup

```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Run the test script
python projects/00-gcp-environment-setup/src/test_connection.py
```

Expected output:
```
======================================================================
  GCP Environment Test
======================================================================

======================================================================
  Checking Authentication
======================================================================
✓ Authentication successful
ℹ️  Default project: data-engineer-475516

======================================================================
  Testing BigQuery Connection
======================================================================
✓ BigQuery connection successful

======================================================================
  Testing Cloud Storage Connection
======================================================================
✓ Cloud Storage connection successful

======================================================================
  Testing Pub/Sub Connection
======================================================================
✓ Pub/Sub connection successful

======================================================================
  Summary
======================================================================
Tests passed: 4/4
✓ All tests passed! Your GCP environment is ready.
```

## Troubleshooting

### Issue: API not enabled error
**Solution**: Enable the API
```bash
gcloud services enable SERVICE_NAME.googleapis.com
```

### Issue: Permission denied
**Solution**: Check IAM roles
```bash
gcloud projects get-iam-policy data-engineer-475516
```

### Issue: Billing not enabled
**Solution**: Enable billing in the console or via CLI
```bash
gcloud billing projects link data-engineer-475516 \
    --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### Issue: Python test script fails
**Solution**: Make sure:
1. Virtual environment is activated
2. Dependencies are installed
3. `GOOGLE_APPLICATION_CREDENTIALS` is set
4. Service account has necessary permissions

## Quick Command Reference

```bash
# Set project (if needed)
gcloud config set project data-engineer-475516

# List enabled APIs
gcloud services list --enabled

# List service accounts
gcloud iam service-accounts list

# Check configuration
gcloud config list

# View logs
gcloud logging read "resource.type=global" --limit=10
```

## Next Steps

Once all tests pass:

1. ✓ Your GCP environment is ready!
2. → Proceed to **Project 1: Batch ETL Pipeline - Weather Data Warehouse**
3. → Or explore the existing tutorial: `tutorials/0010-pubsub-python/`

## Cost Management

Remember to:
- Set up billing alerts (Cloud Console)
- Review costs regularly
- Clean up resources after each project
- Use the cleanup scripts provided

---

**You're all set! Ready to build your first data pipeline.**
