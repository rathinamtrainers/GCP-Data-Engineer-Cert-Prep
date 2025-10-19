# Cloud Composer Setup - Issues and Resolution

## Overview

This document tracks the issues encountered while setting up Cloud Composer for the Weather ETL pipeline orchestration.

**Current Status**: ⚠️ Troubleshooting IAM permissions issue

---

## Issue Timeline

### Attempt 1: With Python Version Flag ❌

**Command**:
```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --python-version 3 \  # ← This flag is the problem
    --environment-size small \
    --node-count 3 \
    --zone us-central1-a \
    --service-account composer-sa@data-engineer-475516.iam.gserviceaccount.com \
    --project data-engineer-475516
```

**Error**:
```
ERROR: (gcloud) Cannot specify --python-version with Composer 2.X or greater.
```

**Cause**: In Composer 2.X, the Python version is tied to the image version, not a separate parameter.

**Fix**: Remove `--python-version` flag

---

### Attempt 2: With Node Count Flag ❌

**Command**:
```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --node-count 3 \  # ← This flag is the problem
    --project data-engineer-475516
```

**Error**:
```
ERROR: (gcloud.composer.environments.create) INVALID_ARGUMENT:
Found 1 problem:
1) Configuring node count is not supported for Cloud Composer environments in versions 2.0.0 and newer.
```

**Cause**: Composer 2.X uses auto-scaling based on `--environment-size` (small/medium/large). The `--node-count` flag is not supported.

**Fix**: Remove `--node-count` flag

---

### Attempt 3: Without Service Account ❌

**Command**:
```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --project data-engineer-475516
```

**Error**:
```
ERROR: (gcloud.composer.environments.create) INVALID_ARGUMENT:
Composer environment service account is required to be explicitly specified.
```

**Cause**: Composer 2.X requires an explicit service account to be specified (no default).

**Fix**: Add `--service-account` parameter with a valid service account

---

### Attempt 4: With Default Compute Service Account ❌

**Command**:
```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --service-account 434782524071-compute@developer.gserviceaccount.com \
    --project data-engineer-475516
```

**Error**:
```
ERROR: (gcloud.composer.environments.create) FAILED_PRECONDITION:
Cloud Composer Service Agent service account (service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com)
is missing required permissions: iam.serviceAccounts.getIamPolicy, iam.serviceAccounts.setIamPolicy.

Check that the Cloud Composer v2 API Service Agent Extension role (roles/composer.ServiceAgentV2Ext)
is granted to service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com and that required
permissions aren't in an IAM deny policy.
```

**Cause**: The Cloud Composer Service Agent (a Google-managed service account) is missing the required IAM role to create and manage Composer environments.

**Service Account**: `service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com`
**Required Role**: `roles/composer.ServiceAgentV2Ext` (Cloud Composer v2 API Service Agent Extension)

**Status**: ⏳ Need to grant permissions

---

## Solution: Grant Required IAM Role

### Step 1: Grant Service Agent Role

The Cloud Composer Service Agent is automatically created when you enable the Cloud Composer API. It needs the `composer.ServiceAgentV2Ext` role to function properly.

**Command**:
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com" \
    --role="roles/composer.ServiceAgentV2Ext"
```

### Step 2: Verify Permissions

```bash
gcloud projects get-iam-policy data-engineer-475516 \
    --flatten="bindings[].members" \
    --filter="bindings.members:service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com"
```

### Step 3: Retry Environment Creation

```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --service-account 434782524071-compute@developer.gserviceaccount.com \
    --project data-engineer-475516
```

---

## Key Learnings

### 1. Composer 2.X Changes from 1.X

| Feature | Composer 1.X | Composer 2.X |
|---------|--------------|--------------|
| **Python Version** | `--python-version` flag | Tied to `--image-version` |
| **Node Scaling** | `--node-count` flag | Auto-scales by `--environment-size` |
| **Service Account** | Optional (uses default) | Required (must specify explicitly) |
| **Service Agent Role** | May work without explicit grant | **Must grant `roles/composer.ServiceAgentV2Ext`** |

### 2. Service Account Requirements

**Two Service Accounts Involved**:

1. **Composer Environment Service Account** (user-specified)
   - Example: `434782524071-compute@developer.gserviceaccount.com`
   - Used by Composer to run Airflow workers and tasks
   - Needs permissions for: GCS, BigQuery, Dataflow, etc.

2. **Cloud Composer Service Agent** (Google-managed)
   - Example: `service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com`
   - Managed by Google, automatically created
   - Needs `roles/composer.ServiceAgentV2Ext` to create/manage environments
   - **This is what's currently missing**

### 3. Common Composer 2.X Flags

**Minimal Configuration**:
```bash
gcloud composer environments create <NAME> \
    --location <REGION> \
    --image-version composer-2.X.X-airflow-2.X.X \
    --environment-size small|medium|large \
    --service-account <SA_EMAIL> \
    --project <PROJECT_ID>
```

**Optional Flags**:
- `--disk-size-gb` - Persistent disk size (default: 30 GB)
- `--machine-type` - Worker machine type (default: n1-standard-4)
- `--network` - VPC network
- `--subnetwork` - VPC subnetwork
- `--env-variables` - Environment variables for Airflow

---

## References

- [Cloud Composer Documentation](https://cloud.google.com/composer/docs)
- [Composer 2 Service Agents](https://cloud.google.com/composer/docs/composer-2/access-control#composer.ServiceAgentV2Ext)
- [Creating Composer 2 Environments](https://cloud.google.com/composer/docs/composer-2/create-environments)
- [Troubleshooting Environment Creation](https://cloud.google.com/composer/docs/composer-2/troubleshooting-environment-creation)

---

## ✅ Solution Applied Successfully!

### Step 1: Grant Service Agent Role ✅ COMPLETE

**Command Executed**:
```bash
gcloud projects add-iam-policy-binding data-engineer-475516 \
    --member="serviceAccount:service-434782524071@cloudcomposer-accounts.iam.gserviceaccount.com" \
    --role="roles/composer.ServiceAgentV2Ext"
```

**Result**: Role successfully granted

### Step 2: Create Environment ✅ IN PROGRESS

**Command Executed**:
```bash
gcloud composer environments create weather-etl-composer \
    --location us-central1 \
    --image-version composer-2.9.9-airflow-2.9.3 \
    --environment-size small \
    --service-account 434782524071-compute@developer.gserviceaccount.com \
    --project data-engineer-475516
```

**Status**: ✅ Creation in progress!
**Operation ID**: `766432f5-f170-485e-abb1-4a6ab87a1cf7`
**Estimated Completion**: ~20-30 minutes

### Monitor Creation Progress

```bash
# Check environment status
gcloud composer environments describe weather-etl-composer \
    --location us-central1 \
    --project data-engineer-475516

# List environments
gcloud composer environments list \
    --locations us-central1 \
    --project data-engineer-475516

# Check operation status
gcloud composer operations describe 766432f5-f170-485e-abb1-4a6ab87a1cf7 \
    --location us-central1 \
    --project data-engineer-475516
```

### Console URL

Monitor creation in the GCP Console:
https://console.cloud.google.com/composer/environments?project=data-engineer-475516

---

## Next Steps

1. ✅ ~~Grant `roles/composer.ServiceAgentV2Ext` role~~ - COMPLETE
2. ✅ **Environment creation initiated** - IN PROGRESS (20-30 min)
3. ⏳ **Get Airflow web UI URL** once environment is ready
4. ⏳ **Upload DAG** to Composer's GCS bucket
5. ⏳ **Test DAG execution** in Airflow UI

---

**Last Updated**: 2025-10-19
**Status**: ✅ Creating (Operation ID: 766432f5-f170-485e-abb1-4a6ab87a1cf7)
