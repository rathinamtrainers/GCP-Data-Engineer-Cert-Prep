# GCP Professional Data Engineer - Certification Prep

**Learn GCP data engineering by building 7 real-world projects.**

This repository takes a **project-based approach** to mastering GCP data engineering and preparing for the Professional Data Engineer certification exam.

## About This Repository

Instead of isolated tutorials, you'll build **7 progressively complex projects** that naturally cover all certification topics. Every project uses `gcloud` CLI commands for hands-on mastery and creates portfolio-worthy work.

**See [PROJECTS.md](PROJECTS.md) for the complete project-based learning path.**

**Alternative**: [EXAM_PREP.md](EXAM_PREP.md) contains a traditional topic-by-topic study roadmap.

## Exam Coverage

The Professional Data Engineer exam has 5 sections:
1. **Designing data processing systems** (~22%)
2. **Ingesting and processing data** (~25%)
3. **Storing the data** (~20%)
4. **Preparing and using data for analysis** (~15%)
5. **Maintaining and automating workloads** (~18%)

## The 7 Projects

### Phase 1: Foundations (Weeks 1-3)
0. **[GCP Environment Setup](projects/00-gcp-environment-setup/)** - gcloud CLI, IAM, billing, monitoring
1. **Batch ETL Pipeline** - Weather data warehouse with Cloud Storage, Dataflow, BigQuery, Composer

### Phase 2: Advanced Processing (Weeks 4-7)
2. **Real-Time Streaming** - IoT sensor analytics with Pub/Sub, Dataflow Streaming, Bigtable
3. **Data Lake Integration** - Multi-source ingestion with Datastream, Dataplex, data quality

### Phase 3: Analytics & Warehousing (Weeks 8-11)
4. **E-Commerce Analytics** - Star schema warehouse with Dataform, BigQuery ML
5. **Event-Driven Platform** - Complex pipelines with Pub/Sub, Cloud Functions, DLQ

### Phase 4: Production Readiness (Weeks 12-14)
6. **Security & DR** - Multi-region, Cloud KMS, DLP, cost optimization
7. **End-to-End Capstone** - Data marketplace with Analytics Hub, CI/CD, full observability

## Repository Structure

```
GCP-Data-Engineer-Cert-Prep/
├── 010-docs/                    # Exam guides and documentation
├── PROJECTS.md                  # Project-based learning path (START HERE)
├── EXAM_PREP.md                 # Traditional topic-by-topic roadmap
├── CLAUDE.md                    # Instructions for Claude Code
├── projects/                    # 7 hands-on projects
│   ├── 00-gcp-environment-setup/
│   ├── 01-batch-etl-weather/   (coming soon)
│   ├── 02-streaming-iot/       (coming soon)
│   ├── 03-data-lake/           (coming soon)
│   ├── 04-star-schema/         (coming soon)
│   ├── 05-event-driven/        (coming soon)
│   ├── 06-security-dr/         (coming soon)
│   └── 07-capstone/            (coming soon)
└── tutorials/                   # On-demand tutorials (supplementary)
    └── 0000-intro-data-engineering/
```

## Learning Approach

**Project-Based Learning**:
- Build 7 real-world projects
- Use gcloud CLI for every operation
- Learn by doing, not by reading
- Create portfolio-worthy work
- Cover all certification topics naturally

## Getting Started

**Start here**: [Project 0: GCP Environment Setup](projects/00-gcp-environment-setup/)

1. Set up your GCP environment with gcloud CLI
2. Build projects sequentially (each builds on previous ones)
3. Read README → Run commands → Understand what happens
4. Experiment and break things (that's how you learn!)

**Time**: 12-14 weeks, 8-12 hours/week
**Cost**: $50-100 total (within GCP free credit)

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

## Key Resources

### In This Repository
- **[PROJECTS.md](PROJECTS.md)** - Complete project-based learning path (recommended)
- **[Project 0: Environment Setup](projects/00-gcp-environment-setup/)** - Start here!
- **[EXAM_PREP.md](EXAM_PREP.md)** - Traditional topic-by-topic roadmap
- **[Introduction to Data Engineering](tutorials/0000-intro-data-engineering/)** - Foundational concepts

### Official Resources
- [Official Exam Guide](010-docs/professional_data_engineer_exam_guide_english.pdf)
- [GCP Documentation](https://cloud.google.com/docs)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [Cloud Skills Boost](https://www.cloudskillsboost.google/)

## What Makes This Different?

Traditional learning: Read → Watch → Quiz → Forget

**This approach**: Build → Break → Fix → Remember

You'll have:
- ✓ 7 portfolio projects
- ✓ Hands-on gcloud CLI mastery
- ✓ Production-ready skills
- ✓ Deep understanding (not memorization)
- ✓ Certification exam readiness

## Questions?

- Check project `troubleshooting.md` files
- Review `commands.md` for detailed CLI explanations
- Refer to GCP documentation
- Learn by experimenting!

---

**Ready to start? → [Project 0: GCP Environment Setup](projects/00-gcp-environment-setup/)**
