# GCP Service Selection Guide

A practical guide to help you choose the right GCP service for your data engineering needs.

## Decision Trees

### Storage: Where should I store my data?

```
Do you need to run SQL queries?
│
├─ YES → Is your data structured/tabular?
│   │
│   ├─ YES → Do you need < 10TB and ACID transactions?
│   │   │
│   │   ├─ YES → Need global distribution?
│   │   │   ├─ YES → Cloud Spanner
│   │   │   └─ NO → Cloud SQL
│   │   │
│   │   └─ NO (large analytics) → BigQuery
│   │
│   └─ NO (semi-structured) → BigQuery or Cloud Storage + BigQuery external tables
│
└─ NO → What's your access pattern?
    │
    ├─ Key-value lookups, high throughput → Cloud Bigtable
    ├─ Document database, mobile/web → Firestore
    ├─ In-memory cache → Memorystore (Redis/Memcached)
    └─ Object/file storage, data lake → Cloud Storage
```

### Processing: How should I process my data?

```
Is your data stream or batch?
│
├─ STREAM → How complex is the transformation?
│   │
│   ├─ Simple (filtering, routing) → Pub/Sub + Cloud Functions
│   ├─ Moderate (aggregations) → Dataflow (Apache Beam)
│   └─ Complex (ML, joins) → Dataflow
│
└─ BATCH → What framework do you use?
    │
    ├─ SQL-based transformations → BigQuery or Dataform
    ├─ Apache Spark/Hadoop → Dataproc
    ├─ Apache Beam → Dataflow
    ├─ Visual ETL designer → Data Fusion
    └─ Custom Python/Java → Dataflow or Cloud Functions
```

### Messaging: How should I move data?

```
What's your use case?
│
├─ Real-time event streaming → Pub/Sub
├─ Database replication (CDC) → Datastream
├─ One-time migration → Database Migration Service or Transfer Service
├─ Scheduled file transfers → Transfer Service or Storage Transfer Service
└─ API-based integration → Cloud Functions or Workflows
```

## Quick Comparison Tables

### Storage Services

| Service | Type | Use Case | Max Size | Query Language | Cost Model |
|---------|------|----------|----------|----------------|------------|
| **BigQuery** | Data Warehouse | Analytics, reporting | Petabytes | SQL | Storage + queries |
| **Cloud Storage** | Object Storage | Data lake, files, backups | Unlimited | None (access via tools) | Storage + operations |
| **Bigtable** | NoSQL (wide-column) | Time-series, IoT, high-throughput | Petabytes | API (no SQL) | Nodes + storage |
| **Spanner** | Relational DB | Global ACID transactions | Petabytes | SQL | Nodes + storage |
| **Cloud SQL** | Relational DB | Traditional apps, moderate scale | 64 TB | SQL | Instance + storage |
| **Firestore** | Document DB | Mobile/web apps, real-time sync | Unlimited | NoSQL queries | Operations + storage |
| **Memorystore** | In-memory cache | Low-latency lookups | 300 GB | Redis/Memcached commands | Memory + network |

### Processing Services

| Service | Type | Best For | Frameworks | Pricing |
|---------|------|----------|------------|---------|
| **BigQuery** | SQL Engine | SQL transformations at scale | SQL, BigQueryML | Slots (compute) + storage |
| **Dataflow** | Stream/Batch | Unified pipelines, complex transformations | Apache Beam (Java, Python) | Workers + resources |
| **Dataproc** | Cluster | Existing Spark/Hadoop jobs | Spark, Hadoop, Hive, Pig | Cluster nodes |
| **Data Fusion** | Visual ETL | Low-code transformations | 100+ connectors, CDAP | Instance + pipeline runs |
| **Dataform** | SQL Workflow | dbt-style SQL transformations | SQL, SQLX | Execution + BigQuery costs |
| **Cloud Functions** | Serverless | Simple event-driven tasks | Python, Node.js, Go, Java | Invocations + compute time |

### Messaging & Integration

| Service | Type | Use Case | Latency | Guaranteed Delivery |
|---------|------|----------|---------|---------------------|
| **Pub/Sub** | Pub/Sub Messaging | Event streaming, decoupling | Milliseconds | Yes |
| **Datastream** | CDC | Database replication | Seconds | Yes |
| **Transfer Service** | Data Transfer | Cloud-to-cloud migration | Hours/Days | Yes |
| **Workflows** | Orchestration | API integration, multi-step logic | Seconds | Yes |
| **Cloud Tasks** | Task Queue | Async job execution | Configurable | Yes |

## Common Scenarios & Solutions

### Scenario 1: Real-time Dashboard
**Need:** Display live website analytics

**Solution:**
1. **Pub/Sub** - Collect clickstream events
2. **Dataflow** - Aggregate events (windowing)
3. **BigQuery** - Store aggregated data
4. **Looker** - Visualize in real-time dashboard

**Why:** Pub/Sub handles high-volume streams, Dataflow does real-time aggregation, BigQuery provides fast queries, Looker connects natively.

---

### Scenario 2: Daily Sales Report
**Need:** Generate report every morning at 8 AM

**Solution:**
1. **Cloud SQL** - Transactional database (orders)
2. **Cloud Composer** - Schedule daily at 8 AM
3. **Dataflow/BigQuery** - Extract and transform
4. **BigQuery** - Store analytics data
5. **Looker/Data Studio** - Generate report

**Why:** Composer handles scheduling, Dataflow/BQ processes data efficiently, Looker automates report delivery.

---

### Scenario 3: IoT Sensor Data
**Need:** Store millions of sensor readings per second

**Solution:**
1. **Pub/Sub** - Ingest sensor events
2. **Dataflow** - Real-time processing
3. **Bigtable** - Store time-series data (low-latency reads)
4. **BigQuery** - Historical analysis (copy aggregates)

**Why:** Pub/Sub scales to millions of messages, Bigtable optimized for time-series, BigQuery for analytics.

---

### Scenario 4: Machine Learning Pipeline
**Need:** Train and serve ML models on customer data

**Solution:**
1. **BigQuery** - Store customer data
2. **BigQuery ML** - Train simple models in SQL
   OR **Vertex AI** - Train complex models
3. **Vertex AI** - Deploy model
4. **Cloud Functions** - Serve predictions via API

**Why:** BigQuery provides features, BQML for quick models, Vertex AI for advanced ML, Functions for serving.

---

### Scenario 5: Multi-region Data Lake
**Need:** Store petabytes of raw data, accessible globally

**Solution:**
1. **Cloud Storage** - Multi-region buckets
2. **Dataplex** - Organize and catalog data
3. **BigQuery** - External tables over Cloud Storage
4. **BigQuery** - Materialized views for frequent queries

**Why:** Cloud Storage is cost-effective for raw data, Dataplex provides governance, BigQuery enables SQL access.

---

### Scenario 6: Migrate PostgreSQL to GCP
**Need:** Move on-premises PostgreSQL database to cloud

**Solution:**

**Option A (Lift & Shift):**
- **Database Migration Service** → **Cloud SQL**

**Option B (Modernize):**
- **Datastream** (CDC) → **BigQuery** (analytics)
- Keep **Cloud SQL** for transactional queries

**Why:** DMS minimizes downtime, Cloud SQL is managed PostgreSQL, BigQuery better for analytics.

---

## Cost Optimization Tips

### BigQuery
- ✅ Use partitioning and clustering
- ✅ Avoid SELECT *, query only needed columns
- ✅ Use materialized views for repeated queries
- ✅ Consider flat-rate pricing for predictable workloads
- ❌ Don't scan entire tables unnecessarily

### Cloud Storage
- ✅ Use lifecycle policies (move to Archive after 90 days)
- ✅ Choose Standard/Nearline/Coldline/Archive based on access frequency
- ✅ Enable compression
- ❌ Don't keep unnecessary copies

### Dataflow
- ✅ Use autoscaling
- ✅ Use Shuffle service for batch jobs
- ✅ Use Streaming Engine for streaming
- ❌ Don't over-provision workers

### Dataproc
- ✅ Use ephemeral clusters (create, process, delete)
- ✅ Use preemptible workers for batch jobs
- ✅ Enable autoscaling
- ❌ Don't keep idle clusters running

### Bigtable
- ✅ Start with minimum nodes, scale up based on CPU
- ✅ Design row keys to avoid hotspots
- ✅ Use replication only when needed
- ❌ Don't over-provision nodes

## When NOT to Use GCP Services

### Don't use BigQuery when:
- You need row-level updates/deletes (use Cloud SQL/Spanner)
- You need < 1 second latency (use Bigtable/Memorystore)
- Your queries are simple key-value lookups (use Bigtable)

### Don't use Bigtable when:
- Your data is < 1 TB (use Cloud SQL, too expensive for small datasets)
- You need SQL queries (use BigQuery/Cloud SQL)
- You need ACID transactions across rows (use Spanner/Cloud SQL)

### Don't use Dataflow when:
- Simple SQL transformations are enough (use BigQuery)
- You have existing Spark code and want minimal changes (use Dataproc)
- Very simple event-driven tasks (use Cloud Functions)

### Don't use Cloud SQL when:
- You need > 10 TB (use Spanner/BigQuery)
- You need global distribution (use Spanner)
- Pure analytics workload (use BigQuery)

### Don't use Spanner when:
- You don't need global distribution (use Cloud SQL, much cheaper)
- Pure analytics, no transactions (use BigQuery)
- NoSQL is sufficient (use Bigtable/Firestore)

## Exam Tips: Service Selection

The exam often tests your ability to choose the right service. Remember:

**For each question, identify:**
1. **Workload type**: Transactional (OLTP) or Analytical (OLAP)?
2. **Data volume**: GBs, TBs, or PBs?
3. **Latency requirements**: Milliseconds, seconds, or minutes?
4. **Query pattern**: SQL, key-value, document, time-series?
5. **Consistency needs**: Strong consistency or eventual?
6. **Budget constraints**: Cost-sensitive or performance-critical?

**Common exam traps:**
- ❌ Using BigQuery for transactional updates
- ❌ Using Cloud SQL for petabyte-scale analytics
- ❌ Using Bigtable for small datasets
- ❌ Using Spanner when regional is sufficient
- ❌ Using Dataproc when BigQuery SQL would work

**Look for keywords:**
- "Real-time" → Pub/Sub, Dataflow, Bigtable
- "Batch" → BigQuery, Dataflow, Dataproc
- "SQL" → BigQuery, Cloud SQL, Spanner
- "Global" → Spanner, Cloud Storage multi-region
- "Time-series" → Bigtable
- "Cost-effective" → BigQuery, Cloud Storage
- "Low latency" → Bigtable, Memorystore
- "Streaming" → Pub/Sub, Dataflow

---

## Quick Decision Checklist

**Before choosing a service, ask:**

- [ ] What is the data volume (GB/TB/PB)?
- [ ] What are the query patterns (SQL/NoSQL/Key-value)?
- [ ] What are the latency requirements (ms/sec/min)?
- [ ] Is it transactional or analytical?
- [ ] Is it batch or streaming?
- [ ] What's the budget constraint?
- [ ] Are there existing tools/frameworks to consider?
- [ ] What are the scaling requirements?

**Still unsure?** Start with managed, serverless options (BigQuery, Dataflow) - they're easier to operate and cost-effective for most use cases.

---

Use this guide as you work through the tutorials. Each tutorial will show you hands-on how to use these services!
