# GCP Data Engineering Projects

## Overview

This learning path takes a **project-based approach** to mastering GCP data engineering. Instead of isolated tutorials, you'll build 7 progressively complex, real-world projects that naturally cover all topics in the GCP Professional Data Engineer certification.

## Learning Philosophy

**Learn by building, not by reading.**

Each project:
- Solves a real-world problem
- Uses `gcloud` CLI commands (hands-on mastery)
- Covers multiple certification topics
- Builds on previous projects
- Creates portfolio-worthy work
- Is fully documented with explanations

## Projects Overview

### [Project 0: GCP Environment & Infrastructure Setup](projects/00-gcp-environment-setup/)

**Duration**: Week 1 (2-3 hours)

**Goal**: Set up a production-ready GCP environment using gcloud CLI

**What You'll Build**:
- Complete GCP project configuration
- IAM roles and service accounts
- Billing alerts and cost monitoring
- Python development environment

**GCP Services**: Project management, IAM, Billing, Monitoring

**Certification Topics**:
- Section 1.1: Security and Compliance (IAM)
- Section 5.1: Resource Optimization (cost management)
- Section 5.4: Monitoring and Troubleshooting

**Skills Learned**:
- gcloud CLI fundamentals
- Service account management
- IAM role assignment
- Cost control best practices

**Prerequisites**: None (start here!)

---

### Project 1: Batch ETL Pipeline - Weather Data Warehouse

**Duration**: Weeks 2-3 (8-10 hours)

**Goal**: Build a classic batch ETL pipeline

**What You'll Build**:
- Ingest data from OpenWeather API → Cloud Storage
- Transform with Apache Beam (Dataflow)
- Load into partitioned BigQuery tables
- Schedule with Cloud Composer (Airflow)
- Create Looker Studio dashboard

**GCP Services**: Cloud Storage, Dataflow, BigQuery, Cloud Composer, Looker Studio

**Certification Topics**:
- Section 2.1: Planning Data Pipelines
- Section 2.2: Building Pipelines (batch processing)
- Section 2.3: Deploying and Operationalizing (Composer)
- Section 3.1: Storage System Selection
- Section 3.2: Data Warehouse (partitioning, clustering)
- Section 4.1: Data Visualization

**Skills Learned**:
- REST API data ingestion
- Apache Beam pipeline development
- BigQuery table design
- Airflow DAG creation
- Batch scheduling patterns

**CLI Commands Covered**:
- `gsutil mb`, `gsutil cp` (Cloud Storage)
- `bq mk`, `bq load` (BigQuery)
- `gcloud dataflow jobs run`
- `gcloud composer environments create`

**Prerequisites**: Project 0

---

### Project 2: Real-Time Streaming - IoT Sensor Analytics

**Duration**: Weeks 4-5 (10-12 hours)

**Goal**: Handle streaming data with windowing and aggregations

**What You'll Build**:
- Simulate IoT sensors publishing to Pub/Sub
- Dataflow streaming pipeline with windowing
- Handle late-arriving data
- Write to BigQuery streaming inserts
- Store time-series data in Bigtable
- Real-time Looker Studio dashboard

**GCP Services**: Pub/Sub, Dataflow Streaming, BigQuery, Bigtable

**Certification Topics**:
- Section 2.2: Building Pipelines (streaming, windowing, late data)
- Section 3.1: Storage System Selection (Bigtable for time-series)
- Section 2.1: Data encryption in transit

**Skills Learned**:
- Pub/Sub topic and subscription management
- Apache Beam streaming concepts
- Windowing strategies (tumbling, sliding, session)
- Late data handling
- Bigtable schema design
- Exactly-once processing

**CLI Commands Covered**:
- `gcloud pubsub topics create/delete`
- `gcloud pubsub subscriptions create`
- `gcloud pubsub topics publish` (testing)
- `cbt createinstance`, `cbt createtable` (Bigtable)

**Prerequisites**: Projects 0, 1

---

### Project 3: Data Lake & Multi-Source Integration

**Duration**: Weeks 6-7 (12-15 hours)

**Goal**: Build an enterprise data lake with medallion architecture

**What You'll Build**:
- Ingest from multiple sources:
  - PostgreSQL database (CDC with Datastream)
  - REST API
  - CSV file uploads
- Implement medallion architecture (Raw → Cleaned → Curated zones)
- Use Dataplex for data cataloging
- Implement data quality checks
- Track data lineage

**GCP Services**: Cloud Storage, Cloud SQL, Datastream, Dataplex, Data Fusion

**Certification Topics**:
- Section 1.4: Data Migrations (Datastream for CDC)
- Section 1.3: Flexibility and Portability (Dataplex)
- Section 1.2: Reliability and Fidelity (data quality)
- Section 3.3: Data Lakes
- Section 3.4: Data Platforms

**Skills Learned**:
- Change Data Capture (CDC) patterns
- Medallion/Delta Lake architecture
- Data quality validation
- Data cataloging and discovery
- Multi-source data integration
- Cloud SQL management

**CLI Commands Covered**:
- `gcloud sql instances create` (Cloud SQL)
- `gcloud datastream` commands (CDC)
- `gcloud dataplex lakes/zones/assets create`
- Data quality scanning

**Prerequisites**: Projects 0, 1, 2

---

### Project 4: E-Commerce Analytics - Star Schema Warehouse

**Duration**: Weeks 8-9 (12-15 hours)

**Goal**: Production data warehouse with dimensional modeling

**What You'll Build**:
- Design star schema (fact + dimension tables)
- Implement SCD Type 2 (slowly changing dimensions)
- Use Dataform for SQL-based transformations
- Create materialized views
- Optimize with BI Engine
- Build BigQuery ML model for customer segmentation
- Create comprehensive BI dashboards

**GCP Services**: BigQuery, Dataform, BI Engine, BigQuery ML

**Certification Topics**:
- Section 3.2: Data Warehouse (star schema, normalization)
- Section 1.2: Data preparation with Dataform
- Section 4.1: Data Visualization (materialized views, BI Engine)
- Section 4.2: AI/ML Preparation (BigQuery ML)
- Section 5.1: Resource Optimization (query optimization)

**Skills Learned**:
- Dimensional modeling (star/snowflake schema)
- Slowly changing dimensions (SCD)
- Dataform workflow
- SQL optimization techniques
- Materialized views
- BigQuery ML for analytics
- Query performance tuning

**CLI Commands Covered**:
- `bq mk --table --time_partitioning_type`
- `bq mk --clustering_fields`
- `gcloud dataform repositories create`
- `bq query` (CREATE MODEL for BigQuery ML)

**Prerequisites**: Projects 0, 1, 3

---

### Project 5: Event-Driven Data Platform

**Duration**: Weeks 10-11 (12-15 hours)

**Goal**: Scalable event-driven architecture

**What You'll Build**:
- Multiple Pub/Sub topics (orders, inventory, shipments)
- Complex Dataflow pipeline with branching logic
- Write to multiple sinks (BigQuery, Bigtable, Cloud Storage)
- Cloud Functions for lightweight event processing
- Dead letter queues for error handling
- Exactly-once processing semantics
- Comprehensive error handling

**GCP Services**: Pub/Sub, Dataflow, Cloud Functions, Cloud Storage, BigQuery, Bigtable

**Certification Topics**:
- Section 1.2: Reliability and Fidelity (fault tolerance)
- Section 2.2: Building Pipelines (complex transformations)
- Section 5.5: Failure Mitigation (DLQ, retry logic)

**Skills Learned**:
- Event-driven architecture patterns
- Pub/Sub topic design
- Complex pipeline branching
- Dead letter queues
- Exactly-once semantics
- Cloud Functions integration
- Error handling strategies

**CLI Commands Covered**:
- `gcloud functions deploy`
- `gcloud pubsub topics/subscriptions create` (advanced config)
- Dataflow pipeline with multiple sinks

**Prerequisites**: Projects 0, 1, 2, 3, 4

---

### Project 6: Multi-Region DR & Security Hardening

**Duration**: Week 12 (10-12 hours)

**Goal**: Production-grade reliability and security

**What You'll Build**:
- Multi-region BigQuery dataset replication
- Disaster recovery procedures and runbooks
- PII detection with Cloud DLP
- Column-level encryption with Cloud KMS
- Row-level security policies in BigQuery
- Comprehensive audit logging
- Cost optimization:
  - BigQuery slots and reservations
  - Table lifecycle policies
  - Cost monitoring dashboards

**GCP Services**: All services with focus on security/operations

**Certification Topics**:
- Section 1.1: Security and Compliance (encryption, DLP, auditing)
- Section 1.2: Disaster recovery and fault tolerance
- Section 5.1: Resource Optimization (slots, reservations)
- Section 5.4: Monitoring and Troubleshooting (Cloud Logging)
- Section 5.5: Failure Mitigation (multi-region, replication)

**Skills Learned**:
- Cloud KMS key management
- Cloud DLP for PII detection
- Multi-region architecture
- Disaster recovery planning
- Security best practices
- Row-level security
- Audit log analysis
- Cost optimization strategies

**CLI Commands Covered**:
- `gcloud kms keyrings/keys create`
- `bq update --encryption_service_account` (CMEK)
- `gcloud dlp` commands
- `gcloud logging` (audit logs)
- `bq mk --reservation` (slot management)

**Prerequisites**: Projects 0-5

---

### Project 7: End-to-End Capstone - Data Marketplace

**Duration**: Weeks 13-14 (15-20 hours)

**Goal**: Combine everything into a production system

**What You'll Build**:
- Internal data marketplace with Analytics Hub
- Multiple data products (batch + streaming)
- Data sharing with external partners
- Automated data quality gates
- Full observability stack:
  - Cloud Monitoring dashboards
  - Custom metrics and alerts
  - Log-based metrics
- Infrastructure as Code (gcloud scripts)
- CI/CD pipeline with Cloud Build
- Comprehensive documentation

**GCP Services**: All services integrated + Analytics Hub, Cloud Build

**Certification Topics**:
- ALL certification topics integrated
- Section 4.3: Data Sharing (Analytics Hub)
- Section 2.3: CI/CD for data pipelines
- Section 5: Complete operations and maintenance

**Skills Learned**:
- Data marketplace concepts
- Analytics Hub setup
- Data sharing governance
- Complete observability
- Infrastructure automation
- CI/CD for data pipelines
- Production readiness checklist

**CLI Commands Covered**:
- `gcloud builds submit` (CI/CD)
- `gcloud bigquery datapolicies create` (Analytics Hub)
- Complete infrastructure automation scripts

**Prerequisites**: Projects 0-6

---

## Learning Path

### Recommended Order

**Phase 1: Foundations (Weeks 1-3)**
1. Project 0: Environment Setup
2. Project 1: Batch ETL Pipeline

**Phase 2: Advanced Processing (Weeks 4-7)**
3. Project 2: Real-Time Streaming
4. Project 3: Data Lake Integration

**Phase 3: Analytics & Warehousing (Weeks 8-11)**
5. Project 4: Star Schema Warehouse
6. Project 5: Event-Driven Platform

**Phase 4: Production Readiness (Weeks 12-14)**
7. Project 6: Security & DR
8. Project 7: End-to-End Capstone

### Time Commitment

- **Total Duration**: 12-14 weeks
- **Time per Week**: 8-12 hours
- **Total Hours**: 100-140 hours

### Flexibility

You can:
- Work at your own pace
- Skip projects if you have experience
- Revisit projects to deepen understanding
- Customize projects for your use cases

---

## Certification Coverage Matrix

| Project | Sec 1: Design | Sec 2: Pipelines | Sec 3: Storage | Sec 4: Analysis | Sec 5: Operations |
|---------|---------------|------------------|----------------|-----------------|-------------------|
| 0       | ✓✓            |                  |                |                 | ✓✓                |
| 1       | ✓             | ✓✓✓              | ✓✓             | ✓               | ✓                 |
| 2       | ✓             | ✓✓✓              | ✓              | ✓               | ✓                 |
| 3       | ✓✓✓           | ✓✓               | ✓✓✓            |                 | ✓                 |
| 4       | ✓             | ✓                | ✓✓✓            | ✓✓✓             | ✓✓                |
| 5       | ✓✓            | ✓✓               | ✓              |                 | ✓✓                |
| 6       | ✓✓✓           | ✓                | ✓              | ✓               | ✓✓✓               |
| 7       | ✓✓            | ✓✓               | ✓✓             | ✓✓              | ✓✓✓               |

Legend:
- ✓ = Touches on topic
- ✓✓ = Covers topic well
- ✓✓✓ = Deep dive into topic

---

## Project Structure

Every project follows this consistent structure:

```
projects/XX-project-name/
├── README.md                    # Project overview, objectives, instructions
├── setup.sh                     # Step-by-step gcloud setup commands
├── cleanup.sh                   # Resource cleanup (avoid costs!)
├── commands.md                  # Command reference with explanations
├── config/
│   ├── .env.template           # Configuration template
│   └── *.yaml                  # Service configurations
├── src/
│   ├── requirements.txt        # Python dependencies
│   ├── *.py                    # Python scripts/pipelines
│   └── tests/                  # Unit tests
├── sql/                         # SQL scripts
├── dags/                        # Airflow DAGs (if applicable)
└── docs/
    ├── architecture.md         # Architecture diagrams
    ├── lessons-learned.md      # Key takeaways
    └── troubleshooting.md      # Common issues

```

## What Makes This Different?

### Traditional Approach
- Read documentation
- Watch videos
- Take quiz
- Forget everything

### This Project-Based Approach
- Build real systems
- Use gcloud CLI (exam relevant)
- Solve actual problems
- Create portfolio work
- Remember through practice

---

## Prerequisites

### Required
- GCP account with $300 free credit
- Basic programming knowledge (Python)
- Command line familiarity
- Basic SQL knowledge

### Recommended
- Understanding of data concepts (ETL, databases)
- Git for version control
- Curiosity and willingness to learn!

---

## Cost Management

All projects are designed to be **cost-effective**:

- Use GCP free tier where possible
- Include cleanup scripts
- Provide cost estimates
- Teach cost optimization

**Expected total cost**: $50-100 for all projects (well within free credit)

---

## Getting Started

1. **Start with Project 0**: Set up your environment
2. **Work sequentially**: Each project builds on previous ones
3. **Read then do**: Read the README, then run commands
4. **Understand, don't copy**: Type commands yourself, understand what they do
5. **Experiment**: Modify projects, break things, learn!

---

## Support & Resources

### Official Resources
- [GCP Documentation](https://cloud.google.com/docs)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)
- [Professional Data Engineer Exam Guide](010-docs/professional_data_engineer_exam_guide_english.pdf)

### Community
- [GCP Reddit](https://www.reddit.com/r/googlecloud/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/google-cloud-platform)

### Getting Help
- Check `troubleshooting.md` in each project
- Review `commands.md` for explanations
- Search error messages in documentation
- Ask in GCP communities

---

## Success Metrics

By completing these projects, you will:

✅ Master gcloud CLI for data engineering
✅ Build production-ready data pipelines
✅ Understand all GCP data services
✅ Be prepared for the certification exam
✅ Have a portfolio of real projects
✅ Gain practical, hands-on experience
✅ Understand cost optimization
✅ Know security best practices

---

## Next Steps

Ready to begin?

**Start with [Project 0: GCP Environment Setup](projects/00-gcp-environment-setup/README.md)**

---

## Contributing

Found an issue or have a suggestion?
- This is a learning repository
- Feel free to adapt projects for your needs
- Share your learnings and improvements

---

## License

This learning material is for educational purposes.

---

**Happy learning! Build, break, learn, repeat. 🚀**
