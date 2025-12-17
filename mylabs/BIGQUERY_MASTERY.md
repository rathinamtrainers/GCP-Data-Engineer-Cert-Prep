# BigQuery Mastery Roadmap

## Complete Study Guide with Hands-On Labs

**Learning Approach**: gcloud CLI + Python + BigQuery Console
**Prerequisites**: GCP Project with billing enabled, Python 3.9+, gcloud CLI installed

---

## Module 1: Foundations (Week 1-2)

### 1.1 Core Concepts

| Topic                    | Key Learning Points                                        |
| ------------------------ | ---------------------------------------------------------- |
| Architecture             | Dremel execution engine, Colossus storage, Jupiter network |
| Slots                    | Query processing units, on-demand vs capacity pricing      |
| Projects/Datasets/Tables | Resource hierarchy and organization                        |
| Jobs                     | Query, load, extract, copy job types                       |

### 1.2 Getting Started

| Topic              | Practice                                |
| ------------------ | --------------------------------------- |
| Console navigation | Create dataset, run query, view results |
| `bq` CLI           | `bq query`, `bq mk`, `bq ls`, `bq show` |
| Client libraries   | Python `google-cloud-bigquery` basics   |
| Authentication     | ADC, service accounts, IAM roles        |

### 1.3 Basic SQL

| Topic                    | Skills                          |
| ------------------------ | ------------------------------- |
| SELECT, FROM, WHERE      | Basic queries                   |
| GROUP BY, ORDER BY       | Aggregations                    |
| JOIN types               | INNER, LEFT, RIGHT, FULL, CROSS |
| UNION, INTERSECT, EXCEPT | Set operations                  |

### Labs - Module 1

| Lab # | Title                 | Tools       | Description                                                     |
| ----- | --------------------- | ----------- | --------------------------------------------------------------- |
| 1.1   | Environment Setup     | gcloud, bq  | Configure authentication, set default project, verify access    |
| 1.2   | Dataset Operations    | bq CLI      | Create, list, describe, and delete datasets                     |
| 1.3   | First Query           | bq CLI      | Query public dataset `bigquery-public-data.samples.shakespeare` |
| 1.4   | Python Client Basics  | Python      | Install library, authenticate, run first query                  |
| 1.5   | Query Public Datasets | Python      | Explore `bigquery-public-data.usa_names.usa_1910_2013`          |
| 1.6   | Basic Aggregations    | bq + Python | GROUP BY, COUNT, SUM, AVG on public data                        |
| 1.7   | JOIN Operations       | bq + Python | Join multiple public tables                                     |
| 1.8   | Job Management        | bq + Python | List jobs, get job details, cancel jobs                         |

---

## Module 2: Data Storage (Week 3-4)

### 2.1 Table Types

| Type               | When to Use                              |
| ------------------ | ---------------------------------------- |
| Native tables      | Standard managed storage                 |
| External tables    | Query data in GCS, Drive, Bigtable       |
| Partitioned tables | Time/integer/ingestion-time partitioning |
| Clustered tables   | Frequently filtered columns              |
| Materialized views | Pre-computed aggregations                |
| Table snapshots    | Point-in-time backups                    |
| Table clones       | Zero-copy duplicates                     |

### 2.2 Schema Design

| Topic                  | Details                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------ |
| Data types             | STRING, INT64, FLOAT64, BOOL, TIMESTAMP, DATE, BYTES, GEOGRAPHY, JSON, STRUCT, ARRAY |
| Nested/Repeated fields | STRUCT and ARRAY usage                                                               |
| Schema evolution       | Adding columns, relaxing modes                                                       |
| Column modes           | NULLABLE, REQUIRED, REPEATED                                                         |

### 2.3 Partitioning Strategies

| Strategy                        | Use Case                    |
| ------------------------------- | --------------------------- |
| Time-unit (DAY/HOUR/MONTH/YEAR) | Time-series data            |
| Integer range                   | Non-date partition keys     |
| Ingestion time                  | Auto-partition by load time |
| Partition expiration            | Auto-delete old data        |
| Partition pruning               | Query optimization          |

### 2.4 Clustering

| Topic                        | Details                                |
| ---------------------------- | -------------------------------------- |
| Cluster columns (up to 4)    | Choose high-cardinality filter columns |
| Clustering with partitioning | Combine for maximum efficiency         |
| Auto re-clustering           | Background optimization                |

### Labs - Module 2

| Lab # | Title                       | Tools       | Description                                  |
| ----- | --------------------------- | ----------- | -------------------------------------------- |
| 2.1   | Create Tables with Schema   | bq CLI      | Create table with JSON schema file           |
| 2.2   | Table Operations            | bq + Python | Create, copy, delete tables programmatically |
| 2.3   | Schema from JSON            | Python      | Define and apply schemas using Python        |
| 2.4   | Nested & Repeated Fields    | bq + Python | Create tables with STRUCT and ARRAY columns  |
| 2.5   | Time Partitioned Table      | bq CLI      | Create DAY/HOUR/MONTH partitioned tables     |
| 2.6   | Integer Range Partitioning  | bq CLI      | Partition by integer ranges                  |
| 2.7   | Ingestion Time Partitioning | bq + Python | Auto-partition on load                       |
| 2.8   | Clustered Tables            | bq CLI      | Create and query clustered tables            |
| 2.9   | Partition + Clustering      | bq + Python | Combine strategies for optimization          |
| 2.10  | Table Snapshots             | bq CLI      | Create and restore from snapshots            |
| 2.11  | Table Clones                | bq CLI      | Create zero-copy clones                      |
| 2.12  | External Tables (GCS)       | bq + Python | Query CSV/Parquet in Cloud Storage           |
| 2.13  | Materialized Views          | bq CLI      | Create and auto-refresh materialized views   |
| 2.14  | Schema Evolution            | Python      | Add columns, relax column modes              |

---

## Module 3: Data Ingestion (Week 5-6)

### 3.1 Batch Loading

| Method                | Format Support                               |
| --------------------- | -------------------------------------------- |
| `bq load`             | CSV, JSON, Avro, Parquet, ORC                |
| Cloud Storage         | Wildcard URIs, folder loads                  |
| Load jobs             | Schema auto-detection, append/truncate modes |
| Data Transfer Service | Scheduled, managed transfers                 |

### 3.2 Streaming Ingestion

| Method               | Characteristics                         |
| -------------------- | --------------------------------------- |
| Storage Write API    | High throughput, exactly-once semantics |
| Legacy streaming API | `insertAll`, deprecated but common      |
| Dataflow → BigQuery  | Apache Beam BigQueryIO                  |
| Pub/Sub → BigQuery   | Subscriptions direct to BigQuery        |

### 3.3 External Data Sources

| Source        | Connection Method                  |
| ------------- | ---------------------------------- |
| Cloud Storage | External tables, federated queries |
| Google Drive  | Sheets, CSV files                  |
| Bigtable      | External connection                |
| Spanner       | Federated queries                  |
| Cloud SQL     | External connection                |
| AWS S3        | BigQuery Omni                      |
| Azure Blob    | BigQuery Omni                      |

### 3.4 Data Transfer Service

| Source Type       | Examples                              |
| ----------------- | ------------------------------------- |
| SaaS applications | Google Ads, YouTube, Campaign Manager |
| Cloud Storage     | Scheduled loads                       |
| Amazon S3         | Cross-cloud transfers                 |
| Teradata/Redshift | Data warehouse migrations             |

### Labs - Module 3

| Lab # | Title                            | Tools            | Description                           |
| ----- | -------------------------------- | ---------------- | ------------------------------------- |
| 3.1   | Load CSV from Local              | bq CLI           | Load local CSV file to BigQuery       |
| 3.2   | Load JSON (Newline Delimited)    | bq CLI           | Load NDJSON files                     |
| 3.3   | Load from GCS                    | bq + Python      | Load files from Cloud Storage bucket  |
| 3.4   | Load Parquet Files               | bq + Python      | Load columnar format data             |
| 3.5   | Load Avro Files                  | bq CLI           | Load Avro with automatic schema       |
| 3.6   | Schema Auto-Detection            | bq + Python      | Let BigQuery infer schema             |
| 3.7   | Wildcard Loads                   | bq CLI           | Load multiple files with URI patterns |
| 3.8   | Append vs Truncate               | Python           | Different write dispositions          |
| 3.9   | Streaming Insert (Legacy)        | Python           | Use `insert_rows_json()` method       |
| 3.10  | Storage Write API                | Python           | High-throughput streaming ingestion   |
| 3.11  | Storage Write API - Exactly Once | Python           | Committed streams for exactly-once    |
| 3.12  | Export to GCS                    | bq + Python      | Export table to CSV/JSON/Avro/Parquet |
| 3.13  | Data Transfer Service Setup      | gcloud           | Configure scheduled transfers         |
| 3.14  | GCS Scheduled Transfer           | gcloud + Console | Automate GCS to BigQuery loads        |
| 3.15  | Federated Query - GCS            | bq + Python      | Query external data without loading   |

---

## Module 4: GoogleSQL Deep Dive (Week 7-9)

### 4.1 Standard Functions

| Category  | Key Functions                                                             |
| --------- | ------------------------------------------------------------------------- |
| String    | `CONCAT`, `SUBSTR`, `REGEXP_EXTRACT`, `SPLIT`, `TRIM`, `FORMAT`           |
| Date/Time | `DATE_DIFF`, `DATE_TRUNC`, `EXTRACT`, `FORMAT_TIMESTAMP`, `PARSE_DATE`    |
| Math      | `ROUND`, `CEIL`, `FLOOR`, `MOD`, `POWER`, `LOG`, `SQRT`                   |
| Aggregate | `SUM`, `AVG`, `COUNT`, `MIN`, `MAX`, `COUNTIF`, `STRING_AGG`, `ARRAY_AGG` |

### 4.2 Advanced Functions

| Category         | Key Functions                                                                               |
| ---------------- | ------------------------------------------------------------------------------------------- |
| Window functions | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`, `NTH_VALUE` |
| Window frames    | `ROWS BETWEEN`, `RANGE BETWEEN`                                                             |
| Analytic         | `PERCENTILE_CONT`, `NTILE`, `CUME_DIST`                                                     |
| Navigation       | `OVER (PARTITION BY ... ORDER BY ...)`                                                      |

### 4.3 Complex Data Types

| Type      | Operations                                                   |
| --------- | ------------------------------------------------------------ |
| ARRAY     | `ARRAY_AGG`, `UNNEST`, `ARRAY_LENGTH`, `ARRAY_TO_STRING`     |
| STRUCT    | Dot notation, nested queries                                 |
| JSON      | `JSON_EXTRACT`, `JSON_VALUE`, `JSON_QUERY`, native JSON type |
| GEOGRAPHY | `ST_GEOGPOINT`, `ST_DISTANCE`, `ST_WITHIN`, `ST_AREA`        |

### 4.4 Advanced SQL Features

| Feature                       | Usage                         |
| ----------------------------- | ----------------------------- |
| CTEs (WITH clause)            | Readable complex queries      |
| Recursive CTEs                | Hierarchical data             |
| PIVOT / UNPIVOT               | Row-column transformations    |
| TABLESAMPLE                   | Random sampling               |
| Scripting                     | DECLARE, SET, IF, LOOP, WHILE |
| Stored procedures             | CREATE PROCEDURE              |
| UDFs (User-Defined Functions) | SQL and JavaScript UDFs       |
| Table functions (TVFs)        | Parameterized views           |

### 4.5 DML Operations

| Operation | Command                            |
| --------- | ---------------------------------- |
| INSERT    | `INSERT INTO table VALUES/SELECT`  |
| UPDATE    | `UPDATE table SET col = val WHERE` |
| DELETE    | `DELETE FROM table WHERE`          |
| MERGE     | Upsert operations                  |
| TRUNCATE  | Fast table clearing                |

### Labs - Module 4

| Lab # | Title                        | Tools       | Description                                     |
| ----- | ---------------------------- | ----------- | ----------------------------------------------- |
| 4.1   | String Functions             | bq + Python | Text manipulation with CONCAT, SUBSTR, REGEXP   |
| 4.2   | Date/Time Functions          | bq + Python | DATE_DIFF, DATE_TRUNC, EXTRACT, timezones       |
| 4.3   | Math & Statistical Functions | bq CLI      | Aggregations, STDDEV, CORR, percentiles         |
| 4.4   | Window Functions - Ranking   | bq + Python | ROW_NUMBER, RANK, DENSE_RANK, NTILE             |
| 4.5   | Window Functions - Analytics | bq + Python | LAG, LEAD, FIRST_VALUE, LAST_VALUE              |
| 4.6   | Window Frames                | bq CLI      | ROWS BETWEEN, RANGE BETWEEN, running totals     |
| 4.7   | Working with ARRAYs          | bq + Python | ARRAY_AGG, UNNEST, ARRAY functions              |
| 4.8   | Working with STRUCTs         | bq + Python | Nested data queries                             |
| 4.9   | ARRAY + STRUCT Combined      | bq + Python | Complex nested/repeated structures              |
| 4.10  | JSON Functions               | bq + Python | JSON_EXTRACT, JSON_VALUE, native JSON           |
| 4.11  | Geospatial Queries           | bq + Python | ST_GEOGPOINT, ST_DISTANCE, geography operations |
| 4.12  | CTEs and Subqueries          | bq + Python | WITH clause, correlated subqueries              |
| 4.13  | Recursive CTEs               | bq CLI      | Hierarchical data traversal                     |
| 4.14  | PIVOT and UNPIVOT            | bq CLI      | Transform rows to columns and vice versa        |
| 4.15  | INSERT Operations            | bq + Python | Insert rows from values and SELECT              |
| 4.16  | UPDATE Operations            | bq + Python | Update existing records                         |
| 4.17  | DELETE Operations            | bq + Python | Delete with conditions                          |
| 4.18  | MERGE (Upsert)               | bq + Python | Insert or update based on conditions            |
| 4.19  | SQL UDFs                     | bq CLI      | Create and use SQL user-defined functions       |
| 4.20  | JavaScript UDFs              | bq CLI      | Create JavaScript UDFs for complex logic        |
| 4.21  | Stored Procedures            | bq + Python | Create and call stored procedures               |
| 4.22  | Scripting Basics             | bq CLI      | Variables, IF/ELSE, loops                       |
| 4.23  | Table-Valued Functions       | bq CLI      | Create parameterized views                      |

---

## Module 5: Performance Optimization (Week 10-11)

### 5.1 Query Optimization

| Technique             | Impact                                      |
| --------------------- | ------------------------------------------- |
| Partition pruning     | Query only needed partitions                |
| Cluster filtering     | Filter on clustered columns                 |
| Avoid SELECT *        | Query only needed columns                   |
| Approximate functions | `APPROX_COUNT_DISTINCT`, `APPROX_QUANTILES` |
| Anti-patterns         | Avoid CROSS JOIN, excessive subqueries      |

### 5.2 Execution Plan Analysis

| Tool                   | Purpose                   |
| ---------------------- | ------------------------- |
| Query plan explanation | EXPLAIN statement         |
| Execution details      | Job information panel     |
| Slot utilization       | INFORMATION_SCHEMA.JOBS   |
| Stage-level metrics    | Bytes shuffled, slot time |

### 5.3 Caching & Materialization

| Feature            | Benefit                                 |
| ------------------ | --------------------------------------- |
| Query cache        | Free repeated identical queries (24h)   |
| Materialized views | Pre-computed aggregations, auto-refresh |
| BI Engine          | In-memory acceleration                  |
| Cached queries     | `--use_cache` flag                      |

### 5.4 Capacity Management

| Concept           | Details                        |
| ----------------- | ------------------------------ |
| On-demand pricing | Pay per TB scanned             |
| Capacity pricing  | Reserved slots (flat-rate)     |
| Reservations      | Slot pools for workloads       |
| Assignments       | Project-to-reservation mapping |
| Autoscaling       | Dynamic slot allocation        |

### Labs - Module 5

| Lab # | Title                         | Tools       | Description                                  |
| ----- | ----------------------------- | ----------- | -------------------------------------------- |
| 5.1   | Query Execution Plan          | bq CLI      | Use EXPLAIN to analyze query plans           |
| 5.2   | Partition Pruning             | bq + Python | Compare costs with/without partition filters |
| 5.3   | Cluster Optimization          | bq + Python | Measure clustering effectiveness             |
| 5.4   | Column Pruning                | bq CLI      | Compare SELECT * vs specific columns         |
| 5.5   | Approximate Functions         | bq CLI      | APPROX_COUNT_DISTINCT vs COUNT(DISTINCT)     |
| 5.6   | Query Anti-Patterns           | bq CLI      | Identify and fix inefficient queries         |
| 5.7   | INFORMATION_SCHEMA.JOBS       | bq + Python | Analyze historical query performance         |
| 5.8   | Slot Utilization Analysis     | Python      | Query slot usage patterns                    |
| 5.9   | Query Cache Behavior          | bq CLI      | Test caching, understand cache invalidation  |
| 5.10  | Materialized View Performance | bq CLI      | Compare MV vs regular queries                |
| 5.11  | Cost Estimation               | bq + Python | Dry run queries, estimate bytes processed    |
| 5.12  | Query Optimization Challenge  | bq + Python | Optimize a poorly performing query           |

---

## Module 6: BigQuery ML (Week 12-14)

### 6.1 Model Types

| Category             | Models                                                                    |
| -------------------- | ------------------------------------------------------------------------- |
| Linear               | `LINEAR_REG`, `LOGISTIC_REG`                                              |
| Tree-based           | `BOOSTED_TREE_CLASSIFIER/REGRESSOR`, `RANDOM_FOREST_CLASSIFIER/REGRESSOR` |
| Deep learning        | `DNN_CLASSIFIER/REGRESSOR`, `DNN_LINEAR_COMBINED`                         |
| Clustering           | `KMEANS`                                                                  |
| Time series          | `ARIMA_PLUS`, `ARIMA_PLUS_XREG`                                           |
| Matrix factorization | `MATRIX_FACTORIZATION`                                                    |
| Imported models      | TensorFlow, ONNX, XGBoost                                                 |

### 6.2 ML Workflow

| Stage               | SQL Commands                |
| ------------------- | --------------------------- |
| Create model        | `CREATE MODEL` with OPTIONS |
| Evaluate            | `ML.EVALUATE()`             |
| Predict             | `ML.PREDICT()`              |
| Feature importance  | `ML.FEATURE_IMPORTANCE()`   |
| Explain predictions | `ML.EXPLAIN_PREDICT()`      |
| Export model        | `ML.EXPORT_MODEL()`         |

### 6.3 Feature Engineering

| Function                | Purpose                        |
| ----------------------- | ------------------------------ |
| `ML.FEATURE_INFO`       | Feature statistics             |
| `ML.TRANSFORM`          | Feature transformation clauses |
| `ML.BUCKETIZE`          | Binning continuous values      |
| `ML.POLYNOMIAL_EXPAND`  | Polynomial features            |
| `ML.QUANTILE_BUCKETIZE` | Quantile-based binning         |
| `ML.STANDARD_SCALER`    | Standardization                |
| `ML.MIN_MAX_SCALER`     | Normalization                  |

### 6.4 Advanced ML Features

| Feature               | Description                  |
| --------------------- | ---------------------------- |
| Hyperparameter tuning | `NUM_TRIALS`, `HPARAM_RANGE` |
| Model registry        | Vertex AI integration        |
| Model versioning      | Replace models               |
| Remote models         | Call Vertex AI models        |

### Labs - Module 6

| Lab # | Title                     | Tools       | Description                                 |
| ----- | ------------------------- | ----------- | ------------------------------------------- |
| 6.1   | Linear Regression         | bq + Python | Predict numerical values                    |
| 6.2   | Logistic Regression       | bq + Python | Binary classification                       |
| 6.3   | Multiclass Classification | bq CLI      | Multi-label classification                  |
| 6.4   | K-Means Clustering        | bq + Python | Customer segmentation                       |
| 6.5   | Boosted Tree Classifier   | bq CLI      | Tree-based classification                   |
| 6.6   | Boosted Tree Regressor    | bq CLI      | Tree-based regression                       |
| 6.7   | Random Forest Models      | bq CLI      | Ensemble tree models                        |
| 6.8   | DNN Classifier            | bq CLI      | Deep neural network classification          |
| 6.9   | ARIMA Time Series         | bq + Python | Time series forecasting                     |
| 6.10  | ARIMA_PLUS Advanced       | bq + Python | Forecasting with holidays, seasonality      |
| 6.11  | Matrix Factorization      | bq CLI      | Recommendation systems                      |
| 6.12  | Model Evaluation          | bq + Python | ML.EVALUATE for all model types             |
| 6.13  | Feature Importance        | bq + Python | ML.FEATURE_IMPORTANCE analysis              |
| 6.14  | Explain Predictions       | bq + Python | ML.EXPLAIN_PREDICT for interpretability     |
| 6.15  | Feature Engineering       | bq CLI      | Transform clause, bucketizing, scaling      |
| 6.16  | Hyperparameter Tuning     | bq CLI      | NUM_TRIALS, HPARAM_RANGE options            |
| 6.17  | Export Model to GCS       | bq + Python | ML.EXPORT_MODEL for deployment              |
| 6.18  | Import TensorFlow Model   | bq CLI      | Use external TF models in BigQuery          |
| 6.19  | End-to-End ML Pipeline    | Python      | Complete workflow: train, evaluate, predict |

---

## Module 7: AI & Generative AI (Week 15-16)

### 7.1 Generative AI Functions

| Function                | Purpose             |
| ----------------------- | ------------------- |
| `ML.GENERATE_TEXT`      | LLM text generation |
| `ML.UNDERSTAND_TEXT`    | Text analysis       |
| `ML.GENERATE_EMBEDDING` | Text embeddings     |
| `ML.ANNOTATE_IMAGE`     | Image analysis      |

### 7.2 Vector Search

| Feature           | Usage                          |
| ----------------- | ------------------------------ |
| Vector index      | `CREATE VECTOR INDEX`          |
| Vector search     | `VECTOR_SEARCH()` function     |
| Distance metrics  | Cosine, Euclidean, DOT_PRODUCT |
| Embedding storage | ARRAY<FLOAT64> columns         |

### 7.3 Remote Models

| Integration       | Purpose                      |
| ----------------- | ---------------------------- |
| Vertex AI         | Access Gemini, PaLM models   |
| Cloud AI Platform | Custom deployed models       |
| Remote functions  | External inference endpoints |

### Labs - Module 7

| Lab # | Title                   | Tools       | Description                                  |
| ----- | ----------------------- | ----------- | -------------------------------------------- |
| 7.1   | Remote Model Connection | bq CLI      | Create connection to Vertex AI               |
| 7.2   | Text Generation         | bq + Python | ML.GENERATE_TEXT with Gemini                 |
| 7.3   | Text Embeddings         | bq + Python | ML.GENERATE_EMBEDDING for text               |
| 7.4   | Vector Table Setup      | bq CLI      | Create table with embedding column           |
| 7.5   | Vector Index Creation   | bq CLI      | CREATE VECTOR INDEX for similarity search    |
| 7.6   | Vector Search Queries   | bq + Python | VECTOR_SEARCH for semantic similarity        |
| 7.7   | RAG Pattern             | bq + Python | Retrieval Augmented Generation with BigQuery |
| 7.8   | Text Analysis           | bq + Python | Sentiment analysis, entity extraction        |
| 7.9   | Image Analysis          | bq CLI      | ML.ANNOTATE_IMAGE for image understanding    |
| 7.10  | Semantic Search App     | Python      | End-to-end semantic search application       |

---

## Module 8: Security & Governance (Week 17-18)

### 8.1 Access Control

| Level         | Mechanism                                            |
| ------------- | ---------------------------------------------------- |
| Project-level | IAM roles (BigQuery Admin, User, Data Editor/Viewer) |
| Dataset-level | Dataset permissions                                  |
| Table-level   | Table ACLs                                           |
| Column-level  | Policy tags                                          |
| Row-level     | Row access policies                                  |

### 8.2 Data Protection

| Feature               | Purpose                          |
| --------------------- | -------------------------------- |
| Column-level security | Restrict column access           |
| Row-level security    | Filter rows by user              |
| Data masking          | Dynamic masking rules            |
| VPC Service Controls  | Network-level isolation          |
| CMEK                  | Customer-managed encryption keys |

### 8.3 Data Governance

| Feature                  | Purpose                      |
| ------------------------ | ---------------------------- |
| Data Catalog             | Metadata discovery           |
| Policy tags              | Classification taxonomy      |
| Data lineage             | Track data flow              |
| Audit logs               | Cloud Audit Logs integration |
| Sensitive data discovery | DLP integration              |

### 8.4 Compliance

| Topic                | Details                    |
| -------------------- | -------------------------- |
| Data residency       | Regional datasets          |
| Differential privacy | Privacy-preserving queries |
| Authorized views     | Controlled data sharing    |
| Authorized datasets  | Cross-project access       |

### Labs - Module 8

| Lab # | Title                          | Tools           | Description                            |
| ----- | ------------------------------ | --------------- | -------------------------------------- |
| 8.1   | IAM Roles Overview             | gcloud          | List and understand BigQuery IAM roles |
| 8.2   | Dataset-Level Permissions      | bq + gcloud     | Grant/revoke dataset access            |
| 8.3   | Table-Level ACLs               | bq + Python     | Fine-grained table permissions         |
| 8.4   | Authorized Views               | bq CLI          | Create views with elevated access      |
| 8.5   | Policy Tags Setup              | gcloud          | Create taxonomy and policy tags        |
| 8.6   | Column-Level Security          | bq + gcloud     | Restrict access to sensitive columns   |
| 8.7   | Row-Level Security             | bq CLI          | CREATE ROW ACCESS POLICY               |
| 8.8   | Data Masking                   | bq + gcloud     | Dynamic data masking rules             |
| 8.9   | Audit Logs Analysis            | bq + Python     | Query BigQuery audit logs              |
| 8.10  | Data Catalog Integration       | gcloud          | Tag and discover data assets           |
| 8.11  | CMEK Setup                     | gcloud          | Customer-managed encryption keys       |
| 8.12  | Service Account Best Practices | gcloud + Python | Secure service account usage           |

---

## Module 9: Administration & Operations (Week 19-20)

### 9.1 Resource Management

| Task                | Method                  |
| ------------------- | ----------------------- |
| Slot reservations   | Create/manage capacity  |
| Workload management | Reservation assignments |
| Query queues        | Job prioritization      |
| Quotas              | Project-level limits    |

### 9.2 Monitoring

| Tool               | Metrics                          |
| ------------------ | -------------------------------- |
| Cloud Monitoring   | Slot usage, query count, storage |
| INFORMATION_SCHEMA | Jobs, tables, views metadata     |
| Audit Logs         | Query history, admin actions     |
| Stackdriver        | Alerts and dashboards            |

### 9.3 INFORMATION_SCHEMA Views

| View                               | Information     |
| ---------------------------------- | --------------- |
| `INFORMATION_SCHEMA.JOBS`          | Query history   |
| `INFORMATION_SCHEMA.TABLES`        | Table metadata  |
| `INFORMATION_SCHEMA.COLUMNS`       | Column details  |
| `INFORMATION_SCHEMA.PARTITIONS`    | Partition info  |
| `INFORMATION_SCHEMA.RESERVATIONS`  | Capacity info   |
| `INFORMATION_SCHEMA.TABLE_STORAGE` | Storage metrics |

### 9.4 Cost Control

| Method               | Implementation                  |
| -------------------- | ------------------------------- |
| Custom cost controls | Maximum bytes billed            |
| Quotas               | Daily query limits              |
| Slot commitments     | Predictable costs               |
| Storage optimization | Partition expiration, lifecycle |

### Labs - Module 9

| Lab # | Title                        | Tools       | Description                           |
| ----- | ---------------------------- | ----------- | ------------------------------------- |
| 9.1   | INFORMATION_SCHEMA Deep Dive | bq + Python | Query all metadata views              |
| 9.2   | Jobs Metadata Analysis       | Python      | Analyze query patterns, costs         |
| 9.3   | Storage Analysis             | bq + Python | TABLE_STORAGE, optimize storage costs |
| 9.4   | Slot Reservations            | bq CLI      | Create and manage reservations        |
| 9.5   | Reservation Assignments      | bq CLI      | Assign projects to reservations       |
| 9.6   | Cost Controls Setup          | bq + Python | Maximum bytes billed per query        |
| 9.7   | Quota Management             | gcloud      | View and request quota changes        |
| 9.8   | Cloud Monitoring Dashboard   | gcloud      | Create BigQuery monitoring dashboard  |
| 9.9   | Alerting Setup               | gcloud      | Alert on query costs, failures        |
| 9.10  | Scheduled Queries            | bq + Python | Automate recurring queries            |
| 9.11  | Query Prioritization         | bq CLI      | Job priority and queue management     |
| 9.12  | Cost Optimization Audit      | Python      | Comprehensive cost analysis script    |

---

## Module 10: Integration & Ecosystem (Week 21-22)

### 10.1 ETL/ELT Tools

| Tool           | Integration         |
| -------------- | ------------------- |
| Dataflow       | BigQueryIO (Beam)   |
| Dataproc       | BigQuery connectors |
| Cloud Composer | BigQuery operators  |
| Dataform       | SQL transformations |
| dbt            | Third-party support |

### 10.2 BI Tools

| Tool          | Connection        |
| ------------- | ----------------- |
| Looker        | Native connector  |
| Looker Studio | Direct connection |
| Google Sheets | Connected Sheets  |
| Tableau       | JDBC/ODBC drivers |
| Power BI      | ODBC driver       |

### 10.3 Analytics Hub

| Feature         | Purpose                    |
| --------------- | -------------------------- |
| Data exchanges  | Publish/subscribe datasets |
| Shared datasets | Cross-org data sharing     |
| Listings        | Data marketplace           |
| Linked datasets | Zero-copy sharing          |

### 10.4 BigQuery Omni

| Feature               | Description                  |
| --------------------- | ---------------------------- |
| Multi-cloud           | Query AWS S3, Azure Blob     |
| Cross-cloud analytics | Unified queries              |
| BigLake               | Open format table management |

### Labs - Module 10

| Lab # | Title                    | Tools            | Description                         |
| ----- | ------------------------ | ---------------- | ----------------------------------- |
| 10.1  | Dataflow to BigQuery     | Python (Beam)    | Stream/batch data with Apache Beam  |
| 10.2  | Dataproc + BigQuery      | gcloud + PySpark | Spark jobs reading/writing BigQuery |
| 10.3  | Cloud Composer DAG       | Python (Airflow) | Orchestrate BigQuery workflows      |
| 10.4  | Dataform Basics          | gcloud + SQL     | SQL-based transformations           |
| 10.5  | Connected Sheets         | Console          | Query BigQuery from Google Sheets   |
| 10.6  | Looker Studio Dashboard  | Console          | Build dashboard on BigQuery data    |
| 10.7  | BigQuery API             | Python           | REST API operations                 |
| 10.8  | Analytics Hub Publisher  | gcloud           | Publish dataset to exchange         |
| 10.9  | Analytics Hub Subscriber | gcloud           | Subscribe to shared datasets        |
| 10.10 | BigLake Tables           | bq CLI           | Manage open format tables           |
| 10.11 | Cross-Region Queries     | bq CLI           | Query across dataset locations      |

---

## Module 11: Advanced Topics (Week 23-24)

### 11.1 Scripting & Procedures

| Feature            | Usage                                     |
| ------------------ | ----------------------------------------- |
| Variables          | `DECLARE`, `SET`                          |
| Control flow       | `IF`, `LOOP`, `WHILE`, `ITERATE`, `LEAVE` |
| Exception handling | `BEGIN...EXCEPTION...END`                 |
| Stored procedures  | `CREATE PROCEDURE`                        |
| Scheduled queries  | Automated execution                       |

### 11.2 Remote Functions

| Type            | Description               |
| --------------- | ------------------------- |
| Cloud Functions | HTTP-triggered UDFs       |
| Cloud Run       | Container-based functions |
| Remote models   | External ML inference     |

### 11.3 Change Data Capture (CDC)

| Feature        | Details                 |
| -------------- | ----------------------- |
| BigQuery CDC   | `APPLY_CHANGES_TO`      |
| Datastream     | Realtime replication    |
| Change history | `FOR SYSTEM_TIME AS OF` |

### 11.4 Time Travel & Snapshots

| Feature     | Capability                             |
| ----------- | -------------------------------------- |
| Time travel | Query historical data (7 days default) |
| Fail-safe   | 7-day recovery period                  |
| Snapshots   | Point-in-time table backup             |
| Clones      | Zero-copy table duplicates             |

### Labs - Module 11

| Lab # | Title                              | Tools       | Description                             |
| ----- | ---------------------------------- | ----------- | --------------------------------------- |
| 11.1  | Scripting Fundamentals             | bq CLI      | Variables, control flow, loops          |
| 11.2  | Advanced Stored Procedures         | bq + Python | Complex procedures with parameters      |
| 11.3  | Exception Handling                 | bq CLI      | TRY/CATCH in BigQuery scripts           |
| 11.4  | Remote Functions - Cloud Functions | gcloud + bq | HTTP UDF with Cloud Functions           |
| 11.5  | Remote Functions - Cloud Run       | gcloud + bq | Container-based remote functions        |
| 11.6  | Time Travel Queries                | bq + Python | FOR SYSTEM_TIME AS OF                   |
| 11.7  | Snapshot Management                | bq CLI      | Create, list, restore snapshots         |
| 11.8  | Clone Workflows                    | bq + Python | Development/testing with clones         |
| 11.9  | CDC with Datastream                | gcloud      | Real-time replication setup             |
| 11.10 | Change History Tracking            | bq CLI      | Track data changes over time            |
| 11.11 | Multi-Statement Transactions       | bq CLI      | BEGIN TRANSACTION, COMMIT, ROLLBACK     |
| 11.12 | Capstone Project                   | All tools   | End-to-end data platform implementation |

---

## Lab Summary

| Module            | Lab Count | Primary Focus                       |
| ----------------- | --------- | ----------------------------------- |
| 1. Foundations    | 8         | Setup, basic queries, Python client |
| 2. Data Storage   | 14        | Tables, partitioning, clustering    |
| 3. Data Ingestion | 15        | Loading, streaming, transfers       |
| 4. GoogleSQL      | 23        | SQL mastery, functions, DML         |
| 5. Performance    | 12        | Optimization, monitoring            |
| 6. BigQuery ML    | 19        | Machine learning models             |
| 7. AI & GenAI     | 10        | Generative AI, vector search        |
| 8. Security       | 12        | Access control, governance          |
| 9. Administration | 12        | Operations, cost management         |
| 10. Integration   | 11        | Ecosystem tools                     |
| 11. Advanced      | 12        | Scripting, CDC, advanced features   |
| **Total**         | **148**   | **Comprehensive BigQuery Mastery**  |

---

## Prerequisites Checklist

Before starting labs:

```bash
# 1. Install gcloud CLI
# https://cloud.google.com/sdk/docs/install

# 2. Authenticate
gcloud auth login
gcloud auth application-default login

# 3. Set project
gcloud config set project YOUR_PROJECT_ID
export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID

# 4. Enable BigQuery API
gcloud services enable bigquery.googleapis.com

# 5. Python setup
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# 6. Install Python libraries
pip install google-cloud-bigquery google-cloud-bigquery-storage pandas pyarrow db-dtypes
```

---

## Cost Management Tips

- Use `bigquery-public-data` for learning (free to query)
- Set maximum bytes billed: `bq query --maximum_bytes_billed=1000000000`
- Monitor with: `bq ls -j -a` (list recent jobs)
- Delete test datasets after labs: `bq rm -r -f dataset_name`
- Use dry runs: `bq query --dry_run` to estimate costs

---

## Certification Alignment

| Exam Section                | Relevant Modules |
| --------------------------- | ---------------- |
| Design data systems (~22%)  | 2, 5, 8          |
| Ingest/process data (~25%)  | 3, 10            |
| Store data (~20%)           | 2, 3, 11         |
| Prepare/analyze data (~15%) | 4, 6, 7          |
| Maintain/automate (~18%)    | 5, 9, 11         |

---

## Next Steps

1. Complete Module 1 labs to establish foundations
2. Progress sequentially through modules
3. Each lab builds on previous knowledge
4. Use public datasets to minimize costs
5. Complete capstone project (Lab 11.12) to integrate all skills


