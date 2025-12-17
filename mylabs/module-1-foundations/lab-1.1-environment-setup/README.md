# Lab 1.1: Environment Setup

## Objective

Configure your local environment to work with BigQuery using:
- gcloud CLI authentication
- bq command-line tool
- Python client library

## Prerequisites

- Google Cloud account (free tier works)
- GCP Project with billing enabled
- gcloud CLI installed ([Install Guide](https://cloud.google.com/sdk/docs/install))
- Python 3.9+

## Estimated Time

15-20 minutes

## Cost

FREE - This lab uses only authentication and metadata queries

---

## Part 1: gcloud CLI Setup

### Step 1.1: Verify gcloud Installation

```bash
gcloud version
```

Expected output shows gcloud version and components.

### Step 1.2: Authenticate with Google Cloud

```bash
gcloud auth login
```

This opens a browser for Google account authentication.

### Step 1.3: Set Your Default Project

```bash
# List available projects
gcloud projects list

# Set default project (replace YOUR_PROJECT_ID)
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud config get-value project
```

### Step 1.4: Enable BigQuery API

```bash
gcloud services enable bigquery.googleapis.com

# Verify it's enabled
gcloud services list --enabled --filter="name:bigquery"
```

### Step 1.5: Set Application Default Credentials (ADC)

```bash
gcloud auth application-default login
```

This creates credentials that Python and other libraries use automatically.

---

## Part 2: bq CLI Verification

### Step 2.1: Test bq CLI

```bash
# Show bq version
bq version

# List datasets in your project
bq ls

# List public datasets (to verify connectivity)
bq ls bigquery-public-data:
```

### Step 2.2: Run Your First Query

```bash
# Query public data (free)
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) as total_words FROM \`bigquery-public-data.samples.shakespeare\`"
```

Expected output: ~164,656 words

### Step 2.3: Explore bq Help

```bash
# General help
bq help

# Help for specific command
bq help query
bq help mk
bq help ls
```

---

## Part 3: Python Environment Setup

### Step 3.1: Create Virtual Environment

```bash
# Navigate to lab directory
cd mylabs/module-1-foundations/lab-1.1-environment-setup

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Linux/Mac)
# source venv/bin/activate
```

### Step 3.2: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 3.3: Set Environment Variable

```bash
# Windows (PowerShell)
$env:GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"

# Windows (CMD)
set GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID

# Linux/Mac
export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID
```

### Step 3.4: Run Verification Script

```bash
python verify_setup.py
```

---

## Part 4: Verification Checklist

Run these commands and verify all pass:

| Check | Command | Expected Result |
|-------|---------|-----------------|
| gcloud auth | `gcloud auth list` | Shows active account |
| Project set | `gcloud config get-value project` | Your project ID |
| BigQuery API | `gcloud services list --enabled --filter="name:bigquery"` | bigquery.googleapis.com |
| bq works | `bq ls bigquery-public-data:` | List of datasets |
| Python works | `python verify_setup.py` | All checks pass |

---

## Common Issues & Solutions

### Issue: "gcloud not found"
**Solution**: Add gcloud to PATH or reinstall Google Cloud SDK

### Issue: "Permission denied" on BigQuery
**Solution**: Ensure BigQuery API is enabled and you have BigQuery User role

### Issue: Python can't authenticate
**Solution**: Run `gcloud auth application-default login` again

### Issue: "No project set"
**Solution**: Run `gcloud config set project YOUR_PROJECT_ID`

---

## Key Concepts Learned

1. **gcloud CLI**: Primary tool for GCP resource management
2. **bq CLI**: Specialized BigQuery command-line tool
3. **ADC (Application Default Credentials)**: Automatic credential discovery for libraries
4. **Project hierarchy**: All BigQuery resources belong to a project

---

## Next Lab

Proceed to **Lab 1.2: Dataset Operations** to create your first BigQuery dataset.
