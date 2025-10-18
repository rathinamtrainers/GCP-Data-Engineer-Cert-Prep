# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Google Cloud Platform (GCP) Data Engineer certification preparation repository with **two learning approaches**:

1. **Project-Based Learning (Recommended)**: [PROJECTS.md](PROJECTS.md) - 7 real-world projects with gcloud CLI commands
2. **Topic-Based Learning (Alternative)**: [EXAM_PREP.md](EXAM_PREP.md) - Traditional tutorial roadmap with on-demand generation

**The project-based approach is the primary learning path** - tutorials are supplementary.

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

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate    # Windows

# Install dependencies from project or tutorial
pip install -r src/requirements.txt  # or requirements.txt
```

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

## GCP Command Patterns

This repository emphasizes gcloud CLI mastery. Common patterns:

### Resource Creation
```bash
# BigQuery
bq mk --dataset --location=US --description="desc" project_id:dataset_name
bq mk --table dataset.table schema.json

# Pub/Sub
gcloud pubsub topics create TOPIC_NAME
gcloud pubsub subscriptions create SUB_NAME --topic=TOPIC_NAME

# Dataflow
gcloud dataflow jobs run JOB_NAME \
  --gcs-location=gs://dataflow-templates/latest/template \
  --region=us-central1 \
  --parameters=input=gs://bucket/input
```

### Resource Cleanup
```bash
# Always clean up in reverse order of creation
bq rm -f -t dataset.table      # Delete table first
bq rm -f -d dataset             # Then dataset
gcloud pubsub subscriptions delete SUB_NAME
gcloud pubsub topics delete TOPIC_NAME
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

## Testing Generated Code

Before delivering tutorials with Python code, verify:
1. All imports are in requirements.txt
2. Code runs without hardcoded values
3. Error handling for missing environment variables
4. setup.sh enables all required APIs
5. cleanup.sh removes all billable resources

## Exam Context (When Relevant)

The Professional Data Engineer exam has 5 sections (see EXAM_PREP.md for details):
1. Designing data processing systems (~22%)
2. Ingesting and processing data (~25%)
3. Storing the data (~20%)
4. Preparing and using data for analysis (~15%)
5. Maintaining and automating workloads (~18%)

When explaining concepts, relate them to exam objectives when helpful.
