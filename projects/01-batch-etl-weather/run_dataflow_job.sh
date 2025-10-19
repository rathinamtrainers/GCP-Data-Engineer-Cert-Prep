#!/bin/bash

################################################################################
# Run Apache Beam Pipeline on Google Cloud Dataflow
################################################################################
#
# This script submits the weather transformation pipeline to Dataflow.
#
# Usage:
#   ./run_dataflow_job.sh
#
################################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="data-engineer-475516"
REGION="us-central1"
ZONE="us-central1-a"

# Buckets
RAW_BUCKET="${PROJECT_ID}-weather-raw"
STAGING_BUCKET="${PROJECT_ID}-weather-staging"
TEMP_BUCKET="${PROJECT_ID}-weather-temp"

# BigQuery
DATASET="weather_data"
TABLE="daily"

# Dataflow configuration
JOB_NAME="weather-transform-$(date +%Y%m%d-%H%M%S)"
SERVICE_ACCOUNT="dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com"
MAX_WORKERS=2
MACHINE_TYPE="n1-standard-1"
DISK_SIZE=30

# Input pattern
INPUT_PATTERN="gs://${RAW_BUCKET}/raw/*/weather-*.json"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Submitting Dataflow Job: Weather Pipeline          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Project: ${PROJECT_ID}"
echo "  Region: ${REGION}"
echo "  Job Name: ${JOB_NAME}"
echo "  Input: ${INPUT_PATTERN}"
echo "  Output: ${PROJECT_ID}:${DATASET}.${TABLE}"
echo "  Workers: Max ${MAX_WORKERS} x ${MACHINE_TYPE}"
echo ""

# Check if venv-beam is activated
if [[ "$VIRTUAL_ENV" != *"venv-beam"* ]]; then
    echo -e "${YELLOW}Activating venv-beam environment...${NC}"
    source venv-beam/bin/activate
fi

# Check credentials
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo -e "${YELLOW}Setting credentials...${NC}"
    export GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
fi

echo -e "${YELLOW}Submitting job to Dataflow...${NC}"
echo ""

# Submit Dataflow job
python src/transformation/weather_pipeline.py \
    --input "${INPUT_PATTERN}" \
    --output "${PROJECT_ID}:${DATASET}.${TABLE}" \
    --runner DataflowRunner \
    --project ${PROJECT_ID} \
    --region ${REGION} \
    --temp_location "gs://${TEMP_BUCKET}/dataflow/temp" \
    --staging_location "gs://${STAGING_BUCKET}/dataflow/staging" \
    --service_account_email ${SERVICE_ACCOUNT} \
    --max_num_workers ${MAX_WORKERS} \
    --machine_type ${MACHINE_TYPE} \
    --disk_size_gb ${DISK_SIZE} \
    --job_name ${JOB_NAME} \
    --setup_file ./setup.py 2>&1 | tee dataflow_job.log

echo ""
echo -e "${GREEN}✓ Dataflow job submitted successfully!${NC}"
echo ""
echo -e "${YELLOW}Monitor your job:${NC}"
echo "  Console: https://console.cloud.google.com/dataflow/jobs/${REGION}/${JOB_NAME}?project=${PROJECT_ID}"
echo ""
echo -e "${YELLOW}Check job status:${NC}"
echo "  gcloud dataflow jobs list --region=${REGION} --status=active"
echo ""
echo -e "${YELLOW}View job logs:${NC}"
echo "  gcloud dataflow jobs describe ${JOB_NAME} --region=${REGION}"
echo ""
