#!/bin/bash

################################################################################
# Monitor Cloud Composer Environment Creation
################################################################################
#
# This script monitors the Composer environment creation progress
#
# Usage:
#   ./monitor_composer.sh
#
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="data-engineer-475516"
LOCATION="us-central1"
ENVIRONMENT_NAME="weather-etl-composer"
OPERATION_ID="766432f5-f170-485e-abb1-4a6ab87a1cf7"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Cloud Composer Environment Monitor                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Environment:${NC} ${ENVIRONMENT_NAME}"
echo -e "${YELLOW}Location:${NC} ${LOCATION}"
echo -e "${YELLOW}Operation ID:${NC} ${OPERATION_ID}"
echo ""

# Function to check environment status
check_environment() {
    echo -e "${YELLOW}Checking environment status...${NC}"
    gcloud composer environments describe ${ENVIRONMENT_NAME} \
        --location ${LOCATION} \
        --project ${PROJECT_ID} \
        --format="value(state)" 2>/dev/null || echo "NOT_CREATED"
}

# Function to check operation status
check_operation() {
    echo -e "${YELLOW}Checking operation status...${NC}"
    gcloud composer operations describe ${OPERATION_ID} \
        --location ${LOCATION} \
        --project ${PROJECT_ID} \
        --format="yaml(metadata.operationType,metadata.state)" 2>/dev/null || echo "Operation not found"
}

# Check current status
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

ENV_STATE=$(check_environment)
echo ""

if [ "$ENV_STATE" == "RUNNING" ]; then
    echo -e "${GREEN}✅ Environment is RUNNING!${NC}"
    echo ""
    echo -e "${YELLOW}Getting Airflow web UI URL...${NC}"
    AIRFLOW_URL=$(gcloud composer environments describe ${ENVIRONMENT_NAME} \
        --location ${LOCATION} \
        --project ${PROJECT_ID} \
        --format="value(config.airflowUri)")
    echo -e "${GREEN}Airflow UI:${NC} ${AIRFLOW_URL}"
    echo ""
    echo -e "${YELLOW}Getting DAGs bucket...${NC}"
    DAGS_BUCKET=$(gcloud composer environments describe ${ENVIRONMENT_NAME} \
        --location ${LOCATION} \
        --project ${PROJECT_ID} \
        --format="value(config.dagGcsPrefix)")
    echo -e "${GREEN}DAGs Bucket:${NC} ${DAGS_BUCKET}"
    echo ""
elif [ "$ENV_STATE" == "CREATING" ]; then
    echo -e "${YELLOW}⏳ Environment is CREATING...${NC}"
    echo ""
    check_operation
    echo ""
    echo -e "${YELLOW}This typically takes 20-30 minutes.${NC}"
    echo -e "${YELLOW}Run this script again to check status.${NC}"
    echo ""
elif [ "$ENV_STATE" == "ERROR" ]; then
    echo -e "${RED}❌ Environment creation FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Check operation for error details:${NC}"
    check_operation
    echo ""
else
    echo -e "${YELLOW}⏳ Environment status: ${ENV_STATE}${NC}"
    echo ""
    check_operation
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Manual Commands:${NC}"
echo ""
echo "# List all environments"
echo "gcloud composer environments list --locations ${LOCATION} --project ${PROJECT_ID}"
echo ""
echo "# View full environment details"
echo "gcloud composer environments describe ${ENVIRONMENT_NAME} \\"
echo "    --location ${LOCATION} --project ${PROJECT_ID}"
echo ""
echo "# View in console"
echo "https://console.cloud.google.com/composer/environments?project=${PROJECT_ID}"
echo ""
