# GCP CLI Commands Reference

This document explains all gcloud CLI commands used in Project 0, with detailed descriptions of what each command does, why it's important, and how it relates to data engineering.

## Table of Contents

1. [Authentication Commands](#authentication-commands)
2. [Project Management](#project-management)
3. [Billing Commands](#billing-commands)
4. [API Management](#api-management)
5. [IAM & Service Accounts](#iam--service-accounts)
6. [Configuration Management](#configuration-management)
7. [Monitoring & Logging](#monitoring--logging)
8. [Quick Reference](#quick-reference)

---

## Authentication Commands

### `gcloud auth login`

**Purpose**: Authenticates you with your Google account

**What it does**:
- Opens your default web browser
- Redirects to Google's OAuth 2.0 flow
- Prompts you to select a Google account
- Asks for permission to access GCP resources
- Stores credentials locally for future gcloud commands

**When to use**:
- First time setting up gcloud CLI
- When switching between different Google accounts
- After logging out or when credentials expire

**Example**:
```bash
gcloud auth login
```

**Output**: Opens browser and displays success message after authentication

---

### `gcloud auth application-default login`

**Purpose**: Sets up Application Default Credentials (ADC) for your applications

**What it does**:
- Creates credentials that Python/Java/Node.js applications can use automatically
- Stores credentials in a well-known location (`~/.config/gcloud/application_default_credentials.json`)
- Allows GCP client libraries to authenticate without explicitly passing credentials

**When to use**:
- Before running Python scripts that use GCP client libraries
- For local development and testing
- When you want apps to use your personal credentials (dev only!)

**Example**:
```bash
gcloud auth application-default login
```

**Important**: For production, use service account keys instead!

---

### `gcloud auth list`

**Purpose**: Lists all authenticated accounts

**What it does**:
- Shows all Google accounts you've authenticated with
- Indicates which account is currently active (marked with `*`)
- Displays the authentication type

**Example**:
```bash
gcloud auth list
```

**Output**:
```
           Credentialed Accounts
ACTIVE  ACCOUNT
*       your-email@gmail.com
        another-email@gmail.com
```

---

### `gcloud auth revoke`

**Purpose**: Removes authentication for an account

**Example**:
```bash
gcloud auth revoke your-email@gmail.com
```

---

## Project Management

### `gcloud projects list`

**Purpose**: Lists all GCP projects you have access to

**What it does**:
- Queries Google Cloud Resource Manager
- Returns all projects where you have at least `resourcemanager.projects.get` permission
- Shows project ID, name, and project number

**Example**:
```bash
gcloud projects list
```

**Output**:
```
PROJECT_ID              NAME                    PROJECT_NUMBER
my-project-123          My Project              123456789012
another-project-456     Another Project         234567890123
```

**Useful filters**:
```bash
# List only active projects
gcloud projects list --filter="lifecycleState:ACTIVE"

# List projects matching a pattern
gcloud projects list --filter="projectId:data-eng-*"
```

---

### `gcloud projects create`

**Purpose**: Creates a new GCP project

**Syntax**:
```bash
gcloud projects create PROJECT_ID [--name="PROJECT_NAME"] [--organization=ORG_ID]
```

**What it does**:
- Creates a new project in Google Cloud Resource Manager
- Generates a unique project number automatically
- Sets up initial IAM policies
- Takes 20-60 seconds to complete

**Project ID requirements**:
- 6-30 characters long
- Lowercase letters, digits, and hyphens only
- Must start with a letter
- Must be globally unique across all of GCP

**Example**:
```bash
gcloud projects create data-eng-learning-20250118 \
    --name="Data Engineering Learning" \
    --labels="environment=learning,purpose=certification"
```

**Important**: Project IDs cannot be changed after creation!

---

### `gcloud projects describe`

**Purpose**: Gets detailed information about a project

**Example**:
```bash
gcloud projects describe data-eng-learning-20250118
```

**Output**:
```yaml
createTime: '2025-01-18T10:30:00.000Z'
lifecycleState: ACTIVE
name: Data Engineering Learning
projectId: data-eng-learning-20250118
projectNumber: '123456789012'
```

---

### `gcloud projects delete`

**Purpose**: Deletes a project (schedules for deletion in 30 days)

**What it does**:
- Marks project for deletion
- 30-day grace period before permanent deletion
- All resources will be deleted
- Billing stops immediately
- Can be restored within 30 days

**Example**:
```bash
gcloud projects delete data-eng-learning-20250118
```

**Warning**: This is irreversible after 30 days!

---

## Billing Commands

### `gcloud billing accounts list`

**Purpose**: Lists billing accounts you have access to

**What it does**:
- Shows all billing accounts where you have billing permissions
- Displays account ID, name, and whether it's open

**Example**:
```bash
gcloud billing accounts list
```

**Output**:
```
ACCOUNT_ID            NAME                OPEN  MASTER_ACCOUNT_ID
01234567-89ABCDEF    My Billing Account  True
```

**Permissions needed**: `billing.accounts.list`

---

### `gcloud billing projects link`

**Purpose**: Links a billing account to a project

**Syntax**:
```bash
gcloud billing projects link PROJECT_ID \
    --billing-account=BILLING_ACCOUNT_ID
```

**What it does**:
- Associates a billing account with your project
- Enables you to use paid GCP services
- Required for most GCP services beyond free tier
- Changes take effect immediately

**Example**:
```bash
gcloud billing projects link data-eng-learning-20250118 \
    --billing-account=01234567-89ABCDEF
```

**Important**: Without billing, you cannot:
- Create Compute Engine VMs
- Store data beyond free tier limits
- Use Dataflow, Composer, or most data services

---

### `gcloud billing projects describe`

**Purpose**: Shows billing information for a project

**Example**:
```bash
gcloud billing projects describe data-eng-learning-20250118
```

**Output**:
```yaml
billingAccountName: billingAccounts/01234567-89ABCDEF
billingEnabled: true
name: projects/data-eng-learning-20250118/billingInfo
projectId: data-eng-learning-20250118
```

---

## API Management

### `gcloud services list`

**Purpose**: Lists GCP services (APIs)

**Variants**:

**List enabled APIs**:
```bash
gcloud services list --enabled
```

**List all available APIs**:
```bash
gcloud services list --available
```

**Filter by name**:
```bash
gcloud services list --available --filter="name:bigquery"
```

**Output example**:
```
NAME                                 TITLE
bigquery.googleapis.com              BigQuery API
storage.googleapis.com               Cloud Storage API
compute.googleapis.com               Compute Engine API
```

---

### `gcloud services enable`

**Purpose**: Enables a GCP API for your project

**Syntax**:
```bash
gcloud services enable SERVICE_NAME
```

**What it does**:
- Activates the specified API for your project
- May take 1-2 minutes to propagate
- Some APIs have dependencies that are enabled automatically
- Required before using any GCP service

**Common APIs for Data Engineering**:

```bash
# Storage & Data Warehouse
gcloud services enable storage.googleapis.com           # Cloud Storage
gcloud services enable bigquery.googleapis.com          # BigQuery

# Data Processing
gcloud services enable dataflow.googleapis.com          # Dataflow
gcloud services enable dataproc.googleapis.com          # Dataproc
gcloud services enable composer.googleapis.com          # Cloud Composer
gcloud services enable datafusion.googleapis.com        # Data Fusion
gcloud services enable dataform.googleapis.com          # Dataform

# Streaming & Messaging
gcloud services enable pubsub.googleapis.com            # Pub/Sub

# Databases
gcloud services enable sqladmin.googleapis.com          # Cloud SQL
gcloud services enable spanner.googleapis.com           # Spanner
gcloud services enable bigtable.googleapis.com          # Bigtable
gcloud services enable firestore.googleapis.com         # Firestore

# Data Governance
gcloud services enable datacatalog.googleapis.com       # Data Catalog
gcloud services enable dataplex.googleapis.com          # Dataplex
gcloud services enable dlp.googleapis.com               # Cloud DLP

# Monitoring & Operations
gcloud services enable monitoring.googleapis.com        # Cloud Monitoring
gcloud services enable logging.googleapis.com           # Cloud Logging

# Core Infrastructure
gcloud services enable compute.googleapis.com           # Compute Engine
gcloud services enable iam.googleapis.com               # IAM
gcloud services enable cloudresourcemanager.googleapis.com  # Resource Manager
```

**Enable multiple APIs at once**:
```bash
gcloud services enable \
    bigquery.googleapis.com \
    storage.googleapis.com \
    dataflow.googleapis.com
```

---

### `gcloud services disable`

**Purpose**: Disables a GCP API

**Example**:
```bash
gcloud services disable bigquery.googleapis.com --force
```

**Warning**: This can break applications and resources that depend on the API!

---

## IAM & Service Accounts

### Understanding IAM

**IAM (Identity and Access Management)** controls who can do what on which resources.

**Key concepts**:
- **Principal**: Who (user, service account, group)
- **Role**: What permissions (bigquery.admin, storage.objectViewer)
- **Resource**: Which resource (project, bucket, dataset)

**Policy**: Binds principals to roles on resources

---

### `gcloud iam service-accounts list`

**Purpose**: Lists all service accounts in a project

**Example**:
```bash
gcloud iam service-accounts list
```

**Output**:
```
DISPLAY NAME                    EMAIL                                          DISABLED
Development Data Engineer       dev-data-engineer@project-id.iam.gserviceaccount.com  False
Dataflow Job Runner            dataflow-runner@project-id.iam.gserviceaccount.com    False
```

---

### `gcloud iam service-accounts create`

**Purpose**: Creates a new service account

**Syntax**:
```bash
gcloud iam service-accounts create SERVICE_ACCOUNT_ID \
    --display-name="DISPLAY_NAME" \
    --description="DESCRIPTION"
```

**What it does**:
- Creates a service account (robot account for applications)
- Generates a unique email: `SA_ID@PROJECT_ID.iam.gserviceaccount.com`
- Initially has no permissions (must grant roles separately)

**Example**:
```bash
gcloud iam service-accounts create dev-data-engineer \
    --display-name="Development Data Engineer" \
    --description="Service account for local development and testing"
```

**Best practices**:
- Use descriptive names that indicate purpose
- Create separate service accounts for different purposes
- Follow principle of least privilege

---

### `gcloud iam service-accounts delete`

**Purpose**: Deletes a service account

**Example**:
```bash
gcloud iam service-accounts delete dev-data-engineer@project-id.iam.gserviceaccount.com
```

**What happens**:
- Service account is deleted
- All keys are invalidated
- Applications using this SA will stop working
- IAM bindings are NOT automatically removed

---

### `gcloud iam service-accounts keys list`

**Purpose**: Lists keys for a service account

**Example**:
```bash
gcloud iam service-accounts keys list \
    --iam-account=dev-data-engineer@project-id.iam.gserviceaccount.com
```

**Output**:
```
KEY_ID                                    CREATED_AT            EXPIRES_AT
a1b2c3d4e5f6...                          2025-01-18T10:00:00Z  9999-12-31T23:59:59Z
```

**Key types**:
- **USER_MANAGED**: Keys you created (shown in list)
- **SYSTEM_MANAGED**: Google-managed keys (not shown, used for compute resources)

---

### `gcloud iam service-accounts keys create`

**Purpose**: Creates and downloads a service account key (JSON)

**Syntax**:
```bash
gcloud iam service-accounts keys create OUTPUT_FILE \
    --iam-account=SERVICE_ACCOUNT_EMAIL
```

**What it does**:
- Generates a new key pair
- Downloads the private key as JSON
- **The private key is shown only once** - store it securely!

**Example**:
```bash
gcloud iam service-accounts keys create ~/gcp-keys/dev-sa-key.json \
    --iam-account=dev-data-engineer@project-id.iam.gserviceaccount.com
```

**Security best practices**:
- Never commit keys to version control
- Store in a secure location
- Set restrictive file permissions: `chmod 600 key.json`
- Rotate keys regularly (every 90 days)
- Use Workload Identity when possible (no keys needed!)

**To use the key**:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

---

### `gcloud iam service-accounts keys delete`

**Purpose**: Deletes a service account key

**Example**:
```bash
gcloud iam service-accounts keys delete KEY_ID \
    --iam-account=dev-data-engineer@project-id.iam.gserviceaccount.com
```

---

### `gcloud projects add-iam-policy-binding`

**Purpose**: Grants an IAM role to a principal on a project

**Syntax**:
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="PRINCIPAL" \
    --role="ROLE"
```

**Member types**:
- `user:email@example.com` - Individual user
- `serviceAccount:sa@project.iam.gserviceaccount.com` - Service account
- `group:group@example.com` - Google Group
- `domain:example.com` - All users in a domain

**Common roles for data engineering**:

```bash
# BigQuery roles
--role="roles/bigquery.admin"                  # Full BigQuery access
--role="roles/bigquery.dataEditor"             # Read/write data
--role="roles/bigquery.dataViewer"             # Read-only data
--role="roles/bigquery.jobUser"                # Run queries

# Storage roles
--role="roles/storage.admin"                   # Full Cloud Storage access
--role="roles/storage.objectAdmin"             # Create/delete/read objects
--role="roles/storage.objectViewer"            # Read-only objects
--role="roles/storage.objectCreator"           # Write-only objects

# Dataflow roles
--role="roles/dataflow.admin"                  # Manage Dataflow jobs
--role="roles/dataflow.developer"              # Create Dataflow jobs
--role="roles/dataflow.worker"                 # For Dataflow worker VMs

# Pub/Sub roles
--role="roles/pubsub.admin"                    # Full Pub/Sub access
--role="roles/pubsub.editor"                   # Create/delete topics/subs
--role="roles/pubsub.publisher"                # Publish messages only
--role="roles/pubsub.subscriber"               # Consume messages only

# Composer roles
--role="roles/composer.admin"                  # Manage Composer environments
--role="roles/composer.worker"                 # For Composer worker pods

# General roles
--role="roles/viewer"                          # Read-only access to everything
--role="roles/editor"                          # Read/write (not IAM changes)
--role="roles/owner"                           # Full control including IAM
```

**Example**:
```bash
gcloud projects add-iam-policy-binding data-eng-learning-20250118 \
    --member="serviceAccount:dev-data-engineer@data-eng-learning-20250118.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"
```

---

### `gcloud projects remove-iam-policy-binding`

**Purpose**: Revokes an IAM role from a principal

**Example**:
```bash
gcloud projects remove-iam-policy-binding data-eng-learning-20250118 \
    --member="serviceAccount:dev-data-engineer@data-eng-learning-20250118.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"
```

---

### `gcloud projects get-iam-policy`

**Purpose**: Displays the IAM policy for a project

**Example**:
```bash
gcloud projects get-iam-policy data-eng-learning-20250118
```

**Output** (YAML format):
```yaml
bindings:
- members:
  - serviceAccount:dev-data-engineer@project.iam.gserviceaccount.com
  role: roles/bigquery.admin
- members:
  - user:your-email@gmail.com
  role: roles/owner
etag: BwYEUX1Q2pE=
version: 1
```

**Useful filters**:
```bash
# View specific member's roles
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:dev-*"
```

---

## Configuration Management

### `gcloud config configurations list`

**Purpose**: Lists all gcloud CLI configurations

**What are configurations?**
- Named sets of gcloud properties
- Let you switch between projects/accounts easily
- Useful when working with multiple projects

**Example**:
```bash
gcloud config configurations list
```

**Output**:
```
NAME                IS_ACTIVE  ACCOUNT                PROJECT
data-eng-learning   True       you@gmail.com          data-eng-learning-20250118
default             False      you@gmail.com          my-other-project
```

---

### `gcloud config configurations create`

**Purpose**: Creates a new named configuration

**Example**:
```bash
gcloud config configurations create data-eng-learning
```

**What it does**:
- Creates a new configuration profile
- Switches to it automatically
- Starts with no properties set (you must configure it)

---

### `gcloud config configurations activate`

**Purpose**: Switches to a different configuration

**Example**:
```bash
gcloud config configurations activate data-eng-learning
```

---

### `gcloud config set`

**Purpose**: Sets a configuration property

**Common properties**:

```bash
# Set project
gcloud config set project data-eng-learning-20250118

# Set default region
gcloud config set compute/region us-central1

# Set default zone
gcloud config set compute/zone us-central1-a

# Set account
gcloud config set account your-email@gmail.com
```

**Available regions** (choose based on location):
- `us-central1` - Iowa, USA
- `us-east1` - South Carolina, USA
- `us-west1` - Oregon, USA
- `europe-west1` - Belgium, Europe
- `asia-southeast1` - Singapore, Asia

---

### `gcloud config get-value`

**Purpose**: Gets the value of a configuration property

**Example**:
```bash
gcloud config get-value project
gcloud config get-value compute/region
```

---

### `gcloud config list`

**Purpose**: Shows all current configuration settings

**Example**:
```bash
gcloud config list
```

**Output**:
```
[compute]
region = us-central1
zone = us-central1-a
[core]
account = your-email@gmail.com
project = data-eng-learning-20250118
```

---

## Monitoring & Logging

### `gcloud logging read`

**Purpose**: Reads log entries from Cloud Logging

**Basic syntax**:
```bash
gcloud logging read "FILTER" --limit=N --format="FORMAT"
```

**Examples**:

**View recent logs**:
```bash
gcloud logging read "resource.type=global" --limit=10
```

**View logs for a specific resource**:
```bash
gcloud logging read "resource.type=bigquery_resource" --limit=20
```

**Filter by severity**:
```bash
gcloud logging read "severity>=ERROR" --limit=50
```

**Filter by time range**:
```bash
gcloud logging read 'timestamp>="2025-01-18T00:00:00Z"' --limit=100
```

**Filter by log name**:
```bash
gcloud logging read 'logName="projects/PROJECT_ID/logs/dataflow.googleapis.com%2Fjob-message"' --limit=10
```

**Output formats**:
- `--format=json` - JSON format
- `--format=yaml` - YAML format
- `--format=table` - Table format

---

### `gcloud logging tail`

**Purpose**: Streams log entries in real-time (like `tail -f`)

**Example**:
```bash
gcloud logging tail "resource.type=dataflow_step"
```

---

## Quick Reference

### Most Common Commands

```bash
# Authentication
gcloud auth login
gcloud auth application-default login
gcloud auth list

# Project management
gcloud projects list
gcloud projects create PROJECT_ID --name="Project Name"
gcloud config set project PROJECT_ID

# API management
gcloud services list --enabled
gcloud services enable SERVICE_NAME.googleapis.com

# Service accounts
gcloud iam service-accounts list
gcloud iam service-accounts create SA_NAME --display-name="Name"
gcloud iam service-accounts keys create key.json --iam-account=SA_EMAIL

# IAM
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:SA_EMAIL" \
    --role="ROLE"

# Configuration
gcloud config list
gcloud config set project PROJECT_ID
gcloud config set compute/region REGION

# Billing
gcloud billing accounts list
gcloud billing projects link PROJECT_ID --billing-account=BILLING_ID

# Help
gcloud help
gcloud COMMAND --help
```

### Getting Help

```bash
# General help
gcloud help

# Command-specific help
gcloud projects --help
gcloud iam service-accounts create --help

# List available commands
gcloud --help

# Interactive help
gcloud alpha interactive
```

---

## Tips & Tricks

### 1. Use `--format` for Better Output

```bash
# JSON output
gcloud projects list --format=json

# Custom table output
gcloud projects list --format="table(projectId,name,projectNumber)"

# Get only specific values
gcloud projects list --format="value(projectId)"
```

### 2. Filter Results

```bash
# Filter projects by name
gcloud projects list --filter="name:Data*"

# Filter by lifecycle state
gcloud projects list --filter="lifecycleState:ACTIVE"

# Complex filters
gcloud projects list --filter="name:Data* AND lifecycleState:ACTIVE"
```

### 3. Use Environment Variables

```bash
# Set project ID
export PROJECT_ID="data-eng-learning-20250118"

# Use in commands
gcloud config set project $PROJECT_ID
```

### 4. Check Quotas

```bash
# View quota usage
gcloud compute project-info describe --project=$PROJECT_ID
```

### 5. Dry Run (for some commands)

```bash
# Validate without executing (not all commands support this)
gcloud compute instances create my-vm --dry-run
```

---

## Certification Exam Tips

1. **Know service account best practices**
   - When to use user accounts vs service accounts
   - How to grant minimal permissions
   - Key rotation strategies

2. **Understand IAM roles**
   - Predefined roles vs custom roles
   - Primitive roles (owner, editor, viewer) vs specific roles
   - Resource hierarchy (organization → folder → project)

3. **API management**
   - Which APIs are required for each service
   - How to troubleshoot "API not enabled" errors

4. **Know common gcloud patterns**
   - Creating resources
   - Listing and filtering
   - Deleting and cleaning up

5. **Configuration management**
   - When to use configurations
   - Default values and how they're applied

---

## Additional Resources

- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [IAM Documentation](https://cloud.google.com/iam/docs)
- [Service Accounts Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)
- [gcloud Cheat Sheet](https://cloud.google.com/sdk/docs/cheatsheet)

---

**Last Updated**: 2025-01-18
