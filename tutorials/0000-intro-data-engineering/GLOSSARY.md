# Data Engineering Glossary

Quick reference guide for common data engineering terms.

## Core Concepts

**Data Pipeline**
: A series of automated steps that move data from source to destination, transforming it along the way.

**ETL (Extract, Transform, Load)**
: Traditional data processing pattern where data is transformed before loading into the warehouse.

**ELT (Extract, Load, Transform)**
: Modern pattern where raw data is loaded first, then transformed in the warehouse.

**Data Warehouse**
: A centralized repository optimized for analytical queries (e.g., BigQuery, Snowflake, Redshift).

**Data Lake**
: A storage repository that holds raw data in its native format (e.g., Cloud Storage, S3, Azure Data Lake).

**Data Lakehouse**
: Combines features of data lakes and warehouses, offering both raw storage and analytical capabilities.

## Processing Types

**Batch Processing**
: Processing large volumes of data at scheduled intervals (hourly, daily, weekly).

**Stream Processing**
: Processing data continuously in real-time as it arrives.

**Micro-batch**
: Processing small batches of data frequently (every few seconds/minutes) to approximate streaming.

**CDC (Change Data Capture)**
: Tracking and capturing changes in a database to replicate them elsewhere.

## Data Modeling

**Schema**
: The structure of a database, defining tables, columns, data types, and relationships.

**Star Schema**
: A denormalized design with a central fact table surrounded by dimension tables.

**Snowflake Schema**
: Like star schema, but dimension tables are normalized into sub-dimensions.

**Fact Table**
: Contains measurable events or transactions (e.g., sales, clicks, orders).

**Dimension Table**
: Contains descriptive attributes about facts (e.g., customer details, product info, dates).

**Normalization**
: Organizing data to reduce duplication by splitting into multiple related tables.

**Denormalization**
: Combining tables to reduce joins and improve query performance (trades space for speed).

## Data Storage Concepts

**Partitioning**
: Dividing a large table into smaller pieces based on a column value (usually date).

**Clustering**
: Sorting and organizing data within partitions to improve query performance.

**Sharding**
: Distributing data across multiple databases or servers based on a key.

**Columnar Storage**
: Storing data by columns rather than rows (e.g., Parquet, ORC) - efficient for analytics.

**Row Storage**
: Traditional storage format where entire rows are stored together - efficient for transactions.

## Data Quality

**Data Validation**
: Checking that data meets expected formats, ranges, and business rules.

**Data Lineage**
: Tracking where data comes from and how it's transformed through pipelines.

**Data Catalog**
: A metadata repository documenting available datasets, their schemas, and ownership.

**Schema Evolution**
: Managing changes to data structure over time while maintaining compatibility.

## Pipeline Orchestration

**DAG (Directed Acyclic Graph)**
: A workflow representation showing task dependencies without circular loops.

**Idempotency**
: A pipeline that produces the same result when run multiple times with the same input.

**Backfill**
: Re-running pipelines for historical dates to fill in missing or corrected data.

**Incremental Load**
: Processing only new or changed data since the last run.

**Full Load**
: Processing the entire dataset every time.

## GCP-Specific Terms

**BigQuery**
: Google's serverless, highly scalable data warehouse.

**Pub/Sub**
: Messaging service for streaming analytics and event-driven systems.

**Dataflow**
: Fully managed service for stream and batch data processing (based on Apache Beam).

**Dataproc**
: Managed Spark and Hadoop service for big data processing.

**Cloud Composer**
: Managed Apache Airflow for workflow orchestration.

**Datastream**
: Serverless change data capture (CDC) and replication service.

**Dataplex**
: Unified data management across data lakes and warehouses.

**Bigtable**
: NoSQL wide-column database for large analytical and operational workloads.

**Spanner**
: Globally distributed, strongly consistent relational database.

**Cloud Storage**
: Object storage service (equivalent to AWS S3).

**BigQuery ML (BQML)**
: Create and execute machine learning models using SQL in BigQuery.

**Looker**
: Business intelligence and analytics platform.

## Performance & Optimization

**Query Optimization**
: Techniques to make queries run faster (filtering early, avoiding SELECT *, using partitions).

**Materialized View**
: A pre-computed query result stored as a table for faster access.

**Caching**
: Storing frequently accessed data in fast storage to reduce latency.

**Slot**
: Unit of computational capacity in BigQuery (like CPU for queries).

**Reservation**
: Pre-purchased BigQuery slots for predictable pricing and performance.

## Data Formats

**CSV (Comma-Separated Values)**
: Simple text format with values separated by commas.

**JSON (JavaScript Object Notation)**
: Flexible text format for nested/hierarchical data.

**Avro**
: Row-based binary format with schema evolution support.

**Parquet**
: Columnar binary format optimized for analytics, highly compressed.

**ORC (Optimized Row Columnar)**
: Columnar format optimized for Hadoop ecosystem.

**Protocol Buffers (Protobuf)**
: Binary serialization format developed by Google.

## Architecture Patterns

**Lambda Architecture**
: Combines batch and stream processing with separate paths, merged at serving layer.

**Kappa Architecture**
: Everything is a stream - single processing path for both real-time and batch.

**Medallion Architecture (Bronze/Silver/Gold)**
: Data refinement layers - raw → cleaned → business-level aggregates.

**SCD (Slowly Changing Dimension)**
: Strategies for handling dimension data that changes over time:
- Type 1: Overwrite old value
- Type 2: Add new row with version/date range
- Type 3: Add new column for previous value

## Monitoring & Operations

**SLA (Service Level Agreement)**
: Commitment to specific performance metrics (e.g., 99.9% uptime).

**SLO (Service Level Objective)**
: Target for a specific metric (e.g., queries complete in < 5 seconds).

**SLI (Service Level Indicator)**
: Actual measured metric used to track SLO.

**Alert/Notification**
: Automated message when a metric crosses a threshold.

**Dead Letter Queue**
: Holds messages that couldn't be processed after multiple retries.

**Circuit Breaker**
: Pattern that stops requests to a failing service to prevent cascade failures.

## Security & Compliance

**IAM (Identity and Access Management)**
: System for managing who can access what resources.

**Encryption at Rest**
: Encrypting data when stored on disk.

**Encryption in Transit**
: Encrypting data while moving across networks.

**PII (Personally Identifiable Information)**
: Data that can identify an individual (name, email, SSN, etc.).

**Data Masking**
: Hiding sensitive data by replacing it with realistic but fake values.

**DLP (Data Loss Prevention)**
: Tools to detect and protect sensitive information.

**GDPR**
: European regulation for data privacy and protection.

## Common Acronyms

- **OLTP**: Online Transaction Processing (operational databases)
- **OLAP**: Online Analytical Processing (data warehouses)
- **ACID**: Atomicity, Consistency, Isolation, Durability (database transaction properties)
- **CAP**: Consistency, Availability, Partition tolerance (distributed systems theorem)
- **RTO**: Recovery Time Objective (max acceptable downtime)
- **RPO**: Recovery Point Objective (max acceptable data loss)
- **BI**: Business Intelligence
- **ML**: Machine Learning
- **AI**: Artificial Intelligence
- **API**: Application Programming Interface
- **SDK**: Software Development Kit
- **CLI**: Command Line Interface

## Quick Tips

**When to use what:**
- **BigQuery**: Analytics on structured data, any size
- **Bigtable**: High-throughput NoSQL, time-series, IoT
- **Spanner**: Global relational database with strong consistency
- **Cloud SQL**: Traditional relational DB for moderate scale
- **Cloud Storage**: Object storage, data lake, file storage
- **Pub/Sub**: Event streaming, real-time messaging
- **Dataflow**: Complex transformations, streaming pipelines
- **Dataproc**: Existing Spark/Hadoop workloads

**Data formats:**
- **CSV**: Simple, human-readable, but slow and large
- **JSON**: Flexible, nested data, but inefficient for analytics
- **Parquet**: Best for analytics (columnar, compressed, fast)
- **Avro**: Good for streaming, schema evolution

**Processing choice:**
- **Batch**: Historical analysis, reports, large transformations
- **Streaming**: Real-time alerts, live dashboards, immediate actions

---

Keep this glossary handy as you work through the tutorials. Bookmark terms you encounter frequently!
