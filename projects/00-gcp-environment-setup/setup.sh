#!/bin/bash

################################################################################
# GCP Environment Setup Script
################################################################################
#
# This script contains all gcloud CLI commands needed to set up your GCP
# environment for data engineering projects.
#
# IMPORTANT: This is an EDUCATIONAL script. Commands are commented out for
# safety. Read each section, understand the commands, then run them manually
# or uncomment and execute.
#
# Usage:
#   1. Read through each section
#   2. Copy and paste commands into your terminal
#   3. Or uncomment commands and run: bash setup.sh
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}GCP Environment Setup${NC}"
echo -e "${GREEN}================================${NC}"

################################################################################
# SECTION 1: Prerequisites Check
################################################################################

echo -e "\n${YELLOW}SECTION 1: Checking Prerequisites${NC}\n"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI is not installed${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "Quick install commands:"
    echo "# For Linux:"
    echo "curl https://sdk.cloud.google.com | bash"
    echo "exec -l \$SHELL"
    echo ""
    echo "# For macOS (with Homebrew):"
    echo "brew install --cask google-cloud-sdk"
    echo ""
    echo "# For Windows:"
    echo "# Download and run: https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    exit 1
else
    echo -e "${GREEN}✓ gcloud CLI is installed${NC}"
    gcloud version
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: Python 3 is not installed${NC}"
    echo "Install Python 3.9+ from: https://www.python.org/downloads/"
    exit 1
else
    echo -e "${GREEN}✓ Python is installed${NC}"
    python3 --version
fi

################################################################################
# SECTION 2: Authentication
################################################################################

echo -e "\n${YELLOW}SECTION 2: Authentication${NC}\n"

# Authenticate with your Google account
# This opens a browser window for you to log in
echo "Run the following command to authenticate:"
echo ""
echo -e "${GREEN}gcloud auth login${NC}"
echo ""
echo "This will:"
echo "  - Open your browser"
echo "  - Ask you to log in with your Google account"
echo "  - Grant gcloud access to your GCP resources"
echo ""

# Uncomment to run automatically:
# gcloud auth login

# Set application default credentials (for Python apps)
echo "After logging in, set application default credentials:"
echo ""
echo -e "${GREEN}gcloud auth application-default login${NC}"
echo ""
echo "This allows your Python applications to authenticate automatically"
echo ""

# Uncomment to run automatically:
# gcloud auth application-default login

# Verify authentication
echo "Verify authentication:"
echo -e "${GREEN}gcloud auth list${NC}"
echo ""
# gcloud auth list

################################################################################
# SECTION 3: Project Setup
################################################################################

echo -e "\n${YELLOW}SECTION 3: GCP Project Setup${NC}\n"

# Set your project ID (must be globally unique)
# Suggested format: data-eng-learning-YYYYMMDD or data-eng-yourname
echo "Choose a unique project ID. Project IDs must be:"
echo "  - 6-30 characters"
echo "  - Lowercase letters, digits, and hyphens"
echo "  - Start with a letter"
echo "  - Globally unique across all GCP"
echo ""
echo "Example: data-eng-learning-20250118"
echo ""

# Replace with your desired project ID
PROJECT_ID="data-eng-learning-$(date +%Y%m%d)"
echo "Suggested PROJECT_ID: ${PROJECT_ID}"
echo ""
echo "To set your project ID, run:"
echo -e "${GREEN}export PROJECT_ID=\"your-project-id-here\"${NC}"
echo ""

# List existing projects (to check if you already have one)
echo "List your existing projects:"
echo -e "${GREEN}gcloud projects list${NC}"
echo ""
# gcloud projects list

# Create a new project
echo "Create a new GCP project:"
echo -e "${GREEN}gcloud projects create \$PROJECT_ID --name=\"Data Engineering Learning\"${NC}"
echo ""
echo "This command:"
echo "  - Creates a new project with the specified ID"
echo "  - Sets a friendly display name"
echo "  - Takes about 30 seconds to complete"
echo ""

# Uncomment to create project:
# gcloud projects create $PROJECT_ID --name="Data Engineering Learning"

# Set the project as your default
echo "Set this project as your default:"
echo -e "${GREEN}gcloud config set project \$PROJECT_ID${NC}"
echo ""
# gcloud config set project $PROJECT_ID

# Verify project is set
echo "Verify current project:"
echo -e "${GREEN}gcloud config get-value project${NC}"
echo ""
# gcloud config get-value project

################################################################################
# SECTION 4: Billing Setup
################################################################################

echo -e "\n${YELLOW}SECTION 4: Billing Setup${NC}\n"

echo "IMPORTANT: You must link a billing account to your project"
echo "to use most GCP services."
echo ""

# List billing accounts
echo "List your billing accounts:"
echo -e "${GREEN}gcloud billing accounts list${NC}"
echo ""
# gcloud billing accounts list

echo "Save your billing account ID:"
echo -e "${GREEN}export BILLING_ACCOUNT_ID=\"your-billing-account-id\"${NC}"
echo ""

# Link billing account to project
echo "Link billing to your project:"
echo -e "${GREEN}gcloud billing projects link \$PROJECT_ID --billing-account=\$BILLING_ACCOUNT_ID${NC}"
echo ""
# gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID

# Verify billing is enabled
echo "Verify billing is enabled:"
echo -e "${GREEN}gcloud billing projects describe \$PROJECT_ID${NC}"
echo ""
# gcloud billing projects describe $PROJECT_ID

################################################################################
# SECTION 5: Enable Required APIs
################################################################################

echo -e "\n${YELLOW}SECTION 5: Enable Required APIs${NC}\n"

echo "Enable essential GCP APIs for data engineering:"
echo ""

# Core APIs
echo "1. Enable Cloud Resource Manager API:"
echo -e "${GREEN}gcloud services enable cloudresourcemanager.googleapis.com${NC}"
echo ""
# gcloud services enable cloudresourcemanager.googleapis.com

echo "2. Enable IAM API:"
echo -e "${GREEN}gcloud services enable iam.googleapis.com${NC}"
echo ""
# gcloud services enable iam.googleapis.com

echo "3. Enable Cloud Billing API:"
echo -e "${GREEN}gcloud services enable cloudbilling.googleapis.com${NC}"
echo ""
# gcloud services enable cloudbilling.googleapis.com

echo "4. Enable Cloud Monitoring API:"
echo -e "${GREEN}gcloud services enable monitoring.googleapis.com${NC}"
echo ""
# gcloud services enable monitoring.googleapis.com

echo "5. Enable Cloud Logging API:"
echo -e "${GREEN}gcloud services enable logging.googleapis.com${NC}"
echo ""
# gcloud services enable logging.googleapis.com

# Data engineering APIs (we'll enable more as we progress through projects)
echo "6. Enable Compute Engine API (for VMs and networking):"
echo -e "${GREEN}gcloud services enable compute.googleapis.com${NC}"
echo ""
# gcloud services enable compute.googleapis.com

echo "7. Enable Cloud Storage API:"
echo -e "${GREEN}gcloud services enable storage.googleapis.com${NC}"
echo ""
# gcloud services enable storage.googleapis.com

echo "8. Enable BigQuery API:"
echo -e "${GREEN}gcloud services enable bigquery.googleapis.com${NC}"
echo ""
# gcloud services enable bigquery.googleapis.com

# List all enabled services
echo "List all enabled APIs:"
echo -e "${GREEN}gcloud services list --enabled${NC}"
echo ""
# gcloud services list --enabled

################################################################################
# SECTION 6: IAM Setup - Service Accounts
################################################################################

echo -e "\n${YELLOW}SECTION 6: IAM Setup - Service Accounts${NC}\n"

echo "Create service accounts for different purposes:"
echo ""

# Service account for local development
DEV_SA_NAME="dev-data-engineer"
DEV_SA_EMAIL="${DEV_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "1. Create a development service account:"
echo -e "${GREEN}gcloud iam service-accounts create ${DEV_SA_NAME} \\
    --display-name=\"Development Data Engineer\" \\
    --description=\"Service account for local development and testing\"${NC}"
echo ""
# gcloud iam service-accounts create $DEV_SA_NAME \
#     --display-name="Development Data Engineer" \
#     --description="Service account for local development and testing"

# Service account for Dataflow jobs
DATAFLOW_SA_NAME="dataflow-runner"
DATAFLOW_SA_EMAIL="${DATAFLOW_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "2. Create a Dataflow service account:"
echo -e "${GREEN}gcloud iam service-accounts create ${DATAFLOW_SA_NAME} \\
    --display-name=\"Dataflow Job Runner\" \\
    --description=\"Service account for running Dataflow pipelines\"${NC}"
echo ""
# gcloud iam service-accounts create $DATAFLOW_SA_NAME \
#     --display-name="Dataflow Job Runner" \
#     --description="Service account for running Dataflow pipelines"

# Service account for Composer (Airflow)
COMPOSER_SA_NAME="composer-orchestrator"
COMPOSER_SA_EMAIL="${COMPOSER_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "3. Create a Composer service account:"
echo -e "${GREEN}gcloud iam service-accounts create ${COMPOSER_SA_NAME} \\
    --display-name=\"Cloud Composer Orchestrator\" \\
    --description=\"Service account for Cloud Composer environments\"${NC}"
echo ""
# gcloud iam service-accounts create $COMPOSER_SA_NAME \
#     --display-name="Cloud Composer Orchestrator" \
#     --description="Service account for Cloud Composer environments"

# List all service accounts
echo "List all service accounts:"
echo -e "${GREEN}gcloud iam service-accounts list${NC}"
echo ""
# gcloud iam service accounts list

################################################################################
# SECTION 7: IAM Setup - Grant Roles
################################################################################

echo -e "\n${YELLOW}SECTION 7: Grant IAM Roles to Service Accounts${NC}\n"

echo "Grant necessary roles to service accounts:"
echo ""

# Development service account roles
echo "1. Grant roles to dev service account:"
echo ""
echo "   a. BigQuery Admin (for development):"
echo -e "   ${GREEN}gcloud projects add-iam-policy-binding \$PROJECT_ID \\
       --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
       --role=\"roles/bigquery.admin\"${NC}"
echo ""
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/bigquery.admin"

echo "   b. Storage Admin:"
echo -e "   ${GREEN}gcloud projects add-iam-policy-binding \$PROJECT_ID \\
       --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
       --role=\"roles/storage.admin\"${NC}"
echo ""
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/storage.admin"

echo "   c. Pub/Sub Editor:"
echo -e "   ${GREEN}gcloud projects add-iam-policy-binding \$PROJECT_ID \\
       --member=\"serviceAccount:${DEV_SA_EMAIL}\" \\
       --role=\"roles/pubsub.editor\"${NC}"
echo ""
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DEV_SA_EMAIL}" \
#     --role="roles/pubsub.editor"

# Dataflow service account roles
echo "2. Grant roles to Dataflow service account:"
echo ""
echo "   a. Dataflow Worker:"
echo -e "   ${GREEN}gcloud projects add-iam-policy-binding \$PROJECT_ID \\
       --member=\"serviceAccount:${DATAFLOW_SA_EMAIL}\" \\
       --role=\"roles/dataflow.worker\"${NC}"
echo ""
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DATAFLOW_SA_EMAIL}" \
#     --role="roles/dataflow.worker"

echo "   b. Storage Object Admin:"
echo -e "   ${GREEN}gcloud projects add-iam-policy-binding \$PROJECT_ID \\
       --member=\"serviceAccount:${DATAFLOW_SA_EMAIL}\" \\
       --role=\"roles/storage.objectAdmin\"${NC}"
echo ""
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:${DATAFLOW_SA_EMAIL}" \
#     --role="roles/storage.objectAdmin"

# View current IAM policy
echo "View current IAM policy:"
echo -e "${GREEN}gcloud projects get-iam-policy \$PROJECT_ID${NC}"
echo ""
# gcloud projects get-iam-policy $PROJECT_ID

################################################################################
# SECTION 8: Service Account Keys
################################################################################

echo -e "\n${YELLOW}SECTION 8: Service Account Keys${NC}\n"

echo "IMPORTANT: Service account keys should be handled carefully!"
echo "  - Never commit keys to version control"
echo "  - Store them securely"
echo "  - Rotate them regularly"
echo "  - Use Workload Identity when possible (for production)"
echo ""

echo "Create a key for the dev service account:"
echo -e "${GREEN}gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \\
    --iam-account=${DEV_SA_EMAIL}${NC}"
echo ""
echo "This will download a JSON key file for local development"
echo ""

# Create directory for keys
# mkdir -p ~/gcp-keys

# Create key
# gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
#     --iam-account=${DEV_SA_EMAIL}

echo "Set environment variable to use the key:"
echo -e "${GREEN}export GOOGLE_APPLICATION_CREDENTIALS=\"\$HOME/gcp-keys/dev-sa-key.json\"${NC}"
echo ""
echo "Add this to your ~/.bashrc or ~/.zshrc to make it permanent"
echo ""

################################################################################
# SECTION 9: Budget Alerts
################################################################################

echo -e "\n${YELLOW}SECTION 9: Budget Alerts${NC}\n"

echo "Set up budget alerts to monitor spending:"
echo ""
echo "NOTE: Budget creation requires using the Cloud Console or REST API"
echo "as it's not directly supported in gcloud CLI."
echo ""
echo "To create a budget alert:"
echo "  1. Go to: https://console.cloud.google.com/billing/budgets"
echo "  2. Click 'Create Budget'"
echo "  3. Set amount: \$50/month (or your preference)"
echo "  4. Set alert thresholds: 50%, 90%, 100%"
echo "  5. Add your email for notifications"
echo ""
echo "Alternatively, use the REST API:"
echo "  https://cloud.google.com/billing/docs/how-to/budget-api-examples"
echo ""

################################################################################
# SECTION 10: Set Up Configuration
################################################################################

echo -e "\n${YELLOW}SECTION 10: Configuration Management${NC}\n"

echo "gcloud supports multiple configurations for different projects/environments"
echo ""

# Create a configuration for this project
CONFIG_NAME="data-eng-learning"

echo "1. Create a named configuration:"
echo -e "${GREEN}gcloud config configurations create ${CONFIG_NAME}${NC}"
echo ""
# gcloud config configurations create $CONFIG_NAME

echo "2. Set project in this configuration:"
echo -e "${GREEN}gcloud config set project \$PROJECT_ID${NC}"
echo ""
# gcloud config set project $PROJECT_ID

echo "3. Set default region (choose one close to you):"
echo -e "${GREEN}gcloud config set compute/region us-central1${NC}"
echo ""
# gcloud config set compute/region us-central1

echo "4. Set default zone:"
echo -e "${GREEN}gcloud config set compute/zone us-central1-a${NC}"
echo ""
# gcloud config set compute/zone us-central1-a

# List configurations
echo "List all configurations:"
echo -e "${GREEN}gcloud config configurations list${NC}"
echo ""
# gcloud config configurations list

# View current configuration
echo "View current configuration:"
echo -e "${GREEN}gcloud config list${NC}"
echo ""
# gcloud config list

################################################################################
# SECTION 11: Enable Cloud Monitoring & Logging
################################################################################

echo -e "\n${YELLOW}SECTION 11: Monitoring & Logging${NC}\n"

echo "Cloud Monitoring and Logging are automatically enabled when you"
echo "use GCP services. No additional setup required!"
echo ""

echo "To view logs:"
echo -e "${GREEN}gcloud logging read \"resource.type=global\" --limit=10${NC}"
echo ""
# gcloud logging read "resource.type=global" --limit=10

echo "To view metrics:"
echo "  Visit: https://console.cloud.google.com/monitoring"
echo ""

################################################################################
# SECTION 12: Python Environment Setup
################################################################################

echo -e "\n${YELLOW}SECTION 12: Python Environment Setup${NC}\n"

echo "Set up Python virtual environment:"
echo ""

echo "1. Navigate to the project directory:"
echo -e "${GREEN}cd \$(pwd)${NC}"
echo ""

echo "2. Create virtual environment:"
echo -e "${GREEN}python3 -m venv venv${NC}"
echo ""
# python3 -m venv venv

echo "3. Activate virtual environment:"
echo ""
echo "   On Linux/Mac:"
echo -e "   ${GREEN}source venv/bin/activate${NC}"
echo ""
echo "   On Windows:"
echo -e "   ${GREEN}venv\\Scripts\\activate${NC}"
echo ""

echo "4. Upgrade pip:"
echo -e "${GREEN}pip install --upgrade pip${NC}"
echo ""
# pip install --upgrade pip

echo "5. Install GCP Python libraries:"
echo -e "${GREEN}pip install -r src/requirements.txt${NC}"
echo ""
# pip install -r src/requirements.txt

################################################################################
# SECTION 13: Verification
################################################################################

echo -e "\n${YELLOW}SECTION 13: Verify Setup${NC}\n"

echo "Run the test script to verify everything is set up correctly:"
echo -e "${GREEN}python src/test_connection.py${NC}"
echo ""
# python src/test_connection.py

################################################################################
# COMPLETION
################################################################################

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Setup Instructions Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the commands above"
echo "  2. Run them one by one in your terminal"
echo "  3. Or uncomment and execute this script"
echo "  4. Run the test script to verify setup"
echo "  5. Proceed to Project 1: Batch ETL Pipeline"
echo ""
echo "For detailed explanations, see: commands.md"
echo ""
echo "Remember to set these environment variables:"
echo "  export PROJECT_ID=\"your-project-id\""
echo "  export GOOGLE_APPLICATION_CREDENTIALS=\"path/to/key.json\""
echo ""

################################################################################
# END OF SETUP SCRIPT
################################################################################
