# Project 1: Weather ETL Pipeline - Complete Setup Guide

## Overview

This guide provides complete step-by-step instructions to set up the Weather ETL Pipeline from scratch in a new GCP project. Each step includes both **GCP Console UI** and **gcloud CLI** instructions.

**Time Required**: 2-3 hours
**Cost**: ~$8-10 for learning (can be cleaned up after)
**Prerequisites**:
- GCP account with billing enabled
- OpenWeather API key (free tier: https://openweathermap.org/api)
- Local machine with Python 3.11

---

## Table of Contents

1. [GCP Project Setup](#step-1-gcp-project-setup)
2. [Enable Required APIs](#step-2-enable-required-apis)
3. [Create Service Account](#step-3-create-service-account)
4. [Create GCS Buckets](#step-4-create-gcs-buckets)
5. [Create BigQuery Dataset and Table](#step-5-create-bigquery-dataset-and-table)
6. [Set Up Local Development Environment](#step-6-set-up-local-development-environment)
7. [Configure Credentials](#step-7-configure-credentials)
8. [Run the Weather Pipeline](#step-8-run-the-weather-pipeline)
9. [Verify Data in BigQuery](#step-9-verify-data-in-bigquery)
10. [(Optional) Set Up Cloud Composer](#step-10-optional-set-up-cloud-composer)
11. [Cleanup Resources](#step-11-cleanup-resources)

---

## Step 1: GCP Project Setup

### What This Does
Creates a new GCP project to isolate all resources for this tutorial.

### Option A: GCP Console UI

1. **Navigate to Project Creation**
   - Go to https://console.cloud.google.com
   - Click the project dropdown at the top (next to "Google Cloud")
   - Click **"NEW PROJECT"**

2. **Fill in Project Details**
   - Project name: `weather-etl-tutorial` (or your choice)
   - Organization: Select your organization (if applicable)
   - Location: Select parent folder (if applicable)
   - Click **"CREATE"**

3. **Wait for Creation**
   - Takes 30-60 seconds
   - You'll see a notification when ready

4. **Select the Project**
   - Click the project dropdown again
   - Select your new project `weather-etl-tutorial`

5. **Enable Billing**
   - Go to **Billing** → **Link a billing account**
   - Select your billing account
   - Click **"SET ACCOUNT"**

### Option B: gcloud CLI

```bash
# Set your project name (change as needed)
export PROJECT_ID="weather-etl-tutorial-$(date +%Y%m%d)"
export PROJECT_NAME="Weather ETL Tutorial"

# Create the project
gcloud projects create ${PROJECT_ID} \
    --name="${PROJECT_NAME}"

# Set as default project for gcloud commands
gcloud config set project ${PROJECT_ID}

# Link billing account (replace BILLING_ACCOUNT_ID with your billing account)
# First, list your billing accounts to get the ID
gcloud billing accounts list

# Then link it (replace XXXXXX-XXXXXX-XXXXXX with your billing account ID)
gcloud billing projects link ${PROJECT_ID} \
    --billing-account=XXXXXX-XXXXXX-XXXXXX
```

### Verification

**Console**: You should see your project name in the top bar.

**CLI**:
```bash
# Verify project exists
gcloud projects describe ${PROJECT_ID}

# Verify billing is enabled
gcloud billing projects describe ${PROJECT_ID}
```

**Expected Output**: Project details and billing account linked.

---

## Step 2: Enable Required APIs

### What This Does
Enables Google Cloud APIs needed for Dataflow, BigQuery, Cloud Storage, and (optionally) Cloud Composer.

### Option A: GCP Console UI

1. **Navigate to APIs & Services**
   - Go to **Navigation Menu (☰)** → **APIs & Services** → **Library**

2. **Enable Dataflow API**
   - Search for "Dataflow API"
   - Click on **"Dataflow API"**
   - Click **"ENABLE"**
   - Wait ~30 seconds for confirmation

3. **Enable BigQuery API**
   - Click **"Library"** to go back
   - Search for "BigQuery API"
   - Click on **"BigQuery API"**
   - Click **"ENABLE"**

4. **Enable Cloud Storage API**
   - Already enabled by default, but verify:
   - Search for "Cloud Storage API"
   - Should show **"API enabled"** (or click **"ENABLE"**)

5. **Enable Compute Engine API**
   - Search for "Compute Engine API"
   - Click on **"Compute Engine API"**
   - Click **"ENABLE"**

6. **(Optional) Enable Cloud Composer API**
   - Search for "Cloud Composer API"
   - Click on **"Cloud Composer API"**
   - Click **"ENABLE"**
   - Note: Only needed if you'll set up Airflow orchestration

### Option B: gcloud CLI

```bash
# Enable all required APIs at once
gcloud services enable \
    dataflow.googleapis.com \
    bigquery.googleapis.com \
    storage.googleapis.com \
    compute.googleapis.com \
    --project=${PROJECT_ID}

# (Optional) Enable Cloud Composer API
gcloud services enable \
    composer.googleapis.com \
    --project=${PROJECT_ID}
```

### Verification

**Console**:
- Go to **APIs & Services** → **Dashboard**
- You should see all enabled APIs listed

**CLI**:
```bash
# List enabled APIs
gcloud services list --enabled --project=${PROJECT_ID}
```

**Expected Output**: You should see `dataflow.googleapis.com`, `bigquery.googleapis.com`, `storage.googleapis.com`, and `compute.googleapis.com` in the list.

---

## Step 3: Create Service Account

### What This Does
Creates a service account that Dataflow jobs will use to access GCS and BigQuery.

### Option A: GCP Console UI

1. **Navigate to IAM & Admin**
   - Go to **Navigation Menu (☰)** → **IAM & Admin** → **Service Accounts**

2. **Create Service Account**
   - Click **"+ CREATE SERVICE ACCOUNT"** at the top

3. **Fill in Service Account Details**
   - Service account name: `dataflow-runner`
   - Service account ID: `dataflow-runner` (auto-filled)
   - Description: `Service account for Dataflow pipeline execution`
   - Click **"CREATE AND CONTINUE"**

4. **Grant Roles (Step 2 of 3)**
   - Click **"Select a role"** dropdown
   - Search for and add these roles:

     **Role 1**: `Dataflow Worker`
     - Type "dataflow worker" in search
     - Select **"Dataflow Worker"**
     - Click **"+ ADD ANOTHER ROLE"**

     **Role 2**: `BigQuery Data Editor`
     - Type "bigquery data editor" in search
     - Select **"BigQuery Data Editor"**
     - Click **"+ ADD ANOTHER ROLE"**

     **Role 3**: `Storage Object Admin`
     - Type "storage object admin" in search
     - Select **"Storage Object Admin"**

   - Click **"CONTINUE"**

5. **Grant Users Access (Step 3 of 3)**
   - Skip this step (leave blank)
   - Click **"DONE"**

6. **Create and Download Key**
   - Find the service account in the list: `dataflow-runner@...`
   - Click the **three dots (⋮)** on the right
   - Select **"Manage keys"**
   - Click **"ADD KEY"** → **"Create new key"**
   - Select **"JSON"**
   - Click **"CREATE"**
   - A JSON key file will download automatically
   - **Save this file securely** (e.g., `~/gcp-keys/weather-etl-sa-key.json`)

### Option B: gcloud CLI

```bash
# Set service account name
export SA_NAME="dataflow-runner"
export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create ${SA_NAME} \
    --display-name="Dataflow Runner Service Account" \
    --description="Service account for Dataflow pipeline execution" \
    --project=${PROJECT_ID}

# Grant Dataflow Worker role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/dataflow.worker"

# Grant BigQuery Data Editor role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/bigquery.dataEditor"

# Grant Storage Object Admin role
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.objectAdmin"

# Create and download JSON key
mkdir -p ~/gcp-keys
gcloud iam service-accounts keys create ~/gcp-keys/weather-etl-sa-key.json \
    --iam-account=${SA_EMAIL} \
    --project=${PROJECT_ID}

echo "Service account key saved to: ~/gcp-keys/weather-etl-sa-key.json"
```

### Verification

**Console**:
- Go to **IAM & Admin** → **Service Accounts**
- You should see `dataflow-runner@...` listed

**CLI**:
```bash
# List service accounts
gcloud iam service-accounts list --project=${PROJECT_ID}

# Verify roles assigned
gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:${SA_EMAIL}"
```

**Expected Output**: Service account exists with 3 roles (Dataflow Worker, BigQuery Data Editor, Storage Object Admin).

---

## Step 4: Create GCS Buckets

### What This Does
Creates 3 Cloud Storage buckets for raw data, temporary files, and staging area.

### Option A: GCP Console UI

**Bucket 1: Raw Data Bucket**

1. **Navigate to Cloud Storage**
   - Go to **Navigation Menu (☰)** → **Cloud Storage** → **Buckets**

2. **Create Bucket**
   - Click **"+ CREATE"** at the top

3. **Configure Bucket**
   - Name: `[YOUR-PROJECT-ID]-weather-raw`
     - Replace `[YOUR-PROJECT-ID]` with your actual project ID
     - Example: `weather-etl-tutorial-20251019-weather-raw`
   - Location type: **Region**
   - Location: **us-central1** (Iowa)
   - Storage class: **Standard**
   - Access control: **Uniform**
   - Protection tools: Leave defaults
   - Click **"CREATE"**

**Bucket 2: Temp Bucket**

4. **Repeat for Temp Bucket**
   - Click **"+ CREATE"** again
   - Name: `[YOUR-PROJECT-ID]-weather-temp`
   - Location: **us-central1**
   - Other settings: Same as above
   - Click **"CREATE"**

**Bucket 3: Staging Bucket**

5. **Repeat for Staging Bucket**
   - Click **"+ CREATE"** again
   - Name: `[YOUR-PROJECT-ID]-weather-staging`
   - Location: **us-central1**
   - Other settings: Same as above
   - Click **"CREATE"**

### Option B: gcloud CLI

```bash
# Set bucket names (using project ID for uniqueness)
export BUCKET_RAW="gs://${PROJECT_ID}-weather-raw"
export BUCKET_TEMP="gs://${PROJECT_ID}-weather-temp"
export BUCKET_STAGING="gs://${PROJECT_ID}-weather-staging"

# Create raw data bucket
gsutil mb -l us-central1 -c STANDARD ${BUCKET_RAW}

# Create temp bucket
gsutil mb -l us-central1 -c STANDARD ${BUCKET_TEMP}

# Create staging bucket
gsutil mb -l us-central1 -c STANDARD ${BUCKET_STAGING}

echo "Buckets created:"
echo "  Raw: ${BUCKET_RAW}"
echo "  Temp: ${BUCKET_TEMP}"
echo "  Staging: ${BUCKET_STAGING}"
```

### Verification

**Console**:
- Go to **Cloud Storage** → **Buckets**
- You should see all 3 buckets listed

**CLI**:
```bash
# List buckets
gsutil ls -p ${PROJECT_ID}
```

**Expected Output**: Three buckets with names ending in `-weather-raw`, `-weather-temp`, and `-weather-staging`.

---

## Step 5: Create BigQuery Dataset and Table

### What This Does
Creates a BigQuery dataset and a partitioned table to store weather data.

### Option A: GCP Console UI

**Create Dataset**

1. **Navigate to BigQuery**
   - Go to **Navigation Menu (☰)** → **BigQuery** → **SQL workspace**

2. **Create Dataset**
   - In the left sidebar (Explorer), find your project
   - Click the **three dots (⋮)** next to your project name
   - Select **"Create dataset"**

3. **Configure Dataset**
   - Dataset ID: `weather_data`
   - Data location: **US (multiple regions in United States)**
   - Default table expiration: **Never**
   - Encryption: **Google-managed key**
   - Click **"CREATE DATASET"**

**Create Table**

4. **Create Table in Dataset**
   - Expand your project in the left sidebar
   - Expand the `weather_data` dataset
   - Click the **three dots (⋮)** next to `weather_data`
   - Select **"Create table"**

5. **Configure Table**
   - **Source**:
     - Create table from: **Empty table**

   - **Destination**:
     - Project: Your project (auto-filled)
     - Dataset: `weather_data`
     - Table: `daily`

   - **Schema**:
     - Click **"+ ADD FIELD"** and add these fields:

     | Field name | Type | Mode | Description |
     |------------|------|------|-------------|
     | city | STRING | NULLABLE | City name |
     | country | STRING | NULLABLE | Country code |
     | latitude | FLOAT | NULLABLE | Latitude |
     | longitude | FLOAT | NULLABLE | Longitude |
     | temperature_celsius | FLOAT | NULLABLE | Temperature in Celsius |
     | feels_like_celsius | FLOAT | NULLABLE | Feels like temperature |
     | humidity_percent | INTEGER | NULLABLE | Humidity percentage |
     | pressure_hpa | INTEGER | NULLABLE | Pressure in hPa |
     | weather_condition | STRING | NULLABLE | Weather condition |
     | weather_description | STRING | NULLABLE | Detailed description |
     | wind_speed_mps | FLOAT | NULLABLE | Wind speed in m/s |
     | clouds_percent | INTEGER | NULLABLE | Cloud coverage % |
     | timestamp | TIMESTAMP | NULLABLE | Observation timestamp |
     | date | DATE | REQUIRED | Observation date |

   - **Partition and cluster settings**:
     - Click **"Advanced options"** to expand
     - Partitioning: **By DAY**
     - Partitioning field: **date**
     - Filter: Leave unchecked

   - Click **"CREATE TABLE"**

### Option B: gcloud CLI

```bash
# Create the dataset
bq mk --dataset \
    --location=US \
    --description="Weather data from OpenWeather API" \
    ${PROJECT_ID}:weather_data

# Create schema file first
cat > /tmp/weather_schema.json << 'EOF'
[
  {"name": "city", "type": "STRING", "mode": "NULLABLE"},
  {"name": "country", "type": "STRING", "mode": "NULLABLE"},
  {"name": "latitude", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "longitude", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "temperature_celsius", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "feels_like_celsius", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "humidity_percent", "type": "INTEGER", "mode": "NULLABLE"},
  {"name": "pressure_hpa", "type": "INTEGER", "mode": "NULLABLE"},
  {"name": "weather_condition", "type": "STRING", "mode": "NULLABLE"},
  {"name": "weather_description", "type": "STRING", "mode": "NULLABLE"},
  {"name": "wind_speed_mps", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "clouds_percent", "type": "INTEGER", "mode": "NULLABLE"},
  {"name": "timestamp", "type": "TIMESTAMP", "mode": "NULLABLE"},
  {"name": "date", "type": "DATE", "mode": "REQUIRED"}
]
EOF

# Create the table with partitioning
bq mk --table \
    --time_partitioning_field=date \
    --time_partitioning_type=DAY \
    --description="Daily weather observations" \
    ${PROJECT_ID}:weather_data.daily \
    /tmp/weather_schema.json

echo "BigQuery dataset and table created successfully!"
```

### Verification

**Console**:
- In BigQuery, expand your project → `weather_data` → `daily`
- Click on `daily` table
- You should see the schema with 14 fields
- Click **"DETAILS"** tab and verify "Partitioned by: DAY (date)"

**CLI**:
```bash
# List datasets
bq ls --project_id=${PROJECT_ID}

# Show table schema
bq show ${PROJECT_ID}:weather_data.daily
```

**Expected Output**: Table schema showing all 14 fields and partitioning on `date` field.

---

## Step 6: Set Up Local Development Environment

### What This Does
Sets up Python 3.11 environment with Apache Beam and project dependencies.

### Prerequisites
- Python 3.11 installed on your local machine
- If not installed, see [BEAM_ENVIRONMENT_SETUP.md](BEAM_ENVIRONMENT_SETUP.md) for pyenv installation

### Steps (All Platforms)

1. **Clone or Download Project Files**
   ```bash
   # If you have the repo
   cd /path/to/GCP-Data-Engineer-Cert-Prep/projects/01-batch-etl-weather

   # Or download these key files from the repo:
   # - src/transformation/weather_pipeline.py
   # - src/ingestion/fetch_weather.py
   # - src/utils/data_validator.py
   # - src/schemas/weather_schema.json
   # - requirements.txt
   # - setup.py
   ```

2. **Create Python Virtual Environment**
   ```bash
   # Using Python 3.11
   python3.11 -m venv venv-beam

   # Activate virtual environment
   # On Linux/Mac:
   source venv-beam/bin/activate

   # On Windows:
   venv-beam\Scripts\activate
   ```

3. **Verify Python Version**
   ```bash
   python --version
   # Should show: Python 3.11.x
   ```

4. **Install Dependencies**
   ```bash
   # Upgrade pip first
   pip install --upgrade pip

   # Install Apache Beam and dependencies
   pip install apache-beam[gcp]==2.52.0
   pip install google-cloud-bigquery
   pip install google-cloud-storage
   pip install requests

   # Or install from requirements.txt if available
   pip install -r requirements.txt
   ```

5. **Verify Installation**
   ```bash
   # Test Apache Beam import
   python -c "import apache_beam as beam; print(f'Apache Beam version: {beam.__version__}')"

   # Should output: Apache Beam version: 2.52.0
   ```

### Verification

```bash
# List installed packages
pip list | grep -E "apache-beam|google-cloud"
```

**Expected Output**:
```
apache-beam                 2.52.0
google-cloud-bigquery       3.x.x
google-cloud-storage        2.x.x
```

---

## Step 7: Configure Credentials

### What This Does
Sets up authentication for local development and service account credentials.

### Steps

1. **Set Environment Variables**
   ```bash
   # Export your project ID
   export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"

   # Set path to service account key (adjust path as needed)
   export GOOGLE_APPLICATION_CREDENTIALS="~/gcp-keys/weather-etl-sa-key.json"

   # Set bucket variables for easy reference
   export BUCKET_RAW="${PROJECT_ID}-weather-raw"
   export BUCKET_TEMP="${PROJECT_ID}-weather-temp"
   export BUCKET_STAGING="${PROJECT_ID}-weather-staging"
   ```

2. **Get OpenWeather API Key**
   - Go to https://openweathermap.org/api
   - Sign up for a free account
   - Navigate to **API keys** section
   - Copy your API key

   ```bash
   # Set OpenWeather API key
   export OPENWEATHER_API_KEY="your_api_key_here"
   ```

3. **Create Configuration File (Optional but Recommended)**
   ```bash
   # Create a .env file for easy reuse
   cat > .env << EOF
   export GOOGLE_CLOUD_PROJECT="${PROJECT_ID}"
   export GOOGLE_APPLICATION_CREDENTIALS="~/gcp-keys/weather-etl-sa-key.json"
   export BUCKET_RAW="${PROJECT_ID}-weather-raw"
   export BUCKET_TEMP="${PROJECT_ID}-weather-temp"
   export BUCKET_STAGING="${PROJECT_ID}-weather-staging"
   export OPENWEATHER_API_KEY="your_api_key_here"
   EOF

   # Load environment variables
   source .env
   ```

### Verification

```bash
# Verify environment variables are set
echo "Project: $GOOGLE_CLOUD_PROJECT"
echo "Credentials: $GOOGLE_APPLICATION_CREDENTIALS"
echo "Raw Bucket: $BUCKET_RAW"

# Test authentication
gcloud auth application-default login
# Or use service account directly
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Verify access
gcloud projects describe $GOOGLE_CLOUD_PROJECT
gsutil ls gs://${BUCKET_RAW}
```

**Expected Output**: Successfully authenticated and can list GCS buckets.

---

## Step 8: Run the Weather Pipeline

### What This Does
Fetches weather data and runs the Dataflow pipeline to load it into BigQuery.

### Option A: Fetch Weather Data Manually

1. **Run Weather Fetcher**
   ```bash
   # Make sure you're in the project directory
   cd /path/to/01-batch-etl-weather

   # Activate virtual environment
   source venv-beam/bin/activate

   # Run weather fetcher
   python src/ingestion/fetch_weather.py \
       --api-key ${OPENWEATHER_API_KEY} \
       --output-bucket ${BUCKET_RAW}
   ```

2. **Verify Data in GCS**
   ```bash
   # List files in raw bucket
   gsutil ls -r gs://${BUCKET_RAW}/raw/

   # View sample file
   gsutil cat gs://${BUCKET_RAW}/raw/$(date +%Y%m%d)/weather-*.json | head -20
   ```

### Option B: Run Complete Pipeline with Dataflow

**Using DirectRunner (Local, for Testing)**

```bash
# Run pipeline locally
python src/transformation/weather_pipeline.py \
    --input "gs://${BUCKET_RAW}/raw/*/weather-*.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DirectRunner \
    --project ${PROJECT_ID} \
    --temp_location "gs://${BUCKET_TEMP}/beam-temp"
```

**Using DataflowRunner (GCP, Production)**

```bash
# Set job name with timestamp
JOB_NAME="weather-transform-$(date +%Y%m%d-%H%M%S)"

# Run Dataflow pipeline
python src/transformation/weather_pipeline.py \
    --input "gs://${BUCKET_RAW}/raw/*/weather-*.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DataflowRunner \
    --project ${PROJECT_ID} \
    --region us-central1 \
    --temp_location "gs://${BUCKET_TEMP}/dataflow/temp" \
    --staging_location "gs://${BUCKET_STAGING}/dataflow/staging" \
    --service_account_email ${SA_EMAIL} \
    --max_num_workers 2 \
    --num_workers 1 \
    --machine_type n1-standard-1 \
    --job_name ${JOB_NAME} \
    --setup_file ./setup.py
```

### Monitor Dataflow Job (Console UI)

1. **Navigate to Dataflow**
   - Go to **Navigation Menu (☰)** → **Dataflow** → **Jobs**

2. **View Job Details**
   - Click on your job name (e.g., `weather-transform-20251019-120000`)
   - View the job graph showing pipeline stages
   - Monitor metrics: Elements added, Throughput, System lag

3. **Check Job Status**
   - Status should progress: **Queued** → **Running** → **Succeeded**
   - Takes 3-5 minutes for small datasets

### Verification

```bash
# Check Dataflow job status
gcloud dataflow jobs list --region=us-central1 --project=${PROJECT_ID}

# Or monitor specific job (replace JOB_ID)
gcloud dataflow jobs describe JOB_ID --region=us-central1
```

**Expected Output**: Job status shows `JOB_STATE_DONE` or `Succeeded`.

---

## Step 9: Verify Data in BigQuery

### What This Does
Confirms that weather data was successfully loaded into BigQuery.

### Option A: GCP Console UI

1. **Navigate to BigQuery**
   - Go to **Navigation Menu (☰)** → **BigQuery** → **SQL workspace**

2. **Query the Data**
   - In the query editor, run:
   ```sql
   SELECT
       COUNT(*) as total_records,
       COUNT(DISTINCT city) as unique_cities,
       MIN(date) as earliest_date,
       MAX(date) as latest_date,
       ROUND(AVG(temperature_celsius), 2) as avg_temp
   FROM `weather_data.daily`
   ```
   - Click **"RUN"**

3. **View Results**
   - You should see results showing:
     - Total records (e.g., 9-18 records)
     - Unique cities (e.g., 9 cities)
     - Date range
     - Average temperature

4. **View Sample Data**
   ```sql
   SELECT
       city,
       country,
       temperature_celsius,
       weather_description,
       timestamp,
       date
   FROM `weather_data.daily`
   ORDER BY timestamp DESC
   LIMIT 10
   ```

### Option B: gcloud CLI (using bq)

```bash
# Count total records
bq query --use_legacy_sql=false \
"SELECT COUNT(*) as total FROM \`${PROJECT_ID}.weather_data.daily\`"

# View summary statistics
bq query --use_legacy_sql=false \
"SELECT
    COUNT(*) as total_records,
    COUNT(DISTINCT city) as unique_cities,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    ROUND(AVG(temperature_celsius), 2) as avg_temp
FROM \`${PROJECT_ID}.weather_data.daily\`"

# View sample data
bq query --use_legacy_sql=false \
"SELECT city, temperature_celsius, weather_description, date
FROM \`${PROJECT_ID}.weather_data.daily\`
LIMIT 5"
```

### Expected Output

**Summary Query Results**:
```
+----------------+----------------+---------------+--------------+----------+
| total_records  | unique_cities  | earliest_date | latest_date  | avg_temp |
+----------------+----------------+---------------+--------------+----------+
|             18 |              9 |    2025-10-19 |   2025-10-19 |    15.67 |
+----------------+----------------+---------------+--------------+----------+
```

**Sample Data**:
```
+-------------+----------------------+----------------------+------------+
|    city     | temperature_celsius  | weather_description  |    date    |
+-------------+----------------------+----------------------+------------+
| New York    |                18.50 | clear sky            | 2025-10-19 |
| London      |                12.30 | light rain           | 2025-10-19 |
| Tokyo       |                21.40 | few clouds           | 2025-10-19 |
...
```

---

## Step 10: (Optional) Set Up Cloud Composer

### What This Does
Sets up Cloud Composer (managed Airflow) for pipeline orchestration.

**Note**: This step is optional and expensive (~$150-200/month). Skip if you just want to learn the pipeline basics.

### Prerequisites

1. **Grant Service Agent Role** (Required for Composer 2.X)
   ```bash
   # Get your project number
   PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")

   # Grant Composer Service Agent role
   gcloud projects add-iam-policy-binding ${PROJECT_ID} \
       --member="serviceAccount:service-${PROJECT_NUMBER}@cloudcomposer-accounts.iam.gserviceaccount.com" \
       --role="roles/composer.ServiceAgentV2Ext"
   ```

### Option A: GCP Console UI

1. **Navigate to Composer**
   - Go to **Navigation Menu (☰)** → **Composer**

2. **Create Environment**
   - Click **"CREATE ENVIRONMENT"** or **"+ CREATE"**

3. **Configure Environment**
   - Name: `weather-etl-composer`
   - Location: **us-central1**
   - Image version: **composer-2.9.9-airflow-2.9.3** (or latest Composer 2.X)
   - Environment size: **Small**
   - Service account: Select your compute default service account
     - Format: `PROJECT_NUMBER-compute@developer.gserviceaccount.com`
   - Click **"CREATE"**

4. **Wait for Creation** (20-30 minutes)
   - Status will show **Creating...**
   - You'll receive an email when ready
   - Final status: **Running**

### Option B: gcloud CLI

```bash
# Get compute default service account
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Create Composer environment (takes 20-30 minutes)
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --service-account ${COMPUTE_SA} \
    --project ${PROJECT_ID}

# Monitor creation
watch gcloud composer environments describe weather-etl-composer \
    --location us-central1 \
    --format="value(state)"
```

### Upload Airflow DAG

**After environment is created:**

```bash
# Get DAGs bucket
DAGS_BUCKET=$(gcloud composer environments describe weather-etl-composer \
    --location us-central1 \
    --format="value(config.dagGcsPrefix)")

# Upload DAG file
gsutil cp dags/weather_etl_dag.py ${DAGS_BUCKET}/

# Verify upload
gsutil ls ${DAGS_BUCKET}/
```

### Access Airflow UI

**Console**:
1. Go to **Composer** → **weather-etl-composer**
2. Click **"AIRFLOW WEB UI"** link at the top
3. Authenticate with your Google account
4. Find `weather_etl_daily` DAG
5. Toggle to unpause, then trigger manually

**CLI**:
```bash
# Get Airflow UI URL
gcloud composer environments describe weather-etl-composer \
    --location us-central1 \
    --format="value(config.airflowUri)"

# Trigger DAG from command line
gcloud composer environments run weather-etl-composer \
    --location us-central1 \
    dags trigger -- weather_etl_daily
```

### Verification

```bash
# Check environment status
gcloud composer environments list --locations us-central1

# Check DAG runs
gcloud composer environments run weather-etl-composer \
    --location us-central1 \
    dags list-runs -- -d weather_etl_daily
```

**Expected Output**: Environment status `RUNNING`, DAG appears in Airflow UI.

---

## Step 11: Cleanup Resources

### What This Does
Deletes all resources to avoid ongoing costs.

### Important
**Always cleanup resources after learning to avoid charges!**

### Option A: GCP Console UI

**Delete Composer (if created)**
1. Go to **Composer** → Select `weather-etl-composer`
2. Click **"DELETE"** → Confirm
3. Wait 10-15 minutes for deletion

**Delete BigQuery Dataset**
1. Go to **BigQuery** → Expand your project
2. Click **three dots (⋮)** next to `weather_data`
3. Click **"Delete"** → Type dataset name → Confirm

**Delete GCS Buckets**
1. Go to **Cloud Storage** → **Buckets**
2. For each bucket (`-weather-raw`, `-weather-temp`, `-weather-staging`):
   - Check the checkbox next to bucket name
   - Click **"DELETE"** at the top
   - Confirm deletion

**Delete Service Account**
1. Go to **IAM & Admin** → **Service Accounts**
2. Find `dataflow-runner@...`
3. Click **three dots (⋮)** → **"Delete"**
4. Confirm deletion

**Delete Project (Optional - Deletes Everything)**
1. Go to **IAM & Admin** → **Settings**
2. Click **"SHUT DOWN"**
3. Type project ID to confirm
4. Click **"SHUT DOWN"** button

### Option B: gcloud CLI

```bash
# Delete Composer environment (if created)
gcloud composer environments delete weather-etl-composer \
    --location us-central1 \
    --project ${PROJECT_ID} \
    --quiet

# Delete BigQuery dataset
bq rm -r -f -d ${PROJECT_ID}:weather_data

# Delete GCS buckets
gsutil -m rm -r gs://${BUCKET_RAW}
gsutil -m rm -r gs://${BUCKET_TEMP}
gsutil -m rm -r gs://${BUCKET_STAGING}

# Delete service account
gcloud iam service-accounts delete ${SA_EMAIL} \
    --project ${PROJECT_ID} \
    --quiet

# (Optional) Delete entire project
gcloud projects delete ${PROJECT_ID} --quiet
```

### Verification

```bash
# Verify all resources deleted
gcloud composer environments list --locations us-central1
bq ls --project_id=${PROJECT_ID}
gsutil ls -p ${PROJECT_ID}
gcloud iam service-accounts list --project ${PROJECT_ID}
```

**Expected Output**: All commands should return empty results or "not found" messages.

---

## Troubleshooting

### Common Issues

**Issue 1: "Permission Denied" when running pipeline**

**Solution**:
```bash
# Verify service account has correct roles
gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:${SA_EMAIL}"

# Re-grant roles if needed (see Step 3)
```

**Issue 2: "Bucket not found" error**

**Solution**:
```bash
# Verify bucket names match your project ID
echo "Expected buckets:"
echo "  gs://${PROJECT_ID}-weather-raw"
echo "  gs://${PROJECT_ID}-weather-temp"
echo "  gs://${PROJECT_ID}-weather-staging"

# List actual buckets
gsutil ls -p ${PROJECT_ID}

# If names don't match, recreate buckets or update variables
```

**Issue 3: Dataflow job fails with "setup.py not found"**

**Solution**:
```bash
# Ensure you're in the project root directory
cd /path/to/01-batch-etl-weather

# Verify setup.py exists
ls -la setup.py

# Run from correct directory
pwd
# Should show: .../01-batch-etl-weather
```

**Issue 4: BigQuery "Table not found" error**

**Solution**:
```bash
# Verify table exists
bq show ${PROJECT_ID}:weather_data.daily

# If not exists, recreate (see Step 5)
```

**Issue 5: Composer environment creation fails**

**Solution**:
```bash
# Check if Service Agent role is granted
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")

gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:service-${PROJECT_NUMBER}@cloudcomposer-accounts.iam.gserviceaccount.com"

# If missing, grant the role (see Step 10 Prerequisites)
```

---

## Quick Reference Commands

### Environment Setup
```bash
# Set all variables at once
export PROJECT_ID="your-project-id"
export SA_EMAIL="dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com"
export GOOGLE_APPLICATION_CREDENTIALS="~/gcp-keys/weather-etl-sa-key.json"
export BUCKET_RAW="${PROJECT_ID}-weather-raw"
export BUCKET_TEMP="${PROJECT_ID}-weather-temp"
export BUCKET_STAGING="${PROJECT_ID}-weather-staging"
export OPENWEATHER_API_KEY="your_api_key"
```

### Run Pipeline (Quick)
```bash
# Activate environment
source venv-beam/bin/activate

# Run Dataflow job
python src/transformation/weather_pipeline.py \
    --input "gs://${BUCKET_RAW}/raw/*/weather-*.json" \
    --output "${PROJECT_ID}:weather_data.daily" \
    --runner DataflowRunner \
    --project ${PROJECT_ID} \
    --region us-central1 \
    --temp_location "gs://${BUCKET_TEMP}/dataflow/temp" \
    --staging_location "gs://${BUCKET_STAGING}/dataflow/staging" \
    --service_account_email ${SA_EMAIL} \
    --job_name "weather-$(date +%Y%m%d-%H%M%S)" \
    --setup_file ./setup.py
```

### Check Data (Quick)
```bash
# Count records
bq query --use_legacy_sql=false \
"SELECT COUNT(*) FROM \`${PROJECT_ID}.weather_data.daily\`"

# View latest data
bq query --use_legacy_sql=false \
"SELECT city, temperature_celsius, date
FROM \`${PROJECT_ID}.weather_data.daily\`
ORDER BY timestamp DESC LIMIT 5"
```

### Cleanup (Quick)
```bash
# Delete all resources
bq rm -r -f -d ${PROJECT_ID}:weather_data
gsutil -m rm -r gs://${BUCKET_RAW}
gsutil -m rm -r gs://${BUCKET_TEMP}
gsutil -m rm -r gs://${BUCKET_STAGING}
gcloud iam service-accounts delete ${SA_EMAIL} --quiet
```

---

## Cost Estimates

### One-Time Setup Costs
- GCS storage: ~$0.01 (< 1 GB)
- Dataflow job: ~$0.10 per run
- BigQuery storage: ~$0.01 (< 1 GB)
- **Total without Composer**: ~$0.12 per run

### Cloud Composer Costs (Optional)
- Small environment: ~$150-200/month
- **Only create if needed for learning Airflow!**

### Cost Optimization Tips
1. Delete Composer immediately after testing
2. Use DirectRunner for local testing (free)
3. Clean up all resources when done
4. Set billing alerts in GCP Console

---

## Next Steps

### After Completing Setup

1. **Explore the Pipeline Code**
   - Review `src/transformation/weather_pipeline.py`
   - Understand DoFn transforms
   - Study BigQuery write patterns

2. **Experiment with Modifications**
   - Add more cities to fetch
   - Add data transformations
   - Modify BigQuery schema

3. **Study Documentation**
   - Read `DATAFLOW_DEPLOYMENT_SUCCESS.md` for troubleshooting
   - Review `BEAM_PIPELINE_SUCCESS.md` for pipeline details
   - Check `QUICK_REFERENCE.md` for common commands

4. **Practice Cleanup**
   - Delete resources
   - Recreate from scratch
   - Practice both Console UI and CLI methods

---

## Additional Resources

### Official Documentation
- [Apache Beam Python SDK](https://beam.apache.org/documentation/sdks/python/)
- [Dataflow Documentation](https://cloud.google.com/dataflow/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Cloud Composer Documentation](https://cloud.google.com/composer/docs)

### Project Documentation
- [README.md](README.md) - Complete project overview
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - High-level summary
- [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) - All docs index

---

**Last Updated**: 2025-10-19
**Version**: 1.0
**Author**: Generated for GCP Data Engineer Certification Prep

**Completion Time**: If you follow all steps sequentially, expect 2-3 hours total (including Composer environment creation wait time).
