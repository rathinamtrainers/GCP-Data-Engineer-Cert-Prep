# GCP Professional Data Engineer - Certification Prep

Comprehensive preparation repository for the Google Cloud Professional Data Engineer certification exam.

## About This Repository

This repository provides a structured learning path for the GCP Professional Data Engineer exam, organized by exam sections with hands-on tutorials generated on-demand as you progress through your studies.

**See [EXAM_PREP.md](EXAM_PREP.md) for the complete study roadmap and learning path.**

## Exam Coverage

The Professional Data Engineer exam has 5 sections:
1. **Designing data processing systems** (~22%)
2. **Ingesting and processing data** (~25%)
3. **Storing the data** (~20%)
4. **Preparing and using data for analysis** (~15%)
5. **Maintaining and automating workloads** (~18%)

## Repository Structure

```
GCP-Data-Engineer-Cert-Prep/
├── 010-docs/                    # Exam guides and documentation
├── EXAM_PREP.md                 # Complete study roadmap with tutorial topics
├── CLAUDE.md                    # Instructions for Claude Code
└── tutorials/                   # Hands-on tutorials (generated on-demand)
    ├── 0100-0199/               # Section 1: Design
    ├── 0200-0299/               # Section 2: Pipelines
    ├── 0300-0399/               # Section 3: Storage
    ├── 0400-0499/               # Section 4: Analysis
    └── 0500-0599/               # Section 5: Operations
```

## Learning Approach

Tutorials are organized by topic but **generated on-demand** as you progress through your learning. This keeps the repository lean and ensures each tutorial is created when you need it, with the most relevant and current examples.

To generate a tutorial, simply ask Claude Code to create it based on the topics outlined in [EXAM_PREP.md](EXAM_PREP.md).

## Getting Started

1. Review the [EXAM_PREP.md](EXAM_PREP.md) study roadmap
2. Follow the recommended study order
3. Generate tutorials as needed for each topic
4. Practice hands-on with your GCP project

## Development Environment

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

## Resources

- [Official Exam Guide](010-docs/professional_data_engineer_exam_guide_english.pdf)
- [GCP Documentation](https://cloud.google.com/docs)
- [Cloud Skills Boost](https://www.cloudskillsboost.google/)
