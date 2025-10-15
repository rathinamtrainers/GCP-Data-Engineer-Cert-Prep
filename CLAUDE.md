# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Google Cloud Platform (GCP) Data Engineer certification preparation repository. It contains a structured study roadmap with tutorial topics that are **generated on-demand** as the user progresses through their learning.

**See [EXAM_PREP.md](EXAM_PREP.md) for the complete study roadmap and all tutorial topics.**

### On-Demand Tutorial Generation

Tutorials are NOT pre-created. When the user requests a tutorial on a specific topic:
1. Check EXAM_PREP.md to identify the appropriate tutorial number and topic
2. Generate a complete, self-contained tutorial in the appropriate `tutorials/00XX-topic/` directory
3. Follow the Tutorial Requirements (below) for structure and content

## Exam Coverage

The Professional Data Engineer exam has 5 sections:
1. **Designing data processing systems** (~22%) - Security, reliability, flexibility, migrations
2. **Ingesting and processing data** (~25%) - Pipelines, batch/streaming, orchestration
3. **Storing the data** (~20%) - Storage systems, data warehouses, data lakes, platforms
4. **Preparing and using data for analysis** (~15%) - Visualization, AI/ML, data sharing
5. **Maintaining and automating workloads** (~18%) - Optimization, monitoring, reliability

## Repository Structure

```
GCP-Data-Engineer-Cert-Prep/
├── 010-docs/                    # Exam guides and documentation
│   └── professional_data_engineer_exam_guide_english.pdf
├── EXAM_PREP.md                 # Complete study roadmap
├── tutorials/                   # Hands-on GCP service tutorials
│   ├── 0010-pubsub-python/      # Section 2: Pub/Sub messaging
│   ├── 0100-0190/               # Section 1: Design (security, reliability, migrations)
│   ├── 0200-0270/               # Section 2: Pipelines (Dataflow, Composer, etc.)
│   ├── 0300-0380/               # Section 3: Storage (BigQuery, Bigtable, etc.)
│   ├── 0400-0450/               # Section 4: Analysis (BI, ML, sharing)
│   └── 0500-0550/               # Section 5: Operations (monitoring, optimization)
└── README.md
```

## Architecture

### Tutorial Organization

Tutorials are organized by exam section using a numbered directory scheme:

**Section 1: Designing (0100-0199)**
- `0100-0129`: Security and compliance (IAM, encryption, DLP)
- `0130-0159`: Reliability and fidelity (Dataflow, Dataform, monitoring)
- `0160-0179`: Flexibility and portability (Dataplex, data catalog)
- `0180-0199`: Data migrations (transfer services, Datastream)

**Section 2: Ingesting/Processing (0200-0299, plus 0010-0099 for foundational)**
- `0010-0099`: Foundational messaging (Pub/Sub)
- `0200-0209`: Pipeline planning
- `0210-0259`: Pipeline building (Dataflow, Dataproc, Beam, Spark)
- `0260-0279`: Pipeline deployment (Composer, Workflows, CI/CD)

**Section 3: Storing (0300-0399)**
- `0300-0349`: Storage systems (BigQuery, Bigtable, Spanner, Cloud SQL, etc.)
- `0350-0369`: Data warehouse design and optimization
- `0370-0389`: Data lakes and platforms (Dataplex)

**Section 4: Analysis (0400-0499)**
- `0400-0429`: Data visualization and BI
- `0430-0449`: AI/ML preparation (BigQueryML, Vertex AI)
- `0450-0469`: Data sharing (Analytics Hub)

**Section 5: Operations (0500-0599)**
- `0500-0519`: Resource optimization and cost management
- `0520-0539`: Automation and workload organization
- `0540-0559`: Monitoring, troubleshooting, disaster recovery

### Tutorial Requirements

Each tutorial should include:
1. **README.md**: Objective, prerequisites, GCP services used, setup instructions
2. **Code examples**: Fully functional with comments
3. **requirements.txt**: Python dependencies (if applicable)
4. **setup.sh**: GCP resource setup commands (commented, not executable for safety)
5. **cleanup.sh**: Resource cleanup commands (to avoid costs)

## Development Environment

This repository uses Python with a virtual environment setup:
- Virtual environment directory: `venv/` (gitignored)
- IDE configuration: `.idea/` (PyCharm/IntelliJ, gitignored)

### Setting Up Environment

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Linux/Mac:
source venv/bin/activate

# Install dependencies (when requirements.txt exists)
pip install -r requirements.txt
```

## Creating Tutorials On-Demand

When the user requests a tutorial:

1. **Directory naming**: Use the pattern `tutorials/00XX-servicename/` (e.g., `0300-bigquery-basics/`)
   - Use the numbering from EXAM_PREP.md to maintain organization

2. **Make it self-contained**: Each tutorial should include all necessary files and dependencies

3. **Focus on learning**: Create practical, runnable examples that teach GCP service concepts

4. **Security best practices**:
   - Never hardcode credentials or project IDs
   - Use environment variables for configuration
   - Add notes about IAM permissions required

5. **Cost awareness**: Include cleanup instructions to avoid unnecessary GCP charges

## Testing GCP Code

GCP Python code typically requires:
- GCP project ID set via environment variable or configuration
- Service account credentials (JSON key file) or Application Default Credentials
- Appropriate IAM permissions for the service being used

Example for Pub/Sub:
```bash
# Set project ID
export GOOGLE_CLOUD_PROJECT=your-project-id

# Run the publisher
python tutorials/0010-pubsub-python/publisher.py
```
