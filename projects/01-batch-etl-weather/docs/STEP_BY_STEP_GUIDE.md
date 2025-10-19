# Project 1: Weather ETL Pipeline - Complete Step-by-Step Guide

## Overview

This guide provides **complete instructions** for building Project 1 from scratch in a new GCP project. Each step includes **both GCP Console UI and CLI instructions** so you can choose your preferred method.

**Total Time:** 2-3 hours (excluding Composer setup)
**Difficulty:** Beginner to Intermediate
**Cost:** $1-2 (or $5-10 if using Composer)

---

## Table of Contents

1. [Prerequisites & Initial Setup](#1-prerequisites--initial-setup)
2. [Get OpenWeather API Key](#2-get-openweather-api-key)
3. [Create Cloud Storage Buckets](#3-create-cloud-storage-buckets)
4. [Create BigQuery Resources](#4-create-bigquery-resources)
5. [Setup Development Environment](#5-setup-development-environment)
6. [Run Data Ingestion](#6-run-data-ingestion)
7. [Load Data to BigQuery](#7-load-data-to-bigquery)
8. [Verification & Testing](#8-verification--testing)
9. [Optional: Setup Cloud Composer](#9-optional-setup-cloud-composer)
10. [Cleanup Resources](#10-cleanup-resources)

---

## 1. Prerequisites & Initial Setup

### Step 1.1: Create a New GCP Project

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/
2. Click on project dropdown at the top
3. Click "NEW PROJECT"
4. Enter Project Name: `weather-etl-project`
5. (Optional) Edit Project ID if you want a custom ID
6. Click "CREATE"
7. Wait 30 seconds for project creation
8. Switch to the new project using the dropdown

**💻 CLI:**
```bash
# Create new project
gcloud projects create weather-etl-project-12345 \
    --name="Weather ETL Project"

# Set as default project
gcloud config set project weather-etl-project-12345

# Verify current project
gcloud config get-value project
```

**✔️ Verify:**
```bash
gcloud projects describe $(gcloud config get-value project)
```

---

### Step 1.2: Link Billing Account

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/billing
2. Select your project from the list
3. Click "LINK A BILLING ACCOUNT"
4. Select your billing account
5. Click "SET ACCOUNT"

**💻 CLI:**
```bash
# List available billing accounts
gcloud billing accounts list

# Link billing account to project
gcloud billing projects link $(gcloud config get-value project) \
    --billing-account=BILLING_ACCOUNT_ID
```

**✔️ Verify:**
```bash
gcloud billing projects describe $(gcloud config get-value project)
```

---

### Step 1.3: Enable Required APIs

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/apis/library
2. Search and enable each of these APIs (click "ENABLE"):
   - Cloud Storage API
   - BigQuery API
   - Dataflow API (optional, for future use)
   - Cloud Composer API (optional, for scheduling)
   - Compute Engine API

**💻 CLI:**
```bash
# Enable all required APIs at once
gcloud services enable \
    storage.googleapis.com \
    bigquery.googleapis.com \
    dataflow.googleapis.com \
    composer.googleapis.com \
    compute.googleapis.com

# This may take 2-3 minutes
```

**✔️ Verify:**
```bash
# List enabled services
gcloud services list --enabled | grep -E "storage|bigquery|dataflow"
```

---

### Step 1.4: Create Service Account for Development

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts
2. Click "CREATE SERVICE ACCOUNT"
3. **Service account details:**
   - Name: `dev-data-engineer`
   - ID: `dev-data-engineer` (auto-filled)
   - Description: `Development service account for weather pipeline`
4. Click "CREATE AND CONTINUE"
5. **Grant roles** (click "Add Another Role" for each):
   - `BigQuery Admin`
   - `Storage Admin`
   - `Dataflow Developer`
6. Click "CONTINUE"
7. Click "DONE"

**💻 CLI:**
```bash
# Set project ID variable
PROJECT_ID=$(gcloud config get-value project)

# Create service account
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for weather pipeline development"

# Grant BigQuery Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"

# Grant Storage Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Grant Dataflow Developer role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/dataflow.developer"
```

**✔️ Verify:**
```bash
gcloud iam service-accounts list --filter="email:dev-data-engineer"
```

---

### Step 1.5: Create Service Account Key

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts
2. Click on `dev-data-engineer` service account
3. Go to "KEYS" tab
4. Click "ADD KEY" → "Create new key"
5. Select "JSON"
6. Click "CREATE"
7. Key file downloads automatically
8. Save it to a secure location: `~/gcp-keys/dev-sa-key.json`

**💻 CLI:**
```bash
# Create keys directory
mkdir -p ~/gcp-keys

# Create and download key
gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
    --iam-account=dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com

# Secure the key file
chmod 600 ~/gcp-keys/dev-sa-key.json
```

**✔️ Verify:**
```bash
ls -l ~/gcp-keys/dev-sa-key.json
```

---

### Step 1.6: Set Authentication Environment Variable

**💻 CLI:**
```bash
# Set for current session
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-keys/dev-sa-key.json

# Add to your shell profile for persistence
echo 'export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-keys/dev-sa-key.json' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc
```

**✔️ Verify:**
```bash
# Check environment variable
echo $GOOGLE_APPLICATION_CREDENTIALS

# Test authentication
gcloud auth application-default print-access-token
```

---

### Step 1.7: Create Service Account for Dataflow

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts
2. Click "CREATE SERVICE ACCOUNT"
3. **Service account details:**
   - Name: `dataflow-runner`
   - ID: `dataflow-runner`
   - Description: `Service account for Dataflow job execution`
4. Click "CREATE AND CONTINUE"
5. **Grant roles:**
   - `Dataflow Worker`
   - `Storage Object Admin`
   - `BigQuery Data Editor`
6. Click "CONTINUE"
7. Click "DONE"

**💻 CLI:**
```bash
# Create Dataflow service account
gcloud iam service-accounts create dataflow-runner \
    --display-name="Dataflow Runner" \
    --description="Service account for Dataflow job execution"

# Grant Dataflow Worker role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/dataflow.worker"

# Grant Storage Object Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

# Grant BigQuery Data Editor role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"
```

**✔️ Verify:**
```bash
gcloud iam service-accounts list --filter="email:dataflow-runner"
```

---

## 2. Get OpenWeather API Key

### Step 2.1: Sign Up for OpenWeather API

**🖱️ Browser:**
1. Go to https://openweathermap.org/api
2. Click "Sign Up" (top right)
3. Fill in registration form:
   - Username
   - Email
   - Password
   - Agree to terms
4. Click "Create Account"
5. Verify your email address (check inbox)

---

### Step 2.2: Get API Key

**🖱️ Browser:**
1. Log in to https://home.openweathermap.org/
2. Go to "API keys" tab
3. Default key is already created
4. Copy the API key (looks like: `83a2fb662aa9f537528e59a40225f0fa`)
5. Save it securely

**⚠️ Note:**
- Free tier allows 60 calls/minute, 1,000,000 calls/month
- API key activation takes ~10 minutes
- Test your key: `https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY`

---

## 3. Create Cloud Storage Buckets

### Step 3.1: Create Raw Data Bucket

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Click "CREATE BUCKET"
3. **Name your bucket:**
   - Bucket name: `YOUR_PROJECT_ID-weather-raw`
   - Must be globally unique
4. **Choose where to store:**
   - Location type: `Region`
   - Region: `us-central1`
5. **Choose a storage class:**
   - Select: `Standard`
6. **Control access:**
   - Uncheck "Enforce public access prevention"
   - Access control: `Uniform`
7. **Protection tools:**
   - Leave defaults
8. Click "CREATE"

**💻 CLI:**
```bash
# Set project ID
PROJECT_ID=$(gcloud config get-value project)

# Create raw data bucket
gsutil mb -p $PROJECT_ID -l us-central1 -c STANDARD \
    gs://${PROJECT_ID}-weather-raw

# Verify bucket created
gsutil ls -p $PROJECT_ID | grep weather-raw
```

**✔️ Verify:**
```bash
gsutil ls -L -b gs://${PROJECT_ID}-weather-raw
```

---

### Step 3.2: Create Staging Bucket

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Click "CREATE BUCKET"
3. **Name:** `YOUR_PROJECT_ID-weather-staging`
4. **Location:** Region → `us-central1`
5. **Storage class:** Standard
6. **Access control:** Uniform
7. Click "CREATE"

**💻 CLI:**
```bash
gsutil mb -p $PROJECT_ID -l us-central1 -c STANDARD \
    gs://${PROJECT_ID}-weather-staging
```

---

### Step 3.3: Create Temp Bucket

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Click "CREATE BUCKET"
3. **Name:** `YOUR_PROJECT_ID-weather-temp`
4. **Location:** Region → `us-central1`
5. **Storage class:** Standard
6. **Access control:** Uniform
7. Click "CREATE"

**💻 CLI:**
```bash
gsutil mb -p $PROJECT_ID -l us-central1 -c STANDARD \
    gs://${PROJECT_ID}-weather-temp
```

**✔️ Verify All Buckets:**
```bash
gsutil ls -p $PROJECT_ID | grep weather
```

Expected output:
```
gs://YOUR_PROJECT_ID-weather-raw/
gs://YOUR_PROJECT_ID-weather-staging/
gs://YOUR_PROJECT_ID-weather-temp/
```

---

### Step 3.4: Set Lifecycle Policy on Temp Bucket

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Click on `YOUR_PROJECT_ID-weather-temp` bucket
3. Go to "LIFECYCLE" tab
4. Click "ADD A RULE"
5. **Select action:**
   - Check "Delete object"
6. Click "CONTINUE"
7. **Select conditions:**
   - Check "Age"
   - Enter: `7` days
8. Click "CONTINUE"
9. Click "CREATE"

**💻 CLI:**
```bash
# Create lifecycle configuration file
cat > /tmp/lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 7}
      }
    ]
  }
}
EOF

# Apply lifecycle policy
gsutil lifecycle set /tmp/lifecycle.json gs://${PROJECT_ID}-weather-temp

# Clean up temp file
rm /tmp/lifecycle.json
```

**✔️ Verify:**
```bash
gsutil lifecycle get gs://${PROJECT_ID}-weather-temp
```

---

## 4. Create BigQuery Resources

### Step 4.1: Create BigQuery Dataset

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/bigquery
2. Click on your project in the left panel
3. Click the three dots (⋮) next to project name
4. Click "Create dataset"
5. **Dataset ID:** `weather_data`
6. **Data location:** `US (multiple regions in US)`
7. **Default table expiration:** Leave blank (never expire)
8. Click "CREATE DATASET"

**💻 CLI:**
```bash
# Create dataset
bq mk --project_id=$PROJECT_ID \
    --location=US \
    --description="Weather data from OpenWeather API" \
    weather_data
```

**✔️ Verify:**
```bash
bq ls --project_id=$PROJECT_ID
```

---

### Step 4.2: Create BigQuery Table with Schema

First, create the schema file locally:

**💻 Create Schema File:**
```bash
# Create sql directory
mkdir -p ~/weather-etl/sql

# Create schema file
cat > ~/weather-etl/sql/schema.json << 'EOF'
[
  {
    "name": "date",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "Date of weather observation"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "Exact timestamp of observation"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "City name"
  },
  {
    "name": "country",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Country code (ISO 3166)"
  },
  {
    "name": "latitude",
    "type": "FLOAT64",
    "mode": "REQUIRED",
    "description": "Latitude coordinate"
  },
  {
    "name": "longitude",
    "type": "FLOAT64",
    "mode": "REQUIRED",
    "description": "Longitude coordinate"
  },
  {
    "name": "temperature_c",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Temperature in Celsius"
  },
  {
    "name": "temperature_f",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Temperature in Fahrenheit"
  },
  {
    "name": "feels_like_c",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Feels like temperature in Celsius"
  },
  {
    "name": "temp_min_c",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Minimum temperature in Celsius"
  },
  {
    "name": "temp_max_c",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Maximum temperature in Celsius"
  },
  {
    "name": "pressure_hpa",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Atmospheric pressure in hPa"
  },
  {
    "name": "humidity_percent",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Humidity percentage"
  },
  {
    "name": "visibility_m",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Visibility in meters"
  },
  {
    "name": "wind_speed_ms",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "Wind speed in m/s"
  },
  {
    "name": "wind_direction_deg",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Wind direction in degrees"
  },
  {
    "name": "clouds_percent",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Cloudiness percentage"
  },
  {
    "name": "weather_main",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Main weather condition"
  },
  {
    "name": "weather_description",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Detailed weather description"
  },
  {
    "name": "sunrise_timestamp",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Sunrise time"
  },
  {
    "name": "sunset_timestamp",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Sunset time"
  },
  {
    "name": "data_source",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Source of weather data"
  },
  {
    "name": "ingestion_timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "When data was ingested into BigQuery"
  }
]
EOF
```

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/bigquery
2. Click on `weather_data` dataset
3. Click "CREATE TABLE"
4. **Create table from:** Empty table
5. **Destination:**
   - Project: Your project
   - Dataset: `weather_data`
   - Table: `daily`
   - Table type: Native table
6. **Schema:**
   - Click "Edit as text"
   - Toggle ON
   - Copy-paste the schema JSON from above
7. **Partition and cluster settings:**
   - Partitioning: `Partition by field`
   - Partition field: `date`
   - Partition type: `Daily`
   - Clustering: `city,country` (comma-separated)
8. Click "CREATE TABLE"

**💻 CLI:**
```bash
# Create table with partitioning and clustering
bq mk --project_id=$PROJECT_ID \
    --table \
    --time_partitioning_field=date \
    --time_partitioning_type=DAY \
    --clustering_fields=city,country \
    --description="Daily weather data from OpenWeather API" \
    weather_data.daily \
    ~/weather-etl/sql/schema.json
```

**✔️ Verify:**
```bash
# View table details
bq show --format=prettyjson $PROJECT_ID:weather_data.daily

# Check partitioning
bq show $PROJECT_ID:weather_data.daily | grep -A 3 "Time Partitioning"

# Check clustering
bq show $PROJECT_ID:weather_data.daily | grep -A 3 "Clustering"
```

---

## 5. Setup Development Environment

### Step 5.1: Clone the Repository

**💻 CLI:**
```bash
# Go to your workspace
cd ~

# Clone the repository
git clone https://github.com/YOUR_USERNAME/GCP-Data-Engineer-Cert-Prep.git

# Navigate to project
cd GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather
```

---

### Step 5.2: Create Python Virtual Environment

**💻 CLI:**
```bash
# Navigate to repository root
cd ~/GCP-Data-Engineer-Cert-Prep

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip
```

**✔️ Verify:**
```bash
which python
# Should show: .../venv/bin/python
```

---

### Step 5.3: Install Python Dependencies

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Install ingestion dependencies
pip install -r src/ingestion/requirements.txt

# Install transformation dependencies
pip install -r src/transformation/requirements.txt

# Install test dependencies
pip install -r tests/requirements.txt
```

**✔️ Verify:**
```bash
pip list | grep -E "google-cloud|requests|pytest"
```

---

### Step 5.4: Configure Environment Variables

**💻 CLI:**
```bash
# Navigate to config directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather/config

# Copy template to .env
cp .env.template .env

# Edit .env file with your values
nano .env  # or use vim, code, etc.
```

**Edit the .env file with your actual values:**

```bash
# Required: Replace these values
GCP_PROJECT_ID=your-project-id-here
OPENWEATHER_API_KEY=your-api-key-here

# Optional: Customize these
CITIES=London,Paris,New York,Tokyo,Sydney,Mumbai,Singapore,Dubai,Berlin,Toronto
```

**Complete .env file example:**
```bash
# GCP Project Configuration
GCP_PROJECT_ID=weather-etl-project-12345
GCP_REGION=us-central1

# Cloud Storage Buckets
RAW_BUCKET=weather-etl-project-12345-weather-raw
STAGING_BUCKET=weather-etl-project-12345-weather-staging
TEMP_BUCKET=weather-etl-project-12345-weather-temp

# BigQuery Configuration
BIGQUERY_DATASET=weather_data
BIGQUERY_TABLE=daily
BIGQUERY_LOCATION=US

# OpenWeather API Configuration
OPENWEATHER_API_KEY=83a2fb662aa9f537528e59a40225f0fa
OPENWEATHER_BASE_URL=https://api.openweathermap.org/data/2.5/weather
CITIES=London,Paris,New York,Tokyo,Sydney,Mumbai,Singapore,Dubai,Berlin,Toronto

# Service Accounts
DEV_SERVICE_ACCOUNT=dev-data-engineer@weather-etl-project-12345.iam.gserviceaccount.com
DATAFLOW_SERVICE_ACCOUNT=dataflow-runner@weather-etl-project-12345.iam.gserviceaccount.com

# Dataflow Configuration
DATAFLOW_STAGING_LOCATION=gs://weather-etl-project-12345-weather-staging/dataflow/staging
DATAFLOW_TEMP_LOCATION=gs://weather-etl-project-12345-weather-temp/dataflow/temp
DATAFLOW_MAX_WORKERS=2
DATAFLOW_MACHINE_TYPE=n1-standard-1
DATAFLOW_DISK_SIZE_GB=30
```

**✔️ Verify:**
```bash
cat config/.env | grep -E "PROJECT_ID|API_KEY"
```

---

## 6. Run Data Ingestion

### Step 6.1: Test API Connection

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Activate virtual environment (if not already active)
source ../../venv/bin/activate

# Test API with curl
curl "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY"
```

Expected response: JSON with weather data

---

### Step 6.2: Fetch Weather Data

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Run data ingestion script
python src/ingestion/fetch_weather.py

# You should see colored output showing:
# ✓ London: 12.5°C
# ✓ Paris: 15.3°C
# ... etc
```

**⚠️ Common Issues:**
- `401 Unauthorized`: API key not activated yet (wait 10 min)
- `404 Not Found`: City name spelling (use "New York" not "NewYork")
- `429 Too Many Requests`: Rate limit exceeded (wait 1 minute)

**✔️ Verify:**
```bash
# Check if data was uploaded to GCS
gsutil ls gs://${PROJECT_ID}-weather-raw/raw/$(date +%Y%m%d)/

# View file contents
gsutil cat gs://${PROJECT_ID}-weather-raw/raw/$(date +%Y%m%d)/weather-*.json | head -50
```

---

### Step 6.3: View Data in Cloud Storage

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Click on `YOUR_PROJECT_ID-weather-raw` bucket
3. Navigate to `raw/` → `YYYYMMDD/` (today's date)
4. You should see file: `weather-TIMESTAMP.json`
5. Click on the file to preview contents

**💻 CLI:**
```bash
# List all files in raw bucket
gsutil ls -l gs://${PROJECT_ID}-weather-raw/raw/*/

# Download a file locally to inspect
gsutil cp gs://${PROJECT_ID}-weather-raw/raw/$(date +%Y%m%d)/weather-*.json /tmp/

# View with jq for pretty formatting
cat /tmp/weather-*.json | jq '.[0]'
```

---

## 7. Load Data to BigQuery

### Step 7.1: Run the Data Loader

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Load data from latest file
python src/transformation/simple_loader.py \
    "gs://${PROJECT_ID}-weather-raw/raw/$(date +%Y%m%d)/weather-*.json"

# You should see:
# ✓ Downloaded X records
# ✓ Valid: X, Invalid: 0
# ✓ Loaded X records to BigQuery
```

**✔️ Verify Loading:**
```bash
# Check BigQuery for data
bq query --use_legacy_sql=false \
    "SELECT COUNT(*) as total_records
     FROM \`${PROJECT_ID}.weather_data.daily\`"
```

---

### Step 7.2: Query Data in BigQuery

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/bigquery
2. Click on `weather_data` → `daily` table
3. Click "QUERY" button
4. Run this query:

```sql
SELECT
    city,
    country,
    ROUND(temperature_c, 1) as temp_c,
    ROUND(temperature_f, 1) as temp_f,
    weather_main,
    humidity_percent,
    timestamp
FROM `weather_data.daily`
ORDER BY city
LIMIT 10
```

5. Click "RUN"

**💻 CLI:**
```bash
# Query recent data
bq query --use_legacy_sql=false \
  "SELECT city,
          ROUND(temperature_c,1) as temp_c,
          weather_main
   FROM \`${PROJECT_ID}.weather_data.daily\`
   ORDER BY timestamp DESC
   LIMIT 10"
```

---

### Step 7.3: Run Sample Queries

**Sample Query 1: Temperature Statistics**
```sql
SELECT
    city,
    ROUND(AVG(temperature_c), 1) as avg_temp,
    ROUND(MIN(temperature_c), 1) as min_temp,
    ROUND(MAX(temperature_c), 1) as max_temp,
    COUNT(*) as observations
FROM `weather_data.daily`
GROUP BY city
ORDER BY avg_temp DESC
```

**Sample Query 2: Weather Conditions**
```sql
SELECT
    weather_main,
    COUNT(*) as count,
    ROUND(AVG(temperature_c), 1) as avg_temp
FROM `weather_data.daily`
GROUP BY weather_main
ORDER BY count DESC
```

**Sample Query 3: Coldest vs Hottest Cities**
```sql
SELECT
    city,
    temperature_c,
    weather_main,
    timestamp
FROM `weather_data.daily`
WHERE temperature_c = (SELECT MIN(temperature_c) FROM `weather_data.daily`)
   OR temperature_c = (SELECT MAX(temperature_c) FROM `weather_data.daily`)
ORDER BY temperature_c
```

---

## 8. Verification & Testing

### Step 8.1: Run Unit Tests

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Run all tests
pytest tests/test_pipeline.py -v

# Run with coverage
pytest tests/test_pipeline.py --cov=src --cov-report=term-missing

# Expected: 24 tests passing
```

---

### Step 8.2: Data Quality Checks

**💻 CLI:**
```bash
# Check for invalid temperatures
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) as invalid_temps
   FROM \`${PROJECT_ID}.weather_data.daily\`
   WHERE temperature_c < -50 OR temperature_c > 60"

# Expected: 0

# Check for missing required fields
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) as missing_fields
   FROM \`${PROJECT_ID}.weather_data.daily\`
   WHERE city IS NULL OR country IS NULL"

# Expected: 0
```

---

### Step 8.3: Run Verification Script

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Run comprehensive verification
bash verify_project.sh

# This checks:
# - File structure (12 Python files)
# - Unit tests (24 tests)
# - GCP authentication
# - Cloud Storage buckets (3)
# - BigQuery resources
# - Data in GCS
# - Data in BigQuery
# - Data quality
# - Temperature statistics
```

---

### Step 8.4: Complete Verification Checklist

**Verify the following:**

✅ **GCP Resources:**
- [ ] Project created and billing enabled
- [ ] 2 service accounts created
- [ ] Required APIs enabled
- [ ] 3 Cloud Storage buckets created
- [ ] BigQuery dataset `weather_data` created
- [ ] BigQuery table `daily` with 23 fields
- [ ] Table partitioned by `date`
- [ ] Table clustered by `city, country`

✅ **Code Setup:**
- [ ] Repository cloned
- [ ] Virtual environment created
- [ ] Python dependencies installed
- [ ] `.env` file configured with API key
- [ ] Authentication configured

✅ **Data Pipeline:**
- [ ] OpenWeather API key working
- [ ] Data ingestion successful (10 cities)
- [ ] Data uploaded to Cloud Storage
- [ ] Data loaded to BigQuery
- [ ] Query results showing weather data
- [ ] 24 unit tests passing
- [ ] 0 data quality issues

---

## 9. Optional: Setup Cloud Composer

**⚠️ WARNING:** Cloud Composer costs ~$300/month. Only set up if you need to learn Airflow orchestration. Otherwise, use Cloud Scheduler or cron jobs.

### Step 9.1: Create Composer Environment

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/composer/environments
2. Click "CREATE ENVIRONMENT"
3. Choose "Composer 2"
4. **Environment details:**
   - Name: `weather-composer`
   - Location: `us-central1`
5. **Node configuration:**
   - Machine type: `n1-standard-1`
   - Node count: `3`
   - Disk size: `20 GB`
6. **Service account:** Select `dev-data-engineer` SA
7. Click "CREATE"
8. **Wait 20-30 minutes** for environment creation

**💻 CLI:**
```bash
# Create Composer environment (takes 20-30 min)
gcloud composer environments create weather-composer \
    --location=us-central1 \
    --python-version=3 \
    --image-version=composer-2-airflow-2 \
    --node-count=3 \
    --zone=us-central1-a \
    --machine-type=n1-standard-1 \
    --disk-size=20 \
    --service-account=dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com
```

**✔️ Verify:**
```bash
gcloud composer environments list --locations=us-central1
```

---

### Step 9.2: Upload Airflow DAG

**💻 CLI:**
```bash
# Navigate to project directory
cd ~/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

# Upload DAG to Composer
gcloud composer environments storage dags import \
    --environment=weather-composer \
    --location=us-central1 \
    --source=dags/weather_etl_dag.py
```

**✔️ Verify:**
```bash
# Get Airflow web UI URL
gcloud composer environments describe weather-composer \
    --location=us-central1 \
    --format="get(config.airflowUri)"

# Open the URL in browser and check for 'weather_etl_daily' DAG
```

---

### Step 9.3: Monitor DAG Execution

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/composer/environments
2. Click on `weather-composer`
3. Click "OPEN AIRFLOW UI"
4. Find DAG: `weather_etl_daily`
5. Toggle it ON (if not already)
6. Click on DAG name to view details
7. Click "Graph" to see task dependencies
8. Monitor task execution

---

## 10. Cleanup Resources

**⚠️ IMPORTANT:** Run these steps to avoid ongoing charges!

### Step 10.1: Delete Cloud Composer (If Created)

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/composer/environments
2. Select `weather-composer`
3. Click "DELETE"
4. Confirm deletion
5. Wait 10-15 minutes for cleanup

**💻 CLI:**
```bash
# Delete Composer environment
gcloud composer environments delete weather-composer \
    --location=us-central1 \
    --quiet

# This takes 10-15 minutes
```

---

### Step 10.2: Delete BigQuery Resources

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/bigquery
2. Click on `weather_data` dataset
3. Click "DELETE"
4. Type dataset name to confirm
5. Check "Also delete tables in this dataset"
6. Click "DELETE"

**💻 CLI:**
```bash
# Delete BigQuery dataset and all tables
bq rm -r -f -d ${PROJECT_ID}:weather_data
```

---

### Step 10.3: Delete Cloud Storage Buckets

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/storage/browser
2. Select all 3 weather buckets (checkboxes)
3. Click "DELETE"
4. Confirm deletion

**💻 CLI:**
```bash
# Delete all objects and buckets
gsutil -m rm -r gs://${PROJECT_ID}-weather-raw
gsutil -m rm -r gs://${PROJECT_ID}-weather-staging
gsutil -m rm -r gs://${PROJECT_ID}-weather-temp
```

---

### Step 10.4: Delete Service Accounts

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts
2. Select both service accounts
3. Click "DELETE"
4. Confirm deletion

**💻 CLI:**
```bash
# Delete service accounts
gcloud iam service-accounts delete \
    dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com \
    --quiet

gcloud iam service-accounts delete \
    dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com \
    --quiet

# Delete downloaded key file
rm ~/gcp-keys/dev-sa-key.json
```

---

### Step 10.5: Delete Project (Optional - Complete Cleanup)

**🖱️ Console UI:**
1. Go to https://console.cloud.google.com/
2. Click on project dropdown
3. Click "Settings" for your project
4. Click "SHUT DOWN"
5. Enter project ID to confirm
6. Click "SHUT DOWN"

**💻 CLI:**
```bash
# Delete entire project
gcloud projects delete ${PROJECT_ID} --quiet

# This deletes everything and stops all charges
```

---

## Cost Summary

### With Composer:
- **Cloud Storage:** ~$0.10/month
- **BigQuery:** ~$0.02/month
- **Dataflow (daily runs):** ~$0.50/month
- **Cloud Composer:** ~$300/month
- **Total:** ~$300/month

### Without Composer (Recommended):
- **Cloud Storage:** ~$0.10/month
- **BigQuery:** ~$0.02/month
- **Dataflow (manual runs):** ~$0.02/run
- **Total:** ~$0.50/month

**Cost Optimization Tips:**
1. Delete Composer immediately after testing
2. Use Cloud Scheduler instead of Composer
3. Run pipeline manually for learning
4. Set up budget alerts
5. Delete resources when not in use

---

## Troubleshooting

### Issue: API Key Not Working
**Solution:**
- Wait 10 minutes after creating API key
- Check key is copied correctly (no spaces)
- Test with: `curl "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_KEY"`

### Issue: Permission Denied Errors
**Solution:**
```bash
# Re-authenticate
gcloud auth application-default login

# Check service account has correct roles
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:dev-data-engineer"
```

### Issue: BigQuery Table Not Found
**Solution:**
```bash
# Verify table exists
bq show ${PROJECT_ID}:weather_data.daily

# If not, recreate with schema
bq mk --table \
    --time_partitioning_field=date \
    --clustering_fields=city,country \
    weather_data.daily \
    sql/schema.json
```

### Issue: No Data in Cloud Storage
**Solution:**
```bash
# Check bucket permissions
gsutil iam get gs://${PROJECT_ID}-weather-raw

# Re-run ingestion with debug flag
python src/ingestion/fetch_weather.py --debug
```

---

## Next Steps

**After completing this project:**

1. **Enhance the pipeline:**
   - Add more cities
   - Implement historical data backfill
   - Add weather forecasts
   - Create Looker Studio dashboard

2. **Proceed to Project 2:**
   - Real-Time Streaming with IoT sensors
   - Learn Pub/Sub and Dataflow streaming

3. **Explore variations:**
   - Use Dataproc instead of Dataflow
   - Add dbt for transformations
   - Implement data quality monitoring

---

## Resources

- [OpenWeather API Docs](https://openweathermap.org/api)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Cloud Storage Guide](https://cloud.google.com/storage/docs)
- [Apache Beam Python SDK](https://beam.apache.org/documentation/sdks/python/)
- [Cloud Composer Guide](https://cloud.google.com/composer/docs)

---

**Congratulations!** 🎉 You've successfully built a production-grade data engineering pipeline on GCP!
