# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Google Cloud Platform (GCP) Data Engineer certification preparation repository with **two learning approaches**:

1. **Project-Based Learning (Recommended)**: [PROJECTS.md](PROJECTS.md) - 7 real-world projects with gcloud CLI commands
2. **Topic-Based Learning (Alternative)**: [EXAM_PREP.md](EXAM_PREP.md) - Traditional tutorial roadmap with on-demand generation

**The project-based approach is the primary learning path** - tutorials are supplementary.

## Repository Status

### Completed Projects
- **Project 0**: [GCP Environment Setup](projects/00-gcp-environment-setup/) - Complete
- **Project 1**: [Batch ETL Weather Pipeline](projects/01-batch-etl-weather/) - Phase 1 Complete (Dataflow), Phase 2 In Progress (Composer)

### Completed Tutorials
- **Tutorial 0000**: [Introduction to Data Engineering](tutorials/0000-intro-data-engineering/) - Foundational concepts

### Key Documentation Files
- **README.md**: Main repository overview and getting started guide
- **PROJECTS.md**: Detailed breakdown of all 7 projects with learning objectives
- **EXAM_PREP.md**: Topic-by-topic exam preparation roadmap
- **CLAUDE.md**: This file - guidance for Claude Code
- **010-docs/**: Official GCP exam guides and documentation

## Key Architecture Principles

### Dual Learning Paths

**Projects (Primary)**: Located in `projects/`
- Sequential, portfolio-building projects (00 through 07)
- Each project has: README.md, setup.sh, cleanup.sh, commands.md, src/, config/, docs/
- Projects build on each other - MUST be completed in order
- Every operation uses gcloud CLI commands
- Projects are pre-created with complete documentation

**Tutorials (Supplementary)**: Located in `tutorials/`
- Generated **on-demand** only when user explicitly requests a specific tutorial
- Numbered by exam section (0010-0099, 0100-0599)
- Self-contained examples of specific GCP services
- NOT required if following project path

### Content Generation Rules

**DO NOT** proactively generate tutorials unless:
1. User explicitly requests a specific tutorial by number or topic
2. User is following the topic-based (EXAM_PREP.md) approach

**DO** guide users through existing project content when they:
1. Are following the project-based (PROJECTS.md) approach
2. Ask general questions about GCP services
3. Need help with specific project tasks

## Tutorial Numbering System (When Generating)

Tutorials use a strict numbering scheme aligned with exam sections:

- `0010-0099`: Foundational (Pub/Sub, data engineering basics)
- `0100-0199`: Section 1 - Designing systems (IAM, encryption, migrations)
- `0200-0299`: Section 2 - Ingestion/processing (Dataflow, Composer, Beam)
- `0300-0399`: Section 3 - Storage (BigQuery, Bigtable, Spanner)
- `0400-0499`: Section 4 - Analysis (BI, ML, Analytics Hub)
- `0500-0599`: Section 5 - Operations (monitoring, optimization, DR)

See EXAM_PREP.md:27-207 for detailed breakdown.

## Development Environment

### Python Environment Setup

Projects use isolated virtual environments. Each project may have its own venv:

```bash
# Navigate to project directory
cd projects/XX-project-name/

# Create virtual environment (use venv-beam for Dataflow projects)
python -m venv venv-beam

# Activate virtual environment
source venv-beam/bin/activate  # Linux/Mac
# venv-beam\Scripts\activate    # Windows

# Install dependencies
pip install -r src/requirements.txt  # or requirements.txt at root
```

**Apache Beam/Dataflow Projects**: Use `venv-beam` naming convention for Python 3.11 compatibility.

### GCP Authentication

All code expects one of these authentication methods:
1. **User authentication**: `gcloud auth application-default login`
2. **Service account key**: Set `GOOGLE_APPLICATION_CREDENTIALS` env var
3. **Project ID**: Set `GOOGLE_CLOUD_PROJECT` env var

Example:
```bash
export GOOGLE_CLOUD_PROJECT=your-project-id
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
```

### Project-Specific Scripts

Each project contains helper scripts for common operations:
- **`setup.sh`**: Creates GCP resources (buckets, datasets, service accounts)
- **`cleanup.sh`**: Deletes all project resources to avoid costs
- **`run_*.sh`**: Execution helpers (e.g., `run_dataflow_job.sh`)
- **`commands.md`**: Reference documentation for all gcloud commands used

## Creating Content (When Requested)

### Tutorial Structure (On-Demand Only)

When user explicitly requests a tutorial, create in `tutorials/00XX-servicename/`:

**Required Files:**
1. **README.md**:
   - Learning objective and prerequisites
   - GCP services covered and IAM permissions needed
   - Clear setup and testing instructions
   - Links to official GCP documentation

2. **Code files** (e.g., `publisher.py`, `subscriber.py`):
   - Fully functional, well-commented code
   - No hardcoded credentials or project IDs
   - Use environment variables for configuration

3. **requirements.txt**: Python dependencies with pinned versions

4. **setup.sh**:
   - Commented gcloud commands (NOT executable by default for safety)
   - Enable required APIs
   - Create GCP resources

5. **cleanup.sh**:
   - Commands to delete all created resources
   - Prevent ongoing GCP costs

### Project Guidance (Primary Role)

When users are working through projects:
1. Read the existing README.md, setup.sh, and related files
2. Help them understand and execute commands
3. Explain gcloud CLI options and GCP service concepts
4. Troubleshoot errors with specific suggestions
5. Do NOT create new files unless fixing bugs or user explicitly requests additions

## Code Architecture

### Project Structure Pattern

All projects follow a consistent structure:

```
projects/XX-project-name/
├── README.md                    # Overview, objectives, instructions
├── setup.sh                     # GCP resource creation (gcloud commands)
├── cleanup.sh                   # Resource cleanup (avoid costs!)
├── run_*.sh                     # Helper scripts for execution
├── commands.md                  # Command reference with explanations
├── config/
│   ├── .env.template           # Configuration template
│   └── *.yaml                  # Service configurations
├── src/
│   ├── requirements.txt        # Python dependencies
│   ├── ingestion/              # Data fetching scripts
│   ├── transformation/         # Apache Beam pipelines
│   ├── utils/                  # Shared utilities (validators, schemas)
│   └── tests/                  # Unit tests
├── dags/                        # Airflow DAGs (if using Composer)
├── sql/                         # SQL scripts
└── docs/
    ├── architecture.md         # Architecture diagrams
    ├── lessons-learned.md      # Key takeaways
    └── troubleshooting.md      # Common issues
```

### Apache Beam Pipeline Pattern

Beam pipelines in this repo follow a consistent structure:
1. **DoFn classes** for transformations (e.g., `ReadJSONArray`, `TransformWeather`)
2. **Utility modules** for validation and schema (`utils/data_validator.py`, `utils/bigquery_schema.py`)
3. **CLI argument parsing** with support for both DirectRunner (local) and DataflowRunner (production)
4. **Path manipulation** to enable imports: `sys.path.insert(0, str(Path(__file__).parent.parent))`

Common imports pattern:
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from utils.data_validator import WeatherDataValidator
from utils.bigquery_schema import SCHEMA_FIELDS
```

### Shell Script Patterns

Scripts use consistent conventions:
- **Color-coded output**: GREEN for success, YELLOW for warnings, RED for errors
- **`set -e`**: Exit on error
- **Configuration variables** at top (PROJECT_ID, REGION, etc.)
- **Prerequisite checks** before execution
- **Detailed output** with next steps

## GCP Command Patterns

This repository emphasizes gcloud CLI mastery. Common patterns:

### Resource Creation
```bash
# BigQuery
bq mk --dataset --location=US --description="desc" project_id:dataset_name
bq mk --table dataset.table schema.json

# Cloud Storage
gsutil mb -p PROJECT_ID -c STANDARD -l REGION gs://bucket-name

# Pub/Sub
gcloud pubsub topics create TOPIC_NAME
gcloud pubsub subscriptions create SUB_NAME --topic=TOPIC_NAME

# Service Accounts
gcloud iam service-accounts create SERVICE_ACCOUNT_NAME \
  --display-name="Display Name"

# IAM Role Binding
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/ROLE_NAME"

# Dataflow (via Python SDK)
python pipeline.py \
  --runner DataflowRunner \
  --project PROJECT_ID \
  --region REGION \
  --temp_location gs://bucket/temp \
  --staging_location gs://bucket/staging \
  --service_account_email SA_EMAIL
```

### Resource Cleanup
```bash
# Always clean up in reverse order of creation
bq rm -f -t dataset.table      # Delete table first
bq rm -f -d dataset             # Then dataset
gsutil -m rm -r gs://bucket     # Delete bucket with all contents
gcloud pubsub subscriptions delete SUB_NAME
gcloud pubsub topics delete TOPIC_NAME
gcloud iam service-accounts delete SA_EMAIL
```

### Monitoring and Debugging
```bash
# Dataflow jobs
gcloud dataflow jobs list --region=REGION --status=active
gcloud dataflow jobs describe JOB_ID --region=REGION

# BigQuery queries
bq query --use_legacy_sql=false 'SELECT * FROM dataset.table LIMIT 10'
bq show --format=prettyjson dataset.table

# Cloud Storage
gsutil ls gs://bucket/path/
gsutil cat gs://bucket/file.json

# Logging (useful for Dataflow debugging)
gcloud logging read "resource.labels.job_id=JOB_ID" --limit=20
```

## Cost Management Awareness

**Critical**: All tutorials and projects must include:
- Cost estimates in README.md
- cleanup.sh with complete resource deletion
- Warnings about resources that incur ongoing costs
- Free tier limitations and recommendations

Common cost traps to warn about:
- Pub/Sub subscriptions (retain messages = cost)
- BigQuery storage (even free tier queries cost for storage)
- Dataflow jobs (if left running)
- Cloud Composer environments (expensive, ~$300/month)

## Security Best Practices

All code must follow these rules:

1. **No hardcoded credentials**: Use environment variables or ADC
2. **No project IDs in code**: Use `os.environ.get('GOOGLE_CLOUD_PROJECT')`
3. **Service account keys**: Warn about security implications, suggest ADC instead
4. **IAM permissions**: Document minimum required roles in README.md
5. **gitignore**: Ensure `.env`, `*.json` (keys), `venv/` are gitignored

## Common Development Workflows

### Running Apache Beam Pipelines

**Local Testing (DirectRunner)**:
```bash
cd projects/01-batch-etl-weather
source venv-beam/bin/activate
python src/transformation/weather_pipeline.py \
  --input gs://bucket/raw/20250118/*.json \
  --output PROJECT:DATASET.TABLE \
  --runner DirectRunner
```

**Production Deployment (DataflowRunner)**:
```bash
# Use helper script (recommended)
bash run_dataflow_job.sh

# Or manually via Python
python src/transformation/weather_pipeline.py \
  --runner DataflowRunner \
  --project PROJECT_ID \
  --region REGION \
  --temp_location gs://bucket/temp \
  --staging_location gs://bucket/staging \
  --service_account_email SA_EMAIL \
  --setup_file ./setup.py
```

### Project Setup Workflow

1. **Navigate to project**: `cd projects/XX-project-name/`
2. **Review README**: Understand objectives and architecture
3. **Review setup.sh**: See what resources will be created
4. **Run setup**: `bash setup.sh` (creates GCP resources)
5. **Configure environment**: Copy `config/.env.template` to `config/.env`, fill in values
6. **Create venv**: `python -m venv venv-beam && source venv-beam/bin/activate`
7. **Install dependencies**: `pip install -r src/requirements.txt`
8. **Test locally**: Run with DirectRunner first
9. **Deploy to production**: Use DataflowRunner or helper scripts
10. **Monitor**: Check Cloud Console and logs
11. **Clean up**: `bash cleanup.sh` when done to avoid costs

### Troubleshooting Dataflow Jobs

When Dataflow jobs fail:
1. **Check job status**: `gcloud dataflow jobs list --region=REGION`
2. **View job details**: `gcloud dataflow jobs describe JOB_ID --region=REGION`
3. **Read logs**: `gcloud logging read "resource.labels.job_id=JOB_ID" --limit=50`
4. **Common issues**:
   - Missing API enablement: Check setup.sh
   - IAM permissions: Service account needs proper roles
   - Import errors: Ensure `setup.py` includes all packages
   - Path issues: Use `sys.path.insert()` for local imports

### Testing Generated Code

Before delivering tutorials with Python code, verify:
1. All imports are in requirements.txt
2. Code runs without hardcoded values
3. Error handling for missing environment variables
4. setup.sh enables all required APIs
5. cleanup.sh removes all billable resources
6. For Apache Beam: setup.py includes all local packages for Dataflow workers

## Exam Context (When Relevant)

The Professional Data Engineer exam has 5 sections (see EXAM_PREP.md for details):
1. Designing data processing systems (~22%)
2. Ingesting and processing data (~25%)
3. Storing the data (~20%)
4. Preparing and using data for analysis (~15%)
5. Maintaining and automating workloads (~18%)

When explaining concepts, relate them to exam objectives when helpful.
