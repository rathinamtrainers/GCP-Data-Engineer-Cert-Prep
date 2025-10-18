# Project 0: GCP Environment & Infrastructure Setup

## Overview

This project establishes your Google Cloud Platform environment for all future data engineering projects. You'll learn to use the `gcloud` CLI to set up a production-ready GCP environment with proper security, cost controls, and monitoring.

**This is the foundation for all subsequent projects.**

## Learning Objectives

By completing this project, you will learn to:

- Install and configure the gcloud CLI
- Create and manage GCP projects using CLI commands
- Enable GCP APIs programmatically
- Set up IAM roles and service accounts
- Configure billing alerts and budgets
- Create a Python development environment for GCP
- Implement basic security best practices
- Set up monitoring and logging
- Manage GCP resources cost-effectively

## Certification Topics Covered

- **Section 1: Designing Data Processing Systems**
  - 1.1 Security and Compliance (IAM, organization policies)
  - 1.3 Flexibility and Portability (project structure)

- **Section 5: Maintaining and Automating Workloads**
  - 5.1 Resource Optimization (cost management)
  - 5.4 Monitoring and Troubleshooting (Cloud Monitoring/Logging setup)

## Prerequisites

### Required
- A Google Cloud account (sign up at https://cloud.google.com/)
- Access to the $300 free credit (for new users)
- A terminal (Linux/Mac) or WSL/Git Bash (Windows)
- Basic command line knowledge

### Recommended
- Basic understanding of cloud concepts
- Familiarity with JSON/YAML configuration files
- Python 3.9+ installed on your machine

## What You'll Build

1. **GCP Project Setup**
   - Create a new GCP project via CLI
   - Configure project settings
   - Enable required APIs

2. **IAM Configuration**
   - Create service accounts for different purposes
   - Assign appropriate IAM roles
   - Generate and manage service account keys

3. **Billing & Cost Management**
   - Set up billing alerts
   - Create budget notifications
   - Configure cost monitoring dashboard

4. **Development Environment**
   - Install gcloud CLI
   - Install Python and create virtual environment
   - Install GCP Python client libraries
   - Configure authentication

5. **Basic Monitoring**
   - Enable Cloud Monitoring
   - Enable Cloud Logging
   - Create a simple dashboard

## GCP Services Used

- **Cloud Resource Manager**: Project management
- **Cloud IAM**: Identity and access management
- **Cloud Billing**: Budget and cost alerts
- **Cloud Monitoring**: Metrics and dashboards
- **Cloud Logging**: Log aggregation and analysis

## Cost Estimate

**$0 - $5/month**

This project uses mostly free-tier services. Costs may include:
- Minimal Cloud Monitoring metrics (free tier: 150 MB/month)
- Cloud Logging (free tier: 50 GB/month)

## Project Structure

```
00-gcp-environment-setup/
├── README.md                    # This file
├── setup.sh                     # Step-by-step setup commands
├── cleanup.sh                   # Resource cleanup
├── commands.md                  # CLI command reference
├── config/
│   ├── .env.template           # Environment variables template
│   ├── project-config.yaml     # Project configuration
│   └── iam-roles.yaml          # IAM role definitions
├── src/
│   ├── requirements.txt        # Python dependencies
│   └── test_connection.py      # Test GCP connection
└── docs/
    ├── architecture.md         # Architecture overview
    ├── troubleshooting.md      # Common issues and solutions
    └── best-practices.md       # GCP best practices
```

## Getting Started

Follow the steps in order:

### Step 1: Install gcloud CLI
See [setup.sh](setup.sh) for installation commands

### Step 2: Authenticate
```bash
gcloud auth login
```

### Step 3: Create GCP Project
Follow commands in [setup.sh](setup.sh)

### Step 4: Configure Environment
Set up Python and test connection

### Step 5: Verify Setup
Run test scripts to ensure everything works

## Detailed Instructions

All detailed, step-by-step instructions with explanations are in:
- **[setup.sh](setup.sh)** - Executable setup script with commented commands
- **[commands.md](commands.md)** - Command reference with detailed explanations

## Testing Your Setup

After completing setup, test your environment:

```bash
# Activate Python virtual environment
source venv/bin/activate  # Linux/Mac
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r src/requirements.txt

# Test GCP connection
python src/test_connection.py
```

Expected output:
```
✓ Authentication successful
✓ Project ID: your-project-id
✓ Billing enabled: True
✓ Required APIs enabled: True
```

## Cleanup

When you're done with ALL projects and want to tear down your environment:

```bash
# See cleanup.sh for detailed cleanup commands
./cleanup.sh
```

**WARNING**: Only run cleanup when you're completely done with all 7 projects!

## Common Issues

### Issue: gcloud command not found
**Solution**: Make sure gcloud CLI is installed and in your PATH
```bash
# Verify installation
which gcloud
gcloud version
```

### Issue: Permission denied errors
**Solution**: Ensure you're authenticated and have project owner/editor role
```bash
gcloud auth list
gcloud projects get-iam-policy PROJECT_ID
```

### Issue: API not enabled
**Solution**: Enable the API using gcloud
```bash
gcloud services enable SERVICE_NAME.googleapis.com
```

See [docs/troubleshooting.md](docs/troubleshooting.md) for more solutions.

## Key Takeaways

After completing this project, you should understand:

✅ How to manage GCP projects using CLI commands
✅ IAM roles and service accounts for security
✅ How to control costs with billing alerts and budgets
✅ Basic monitoring and logging setup
✅ Python development environment for GCP
✅ Authentication methods (user vs service account)
✅ How to enable and manage GCP APIs

## Next Steps

Once your environment is set up, proceed to:

**[Project 1: Batch ETL Pipeline - Weather Data Warehouse](../01-batch-etl-weather/README.md)**

## Resources

### Official Documentation
- [gcloud CLI Overview](https://cloud.google.com/sdk/gcloud)
- [GCP IAM Documentation](https://cloud.google.com/iam/docs)
- [Cloud Billing Documentation](https://cloud.google.com/billing/docs)
- [Python Client Libraries](https://cloud.google.com/python/docs/reference)

### Useful Commands Quick Reference
```bash
# Project management
gcloud projects list
gcloud projects describe PROJECT_ID
gcloud config set project PROJECT_ID

# IAM
gcloud iam service-accounts list
gcloud projects get-iam-policy PROJECT_ID

# APIs
gcloud services list --available
gcloud services list --enabled

# Billing
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID

# Configuration
gcloud config list
gcloud config configurations list
```

## Questions for Reflection

1. Why is it important to use service accounts instead of your personal credentials for applications?
2. What's the difference between project-level and organization-level IAM policies?
3. How can you minimize GCP costs while learning?
4. What are the security implications of downloading service account keys?

## Notes

- Keep your service account keys secure (never commit to git!)
- Always clean up resources after testing to avoid costs
- Use the free tier wisely - monitor your usage
- Project IDs must be globally unique in GCP

---

**Estimated Time**: 2-3 hours for first-time setup

**Difficulty**: Beginner

**Prerequisites**: None (start here!)
