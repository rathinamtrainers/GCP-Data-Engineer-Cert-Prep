# Data Engineering Concepts - Deep Dive

An advanced exploration of data engineering principles, patterns, and practices.

## Table of Contents

1. [Data Pipeline Architecture Patterns](#1-data-pipeline-architecture-patterns)
2. [Advanced Data Modeling](#2-advanced-data-modeling)
3. [Data Quality Framework](#3-data-quality-framework)
4. [Performance Optimization](#4-performance-optimization)
5. [Reliability and Fault Tolerance](#5-reliability-and-fault-tolerance)
6. [Cost Optimization Strategies](#6-cost-optimization-strategies)
7. [Security and Compliance](#7-security-and-compliance)
8. [Real-World Case Studies](#8-real-world-case-studies)

---

## 1. Data Pipeline Architecture Patterns

### 1.1 Lambda Architecture

**Concept**: Combines batch and real-time processing in parallel to handle both historical and live data.

**Architecture Components**:
```
Data Sources
    ↓
    ├─→ Batch Layer (comprehensive, accurate, slow)
    │   └─→ Batch Processing (Dataflow, Dataproc)
    │       └─→ Batch Views (BigQuery)
    │
    └─→ Speed Layer (approximate, fast)
        └─→ Stream Processing (Pub/Sub, Dataflow)
            └─→ Real-time Views (Bigtable, Memorystore)
                ↓
        Serving Layer (merges both views)
            └─→ Query Interface (BigQuery, API)
```

**When to Use**:
- Need both historical accuracy and real-time insights
- Different latency requirements for different use cases
- Can tolerate temporary inconsistencies

**GCP Implementation**:
```
Sources → Pub/Sub → ├─→ Dataflow (streaming) → Bigtable (real-time)
                     │
                     └─→ Cloud Storage → Dataflow (batch) → BigQuery
                                                              ↓
                                                    Serving Layer
```

**Pros**:
- ✅ Best of both worlds: speed and accuracy
- ✅ Fault tolerant (can recompute from batch layer)
- ✅ Handles late-arriving data gracefully

**Cons**:
- ❌ Complexity: maintain two pipelines
- ❌ Code duplication (same logic in batch and stream)
- ❌ Higher operational overhead

---

### 1.2 Kappa Architecture

**Concept**: Everything is a stream. Single processing path handles both real-time and historical data.

**Architecture Components**:
```
Data Sources
    ↓
Streaming Platform (Pub/Sub)
    ↓
Stream Processing (Dataflow)
    ├─→ Fast Storage (Bigtable) - recent data
    └─→ Slow Storage (BigQuery) - historical data
         ↓
    Serving Layer
```

**When to Use**:
- Stream processing can handle the volume
- Don't need complex batch transformations
- Want to avoid code duplication
- Team expertise in stream processing

**GCP Implementation**:
```
Sources → Pub/Sub → Dataflow (streaming only)
                        ├─→ Bigtable (recent 7 days)
                        └─→ BigQuery (all historical)
```

**Pros**:
- ✅ Simpler: single codebase
- ✅ Easier to maintain
- ✅ True real-time architecture

**Cons**:
- ❌ Stream processing must handle all complexity
- ❌ Reprocessing requires replaying entire stream
- ❌ May be expensive for massive historical data

---

### 1.3 Medallion Architecture (Bronze/Silver/Gold)

**Concept**: Progressive data refinement through quality layers.

```
┌─────────────────────────────────────────────────────┐
│ BRONZE LAYER (Raw Data)                             │
│ - Exact copy of source data                         │
│ - No transformations                                │
│ - Audit trail and lineage                           │
│ Storage: Cloud Storage (Parquet, Avro)              │
└─────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────┐
│ SILVER LAYER (Cleaned Data)                         │
│ - Deduplicated                                      │
│ - Standardized formats                              │
│ - Basic transformations                             │
│ - Data quality checks applied                       │
│ Storage: Cloud Storage + BigQuery External Tables   │
└─────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────┐
│ GOLD LAYER (Business-Level Data)                    │
│ - Aggregated metrics                                │
│ - Business logic applied                            │
│ - Optimized for analytics                           │
│ - Star/snowflake schema                             │
│ Storage: BigQuery (partitioned, clustered)          │
└─────────────────────────────────────────────────────┘
```

**When to Use**:
- Building a data lake
- Need to preserve raw data
- Multiple teams with different data needs
- Regulatory requirements for audit trails

**GCP Implementation**:
```
# Bronze
sources → Cloud Storage (gs://bucket/bronze/raw/)

# Silver
Bronze → Dataflow → Cloud Storage (gs://bucket/silver/cleaned/)
                  → BigQuery external tables

# Gold
Silver → Dataform/BigQuery → BigQuery (partitioned tables)
```

**Best Practices**:
1. **Bronze**: Keep forever (cheap), immutable
2. **Silver**: Keep 1-2 years, enable time travel
3. **Gold**: Optimize for query performance
4. **Governance**: Different access controls per layer

---

### 1.4 Event-Driven Architecture

**Concept**: Components communicate through events, enabling loose coupling and scalability.

```
Event Producers
    ↓
Event Bus (Pub/Sub)
    ↓
Event Processors (multiple subscribers)
    ├─→ Stream Analytics (Dataflow)
    ├─→ Data Lake Ingestion (Cloud Storage)
    ├─→ Real-time Alerting (Cloud Functions)
    └─→ Event Sourcing (Bigtable/BigQuery)
```

**Event Types**:
1. **Domain Events**: Business occurrences (order_placed, payment_received)
2. **System Events**: Technical occurrences (file_uploaded, job_completed)
3. **Integration Events**: Cross-system communication

**GCP Pattern**:
```python
# Publisher (Order Service)
from google.cloud import pubsub_v1

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, 'order-events')

event = {
    'event_type': 'order_placed',
    'order_id': '12345',
    'customer_id': '67890',
    'timestamp': '2025-01-19T10:00:00Z',
    'amount': 99.99
}

publisher.publish(topic_path, json.dumps(event).encode())

# Multiple Subscribers
# 1. Analytics Team: order-events → Dataflow → BigQuery
# 2. Inventory Team: order-events → Cloud Functions → Update inventory
# 3. Shipping Team: order-events → Cloud Functions → Create shipping label
# 4. ML Team: order-events → Bigtable → Real-time recommendations
```

**Benefits**:
- ✅ Loose coupling between services
- ✅ Easy to add new consumers
- ✅ Natural fit for microservices
- ✅ Supports event sourcing patterns

**Challenges**:
- ❌ Eventual consistency
- ❌ Event ordering issues
- ❌ Schema evolution management
- ❌ Debugging distributed flows

---

## 2. Advanced Data Modeling

### 2.1 Dimensional Modeling Deep Dive

#### Star Schema (Denormalized)

```
        ┌─────────────────┐
        │  Date Dimension │
        │  - date_key     │
        │  - full_date    │
        │  - year         │
        │  - quarter      │
        │  - month        │
        └─────────────────┘
                │
                │
┌─────────────────┐         ┌─────────────────┐
│ Product Dim     │         │   Sales Fact    │
│  - product_key  │────────│  - date_key     │
│  - product_name │         │  - product_key  │
│  - category     │         │  - customer_key │
│  - price        │         │  - store_key    │
└─────────────────┘         │  - quantity     │
                            │  - revenue      │
                            │  - profit       │
                            └─────────────────┘
┌─────────────────┐                │
│ Customer Dim    │                │
│  - customer_key │────────────────┘
│  - name         │
│  - segment      │
│  - region       │
└─────────────────┘
```

**Design Principles**:
1. **Fact Table**: Contains measurements (revenue, quantity, duration)
2. **Dimension Tables**: Provide context (who, what, when, where)
3. **Grain**: Defines the level of detail (e.g., "one row per order line item")
4. **Surrogate Keys**: Use integer keys instead of business keys

**BigQuery Implementation**:
```sql
-- Fact Table
CREATE TABLE sales_fact (
  date_key INT64,
  product_key INT64,
  customer_key INT64,
  store_key INT64,
  quantity INT64,
  revenue NUMERIC(10,2),
  profit NUMERIC(10,2)
)
PARTITION BY date_key  -- Partition by date for performance
CLUSTER BY product_key, customer_key;  -- Cluster for common queries

-- Date Dimension
CREATE TABLE dim_date (
  date_key INT64,
  full_date DATE,
  year INT64,
  quarter INT64,
  month INT64,
  month_name STRING,
  day_of_week STRING,
  is_weekend BOOL,
  is_holiday BOOL
);

-- Usage: Fast analytical queries
SELECT
  d.year,
  d.quarter,
  p.category,
  SUM(f.revenue) as total_revenue
FROM sales_fact f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2024
GROUP BY d.year, d.quarter, p.category;
```

---

#### Snowflake Schema (Normalized)

```
Product Dimension splits into:
┌─────────────────┐
│ Product         │
│  - product_key  │
│  - name         │
│  - category_key │──→ ┌─────────────────┐
└─────────────────┘     │ Category        │
                        │  - category_key │
                        │  - category_name│
                        │  - dept_key     │──→ ┌──────────────┐
                        └─────────────────┘     │ Department   │
                                                │  - dept_key  │
                                                │  - dept_name │
                                                └──────────────┘
```

**When to Use**:
- **Star**: Most cases in BigQuery (denormalized is faster)
- **Snowflake**: When dimension tables are huge and duplication is expensive

---

### 2.2 Slowly Changing Dimensions (SCD)

#### Type 1: Overwrite (No History)

```sql
-- Customer changes address
UPDATE dim_customer
SET address = '789 New St',
    city = 'Boston'
WHERE customer_id = 123;

-- Old data is LOST
```

**Use Case**: Corrections, non-critical attributes

---

#### Type 2: Add New Row (Full History)

```sql
-- Customer changes address - keep history
CREATE TABLE dim_customer (
  customer_key INT64,      -- Surrogate key (unique)
  customer_id INT64,       -- Business key (same for same customer)
  name STRING,
  address STRING,
  city STRING,
  effective_date DATE,     -- When this version became active
  end_date DATE,           -- When this version ended (NULL = current)
  is_current BOOL          -- TRUE for latest version
);

-- Insert new row for address change
INSERT INTO dim_customer VALUES
  (456, 123, 'John Doe', '789 New St', 'Boston', '2025-01-19', NULL, TRUE);

-- Close out old row
UPDATE dim_customer
SET end_date = '2025-01-18',
    is_current = FALSE
WHERE customer_key = 123;  -- Old surrogate key
```

**BigQuery Best Practice**:
```sql
-- Query to get current customer data
SELECT *
FROM dim_customer
WHERE is_current = TRUE;

-- Query to get customer data as of specific date
SELECT *
FROM dim_customer
WHERE '2024-12-01' BETWEEN effective_date AND IFNULL(end_date, '9999-12-31');
```

**Use Case**: Track history of important attributes (pricing, customer segments, product categories)

---

#### Type 3: Add New Column (Limited History)

```sql
CREATE TABLE dim_customer (
  customer_key INT64,
  customer_id INT64,
  name STRING,
  current_address STRING,
  previous_address STRING,
  address_change_date DATE
);

-- Update when address changes
UPDATE dim_customer
SET previous_address = current_address,
    current_address = '789 New St',
    address_change_date = CURRENT_DATE()
WHERE customer_id = 123;
```

**Use Case**: Need to compare only current vs previous value

---

### 2.3 Data Vault Modeling

**Concept**: Enterprise-scale modeling for flexibility and auditability.

**Components**:
1. **Hubs**: Business entities (Customer, Product, Order)
2. **Links**: Relationships between hubs (Order_Customer, Order_Product)
3. **Satellites**: Attributes and history (Customer_Details, Product_Pricing)

```
Hub_Customer                 Link_Order_Customer              Hub_Order
- customer_key               - link_key                       - order_key
- customer_id                - customer_key                   - order_id
- load_date                  - order_key                      - load_date
- source                     - load_date                      - source
                             - source
        ↓                                                             ↓
Sat_Customer_Details                                     Sat_Order_Details
- customer_key                                           - order_key
- name                                                   - order_date
- email                                                  - total_amount
- address                                                - status
- effective_date                                         - effective_date
- load_date                                              - load_date
```

**Benefits**:
- Historical tracking built-in
- Easy to integrate new sources
- Audit trail for compliance

**When to Use**:
- Enterprise data warehouse
- Heavy regulatory requirements
- Multiple source systems
- Need extreme flexibility

**GCP Note**: BigQuery's flexibility reduces need for Data Vault complexity in many cases.

---

## 3. Data Quality Framework

### 3.1 Six Dimensions of Data Quality

#### 1. Accuracy
**Definition**: Data correctly represents reality

**Tests**:
```sql
-- Check if sales totals match source system
SELECT
  COUNT(*) as mismatched_orders
FROM warehouse.orders w
LEFT JOIN source.orders s ON w.order_id = s.order_id
WHERE ABS(w.total - s.total) > 0.01;  -- Accounting for floating point

-- Validation: Should return 0
```

---

#### 2. Completeness
**Definition**: All required data is present

**Tests**:
```sql
-- Check for missing required fields
SELECT
  COUNTIF(customer_id IS NULL) as missing_customer,
  COUNTIF(order_date IS NULL) as missing_date,
  COUNTIF(total IS NULL) as missing_total,
  COUNT(*) as total_rows
FROM orders
WHERE order_date = CURRENT_DATE();

-- Alert if any counts > 0
```

---

#### 3. Consistency
**Definition**: Data is uniform across systems

**Tests**:
```sql
-- Check if customer data matches across tables
SELECT
  o.customer_id,
  o.customer_name as orders_name,
  c.name as customers_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.customer_name != c.name;

-- Should return 0 rows
```

---

#### 4. Timeliness
**Definition**: Data is available when needed

**Tests**:
```sql
-- Check data freshness
SELECT
  MAX(ingestion_timestamp) as last_update,
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(ingestion_timestamp), MINUTE) as minutes_old
FROM orders;

-- Alert if minutes_old > 60 (or your SLA)
```

---

#### 5. Validity
**Definition**: Data conforms to defined formats and rules

**Tests**:
```sql
-- Check data format validity
SELECT
  COUNTIF(NOT REGEXP_CONTAINS(email, r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')) as invalid_emails,
  COUNTIF(NOT REGEXP_CONTAINS(phone, r'^\+?1?\d{10,15}$')) as invalid_phones,
  COUNTIF(total < 0) as negative_totals,
  COUNTIF(order_date > CURRENT_DATE()) as future_dates
FROM customers;

-- Alert if any count > 0
```

---

#### 6. Uniqueness
**Definition**: No unexpected duplicates

**Tests**:
```sql
-- Check for duplicate records
SELECT
  order_id,
  COUNT(*) as duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Should return 0 rows (or handle duplicates in pipeline)
```

---

### 3.2 Implementing Data Quality in GCP

**Automated Quality Checks with Dataflow**:
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

class ValidateRecord(beam.DoFn):
    """DoFn to validate each record"""

    def process(self, element):
        errors = []

        # Completeness check
        if not element.get('customer_id'):
            errors.append('Missing customer_id')

        # Validity check
        if element.get('total', 0) < 0:
            errors.append('Negative total')

        # Format check
        email = element.get('email', '')
        if '@' not in email:
            errors.append('Invalid email format')

        if errors:
            # Send to dead letter queue
            yield beam.pvalue.TaggedOutput('errors', {
                'record': element,
                'errors': errors,
                'timestamp': beam.utils.timestamp.Timestamp.now()
            })
        else:
            # Send to main output
            yield element

# Pipeline
with beam.Pipeline(options=PipelineOptions()) as p:

    # Read data
    records = p | 'Read' >> beam.io.ReadFromBigQuery(query='SELECT * FROM dataset.raw_orders')

    # Validate
    validated = records | 'Validate' >> beam.ParDo(ValidateRecord()).with_outputs('errors', main='valid')

    # Write valid records to BigQuery
    validated.valid | 'Write Valid' >> beam.io.WriteToBigQuery(
        'project:dataset.validated_orders',
        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
    )

    # Write errors to separate table
    validated.errors | 'Write Errors' >> beam.io.WriteToBigQuery(
        'project:dataset.data_quality_errors',
        write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
    )
```

**Monitoring Dashboard**:
```sql
-- Create data quality metrics table
CREATE OR REPLACE TABLE monitoring.data_quality_metrics AS
SELECT
  'orders' as table_name,
  CURRENT_TIMESTAMP() as check_timestamp,
  COUNT(*) as total_records,
  COUNTIF(customer_id IS NULL) as missing_customer_id,
  COUNTIF(total < 0) as negative_totals,
  COUNTIF(order_date > CURRENT_DATE()) as future_dates,
  ROUND(COUNTIF(customer_id IS NOT NULL) / COUNT(*) * 100, 2) as completeness_pct
FROM dataset.orders
WHERE DATE(ingestion_timestamp) = CURRENT_DATE();

-- Visualize in Looker Studio or create alerts
```

---

## 4. Performance Optimization

### 4.1 BigQuery Optimization Strategies

#### Partitioning

**Types**:
1. **Time-unit column partitioning** (most common)
2. **Ingestion time partitioning**
3. **Integer range partitioning**

```sql
-- Create partitioned table (daily partitions)
CREATE TABLE sales (
  order_id INT64,
  customer_id INT64,
  order_date DATE,
  total NUMERIC(10,2)
)
PARTITION BY order_date
OPTIONS(
  partition_expiration_days=730,  -- Auto-delete after 2 years
  require_partition_filter=true   -- Force users to filter by date
);

-- Query optimization: Only scans relevant partition
SELECT SUM(total)
FROM sales
WHERE order_date = '2025-01-19';  -- Scans only 1 day's data

-- Bad query: Scans entire table
SELECT SUM(total)
FROM sales
WHERE customer_id = 123;  -- No partition filter!
```

**Cost Savings Example**:
```
Table size: 10 TB
Query without partition filter: Scans 10 TB = $50
Query with partition filter (1 day): Scans ~27 GB = $0.14
Savings: 99.7%
```

---

#### Clustering

**Concept**: Sort data within partitions by specified columns

```sql
-- Create partitioned AND clustered table
CREATE TABLE sales (
  order_id INT64,
  customer_id INT64,
  product_id INT64,
  order_date DATE,
  total NUMERIC(10,2)
)
PARTITION BY order_date
CLUSTER BY customer_id, product_id;  -- Sort by these columns

-- Optimized query (uses both partition and clustering)
SELECT SUM(total)
FROM sales
WHERE order_date BETWEEN '2025-01-01' AND '2025-01-31'  -- Partition filter
  AND customer_id = 123;  -- Clustering filter

-- BigQuery skips irrelevant data blocks
```

**Clustering Guidelines**:
- Use up to 4 columns
- Order by cardinality: high cardinality first
- Common filter/GROUP BY columns
- Best when table > 1 GB

---

#### Query Optimization

**1. SELECT only needed columns**
```sql
-- ❌ Bad: Scans entire table
SELECT * FROM sales WHERE order_date = '2025-01-19';

-- ✅ Good: Scans only needed columns
SELECT order_id, total FROM sales WHERE order_date = '2025-01-19';
```

**2. Use LIMIT for exploration**
```sql
-- ❌ Bad: Returns millions of rows
SELECT * FROM sales WHERE order_date > '2024-01-01';

-- ✅ Good: Limit results during exploration
SELECT * FROM sales WHERE order_date > '2024-01-01' LIMIT 1000;
```

**3. Filter early in CTEs**
```sql
-- ✅ Good: Filter before joining
WITH recent_orders AS (
  SELECT order_id, customer_id, total
  FROM sales
  WHERE order_date >= '2025-01-01'  -- Filter early
)
SELECT
  o.order_id,
  c.name,
  o.total
FROM recent_orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

**4. Use approximate aggregation for large datasets**
```sql
-- Exact count (slower, more expensive)
SELECT COUNT(DISTINCT customer_id) FROM sales;

-- Approximate count (faster, 98%+ accurate)
SELECT APPROX_COUNT_DISTINCT(customer_id) FROM sales;
```

**5. Denormalize for repeated joins**
```sql
-- Instead of joining every query
SELECT o.order_id, c.name, p.product_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

-- Denormalize into a wide table
CREATE TABLE orders_denorm AS
SELECT
  o.order_id,
  o.customer_id,
  c.name as customer_name,
  o.product_id,
  p.product_name,
  o.total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

-- Now simple, fast queries
SELECT order_id, customer_name, product_name
FROM orders_denorm
WHERE order_date = '2025-01-19';
```

---

### 4.2 Dataflow Optimization

**1. Use Shuffle Service (Batch)**
```python
# Offload shuffle to managed service
pipeline_options = PipelineOptions([
    '--dataflow_service_options=shuffle_mode=service',
])
```

**2. Use Streaming Engine (Streaming)**
```python
# Better autoscaling and state management
pipeline_options = PipelineOptions([
    '--streaming',
    '--enable_streaming_engine',
])
```

**3. Optimize Window Size**
```python
# ❌ Too small: High overhead
windowed = events | beam.WindowInto(window.FixedWindows(1))  # 1 second

# ✅ Appropriate for use case
windowed = events | beam.WindowInto(window.FixedWindows(60))  # 1 minute

# Balance between:
# - Smaller windows = lower latency, higher cost
# - Larger windows = higher latency, lower cost
```

**4. Use Combiners for Aggregations**
```python
# ❌ Inefficient: Sends all data to one worker
total = events | beam.Map(lambda x: x['amount']) \
              | beam.CombineGlobally(sum)

# ✅ Efficient: Partial aggregation on each worker
total = events | beam.Map(lambda x: x['amount']) \
              | beam.CombineGlobally(beam.combiners.SumCombineFn())
```

---

## 5. Reliability and Fault Tolerance

### 5.1 Exactly-Once Processing

**Problem**: Messages can be delivered multiple times in distributed systems

**Solution**: Idempotent processing

**Pattern 1: Upsert with Unique Key**
```sql
-- Merge into BigQuery (upsert)
MERGE INTO target_table T
USING source_data S
ON T.order_id = S.order_id  -- Unique key
WHEN MATCHED THEN
  UPDATE SET total = S.total, updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (order_id, total, created_at) VALUES (S.order_id, S.total, CURRENT_TIMESTAMP());
```

**Pattern 2: Dedupe in Dataflow**
```python
import apache_beam as beam

class DeduplicateTransform(beam.PTransform):
    """Remove duplicates based on unique key"""

    def expand(self, pcoll):
        return (
            pcoll
            | 'Add Key' >> beam.Map(lambda x: (x['order_id'], x))
            | 'Dedupe' >> beam.Deduplicate()
            | 'Remove Key' >> beam.Values()
        )

# Usage
deduplicated = events | 'Dedupe Orders' >> DeduplicateTransform()
```

**Pattern 3: State-based Deduplication (Streaming)**
```python
from apache_beam import DoFn
from apache_beam.transforms.userstate import ReadModifyWriteStateSpec

class StatefulDedupe(DoFn):
    """Use state to track seen IDs"""

    SEEN_IDS = ReadModifyWriteStateSpec('seen_ids', beam.coders.BooleanCoder())

    def process(self, element, seen_ids=DoFn.StateParam(SEEN_IDS)):
        order_id = element['order_id']

        if seen_ids.read() is None:  # First time seeing this ID
            seen_ids.write(True)
            yield element
        # else: duplicate, don't yield
```

---

### 5.2 Dead Letter Queues

**Concept**: Separate failed messages for investigation without blocking pipeline

**Implementation**:
```python
class ProcessWithErrorHandling(beam.DoFn):
    """Process records with error handling"""

    def process(self, element):
        try:
            # Process record
            result = transform(element)

            # Validate result
            if result.get('total', 0) > 0:
                yield result
            else:
                raise ValueError('Invalid total')

        except Exception as e:
            # Send to DLQ with error details
            yield beam.pvalue.TaggedOutput('errors', {
                'original_record': element,
                'error_message': str(e),
                'error_timestamp': beam.utils.timestamp.Timestamp.now(),
                'pipeline_step': 'transform'
            })

# Pipeline
with beam.Pipeline() as p:

    results = (
        p
        | 'Read' >> beam.io.ReadFromPubSub(subscription=sub)
        | 'Process' >> beam.ParDo(ProcessWithErrorHandling()).with_outputs('errors', main='success')
    )

    # Write successful records
    results.success | 'Write Success' >> beam.io.WriteToBigQuery('dataset.orders')

    # Write errors to DLQ
    results.errors | 'Write DLQ' >> beam.io.WriteToBigQuery('dataset.dlq')
```

**DLQ Monitoring**:
```sql
-- Alert on DLQ records
SELECT
  pipeline_step,
  error_message,
  COUNT(*) as error_count
FROM dataset.dlq
WHERE error_timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY pipeline_step, error_message
ORDER BY error_count DESC;
```

---

### 5.3 Retry Strategies

**Exponential Backoff**:
```python
from google.api_core import retry
import google.cloud.bigquery as bq

# Configure retry with exponential backoff
custom_retry = retry.Retry(
    initial=1.0,      # Initial delay: 1 second
    maximum=60.0,     # Max delay: 60 seconds
    multiplier=2.0,   # Double delay each retry
    deadline=300.0,   # Give up after 5 minutes
    predicate=retry.if_transient_error  # Only retry transient errors
)

client = bq.Client()

# API call with retry
query_job = client.query(
    "SELECT * FROM dataset.table",
    retry=custom_retry
)
```

**Dataflow Retry**:
```python
# Pub/Sub automatically retries with exponential backoff
# Configure max retries in subscription
subscription = pubsub_v1.Subscription(
    name='projects/PROJECT/subscriptions/SUBSCRIPTION',
    topic='projects/PROJECT/topics/TOPIC',
    ack_deadline_seconds=60,  # Time to process before retry
    retry_policy=pubsub_v1.RetryPolicy(
        minimum_backoff='10s',
        maximum_backoff='600s'
    )
)
```

---

## 6. Cost Optimization Strategies

### 6.1 BigQuery Cost Optimization

**1. Use On-Demand vs Flat-Rate Pricing**

```
On-Demand: Pay per query ($5 per TB scanned)
- Good for: Variable workloads, getting started
- Bad for: Consistent heavy usage

Flat-Rate: Reserve slots ($2,000/month for 100 slots)
- Good for: Predictable heavy usage (>400 TB/month)
- Bad for: Occasional queries
```

**2. Partition and Cluster**
```
Example: 10 TB table, 100 queries/day

Without optimization:
- 10 TB × 100 queries = 1,000 TB scanned
- 1,000 TB × $5 = $5,000/day

With partitioning (scan 1%):
- 0.1 TB × 100 queries = 10 TB scanned
- 10 TB × $5 = $50/day

Savings: 99%
```

**3. Set Query Cost Controls**
```sql
-- Set maximum bytes billed
SELECT *
FROM large_table
WHERE date = '2025-01-19'
LIMIT 1000;
-- Run with maximum_bytes_billed = 100MB
-- Query will fail if it would scan more
```

**4. Materialized Views for Repeated Queries**
```sql
-- Expensive repeated query
SELECT
  DATE(order_date) as date,
  customer_segment,
  SUM(total) as revenue
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY DATE(order_date), customer_segment;

-- Create materialized view (computed once, queried many times)
CREATE MATERIALIZED VIEW daily_revenue_by_segment AS
SELECT
  DATE(order_date) as date,
  customer_segment,
  SUM(total) as revenue
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY DATE(order_date), customer_segment;

-- Now queries are cheap (scan MV, not raw table)
SELECT * FROM daily_revenue_by_segment WHERE date = '2025-01-19';
```

---

### 6.2 Cloud Storage Cost Optimization

**Storage Classes**:
```
Standard: $0.020/GB/month
- Frequent access (>1/month)

Nearline: $0.010/GB/month + $0.01/GB retrieval
- Access every 30-90 days

Coldline: $0.004/GB/month + $0.02/GB retrieval
- Access every 90-365 days

Archive: $0.0012/GB/month + $0.05/GB retrieval
- Access < once/year
```

**Lifecycle Policies**:
```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30, "matchesStorageClass": ["STANDARD"]}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90, "matchesStorageClass": ["NEARLINE"]}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 730}
      }
    ]
  }
}
```

**Example Savings**:
```
1 TB data, retained 2 years

Standard (no lifecycle): 1024 GB × $0.020 × 24 months = $492

With lifecycle:
- Month 1-1: Standard: 1024 × $0.020 × 1 = $20
- Month 2-3: Nearline: 1024 × $0.010 × 2 = $20
- Month 4-24: Coldline: 1024 × $0.004 × 21 = $86
Total: $126

Savings: 74%
```

---

### 6.3 Dataflow Cost Optimization

**1. Right-size Workers**
```python
# Over-provisioned (expensive)
pipeline_options = PipelineOptions([
    '--machine_type=n1-standard-8',
    '--num_workers=20',
])

# Right-sized (cost-effective)
pipeline_options = PipelineOptions([
    '--machine_type=n1-standard-2',
    '--autoscaling_algorithm=THROUGHPUT_BASED',
    '--max_num_workers=10',
])
```

**2. Use Shuffle Service and Streaming Engine**
```python
# Offload to managed services (more efficient)
pipeline_options = PipelineOptions([
    '--dataflow_service_options=shuffle_mode=service',
    '--enable_streaming_engine',  # For streaming jobs
])
```

**3. Use Flexible Resource Scheduling (Batch)**
```python
# Use cheaper resources with longer wait time
pipeline_options = PipelineOptions([
    '--flexrs_goal=COST_OPTIMIZED',  # vs SPEED_OPTIMIZED
])
```

---

## 7. Security and Compliance

### 7.1 Encryption

**Encryption at Rest**:

1. **Google-managed keys (default)**: No configuration needed
2. **Customer-managed keys (CMEK)**:

```bash
# Create key ring and key
gcloud kms keyrings create my-keyring --location=us-central1

gcloud kms keys create my-key \
  --location=us-central1 \
  --keyring=my-keyring \
  --purpose=encryption

# Create BigQuery dataset with CMEK
bq mk --dataset \
  --location=US \
  --default_kms_key=projects/PROJECT/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key \
  my_dataset
```

**Encryption in Transit**: Always enabled (TLS)

---

### 7.2 Access Control (IAM)

**Principle of Least Privilege**:

```bash
# ❌ Too permissive
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:analyst@company.com" \
  --role="roles/owner"

# ✅ Least privilege
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:analyst@company.com" \
  --role="roles/bigquery.dataViewer"
```

**BigQuery Column-Level Security**:
```sql
-- Create policy tag taxonomy
CREATE TAG TEMPLATE pii_tag
  OPTIONS(display_name="PII Classification");

-- Apply to column
ALTER TABLE customers
  ALTER COLUMN email SET OPTIONS(policy_tags=('projects/PROJECT/taxonomies/123/policyTags/456'));

-- Only users with fine-grained reader role can see email column
```

**Row-Level Security**:
```sql
-- Create row access policy
CREATE ROW ACCESS POLICY regional_sales_filter
ON sales
GRANT TO ('user:manager-us@company.com')
FILTER USING (region = 'US');

-- manager-us@company.com can only see US sales
```

---

### 7.3 Data Loss Prevention (DLP)

**Detect PII**:
```python
from google.cloud import dlp_v2

def inspect_data_for_pii(project_id, data):
    dlp = dlp_v2.DlpServiceClient()

    # Configure inspection
    inspect_config = {
        "info_types": [
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"},
            {"name": "CREDIT_CARD_NUMBER"},
            {"name": "US_SOCIAL_SECURITY_NUMBER"},
        ]
    }

    # Inspect
    response = dlp.inspect_content(
        request={
            "parent": f"projects/{project_id}",
            "inspect_config": inspect_config,
            "item": {"value": data}
        }
    )

    # Results
    for finding in response.result.findings:
        print(f"Found {finding.info_type.name}: {finding.quote}")
```

**Automated De-identification**:
```python
def deidentify_with_masking(project_id, text):
    dlp = dlp_v2.DlpServiceClient()

    # Mask PII with asterisks
    deidentify_config = {
        "info_type_transformations": {
            "transformations": [
                {
                    "primitive_transformation": {
                        "character_mask_config": {
                            "masking_character": "*",
                            "number_to_mask": 0  # Mask all characters
                        }
                    }
                }
            ]
        }
    }

    response = dlp.deidentify_content(
        request={
            "parent": f"projects/{project_id}",
            "deidentify_config": deidentify_config,
            "item": {"value": text}
        }
    )

    return response.item.value

# Example
original = "Customer email is john.doe@email.com and phone is 555-1234"
masked = deidentify_with_masking(project_id, original)
# Result: "Customer email is ******************** and phone is ********"
```

---

## 8. Real-World Case Studies

### Case Study 1: E-Commerce Recommendation Engine

**Challenge**: Generate real-time product recommendations for 10M monthly users

**Architecture**:
```
User Actions
    ↓
Pub/Sub (clickstream events)
    ↓
Dataflow (streaming)
    ├─→ BigQuery (historical analysis)
    └─→ Bigtable (user profiles, recent activity)
         ↓
Cloud Functions (recommendation API)
    ↓
Website (serve recommendations)
```

**Key Decisions**:
1. **Pub/Sub**: Handle 100K events/second
2. **Dataflow**: Real-time aggregation (user sessions, trending products)
3. **Bigtable**: Sub-10ms latency for lookups
4. **BigQuery**: Batch ML training daily
5. **BigQuery ML**: Simple recommendation model

**Results**:
- 8ms p99 latency for recommendations
- $2,000/month cost (managed services)
- 15% increase in conversions

---

### Case Study 2: Healthcare Data Warehouse

**Challenge**: Consolidate patient data from 50 clinics, HIPAA compliant

**Architecture**:
```
Clinic Databases (on-prem)
    ↓
Datastream (CDC)
    ↓
Cloud Storage (encrypted, HIPAA zone)
    ↓
Dataflow (data quality, de-identification)
    ↓
BigQuery (CMEK encryption, VPC-SC)
    ↓
Looker (dashboards for clinicians)
```

**Key Security Measures**:
1. **VPC Service Controls**: Prevent data exfiltration
2. **CMEK**: Customer-managed encryption keys
3. **DLP**: Automated PII detection
4. **Row-level security**: Clinics see only their patients
5. **Audit logs**: All data access logged
6. **Access controls**: Just-in-time access for engineers

**Results**:
- HIPAA compliant architecture
- 99.9% uptime
- Real-time patient insights
- $5,000/month (including Datastream)

---

### Case Study 3: Financial Services Risk Analytics

**Challenge**: Calculate risk metrics on 10 PB historical transactions, sub-minute freshness

**Architecture**:
```
Trading Systems
    ↓
Pub/Sub
    ├─→ Dataflow (streaming) → Bigtable (live positions)
    └─→ Cloud Storage (audit trail)
         ↓
    Dataflow (batch) → BigQuery (historical analysis)
         ↓
    Dataform (risk calculations)
         ↓
    BigQuery (risk reports)
         ↓
    Custom API (risk dashboard)
```

**Key Optimizations**:
1. **Partitioned BigQuery tables**: By trade date
2. **Materialized views**: Pre-aggregated risk metrics
3. **BigQuery BI Engine**: In-memory acceleration for dashboards
4. **Dataflow Streaming Engine**: Handle 500K trades/second
5. **Multi-region**: US and EU deployments

**Results**:
- 30-second latency for risk metrics
- Handles market spikes (2M trades/second)
- $50,000/month (cost of compliance)
- Passed regulatory audit

---

## Summary and Key Takeaways

### Architecture Patterns
- **Lambda**: Use when you need both batch accuracy and stream speed
- **Kappa**: Simplify with stream-only if volume permits
- **Medallion**: Organize data lakes with progressive refinement
- **Event-Driven**: Decouple systems with Pub/Sub

### Data Modeling
- **Star schema**: Default for analytics (denormalized, fast)
- **SCD Type 2**: Track history for important dimensions
- **Data Vault**: Enterprise-scale with heavy audit requirements

### Data Quality
- Implement all 6 dimensions: Accuracy, Completeness, Consistency, Timeliness, Validity, Uniqueness
- Automate checks in pipelines (Dataflow, BigQuery)
- Monitor continuously, alert on failures
- Use dead letter queues to isolate bad data

### Performance
- **BigQuery**: Partition by date, cluster by common filters, avoid SELECT *
- **Dataflow**: Use Shuffle Service, Streaming Engine, right-size workers
- **Materialized views**: Pre-compute expensive aggregations

### Reliability
- Implement idempotency for exactly-once processing
- Use dead letter queues for error handling
- Implement retry with exponential backoff
- Monitor and alert on pipeline health

### Cost
- **BigQuery**: Partition/cluster (99% savings possible), materialized views, flat-rate for heavy usage
- **Cloud Storage**: Lifecycle policies (74% savings), compression
- **Dataflow**: Autoscaling, FlexRS, Shuffle Service

### Security
- Encrypt at rest (CMEK) and in transit (TLS)
- Principle of least privilege (IAM)
- Column and row-level security in BigQuery
- Use DLP for PII detection and de-identification
- Comprehensive audit logging

---

## Next Steps

You now have a deep understanding of data engineering concepts. Ready to apply this knowledge:

1. **Start with Project 1**: [Batch ETL Pipeline](../../projects/01-batch-etl-weather/)
   - Apply: Medallion architecture, data quality checks, monitoring

2. **Try a Tutorial**: [BigQuery Basics (0300)](../0300-bigquery-basics/)
   - Practice: Partitioning, clustering, query optimization

3. **Review**: [Service Selection Guide](SERVICE_SELECTION_GUIDE.md)
   - Master: When to use which GCP service

4. **Reference**: [Glossary](GLOSSARY.md)
   - Quick lookup for any term

---

**Remember**: Data engineering is about building reliable, scalable, cost-effective data infrastructure. Focus on:
- ✅ Reliability over cleverness
- ✅ Simplicity over complexity
- ✅ Monitoring over hoping
- ✅ Cost-awareness over unlimited spending
- ✅ Security by design, not as afterthought

Happy data engineering! 🚀
