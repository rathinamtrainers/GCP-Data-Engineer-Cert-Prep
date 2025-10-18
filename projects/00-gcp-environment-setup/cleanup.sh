#!/bin/bash

################################################################################
# GCP Environment Cleanup Script
################################################################################
#
# This script contains commands to clean up all resources created during
# the GCP environment setup.
#
# ⚠️  WARNING: This script will DELETE resources and data! ⚠️
#
# Only run this when you're completely done with ALL 7 projects!
#
# Usage:
#   1. Review each section carefully
#   2. Understand what will be deleted
#   3. Run commands manually (recommended) or uncomment and execute
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}================================${NC}"
echo -e "${RED}GCP Environment Cleanup${NC}"
echo -e "${RED}================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  WARNING: This will DELETE resources! ⚠️${NC}"
echo ""
echo "This script will remove:"
echo "  • Service accounts and keys"
echo "  • IAM policy bindings"
echo "  • Enabled APIs (some)"
echo "  • gcloud configurations"
echo ""
echo "This script will NOT delete:"
echo "  • The GCP project itself (manual deletion required)"
echo "  • Billing account settings"
echo "  • Data in Cloud Storage, BigQuery, etc."
echo ""

read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

################################################################################
# SECTION 1: Get Project ID
################################################################################

echo -e "\n${YELLOW}SECTION 1: Getting Project ID${NC}\n"

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}ERROR: No project is set${NC}"
    echo "Set your project first:"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "Current project: ${PROJECT_ID}"
echo ""

read -p "Is this the correct project to clean up? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled. Set the correct project first:"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    exit 0
fi

################################################################################
# SECTION 2: Delete Service Account Keys
################################################################################

echo -e "\n${YELLOW}SECTION 2: Deleting Service Account Keys${NC}\n"

# Service account names
DEV_SA_NAME="dev-data-engineer"
DEV_SA_EMAIL="${DEV_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

DATAFLOW_SA_NAME="dataflow-runner"
DATAFLOW_SA_EMAIL="${DATAFLOW_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

COMPOSER_SA_NAME="composer-orchestrator"
COMPOSER_SA_EMAIL="${COMPOSER_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "List keys for dev service account:"
echo -e "${GREEN}gcloud iam service-accounts keys list \\
    --iam-account=${DEV_SA_EMAIL}${NC}"
echo ""
# gcloud iam service-accounts keys list --iam-account=${DEV_SA_EMAIL}

echo "Delete keys (except Google-managed keys):"
echo ""
echo "Get the KEY_ID from the list above, then run:"
echo -e "${GREEN}gcloud iam service-accounts keys delete KEY_ID \\
    --iam-account=${DEV_SA_EMAIL}${NC}"
echo ""

# To delete all user-managed keys programmatically:
# for key in $(gcloud iam service-accounts keys list --iam-account=${DEV_SA_EMAIL} --filter="keyType=USER_MANAGED" --format="value(name)"); do
#     gcloud iam service-accounts keys delete $key --iam-account=${DEV_SA_EMAIL} --quiet
# done

echo "Delete local key files:"
echo -e "${GREEN}rm -f ~/gcp-keys/dev-sa-key.json${NC}"
echo ""
# rm -f ~/gcp-keys/dev-sa-key.json

################################################################################
# SECTION 3: Remove IAM Policy Bindings
################################################################################

echo -e "\n${YELLOW}SECTION 3: Removing IAM Policy Bindings${NC}\n"

echo "Remove IAM roles from dev service account:"
echo ""

echo "1. Remove BigQuery Admin:"
echo -e "${GREEN}gcloud projects remove-iam-policy-binding \$PROJECT_ID \\
    --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
    --role=\"roles/bigquery.admin\"${NC}"
echo ""
# gcloud projects remove-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/bigquery.admin"

echo "2. Remove Storage Admin:"
echo -e "${GREEN}gcloud projects remove-iam-policy-binding \$PROJECT_ID \\
    --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
    --role=\"roles/storage.admin\"${NC}"
echo ""
# gcloud projects remove-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/storage.admin"

echo "3. Remove Pub/Sub Editor:"
echo -e "${GREEN}gcloud projects remove-iam-policy-binding \$PROJECT_ID \\
    --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
    --role=\"roles/pubsub.editor\"${NC}"
echo ""
# gcloud projects remove-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/pubsub.editor"

echo "Remove IAM roles from Dataflow service account:"
echo ""

echo "4. Remove Dataflow Worker:"
echo -e "${GREEN}gcloud projects remove-iam-policy-binding \$PROJECT_ID \\
    --member=\"serviceAccount:${DATAFLOW_SA_EMAIL}\" \\
    --role=\"roles/dataflow.worker\"${NC}"
echo ""
# gcloud projects remove-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DATAFLOW_SA_EMAIL}" \
#     --role="roles/dataflow.worker"

echo "5. Remove Storage Object Admin:"
echo -e "${GREEN}gcloud projects remove-iam-policy-binding \$PROJECT_ID \\
    --member=\"serviceAccount:${DATAFLOW_SA_EMAIL}\" \\
    --role=\"roles/storage.objectAdmin\"${NC}"
echo ""
# gcloud projects remove-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DATAFLOW_SA_EMAIL}" \
#     --role="roles/storage.objectAdmin"

################################################################################
# SECTION 4: Delete Service Accounts
################################################################################

echo -e "\n${YELLOW}SECTION 4: Deleting Service Accounts${NC}\n"

echo "Delete dev service account:"
echo -e "${GREEN}gcloud iam service-accounts delete ${DEV_SA_EMAIL} --quiet${NC}"
echo ""
# gcloud iam service-accounts delete ${DEV_SA_EMAIL} --quiet

echo "Delete Dataflow service account:"
echo -e "${GREEN}gcloud iam service-accounts delete ${DATAFLOW_SA_EMAIL} --quiet${NC}"
echo ""
# gcloud iam service-accounts delete ${DATAFLOW_SA_EMAIL} --quiet

echo "Delete Composer service account:"
echo -e "${GREEN}gcloud iam service-accounts delete ${COMPOSER_SA_EMAIL} --quiet${NC}"
echo ""
# gcloud iam service-accounts delete ${COMPOSER_SA_EMAIL} --quiet

################################################################################
# SECTION 5: Disable APIs (Optional)
################################################################################

echo -e "\n${YELLOW}SECTION 5: Disabling APIs (Optional)${NC}\n"

echo "NOTE: Disabling APIs is optional. It doesn't save money but keeps"
echo "your project cleaner. Some APIs cannot be disabled if resources exist."
echo ""

echo "Disable BigQuery API:"
echo -e "${GREEN}gcloud services disable bigquery.googleapis.com --force${NC}"
echo ""
# gcloud services disable bigquery.googleapis.com --force

echo "Disable Cloud Storage API:"
echo -e "${GREEN}gcloud services disable storage.googleapis.com --force${NC}"
echo ""
# gcloud services disable storage.googleapis.com --force

echo "Disable Compute Engine API:"
echo -e "${GREEN}gcloud services disable compute.googleapis.com --force${NC}"
echo ""
# gcloud services disable compute.googleapis.com --force

################################################################################
# SECTION 6: Delete gcloud Configuration
################################################################################

echo -e "\n${YELLOW}SECTION 6: Deleting gcloud Configuration${NC}\n"

CONFIG_NAME="data-eng-learning"

echo "List all configurations:"
echo -e "${GREEN}gcloud config configurations list${NC}"
echo ""
# gcloud config configurations list

echo "Delete the configuration:"
echo -e "${GREEN}gcloud config configurations delete ${CONFIG_NAME} --quiet${NC}"
echo ""
# gcloud config configurations delete ${CONFIG_NAME} --quiet

echo "Switch back to default configuration:"
echo -e "${GREEN}gcloud config configurations activate default${NC}"
echo ""
# gcloud config configurations activate default

################################################################################
# SECTION 7: Clean Up Local Environment
################################################################################

echo -e "\n${YELLOW}SECTION 7: Cleaning Local Environment${NC}\n"

echo "Remove Python virtual environment:"
echo -e "${GREEN}rm -rf venv/${NC}"
echo ""
# rm -rf venv/

echo "Remove service account keys directory:"
echo -e "${GREEN}rm -rf ~/gcp-keys${NC}"
echo ""
# rm -rf ~/gcp-keys

echo "Remove environment variables from your shell config:"
echo "  Edit ~/.bashrc or ~/.zshrc and remove:"
echo "    export GOOGLE_APPLICATION_CREDENTIALS=..."
echo "    export PROJECT_ID=..."
echo ""

################################################################################
# SECTION 8: Delete Project (Manual)
################################################################################

echo -e "\n${YELLOW}SECTION 8: Delete GCP Project${NC}\n"

echo -e "${RED}⚠️  FINAL STEP: Delete the entire project ⚠️${NC}"
echo ""
echo "This will permanently delete:"
echo "  • All data in Cloud Storage, BigQuery, etc."
echo "  • All configurations and settings"
echo "  • All compute resources"
echo "  • Everything in the project"
echo ""
echo "To delete the project:"
echo -e "${GREEN}gcloud projects delete ${PROJECT_ID}${NC}"
echo ""
echo "This action:"
echo "  • Cannot be undone"
echo "  • Takes 30 days to complete (scheduled deletion)"
echo "  • Can be cancelled within 30 days"
echo "  • Requires you to type the project ID to confirm"
echo ""

# Uncomment to delete project (BE VERY CAREFUL):
# gcloud projects delete ${PROJECT_ID}

echo "Alternatively, delete via Console:"
echo "  1. Go to: https://console.cloud.google.com/cloud-resource-manager"
echo "  2. Select your project"
echo "  3. Click 'Delete'"
echo "  4. Enter project ID to confirm"
echo ""

################################################################################
# SECTION 9: Verify Cleanup
################################################################################

echo -e "\n${YELLOW}SECTION 9: Verify Cleanup${NC}\n"

echo "Verify service accounts are deleted:"
echo -e "${GREEN}gcloud iam service-accounts list${NC}"
echo ""
# gcloud iam service-accounts list

echo "Verify configurations:"
echo -e "${GREEN}gcloud config configurations list${NC}"
echo ""
# gcloud config configurations list

echo "Check your billing:"
echo "  Visit: https://console.cloud.google.com/billing"
echo "  Verify: No active resources are consuming charges"
echo ""

################################################################################
# COMPLETION
################################################################################

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Cleanup Instructions Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "What was cleaned up:"
echo "  ✓ Service account keys"
echo "  ✓ IAM policy bindings"
echo "  ✓ Service accounts"
echo "  ✓ gcloud configurations"
echo "  ✓ Local files"
echo ""
echo "What remains (manual cleanup needed):"
echo "  • GCP project (use: gcloud projects delete $PROJECT_ID)"
echo "  • Data resources (if any)"
echo "  • Billing account (remains active)"
echo ""
echo "Final steps:"
echo "  1. Check billing dashboard for any remaining charges"
echo "  2. Delete the project if you're completely done"
echo "  3. Unset environment variables in your shell config"
echo ""
echo "Thank you for learning GCP Data Engineering!"
echo ""

################################################################################
# END OF CLEANUP SCRIPT
################################################################################
