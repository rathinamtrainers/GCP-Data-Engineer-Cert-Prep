# GCP Environment Setup - Execution Log

**Project**: data-engineer-475516
**Date**: 2025-10-18
**Purpose**: Complete GCP environment setup for data engineering projects

This document logs every command executed, its output, and explanation of what it does.

---

## Table of Contents

1. [Initial Status Check](#initial-status-check)
2. [Enabling Required APIs](#enabling-required-apis)
3. [Setting Default Region and Zone](#setting-default-region-and-zone)
4. [Creating Service Accounts](#creating-service-accounts)
5. [Granting IAM Roles](#granting-iam-roles)
6. [Creating Service Account Keys](#creating-service-account-keys)
7. [Creating Configuration Files](#creating-configuration-files)
8. [Python Environment Setup](#python-environment-setup)
9. [Testing Setup](#testing-setup)
10. [Summary and Next Steps](#summary-and-next-steps)

---

## Initial Status Check

### Command: Check Project Details
```bash
gcloud projects describe data-engineer-475516
```

**Purpose**: Verify project exists and get project details

**Output**:
```yaml
createTime: '2025-10-18T16:05:19.241167Z'
lifecycleState: ACTIVE
name: data-engineer
parent:
  id: '401231695336'
  type: organization
projectId: data-engineer-475516
projectNumber: '434782524071'
```

**What this tells us**:
- ✓ Project is ACTIVE (good!)
- ✓ Project ID: data-engineer-475516
- ✓ Project Number: 434782524071 (used for some API calls)
- ✓ Part of organization (ID: 401231695336)
- ✓ Created on: 2025-10-18

---

### Command: Check Billing Status
```bash
gcloud billing projects describe data-engineer-475516
```

**Purpose**: Ensure billing is enabled (required for most GCP services)

**Output**:
```yaml
billingAccountName: billingAccounts/015BD5-1865A1-4C89C3
billingEnabled: true
name: projects/data-engineer-475516/billingInfo
projectId: data-engineer-475516
```

**What this tells us**:
- ✓ Billing is ENABLED
- ✓ Linked to billing account: 015BD5-1865A1-4C89C3
- ℹ️  Without billing, we cannot use paid services (Dataflow, Composer, etc.)

---

### Command: Check Currently Enabled APIs
```bash
gcloud services list --enabled --project=data-engineer-475516
```

**Purpose**: See which GCP APIs are already enabled

**Output** (partial):
```
NAME
analyticshub.googleapis.com          # Analytics Hub (data sharing)
bigquery.googleapis.com              # BigQuery (data warehouse)
bigqueryconnection.googleapis.com    # BigQuery connections
dataform.googleapis.com              # Dataform (SQL transformations)
dataplex.googleapis.com              # Dataplex (data lake management)
logging.googleapis.com               # Cloud Logging
monitoring.googleapis.com            # Cloud Monitoring
storage-api.googleapis.com           # Cloud Storage
```

**What this tells us**:
- ✓ BigQuery APIs already enabled
- ✓ Storage API enabled
- ✓ Logging and Monitoring enabled
- ❌ Missing: Pub/Sub, Dataflow, Composer, Compute Engine, IAM
- ❌ Missing: Database services (Cloud SQL, Bigtable, Spanner)

---

### Command: Check Existing Service Accounts
```bash
gcloud iam service-accounts list --project=data-engineer-475516
```

**Purpose**: See if any service accounts already exist

**Output**:
```
Listed 0 items.
```

**What this tells us**:
- ❌ No custom service accounts created yet
- ℹ️  We'll need to create service accounts for:
  - Local development
  - Dataflow jobs
  - Cloud Composer environments

---

## Enabling Required APIs

APIs are like "switches" that turn on GCP services. Each service requires its API to be enabled.

### Why Enable APIs?

- **Security**: APIs are disabled by default to prevent unauthorized usage
- **Billing**: Enabling an API doesn't cost money; using the service does
- **Time**: APIs can take 1-2 minutes to fully activate across Google's infrastructure

### Command: Enable Compute Engine API
```bash
gcloud services enable compute.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Enables virtual machine creation
- Required for: Dataflow (uses VMs behind the scenes), Composer, Dataproc
- Foundation for networking (VPCs, firewalls)

**Expected Output**:
```
Operation "operations/..." finished successfully.
```

**What happens**:
- Google registers your project for Compute Engine
- Creates default VPC network (if not exists)
- Takes ~30-60 seconds

---

### Command: Enable IAM API
```bash
gcloud services enable iam.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Identity and Access Management
- Required for: Creating service accounts, managing permissions
- Controls "who can do what" in your project

**Why this matters**:
- Without IAM API, you can't create service accounts
- Service accounts are how applications authenticate to GCP
- Best practice: Applications should NEVER use personal credentials

---

### Command: Enable Cloud Resource Manager API
```bash
gcloud services enable cloudresourcemanager.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Manage projects, folders, organizations programmatically
- Required for: Viewing/updating project metadata
- Used by: gcloud commands that query project info

---

### Command: Enable Pub/Sub API
```bash
gcloud services enable pubsub.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Messaging service for event-driven architectures
- Required for: Projects 2, 5, 7 (streaming, event-driven pipelines)
- Enables: Creating topics, subscriptions, publishing/consuming messages

**Exam relevance**: ~10-15% of exam questions involve Pub/Sub

---

### Command: Enable Dataflow API
```bash
gcloud services enable dataflow.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Fully managed Apache Beam pipeline execution
- Required for: Projects 1, 2, 3, 5 (all pipeline projects)
- Handles: Both batch and streaming data processing

**Exam relevance**: ~20% of exam questions involve Dataflow

**What it does behind the scenes**:
- Provisions VMs to run your pipeline code
- Manages autoscaling
- Handles worker communication

---

### Command: Enable Cloud Composer API
```bash
gcloud services enable composer.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Fully managed Apache Airflow (workflow orchestration)
- Required for: Projects 1, 7 (scheduling and orchestration)
- Used to: Schedule DAGs (Directed Acyclic Graphs)

**Exam relevance**: ~10% of exam questions involve Composer/Airflow

**Cost note**: Composer is one of the more expensive services (~$300/month for basic environment)
- We'll use it carefully and shut down when not needed

---

### Command: Enable Dataproc API
```bash
gcloud services enable dataproc.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Managed Apache Spark and Hadoop clusters
- Alternative to Dataflow for Spark-based workloads
- Good for: Existing Spark code, machine learning with Spark MLlib

**When to use Dataproc vs Dataflow**:
- Dataproc: Have existing Spark/Hadoop code, need specific Spark features
- Dataflow: New pipelines, autoscaling important, unified batch/streaming

---

### Command: Enable Data Fusion API
```bash
gcloud services enable datafusion.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Visual ETL builder (code-free pipelines)
- Generates Dataproc or Dataflow pipelines under the hood
- Good for: Non-programmers building pipelines, rapid prototyping

---

### Command: Enable Cloud SQL API
```bash
gcloud services enable sqladmin.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Managed MySQL, PostgreSQL, SQL Server databases
- Required for: Project 3 (multi-source data integration)
- Used for: Operational databases, transactional workloads

**Exam tip**: Know when to use Cloud SQL vs BigQuery vs Spanner
- Cloud SQL: < 30 TB, regional, traditional RDBMS
- BigQuery: Analytics, data warehouse, petabyte-scale
- Spanner: Global, horizontally scalable, strong consistency

---

### Command: Enable Cloud Spanner API
```bash
gcloud services enable spanner.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Globally distributed, horizontally scalable relational database
- Best for: Global applications, need SQL + scalability + consistency
- Unique feature: Global transactions with strong consistency

**Cost note**: Spanner is expensive (minimum ~$650/month)
- We'll create instances only for learning, then delete immediately

---

### Command: Enable Bigtable API
```bash
gcloud services enable bigtable.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- NoSQL wide-column database (like Apache HBase)
- Best for: Time-series data, IoT sensors, high-throughput writes
- Required for: Project 2 (IoT streaming)

**Key characteristics**:
- Single-digit millisecond latency
- Handles millions of operations per second
- Column-family data model

**Exam tip**: Bigtable is for operational workloads, BigQuery is for analytics

---

### Command: Enable Data Catalog API
```bash
gcloud services enable datacatalog.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Metadata management and data discovery
- Automatic discovery of: BigQuery datasets, Pub/Sub topics, Cloud Storage buckets
- Tag data assets with business metadata

---

### Command: Enable Cloud DLP API
```bash
gcloud services enable dlp.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Data Loss Prevention - detect and mask sensitive data
- Finds: PII (emails, SSNs, credit cards), custom patterns
- Required for: Project 6 (security hardening)

**Exam relevance**: Compliance and data governance questions

---

### Command: Enable Cloud KMS API
```bash
gcloud services enable cloudkms.googleapis.com --project=data-engineer-475516
```

**Purpose**:
- Key Management Service - encryption key management
- Used for: Customer-managed encryption keys (CMEK)
- Required for: Project 6 (encryption)

**Default GCP behavior**:
- Google encrypts all data at rest automatically
- KMS lets you control and rotate encryption keys
- Required for compliance (HIPAA, PCI-DSS)

---

### Command: Verify All APIs Enabled
```bash
gcloud services list --enabled --project=data-engineer-475516 | wc -l
```

**Purpose**: Count how many APIs are now enabled

**Expected**: ~25-30 APIs

---

## Setting Default Region and Zone

### Why Set Default Region?

- **Reduces command length**: Don't need to specify region for every command
- **Proximity**: Choose region close to users for low latency
- **Compliance**: Some data must stay in specific regions (GDPR, etc.)
- **Cost**: Prices vary slightly by region

### Region Selection Guide

| Region | Location | Best For |
|--------|----------|----------|
| us-central1 | Iowa, USA | General purpose, lowest cost |
| us-east1 | South Carolina, USA | East coast users |
| us-west1 | Oregon, USA | West coast users |
| europe-west1 | Belgium | EU users, GDPR compliance |
| asia-southeast1 | Singapore | Asia-Pacific users |

### Command: Set Default Region
```bash
gcloud config set compute/region us-central1
```

**Purpose**: Set default region for all compute resources

**Output**:
```
Updated property [compute/region].
```

**What this affects**:
- Dataflow jobs will run in this region
- Cloud Storage buckets default to this region
- Composer environments default to this region

---

### Command: Set Default Zone
```bash
gcloud config set compute/zone us-central1-a
```

**Purpose**: Set default zone for VM instances

**Output**:
```
Updated property [compute/zone].
```

**Zone vs Region**:
- **Region**: us-central1 (geographic area with multiple data centers)
- **Zone**: us-central1-a, us-central1-b, etc. (individual data centers)
- Resources in different zones have higher availability (fault isolation)

---

### Command: Verify Configuration
```bash
gcloud config list
```

**Expected Output**:
```
[compute]
region = us-central1
zone = us-central1-a
[core]
account = rajan@rathinamtrainers.com
disable_usage_reporting = True
project = data-engineer-475516
```

---

## Creating Service Accounts

### What Are Service Accounts?

Service accounts are "robot accounts" for applications:
- Applications authenticate as a service account
- NOT tied to a human user
- Have their own credentials (keys)
- Can be granted specific permissions

### Why Use Service Accounts?

**Security**:
- Applications don't use your personal credentials
- Can revoke app access without affecting your access
- Easier to audit (service account name shows in logs)

**Best Practices**:
- Create separate service accounts for each application/purpose
- Principle of least privilege (only grant needed permissions)
- Rotate keys every 90 days

---

### Command: Create Development Service Account
```bash
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for local development and testing" \
    --project=data-engineer-475516
```

**Purpose**: Service account for running code on your local machine

**Expected Output**:
```
Created service account [dev-data-engineer].
```

**What gets created**:
- Service account ID: `dev-data-engineer`
- Service account email: `dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com`
- No permissions yet (we'll grant them next)

**When to use this**:
- Running Python scripts locally
- Testing Dataflow pipelines from your laptop
- Querying BigQuery from local code

---

### Command: Create Dataflow Service Account
```bash
gcloud iam service-accounts create dataflow-runner \
    --display-name="Dataflow Job Runner" \
    --description="Service account for running Dataflow pipelines" \
    --project=data-engineer-475516
```

**Purpose**: Service account for Dataflow worker VMs

**Why separate from dev account?**
- Dataflow workers need different permissions
- Security: limit blast radius if compromised
- Auditing: track which actions came from Dataflow vs dev

**What Dataflow workers do**:
- Read from Cloud Storage (staging files)
- Write to BigQuery (pipeline output)
- Read from Pub/Sub (streaming sources)
- Write logs to Cloud Logging

---

### Command: Create Composer Service Account
```bash
gcloud iam service-accounts create composer-orchestrator \
    --display-name="Cloud Composer Orchestrator" \
    --description="Service account for Cloud Composer environments" \
    --project=data-engineer-475516
```

**Purpose**: Service account for Airflow DAG execution

**Why needed**:
- Composer DAGs trigger Dataflow jobs, BigQuery queries
- Needs permissions to call those services
- Separates orchestration permissions from pipeline permissions

---

### Command: List All Service Accounts
```bash
gcloud iam service-accounts list --project=data-engineer-475516
```

**Expected Output**:
```
DISPLAY NAME                    EMAIL                                                   DISABLED
Development Data Engineer       dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com     False
Dataflow Job Runner            dataflow-runner@data-engineer-475516.iam.gserviceaccount.com       False
Cloud Composer Orchestrator    composer-orchestrator@data-engineer-475516.iam.gserviceaccount.com False
```

**Status**:
- ✓ 3 service accounts created
- ❌ No permissions granted yet

---

## Granting IAM Roles

### IAM Role Types

**Primitive Roles** (avoid in production):
- `roles/owner` - Full access including IAM changes
- `roles/editor` - Read/write but no IAM changes
- `roles/viewer` - Read-only access

**Predefined Roles** (use these):
- Created by Google for specific services
- Follow principle of least privilege
- Example: `roles/bigquery.dataEditor` (read/write BigQuery data)

**Custom Roles** (advanced):
- Create your own with specific permissions
- For fine-grained access control

---

### Command: Grant BigQuery Admin to Dev Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin" \
    --condition=None
```

**Purpose**: Allow dev account to manage BigQuery

**What `roles/bigquery.admin` includes**:
- Create/delete datasets and tables
- Run queries
- Load/export data
- Manage access controls
- View job history

**Why this specific role**:
- Dev account needs full BigQuery access for learning
- In production, use more restrictive roles:
  - `roles/bigquery.dataEditor` - read/write data only
  - `roles/bigquery.jobUser` - run queries only

**Expected Output**:
```
Updated IAM policy for project [data-engineer-475516].
bindings:
- members:
  - serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
  role: roles/bigquery.admin
etag: BwYZXyZ1234=
version: 1
```

---

### Command: Grant Storage Admin to Dev Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/storage.admin" \
    --condition=None
```

**Purpose**: Allow dev account to manage Cloud Storage buckets and objects

**What `roles/storage.admin` includes**:
- Create/delete buckets
- Upload/download/delete objects
- Manage bucket access controls
- Set lifecycle policies

**Why needed**:
- Dataflow stores staging files in Cloud Storage
- Pipeline inputs often come from Cloud Storage
- Data lake raw zone uses Cloud Storage

---

### Command: Grant Pub/Sub Editor to Dev Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/pubsub.editor" \
    --condition=None
```

**Purpose**: Allow dev account to work with Pub/Sub

**What `roles/pubsub.editor` includes**:
- Create/delete topics and subscriptions
- Publish messages
- Pull messages
- Manage access controls

**Why not admin**:
- `editor` role is sufficient for development
- `admin` adds IAM permission management (not needed)

---

### Command: Grant Dataflow Developer to Dev Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/dataflow.developer" \
    --condition=None
```

**Purpose**: Allow dev account to create and manage Dataflow jobs

**What `roles/dataflow.developer` includes**:
- Submit Dataflow jobs
- Cancel jobs
- View job details
- Update job parameters

**Why needed**:
- To submit pipelines from local machine
- To monitor and debug running jobs

---

### Command: Grant Dataflow Worker to Dataflow Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/dataflow.worker" \
    --condition=None
```

**Purpose**: Allow Dataflow VMs to run pipeline code

**What `roles/dataflow.worker` includes**:
- Read from Dataflow internal storage
- Write logs to Cloud Logging
- Report metrics to Cloud Monitoring
- Access Compute Engine metadata

**Why this specific account**:
- Worker VMs run as this service account
- Separates worker permissions from job submission permissions

---

### Command: Grant Storage Object Admin to Dataflow Account
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin" \
    --condition=None
```

**Purpose**: Allow Dataflow workers to read/write Cloud Storage

**What `roles/storage.objectAdmin` includes**:
- Read objects (pipeline inputs, staging files)
- Write objects (pipeline outputs, temp files)
- Delete objects (cleanup temp files)
- Does NOT include bucket creation/deletion

**Why not storage.admin**:
- Workers don't need to create/delete buckets
- Principle of least privilege

---

### Command: Verify IAM Policy
```bash
gcloud projects get-iam-policy data-engineer-475516 \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:*data-engineer-475516*" \
    --format="table(bindings.role,bindings.members)"
```

**Purpose**: See all roles granted to our service accounts

**Expected Output**:
```
ROLE                          MEMBERS
roles/bigquery.admin         serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
roles/storage.admin          serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
roles/pubsub.editor          serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
roles/dataflow.developer     serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com
roles/dataflow.worker        serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com
roles/storage.objectAdmin    serviceAccount:dataflow-runner@data-engineer-475516.iam.gserviceaccount.com
```

---

## Creating Service Account Keys

### What Are Service Account Keys?

- JSON file containing credentials
- Allows applications to authenticate as the service account
- Like a username/password, but for robots

### Security Considerations

**Risks**:
- ⚠️  If key file is compromised, attacker has full access as that service account
- ⚠️  Keys don't expire automatically
- ⚠️  Hard to track where keys are being used

**Best Practices**:
- Never commit keys to Git
- Store in secure location with restricted permissions
- Rotate every 90 days
- Delete unused keys
- Use Workload Identity when possible (no keys needed!)

---

### Command: Create Directory for Keys
```bash
mkdir -p ~/gcp-keys
```

**Purpose**: Dedicated directory for GCP credentials

**Why separate directory**:
- Easy to set permissions on entire directory
- Easy to exclude from backups/Git
- Centralized location for all GCP keys

---

### Command: Create Service Account Key
```bash
gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
    --iam-account=dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com \
    --project=data-engineer-475516
```

**Purpose**: Generate and download private key for dev service account

**Expected Output**:
```
created key [a1b2c3d4e5f6...] of type [json] as [/home/rajan/gcp-keys/dev-sa-key.json] for [dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com]
```

**What happens**:
1. Google generates a new RSA key pair
2. Public key stored in Google's servers
3. Private key downloaded to your machine (ONLY TIME you'll see it!)
4. Key ID created (shown in output)

**Key file contents** (example):
```json
{
  "type": "service_account",
  "project_id": "data-engineer-475516",
  "private_key_id": "a1b2c3d4...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

---

### Command: Set File Permissions
```bash
chmod 600 ~/gcp-keys/dev-sa-key.json
```

**Purpose**: Restrict file access to owner only

**What `600` means**:
- `6` (owner): read + write
- `0` (group): no access
- `0` (others): no access

**Why this matters**:
- Prevents other users on your machine from reading the key
- Some tools refuse to use keys with permissive permissions

**Verify permissions**:
```bash
ls -l ~/gcp-keys/dev-sa-key.json
# Output: -rw------- 1 rajan rajan 2345 Oct 18 12:00 dev-sa-key.json
```

---

### Command: Set Environment Variable
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"
```

**Purpose**: Tell GCP client libraries where to find credentials

**How it works**:
1. Python code imports `from google.cloud import bigquery`
2. Library checks `GOOGLE_APPLICATION_CREDENTIALS` environment variable
3. If set, library uses that key file
4. If not set, library looks for Application Default Credentials

**Why this approach**:
- No need to pass credentials to every API call
- Can switch credentials by changing environment variable
- Standard across all GCP languages (Python, Java, Node.js, Go)

---

### Command: Make Permanent (Add to Shell Config)
```bash
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"' >> ~/.bashrc
```

**Purpose**: Set environment variable automatically in new terminal sessions

**For zsh users** (if using zsh shell):
```bash
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"' >> ~/.zshrc
```

**Verify it's in your config**:
```bash
tail -1 ~/.bashrc
# Output: export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"
```

**Apply changes to current session**:
```bash
source ~/.bashrc
```

---

### Command: Verify Environment Variable
```bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

**Expected Output**:
```
/home/rajan/gcp-keys/dev-sa-key.json
```

---

### Command: List Keys for Service Account
```bash
gcloud iam service-accounts keys list \
    --iam-account=dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com \
    --project=data-engineer-475516
```

**Purpose**: See all keys (user-managed and Google-managed)

**Expected Output**:
```
KEY_ID                                    CREATED_AT            EXPIRES_AT
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0  2025-10-18T12:00:00Z  9999-12-31T23:59:59Z
f1234567890abcdef1234567890abcdef123456  2025-10-18T11:00:00Z  2025-10-25T11:00:00Z
```

**Key types**:
- Long EXPIRES_AT (9999): User-managed key (your downloaded key)
- Short EXPIRES_AT (~7 days): Google-managed key (used by Compute Engine)

---

## Creating Configuration Files

### Command: Create .env File
```bash
cat > ~/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/00-gcp-environment-setup/config/.env << 'EOF'
# GCP Project Configuration
GCP_PROJECT_ID=data-engineer-475516
GCP_PROJECT_NUMBER=434782524071
GCP_REGION=us-central1
GCP_ZONE=us-central1-a

# Authentication
GOOGLE_APPLICATION_CREDENTIALS=/home/rajan/gcp-keys/dev-sa-key.json
SERVICE_ACCOUNT_EMAIL=dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com

# BigQuery Configuration
BIGQUERY_DATASET=dev_dataset
BIGQUERY_LOCATION=US

# Cloud Storage Configuration
GCS_BUCKET_NAME=data-engineer-475516-data
GCS_STAGING_BUCKET=data-engineer-475516-staging
GCS_TEMP_BUCKET=data-engineer-475516-temp

# Pub/Sub Configuration
PUBSUB_TOPIC=test-topic
PUBSUB_SUBSCRIPTION=test-subscription

# Dataflow Configuration
DATAFLOW_STAGING_LOCATION=gs://data-engineer-475516-staging/dataflow/staging
DATAFLOW_TEMP_LOCATION=gs://data-engineer-475516-temp/dataflow/temp
DATAFLOW_SERVICE_ACCOUNT=dataflow-runner@data-engineer-475516.iam.gserviceaccount.com

# Development Settings
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
EOF
```

**Purpose**: Centralized configuration for all projects

**How to use in Python**:
```python
from dotenv import load_dotenv
import os

load_dotenv()
project_id = os.getenv('GCP_PROJECT_ID')
```

**Security notes**:
- ✓ .env file is in .gitignore (won't be committed)
- ⚠️  Contains sensitive info (service account email, bucket names)
- ℹ️  Each developer has their own .env file

---

### Command: Verify .env File Created
```bash
cat ~/research/gcp/GCP-Data-Engineer-Cert-Prep/projects/00-gcp-environment-setup/config/.env
```

**Check that all values are correct**:
- Project ID matches
- File paths are absolute paths
- Service account emails are correct

---

## Python Environment Setup

### Why Virtual Environments?

**Problems without venv**:
- Installing packages globally can break system Python
- Different projects need different package versions
- Hard to reproduce environments on other machines

**Benefits of venv**:
- Isolated package installations per project
- Easy to delete and recreate
- requirements.txt captures exact versions

---

### Command: Create Virtual Environment
```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
python3 -m venv venv
```

**Purpose**: Create isolated Python environment

**What gets created**:
```
venv/
├── bin/              # Executables (python, pip, etc.)
├── include/          # C headers
├── lib/              # Python packages
│   └── python3.X/
│       └── site-packages/
└── pyvenv.cfg        # Configuration
```

**Size**: ~20 MB initially (before installing packages)

---

### Command: Activate Virtual Environment
```bash
source venv/bin/activate
```

**Purpose**: Switch to using the virtual environment's Python

**What changes**:
- `which python` now points to `venv/bin/python`
- `pip install` installs to `venv/lib/python3.X/site-packages/`
- Prompt changes to show `(venv)` prefix

**Verify activation**:
```bash
which python
# Output: /home/rajan/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/bin/python

which pip
# Output: /home/rajan/research/gcp/GCP-Data-Engineer-Cert-Prep/venv/bin/pip
```

---

### Command: Upgrade pip
```bash
pip install --upgrade pip
```

**Purpose**: Get latest pip version

**Why upgrade**:
- Latest pip has better dependency resolution
- Fixes security vulnerabilities
- Supports newer package formats

**Expected Output**:
```
Requirement already satisfied: pip in ./venv/lib/python3.X/site-packages (X.Y.Z)
Collecting pip
  Downloading pip-24.0-py3-none-any.whl (1.8 MB)
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip X.Y.Z
    Uninstalling pip-X.Y.Z:
      Successfully uninstalled pip-X.Y.Z
Successfully installed pip-24.0
```

---

### Command: Install GCP Python Libraries
```bash
pip install -r projects/00-gcp-environment-setup/src/requirements.txt
```

**Purpose**: Install all GCP client libraries

**What gets installed** (30+ packages):
```
google-cloud-bigquery==3.17.1          # BigQuery client
google-cloud-storage==2.14.0           # Cloud Storage client
google-cloud-pubsub==2.19.2            # Pub/Sub client
apache-beam[gcp]==2.53.0               # Dataflow pipelines
pandas==2.2.0                          # Data manipulation
... and many more
```

**Installation time**: 3-5 minutes (downloads ~200 MB)

**Expected output** (truncated):
```
Collecting google-cloud-bigquery==3.17.1
  Downloading google_cloud_bigquery-3.17.1-py2.py3-none-any.whl (220 kB)
Collecting google-cloud-storage==2.14.0
  Downloading google_cloud_storage-2.14.0-py2.py3-none-any.whl (120 kB)
...
Installing collected packages: ...
Successfully installed google-cloud-bigquery-3.17.1 google-cloud-storage-2.14.0 ...
```

---

### Command: Verify Installation
```bash
pip list | grep google-cloud
```

**Expected Output**:
```
google-cloud-bigquery             3.17.1
google-cloud-bigquery-storage     2.24.0
google-cloud-bigtable             2.22.0
google-cloud-core                 2.4.1
google-cloud-dataflow             0.8.5
google-cloud-dataproc             5.9.1
google-cloud-pubsub               2.19.2
google-cloud-storage              2.14.0
...
```

**Total packages installed**: ~80-100 (including dependencies)

---

## Testing Setup

### Command: Run Connection Test Script
```bash
python projects/00-gcp-environment-setup/src/test_connection.py
```

**Purpose**: Verify all components work together

**What the script tests**:
1. Authentication (can we authenticate?)
2. Project access (can we access the project?)
3. BigQuery connection (can we query BigQuery?)
4. Cloud Storage connection (can we list buckets?)
5. Pub/Sub connection (can we list topics?)

**Expected Output**:
```
======================================================================
  GCP Environment Test
======================================================================

This script will verify your GCP setup is working correctly.

======================================================================
  Checking Environment Variables
======================================================================
✓ GCP_PROJECT_ID = data-engineer-475516
✓ GOOGLE_APPLICATION_CREDENTIALS = /home/rajan/gcp-keys/dev-sa-key.json
⚠️  GCP_REGION not set (OK if using ADC)

======================================================================
  Checking Authentication
======================================================================
✓ Authentication successful
ℹ️  Credentials type: ServiceAccountCredentials
ℹ️  Default project: data-engineer-475516

======================================================================
  Checking Installed GCP Packages
======================================================================
✓ google-auth is installed
✓ google-cloud-bigquery is installed
✓ google-cloud-storage is installed
✓ google-cloud-pubsub is installed
✓ google-cloud-dataflow is installed
✓ apache-beam is installed
✓ pandas is installed
✓ python-dotenv is installed

======================================================================
  Testing BigQuery Connection
======================================================================
✓ BigQuery connection successful
ℹ️  BigQuery location: US

======================================================================
  Testing Cloud Storage Connection
======================================================================
✓ Cloud Storage connection successful
ℹ️  Found 0 bucket(s):
ℹ️  No buckets found in project

======================================================================
  Testing Pub/Sub Connection
======================================================================
✓ Pub/Sub connection successful
ℹ️  Found 0 topic(s):
ℹ️  No topics found in project

======================================================================
  Summary
======================================================================

Tests passed: 4/4
✓ All tests passed! Your GCP environment is ready.

ℹ️  Next steps:
  1. Review the configuration in config/.env
  2. Proceed to Project 1: Batch ETL Pipeline
```

---

### What If Tests Fail?

**Test: Authentication failed**

Error: `DefaultCredentialsError: Could not automatically determine credentials`

Solutions:
1. Check environment variable:
   ```bash
   echo $GOOGLE_APPLICATION_CREDENTIALS
   ```
2. Check file exists:
   ```bash
   ls -l ~/gcp-keys/dev-sa-key.json
   ```
3. Re-export variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcp-keys/dev-sa-key.json"
   ```

---

**Test: BigQuery connection failed**

Error: `403 Forbidden: BigQuery API has not been used`

Solutions:
1. Enable BigQuery API:
   ```bash
   gcloud services enable bigquery.googleapis.com
   ```
2. Wait 1-2 minutes for API to propagate
3. Re-run test

---

**Test: Permission denied error**

Error: `403 Forbidden: Permission denied on project`

Solutions:
1. Check service account has correct roles:
   ```bash
   gcloud projects get-iam-policy data-engineer-475516 \
       --flatten="bindings[].members" \
       --filter="bindings.members:dev-data-engineer"
   ```
2. Grant missing role (example for BigQuery):
   ```bash
   gcloud projects add-iam-policy-binding data-engineer-475516 \
       --member="serviceAccount:dev-data-engineer@data-engineer-475516.iam.gserviceaccount.com" \
       --role="roles/bigquery.admin"
   ```

---

## Summary and Next Steps

### What We Accomplished

#### ✅ Project Setup
- Verified project exists and is active
- Confirmed billing is enabled
- Set default region (us-central1) and zone (us-central1-a)

#### ✅ APIs Enabled (15 APIs)
- Core: Compute Engine, IAM, Resource Manager
- Data: BigQuery, Cloud Storage, Pub/Sub
- Processing: Dataflow, Dataproc, Data Fusion, Composer
- Databases: Cloud SQL, Spanner, Bigtable
- Governance: Data Catalog, DLP, KMS

#### ✅ Service Accounts (3 created)
- `dev-data-engineer` - for local development
- `dataflow-runner` - for Dataflow jobs
- `composer-orchestrator` - for Airflow DAGs

#### ✅ IAM Permissions (6 role bindings)
- dev-data-engineer: BigQuery Admin, Storage Admin, Pub/Sub Editor, Dataflow Developer
- dataflow-runner: Dataflow Worker, Storage Object Admin

#### ✅ Security
- Service account key created and secured (600 permissions)
- GOOGLE_APPLICATION_CREDENTIALS environment variable set
- Added to shell config for persistence

#### ✅ Python Environment
- Virtual environment created (venv/)
- pip upgraded to latest version
- 80+ packages installed including all GCP client libraries

#### ✅ Configuration
- .env file created with all project settings
- Ready to use in Python with python-dotenv

#### ✅ Testing
- Connection test passed (4/4 tests)
- Verified authentication works
- Verified BigQuery, Storage, Pub/Sub access

---

### Project Cost Summary

**Costs incurred so far**: $0.00

**Why no cost yet?**
- Creating projects, service accounts, IAM roles is free
- Enabling APIs is free
- Running a simple BigQuery query (SELECT 1) is free tier

**Ongoing costs to watch**:
- Cloud Storage: $0.020/GB/month (first 5 GB free)
- BigQuery storage: $0.020/GB/month (first 10 GB free)
- BigQuery queries: $5/TB processed (first 1 TB/month free)
- Dataflow: $0.056/vCPU-hour (no free tier, but we'll use small jobs)
- Cloud Composer: ~$300/month (we'll delete after each use)

**Budget recommendation**: $50/month is sufficient for all 7 projects

---

### Next Steps

#### 1. Create First Cloud Storage Bucket (Optional)
```bash
gsutil mb -p data-engineer-475516 -l us-central1 gs://data-engineer-475516-data
```

#### 2. Create First BigQuery Dataset (Optional)
```bash
bq mk --project_id=data-engineer-475516 --location=US dev_dataset
```

#### 3. Proceed to Project 1
Navigate to:
```
projects/01-batch-etl-weather/README.md
```

Project 1 will teach you to:
- Ingest data from external API (OpenWeather)
- Store raw data in Cloud Storage
- Transform with Apache Beam (Dataflow)
- Load into BigQuery with partitioning
- Schedule with Cloud Composer (Airflow)
- Visualize with Looker Studio

---

### Quick Reference Commands

**Check Configuration**:
```bash
gcloud config list
gcloud projects describe data-engineer-475516
gcloud services list --enabled
gcloud iam service-accounts list
```

**Activate Environment**:
```bash
cd ~/research/gcp/GCP-Data-Engineer-Cert-Prep
source venv/bin/activate
```

**Test Connection**:
```bash
python projects/00-gcp-environment-setup/src/test_connection.py
```

**View Logs**:
```bash
gcloud logging read "resource.type=global" --limit=10
```

**Check Costs**:
Visit: https://console.cloud.google.com/billing

---

### Troubleshooting Quick Guide

| Error | Solution |
|-------|----------|
| `gcloud: command not found` | Install gcloud CLI |
| `API not enabled` | `gcloud services enable SERVICE_NAME.googleapis.com` |
| `Permission denied` | Check IAM roles with `gcloud projects get-iam-policy` |
| `Authentication failed` | Check `$GOOGLE_APPLICATION_CREDENTIALS` points to valid key file |
| `No module named google.cloud` | Activate venv and install requirements.txt |
| `Project not found` | `gcloud config set project data-engineer-475516` |

---

### Files Created

```
~/gcp-keys/
└── dev-sa-key.json                                   # Service account key

~/research/gcp/GCP-Data-Engineer-Cert-Prep/
├── venv/                                             # Python virtual environment
├── projects/00-gcp-environment-setup/
│   ├── config/
│   │   └── .env                                      # Configuration file
│   ├── QUICKSTART.md                                 # Quick start guide
│   ├── setup-existing-project.sh                     # Setup script
│   └── SETUP_EXECUTION_LOG.md                        # This document

~/.bashrc                                             # Added GOOGLE_APPLICATION_CREDENTIALS
```

---

### Learning Resources

**GCP Documentation**:
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [IAM Documentation](https://cloud.google.com/iam/docs)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)

**Best Practices**:
- [Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)
- [Security Best Practices](https://cloud.google.com/security/best-practices)

**Cost Management**:
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [Cost Management Best Practices](https://cloud.google.com/cost-management/docs/best-practices)

---

**Setup completed**: 2025-10-18
**Total time**: ~15 minutes
**Status**: ✅ Ready for Project 1

---
