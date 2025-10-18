#!/bin/bash

################################################################################
# Quick Setup for Existing GCP Project: data-engineer-475516
################################################################################
#
# This script completes the setup for your existing GCP project.
# Run commands one by one or execute the entire script.
#
################################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ID="data-engineer-475516"
PROJECT_NUMBER="434782524071"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Setting up: $PROJECT_ID${NC}"
echo -e "${GREEN}================================${NC}"

################################################################################
# 1. Enable Required APIs
################################################################################

echo -e "\n${YELLOW}Step 1: Enabling Required APIs${NC}\n"

echo "Enabling core APIs..."
gcloud services enable compute.googleapis.com --project=$PROJECT_ID
gcloud services enable iam.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudresourcemanager.googleapis.com --project=$PROJECT_ID

echo "Enabling data engineering APIs..."
gcloud services enable storage.googleapis.com --project=$PROJECT_ID
gcloud services enable pubsub.googleapis.com --project=$PROJECT_ID
gcloud services enable dataflow.googleapis.com --project=$PROJECT_ID
gcloud services enable composer.googleapis.com --project=$PROJECT_ID
gcloud services enable dataproc.googleapis.com --project=$PROJECT_ID
gcloud services enable datafusion.googleapis.com --project=$PROJECT_ID

echo "Enabling database APIs..."
gcloud services enable sqladmin.googleapis.com --project=$PROJECT_ID
gcloud services enable spanner.googleapis.com --project=$PROJECT_ID
gcloud services enable bigtable.googleapis.com --project=$PROJECT_ID

echo "Enabling additional services..."
gcloud services enable datacatalog.googleapis.com --project=$PROJECT_ID
gcloud services enable dlp.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudkms.googleapis.com --project=$PROJECT_ID

echo -e "${GREEN}✓ APIs enabled${NC}"

################################################################################
# 2. Set Default Region and Zone
################################################################################

echo -e "\n${YELLOW}Step 2: Setting Default Region and Zone${NC}\n"

gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

echo -e "${GREEN}✓ Region set to us-central1${NC}"

################################################################################
# 3. Create Service Accounts
################################################################################

echo -e "\n${YELLOW}Step 3: Creating Service Accounts${NC}\n"

# Development service account
echo "Creating dev-data-engineer service account..."
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for local development and testing" \
    --project=$PROJECT_ID

# Dataflow service account
echo "Creating dataflow-runner service account..."
gcloud iam service-accounts create dataflow-runner \
    --display-name="Dataflow Job Runner" \
    --description="Service account for running Dataflow pipelines" \
    --project=$PROJECT_ID

# Composer service account
echo "Creating composer-orchestrator service account..."
gcloud iam service-accounts create composer-orchestrator \
    --display-name="Cloud Composer Orchestrator" \
    --description="Service account for Cloud Composer environments" \
    --project=$PROJECT_ID

echo -e "${GREEN}✓ Service accounts created${NC}"

# List service accounts
gcloud iam service-accounts list --project=$PROJECT_ID

################################################################################
# 4. Grant IAM Roles
################################################################################

echo -e "\n${YELLOW}Step 4: Granting IAM Roles${NC}\n"

DEV_SA="dev-data-engineer@${PROJECT_ID}.iam.gserviceaccount.com"
DATAFLOW_SA="dataflow-runner@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Granting roles to dev service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DEV_SA}" \
    --role="roles/bigquery.admin" \
    --condition=None

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DEV_SA}" \
    --role="roles/storage.admin" \
    --condition=None

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DEV_SA}" \
    --role="roles/pubsub.editor" \
    --condition=None

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DEV_SA}" \
    --role="roles/dataflow.developer" \
    --condition=None

echo "Granting roles to Dataflow service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DATAFLOW_SA}" \
    --role="roles/dataflow.worker" \
    --condition=None

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${DATAFLOW_SA}" \
    --role="roles/storage.objectAdmin" \
    --condition=None

echo -e "${GREEN}✓ IAM roles granted${NC}"

################################################################################
# 5. Create Service Account Key
################################################################################

echo -e "\n${YELLOW}Step 5: Creating Service Account Key${NC}\n"

# Create directory for keys
mkdir -p ~/gcp-keys

# Create key
KEY_FILE="$HOME/gcp-keys/dev-sa-key.json"
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$DEV_SA \
    --project=$PROJECT_ID

# Set permissions
chmod 600 $KEY_FILE

echo -e "${GREEN}✓ Key created: $KEY_FILE${NC}"

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE

echo ""
echo "Add this to your ~/.bashrc or ~/.zshrc:"
echo "export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_FILE\""

################################################################################
# 6. Create .env file
################################################################################

echo -e "\n${YELLOW}Step 6: Creating .env Configuration${NC}\n"

ENV_FILE="$(dirname $0)/config/.env"

cat > $ENV_FILE << EOF
# GCP Project Configuration
GCP_PROJECT_ID=$PROJECT_ID
GCP_PROJECT_NUMBER=$PROJECT_NUMBER
GCP_REGION=us-central1
GCP_ZONE=us-central1-a

# Authentication
GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
SERVICE_ACCOUNT_EMAIL=$DEV_SA

# BigQuery Configuration
BIGQUERY_DATASET=dev_dataset
BIGQUERY_LOCATION=US

# Cloud Storage Configuration
GCS_BUCKET_NAME=${PROJECT_ID}-data
GCS_STAGING_BUCKET=${PROJECT_ID}-staging
GCS_TEMP_BUCKET=${PROJECT_ID}-temp

# Pub/Sub Configuration
PUBSUB_TOPIC=test-topic
PUBSUB_SUBSCRIPTION=test-subscription

# Dataflow Configuration
DATAFLOW_STAGING_LOCATION=gs://${PROJECT_ID}-staging/dataflow/staging
DATAFLOW_TEMP_LOCATION=gs://${PROJECT_ID}-temp/dataflow/temp
DATAFLOW_SERVICE_ACCOUNT=$DATAFLOW_SA

# Development Settings
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
EOF

echo -e "${GREEN}✓ Configuration file created: $ENV_FILE${NC}"

################################################################################
# Summary
################################################################################

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"

echo -e "\nWhat was configured:"
echo "  ✓ Required APIs enabled"
echo "  ✓ Default region set to us-central1"
echo "  ✓ 3 service accounts created"
echo "  ✓ IAM roles granted"
echo "  ✓ Service account key created"
echo "  ✓ .env configuration file created"

echo -e "\nNext steps:"
echo "  1. Add this to your shell config (~/.bashrc or ~/.zshrc):"
echo "     export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_FILE\""
echo ""
echo "  2. Set up Python environment:"
echo "     cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep"
echo "     python3 -m venv venv"
echo "     source venv/bin/activate"
echo "     pip install -r projects/00-gcp-environment-setup/src/requirements.txt"
echo ""
echo "  3. Test your setup:"
echo "     python projects/00-gcp-environment-setup/src/test_connection.py"
echo ""
echo "  4. Proceed to Project 1!"
echo ""

################################################################################
# END
################################################################################
