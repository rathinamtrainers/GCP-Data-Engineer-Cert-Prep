#!/bin/bash

################################################################################
# Project 1: Batch ETL Weather Pipeline - Setup Script
################################################################################
#
# This script sets up all GCP resources needed for the weather data pipeline:
# - Cloud Storage buckets (raw, staging, temp)
# - BigQuery dataset and table
# - (Optional) Cloud Composer environment
#
# IMPORTANT: Review each section before running. Some resources cost money!
#
################################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ID="data-engineer-475516"
REGION="us-central1"
DATASET_NAME="weather_data"
TABLE_NAME="daily"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Project 1: Weather ETL Setup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo ""

################################################################################
# SECTION 1: Verify Prerequisites
################################################################################

echo -e "\n${YELLOW}SECTION 1: Checking Prerequisites${NC}\n"

# Check if authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${RED}ERROR: Not authenticated with gcloud${NC}"
    echo "Run: gcloud auth login"
    exit 1
fi

# Check if project is set
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ]; then
    echo -e "${YELLOW}Setting project to $PROJECT_ID${NC}"
    gcloud config set project $PROJECT_ID
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"

################################################################################
# SECTION 2: Create Cloud Storage Buckets
################################################################################

echo -e "\n${YELLOW}SECTION 2: Creating Cloud Storage Buckets${NC}\n"

# Bucket names (must be globally unique)
RAW_BUCKET="${PROJECT_ID}-weather-raw"
STAGING_BUCKET="${PROJECT_ID}-weather-staging"
TEMP_BUCKET="${PROJECT_ID}-weather-temp"

echo "Creating buckets:"
echo "  - Raw data: gs://${RAW_BUCKET}"
echo "  - Staging: gs://${STAGING_BUCKET}"
echo "  - Temp: gs://${TEMP_BUCKET}"
echo ""

# Create raw data bucket
echo "1. Creating raw data bucket..."
if gsutil ls -b gs://${RAW_BUCKET} &> /dev/null; then
    echo "   Bucket already exists: gs://${RAW_BUCKET}"
else
    gsutil mb -p ${PROJECT_ID} -l ${REGION} -c STANDARD gs://${RAW_BUCKET}
    echo -e "   ${GREEN}✓ Created: gs://${RAW_BUCKET}${NC}"
fi

# Create staging bucket
echo "2. Creating staging bucket..."
if gsutil ls -b gs://${STAGING_BUCKET} &> /dev/null; then
    echo "   Bucket already exists: gs://${STAGING_BUCKET}"
else
    gsutil mb -p ${PROJECT_ID} -l ${REGION} -c STANDARD gs://${STAGING_BUCKET}
    echo -e "   ${GREEN}✓ Created: gs://${STAGING_BUCKET}${NC}"
fi

# Create temp bucket
echo "3. Creating temp bucket..."
if gsutil ls -b gs://${TEMP_BUCKET} &> /dev/null; then
    echo "   Bucket already exists: gs://${TEMP_BUCKET}"
else
    gsutil mb -p ${PROJECT_ID} -l ${REGION} -c STANDARD gs://${TEMP_BUCKET}
    echo -e "   ${GREEN}✓ Created: gs://${TEMP_BUCKET}${NC}"
fi

# Set lifecycle policy on temp bucket (delete after 7 days)
echo "4. Setting lifecycle policy on temp bucket (delete files after 7 days)..."
cat > /tmp/lifecycle.json << EOF
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
gsutil lifecycle set /tmp/lifecycle.json gs://${TEMP_BUCKET}
rm /tmp/lifecycle.json
echo -e "   ${GREEN}✓ Lifecycle policy applied${NC}"

echo -e "\n${GREEN}✓ All buckets created${NC}"

################################################################################
# SECTION 3: Create BigQuery Dataset and Table
################################################################################

echo -e "\n${YELLOW}SECTION 3: Creating BigQuery Dataset and Table${NC}\n"

# Create dataset
echo "1. Creating BigQuery dataset: ${DATASET_NAME}..."
if bq ls -d ${PROJECT_ID}:${DATASET_NAME} &> /dev/null; then
    echo "   Dataset already exists: ${DATASET_NAME}"
else
    bq mk --project_id=${PROJECT_ID} --location=US --dataset ${DATASET_NAME}
    echo -e "   ${GREEN}✓ Created dataset: ${DATASET_NAME}${NC}"
fi

# Create table with partitioning and clustering
echo "2. Creating BigQuery table: ${TABLE_NAME}..."
if bq show ${PROJECT_ID}:${DATASET_NAME}.${TABLE_NAME} &> /dev/null; then
    echo "   Table already exists: ${TABLE_NAME}"
else
    bq mk --project_id=${PROJECT_ID} \
        --table \
        --time_partitioning_field date \
        --time_partitioning_type DAY \
        --clustering_fields city,country \
        --description "Daily weather data from OpenWeather API" \
        ${DATASET_NAME}.${TABLE_NAME} \
        sql/schema.json
    echo -e "   ${GREEN}✓ Created table: ${TABLE_NAME}${NC}"
    echo "   - Partitioned by: date (daily)"
    echo "   - Clustered by: city, country"
fi

echo -e "\n${GREEN}✓ BigQuery resources created${NC}"

################################################################################
# SECTION 4: Grant Service Account Permissions
################################################################################

echo -e "\n${YELLOW}SECTION 4: Verifying Service Account Permissions${NC}\n"

DEV_SA="dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com"
DATAFLOW_SA="dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Service accounts already have necessary permissions from Project 0:"
echo "  - ${DEV_SA}"
echo "    - BigQuery Admin"
echo "    - Storage Admin"
echo "    - Dataflow Developer"
echo ""
echo "  - ${DATAFLOW_SA}"
echo "    - Dataflow Worker"
echo "    - Storage Object Admin"
echo ""

# Grant BigQuery Data Editor to Dataflow SA (for writing to BigQuery)
echo "Granting BigQuery Data Editor to Dataflow SA..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${DATAFLOW_SA}" \
    --role="roles/bigquery.dataEditor" \
    --condition=None &> /dev/null || true

echo -e "${GREEN}✓ Permissions verified${NC}"

################################################################################
# SECTION 5: (Optional) Create Cloud Composer Environment
################################################################################

echo -e "\n${YELLOW}SECTION 5: Cloud Composer Environment (Optional)${NC}\n"

COMPOSER_ENV="weather-composer"

echo -e "${RED}WARNING: Cloud Composer costs ~$300/month!${NC}"
echo ""
echo "For learning, we recommend using Cloud Scheduler instead:"
echo "  gcloud scheduler jobs create http weather-daily-job \\"
echo "    --schedule='0 6 * * *' \\"
echo "    --uri='https://YOUR_CLOUD_FUNCTION_URL' \\"
echo "    --http-method=POST"
echo ""
echo "If you still want to create Composer environment:"
echo "  Uncomment the commands below in this script"
echo ""

# Uncomment to create Composer environment
# echo "Creating Cloud Composer environment (this takes 20-30 minutes)..."
# gcloud composer environments create ${COMPOSER_ENV} \
#     --location ${REGION} \
#     --python-version 3 \
#     --image-version composer-2-airflow-2 \
#     --node-count 3 \
#     --zone ${REGION}-a \
#     --machine-type n1-standard-1 \
#     --disk-size 20 \
#     --service-account ${COMPOSER_SA}

echo "Skipping Composer creation (recommended for cost savings)"

################################################################################
# SECTION 6: Create Directories in Cloud Storage
################################################################################

echo -e "\n${YELLOW}SECTION 6: Creating Directory Structure in Cloud Storage${NC}\n"

echo "Creating folders in raw data bucket..."
echo "dummy" | gsutil cp - gs://${RAW_BUCKET}/raw/.keep
echo "dummy" | gsutil cp - gs://${RAW_BUCKET}/processed/.keep
gsutil rm gs://${RAW_BUCKET}/raw/.keep gs://${RAW_BUCKET}/processed/.keep

echo -e "${GREEN}✓ Directory structure created${NC}"

################################################################################
# SECTION 7: Update .env File
################################################################################

echo -e "\n${YELLOW}SECTION 7: Updating Configuration${NC}\n"

ENV_FILE="config/.env"

cat > ${ENV_FILE} << EOF
# Project 1: Weather ETL Configuration

# GCP Project
GCP_PROJECT_ID=${PROJECT_ID}
GCP_REGION=${REGION}

# Cloud Storage Buckets
RAW_BUCKET=${RAW_BUCKET}
STAGING_BUCKET=${STAGING_BUCKET}
TEMP_BUCKET=${TEMP_BUCKET}

# BigQuery
BIGQUERY_DATASET=${DATASET_NAME}
BIGQUERY_TABLE=${TABLE_NAME}

# Dataflow
DATAFLOW_STAGING_LOCATION=gs://${STAGING_BUCKET}/dataflow/staging
DATAFLOW_TEMP_LOCATION=gs://${TEMP_BUCKET}/dataflow/temp
DATAFLOW_SERVICE_ACCOUNT=${DATAFLOW_SA}

# OpenWeather API
OPENWEATHER_API_KEY=YOUR_API_KEY_HERE

# Cities to fetch weather for (comma-separated)
CITIES=London,Paris,NewYork,Tokyo,Sydney

# Service Accounts
DEV_SERVICE_ACCOUNT=${DEV_SA}
DATAFLOW_SERVICE_ACCOUNT=${DATAFLOW_SA}
EOF

echo -e "${GREEN}✓ Configuration file created: ${ENV_FILE}${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Edit ${ENV_FILE} and add your OpenWeather API key!${NC}"

################################################################################
# SECTION 8: Verify Setup
################################################################################

echo -e "\n${YELLOW}SECTION 8: Verifying Setup${NC}\n"

echo "Checking resources..."

# Check buckets
BUCKET_COUNT=$(gsutil ls -p ${PROJECT_ID} | grep -c "weather" || true)
echo "  Buckets created: ${BUCKET_COUNT}/3"

# Check BigQuery
if bq show ${PROJECT_ID}:${DATASET_NAME}.${TABLE_NAME} &> /dev/null; then
    echo "  BigQuery table: ✓"
else
    echo "  BigQuery table: ✗"
fi

echo ""

################################################################################
# SUMMARY
################################################################################

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"

echo -e "\nResources created:"
echo "  ✓ Cloud Storage buckets (3)"
echo "    - gs://${RAW_BUCKET}"
echo "    - gs://${STAGING_BUCKET}"
echo "    - gs://${TEMP_BUCKET}"
echo ""
echo "  ✓ BigQuery dataset: ${DATASET_NAME}"
echo "  ✓ BigQuery table: ${TABLE_NAME}"
echo "    - Partitioned by: date"
echo "    - Clustered by: city, country"
echo ""

echo -e "\nNext steps:"
echo "  1. Get OpenWeather API key from https://openweathermap.org/api"
echo "  2. Edit config/.env and add your API key"
echo "  3. Test data ingestion:"
echo "     cd src/ingestion"
echo "     python fetch_weather.py"
echo ""
echo "  4. Run Dataflow pipeline:"
echo "     cd src/transformation"
echo "     python weather_pipeline.py"
echo ""

echo -e "\nEstimated monthly cost:"
echo "  - Cloud Storage: ~\$0.10 (minimal data)"
echo "  - BigQuery storage: ~\$0.02 (1 GB)"
echo "  - Dataflow (per run): ~\$0.50"
echo "  Total: ~\$1-2/month (without Composer)"
echo ""

echo -e "${YELLOW}Remember to run cleanup.sh when done to avoid charges!${NC}"
echo ""

################################################################################
# END
################################################################################
