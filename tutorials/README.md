# GCP Data Engineer Tutorials

This directory contains hands-on tutorials for GCP services, organized by exam section.

## Organization

Tutorials are numbered according to the exam sections in [EXAM_PREP.md](../EXAM_PREP.md):

- **0100-0199**: Section 1 - Designing Data Processing Systems
- **0200-0299**: Section 2 - Ingesting and Processing Data
- **0300-0399**: Section 3 - Storing the Data
- **0400-0499**: Section 4 - Preparing and Using Data for Analysis
- **0500-0599**: Section 5 - Maintaining and Automating Workloads

## On-Demand Generation

Tutorials are **generated as needed** when you're ready to learn a specific topic. Simply ask Claude Code to create a tutorial for the topic you want to study.

Example: "Create the BigQuery basics tutorial (0300)" or "I'm ready to learn about Pub/Sub, can you generate that tutorial?"

## Tutorial Structure

Each tutorial typically includes:
- **README.md**: Learning objectives, prerequisites, and instructions
- **Code examples**: Fully functional Python scripts with comments
- **requirements.txt**: Python dependencies
- **setup.sh**: GCP resource setup commands (commented for safety)
- **cleanup.sh**: Resource cleanup to avoid unnecessary costs

## Before Starting

1. Ensure you have a GCP project set up
2. Install the `gcloud` CLI and authenticate
3. Set your project ID: `gcloud config set project YOUR_PROJECT_ID`
4. Enable billing on your project
5. Create a Python virtual environment (see main README.md)

## Cost Management

⚠️ **Important**: Always run cleanup scripts after completing tutorials to avoid unexpected GCP charges. Most tutorials include cleanup instructions or scripts.
