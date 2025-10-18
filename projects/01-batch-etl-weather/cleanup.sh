#!/bin/bash

################################################################################
# Project 1: Weather ETL Pipeline - Cleanup Script
################################################################################
#
# This script removes all GCP resources created for the weather pipeline
#
# ⚠️  WARNING: This will DELETE all data and resources! ⚠️
#
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ID="data-engineer-475516"
REGION="us-central1"
DATASET_NAME="weather_data"

echo -e "${RED}================================${NC}"
echo -e "${RED}Weather ETL Cleanup${NC}"
echo -e "${RED}================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  This will DELETE all weather pipeline resources!${NC}"
echo ""

read -p "Are you sure? Type 'yes' to continue: " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

################################################################################
# 1. Delete BigQuery Resources
################################################################################

echo -e "\n${YELLOW}1. Deleting BigQuery resources...${NC}\n"

# Delete table
if bq show ${PROJECT_ID}:${DATASET_NAME}.daily &> /dev/null; then
    bq rm -f -t ${PROJECT_ID}:${DATASET_NAME}.daily
    echo "✓ Deleted table: ${DATASET_NAME}.daily"
fi

# Delete dataset
if bq ls -d ${PROJECT_ID}:${DATASET_NAME} &> /dev/null; then
    bq rm -r -f -d ${PROJECT_ID}:${DATASET_NAME}
    echo "✓ Deleted dataset: ${DATASET_NAME}"
fi

################################################################################
# 2. Delete Cloud Storage Buckets
################################################################################

echo -e "\n${YELLOW}2. Deleting Cloud Storage buckets...${NC}\n"

RAW_BUCKET="${PROJECT_ID}-weather-raw"
STAGING_BUCKET="${PROJECT_ID}-weather-staging"
TEMP_BUCKET="${PROJECT_ID}-weather-temp"

for bucket in $RAW_BUCKET $STAGING_BUCKET $TEMP_BUCKET; do
    if gsutil ls -b gs://${bucket} &> /dev/null; then
        gsutil -m rm -r gs://${bucket}
        echo "✓ Deleted bucket: gs://${bucket}"
    fi
done

################################################################################
# 3. Delete Cloud Composer Environment (if exists)
################################################################################

echo -e "\n${YELLOW}3. Checking for Cloud Composer environment...${NC}\n"

COMPOSER_ENV="weather-composer"

if gcloud composer environments describe ${COMPOSER_ENV} --location ${REGION} &> /dev/null; then
    echo "Deleting Composer environment (this takes 10-15 minutes)..."
    gcloud composer environments delete ${COMPOSER_ENV} \
        --location ${REGION} \
        --quiet
    echo "✓ Deleted Composer environment"
else
    echo "No Composer environment found (skipping)"
fi

################################################################################
# Summary
################################################################################

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Deleted resources:"
echo "  ✓ BigQuery dataset and table"
echo "  ✓ Cloud Storage buckets (3)"
echo "  ✓ Composer environment (if it existed)"
echo ""
echo "Resources retained (from Project 0):"
echo "  • Service accounts"
echo "  • IAM permissions"
echo "  • Enabled APIs"
echo ""
echo "These can be reused for other projects."
echo ""
