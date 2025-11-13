# Dual-Cloud BI Developer - Power BI (Azure) + Looker Studio (GCP)
## Hands-On Labs - Master Both Platforms

**Total Labs**: 50 comprehensive exercises
**Unique Approach**: Build everything twice - Azure AND GCP
**Career Impact**: Dual-cloud BI expertise (extremely rare!)
**Timeline**: 4-6 weeks intensive

---

## 🎯 Why Dual-Cloud Approach?

### Your Unique Value Proposition:
> "I'm a dual-cloud BI specialist proficient in both **Power BI (Azure/Microsoft stack)** and **Looker Studio (GCP stack)**. I can build dashboards, integrate data pipelines, and deliver analytics solutions on either platform - or bridge both in multi-cloud environments."

### Market Reality:
- **70% of enterprises** use multi-cloud strategies
- **Power BI** dominates business user BI (5M+ users)
- **GCP/Looker** growing in data-heavy companies (Netflix, Spotify, Twitter)
- **Very few professionals** know both deeply

### Career Benefits:
✅ **2x job opportunities** (Azure shops + GCP shops + hybrid)
✅ **Higher salary** (niche dual-cloud skills)
✅ **Better understanding** (learn by comparison)
✅ **Future-proof** (cloud-agnostic skills)

---

## 📋 Lab Structure

Each lab follows this format:

### Lab XXX: [Topic Name]
**Part A**: Power BI (Azure) Implementation (60% time)
**Part B**: Looker Studio (GCP) Implementation (30% time)
**Part C**: Comparison & Analysis (10% time)

**Deliverables**:
- Power BI solution (.pbix file)
- Looker Studio dashboard (link)
- Comparison document (.md file)

---

## 🛠️ Tools & Setup

### Power BI Stack (Azure/Microsoft)
- ✅ Power BI Desktop (Windows - free)
- ✅ Power BI Service (free account)
- ✅ Azure Free Account ($200 credit)
- ✅ Azure SQL Database (free tier)
- ✅ Azure Data Factory (free tier)
- ✅ Visual Studio 2022 (free)
- ✅ SQL Server 2022 Developer (free)

### Looker Studio Stack (GCP/Google)
- ✅ Looker Studio (completely free)
- ✅ Google Cloud Account (free tier + $300 credit)
- ✅ BigQuery (free tier: 1TB queries/month, 10GB storage)
- ✅ Cloud Storage (free tier)
- ✅ Cloud Composer (Airflow - optional, not free)
- ✅ Google Workspace (optional for advanced features)

**Total Cost**: $0-50/month if staying in free tiers

---

## Week 1: BI Fundamentals on Both Platforms (18 Labs)

### Section A: Getting Started (3 Labs)

#### Lab 001: Dual-Cloud Environment Setup
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Power BI Setup (1.5 hours)**
1. Install Power BI Desktop (Windows)
2. Create Power BI Service free account
3. Install DAX Studio
4. Create Azure free account
5. Provision Azure SQL Database (free tier)

**Part B: Looker Studio Setup (1 hour)**
1. Create Google Cloud account (free tier + $300 credit)
2. Enable BigQuery API
3. Access Looker Studio (datastudio.google.com)
4. Load sample data to BigQuery (public datasets)
5. Create first connection in Looker Studio

**Part C: Environment Comparison (30 mins)**
Document:
- Installation complexity (Power BI: desktop app, Looker: web-only)
- Cost comparison (both free for basic use)
- Platform requirements (Windows vs browser-based)

**Deliverables**:
- Both environments configured
- Screenshots of both tools
- `comparison-001.md` document

---

#### Lab 002: First Data Import & Basic Visualizations
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Common Dataset**: Sales data (100 rows CSV)
- Date, Product, Region, Sales, Quantity, Customer

**Part A: Power BI (2.5 hours)**
1. Import CSV into Power BI Desktop
2. Create 5 visualizations:
   - Bar chart (Sales by Product)
   - Line chart (Sales over time)
   - Pie chart (Sales by Region)
   - Table (Top 10 customers)
   - Card (Total Sales)
3. Add 2 slicers (Date, Region)
4. Format and publish to Power BI Service

**Part B: Looker Studio (1.5 hours)**
1. Upload same CSV to Google Sheets or BigQuery
2. Connect Looker Studio to data source
3. Create same 5 visualizations:
   - Bar chart (Sales by Product)
   - Time series (Sales over time)
   - Pie chart (Sales by Region)
   - Table (Top 10 customers)
   - Scorecard (Total Sales)
4. Add 2 filter controls (Date, Region)
5. Share Looker Studio report (public link)

**Part C: Comparison (30 mins)**
Compare:
- **Data import**: CSV handling differences
- **Visualization types**: Available chart types
- **Interactivity**: Slicers vs filters
- **Sharing**: Workspace vs link-based
- **Performance**: Load times

**Deliverables**:
- `sales-dashboard.pbix` (Power BI)
- Looker Studio link
- `comparison-002.md`

**Key Insight**: Power BI has more visualization options, Looker Studio is simpler for quick dashboards

---

#### Lab 003: Data Transformation & Preparation
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Common Dataset**: Messy sales data (nulls, wrong types, duplicates)

**Part A: Power Query (Power BI) (2.5 hours)**
1. Open Power Query Editor
2. Perform transformations:
   - Remove columns
   - Change data types
   - Filter nulls
   - Split columns
   - Create custom column
   - Replace values
3. Review M code
4. Apply and load

**Part B: BigQuery + Looker Studio (2 hours)**
1. Upload messy CSV to BigQuery
2. Write SQL query for transformations:
   ```sql
   SELECT
     CAST(Date AS DATE) as Date,
     UPPER(TRIM(Product)) as Product,
     Region,
     CAST(Sales AS FLOAT64) as Sales,
     Quantity,
     CONCAT(FirstName, ' ', LastName) as FullName,
     CASE
       WHEN Sales > 1000 THEN 'High'
       WHEN Sales > 500 THEN 'Medium'
       ELSE 'Low'
     END as SalesCategory
   FROM `project.dataset.raw_sales`
   WHERE Sales IS NOT NULL
   ```
3. Create view in BigQuery
4. Connect Looker Studio to view
5. Create dashboard

**Part C: Comparison (30 mins)**
Compare:
- **Approach**: Visual (Power Query) vs SQL (BigQuery)
- **Flexibility**: M language vs SQL
- **Learning curve**: Power Query easier for non-coders
- **Power**: SQL more powerful for complex transformations
- **Reusability**: BigQuery views are shared, Power Query is per-file

**Deliverables**:
- Power BI with clean data
- BigQuery transformation SQL
- Looker Studio on clean view
- `comparison-003.md`

**Key Insight**: Power Query for business users, SQL for data engineers

---

### Section B: Advanced Calculations (8 Labs)

#### Lab 004: Basic Aggregations - DAX vs Calculated Fields
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI DAX Measures (2.5 hours)**
Create 15 measures:
```dax
Total Sales = SUM(Sales[Amount])
Total Quantity = SUM(Sales[Quantity])
Average Sales = AVERAGE(Sales[Amount])
Distinct Customers = DISTINCTCOUNT(Sales[CustomerID])
Total Profit = [Total Sales] - SUM(Sales[Cost])
Profit Margin = DIVIDE([Total Profit], [Total Sales], 0)
Average Order Value = DIVIDE([Total Sales], COUNTROWS(Sales), 0)
// ... 8 more measures
```

**Part B: Looker Studio Calculated Fields (1.5 hours)**
Create same 15 calculations:
```
Total Sales = SUM(Sales)
Total Quantity = SUM(Quantity)
Average Sales = AVG(Sales)
Distinct Customers = COUNT_DISTINCT(CustomerID)
Total Profit = SUM(Sales) - SUM(Cost)
Profit Margin = Total Profit / Total Sales
Average Order Value = Total Sales / COUNT(TransactionID)
// ... 8 more fields
```

**Part C: Comparison (30 mins)**
Compare:
- **Language**: DAX vs simple expressions
- **Power**: DAX far more powerful (filter context, time intelligence)
- **Complexity**: Looker Studio simpler for basic calculations
- **Reusability**: Both store calculations separately from data
- **Performance**: Both computed on-the-fly

**Deliverables**:
- Power BI with 15 DAX measures
- Looker Studio with 15 calculated fields
- Side-by-side comparison table
- `comparison-004.md`

**Key Insight**: DAX is a full programming language, Looker Studio is formula-based (like Excel)

---

#### Lab 005: Time Intelligence - YoY, MoM, YTD
⬜ **Status**: Not Started
**Time**: 5-6 hours

**Part A: Power BI Time Intelligence (3-4 hours)**
1. Create Date table:
```dax
Date Table = CALENDAR(MIN(Sales[Date]), MAX(Sales[Date]))
```
2. Add date columns (Year, Quarter, Month, etc.)
3. Mark as Date Table
4. Create 15 time intelligence measures:
```dax
Sales YTD = TOTALYTD([Total Sales], 'Date'[Date])
Sales Last Year = CALCULATE([Total Sales], SAMEPERIODLASTYEAR('Date'[Date]))
Sales YoY Growth = [Total Sales] - [Sales Last Year]
Sales YoY % = DIVIDE([Sales YoY Growth], [Sales Last Year], 0)
Sales MTD = TOTALMTD([Total Sales], 'Date'[Date])
Sales Last Month = CALCULATE([Total Sales], PREVIOUSMONTH('Date'[Date]))
Sales MoM % = DIVIDE([Total Sales] - [Sales Last Month], [Sales Last Month], 0)
Sales Rolling 3 Months = CALCULATE([Total Sales], DATESINPERIOD('Date'[Date], MAX('Date'[Date]), -3, MONTH))
// ... more time measures
```

**Part B: Looker Studio with BigQuery (2 hours)**
1. Create date dimension in BigQuery:
```sql
CREATE OR REPLACE TABLE dataset.dim_date AS
SELECT
  date,
  EXTRACT(YEAR FROM date) as year,
  EXTRACT(QUARTER FROM date) as quarter,
  EXTRACT(MONTH FROM date) as month,
  EXTRACT(WEEK FROM date) as week,
  EXTRACT(DAYOFWEEK FROM date) as day_of_week
FROM UNNEST(GENERATE_DATE_ARRAY('2020-01-01', '2025-12-31')) as date;
```

2. Create time intelligence calculations in Looker Studio:
```
Sales YTD = Use date range filter + SUM
Sales Last Year = Use comparison date range
YoY Growth % = Use built-in comparison feature
```

3. OR use BigQuery SQL for complex calculations:
```sql
SELECT
  date,
  SUM(sales) as total_sales,
  SUM(SUM(sales)) OVER (
    PARTITION BY EXTRACT(YEAR FROM date)
    ORDER BY date
  ) as sales_ytd,
  SUM(sales) - LAG(SUM(sales), 12) OVER (ORDER BY date) as yoy_growth
FROM sales_table
GROUP BY date
```

**Part C: Comparison (30 mins)**
Compare:
- **Native support**: Power BI has built-in time intelligence, Looker Studio limited
- **Complexity**: DAX time functions easier than SQL window functions
- **Flexibility**: BigQuery SQL more flexible for custom logic
- **Best practice**: Power BI for BI users, BigQuery for data engineers

**Deliverables**:
- Power BI with complete time intelligence
- Looker Studio with time comparisons (using BigQuery SQL)
- `comparison-005.md`

**Key Insight**: Power BI's time intelligence is best-in-class, Looker Studio needs BigQuery SQL for complex scenarios

---

#### Lab 006: Iterator Functions - SUMX vs SQL Aggregations
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI Iterators (2.5 hours)**
```dax
Total Revenue = SUMX(Sales, Sales[Quantity] * Sales[Price])
Average Line Value = AVERAGEX(Sales, Sales[Quantity] * Sales[Price])
Weighted Average Price = SUMX(Sales, Sales[Quantity] * Sales[Price]) / SUM(Sales[Quantity])
Count High Value = COUNTX(FILTER(Sales, Sales[Amount] > 1000), Sales[Amount])
Rank Product = RANKX(ALL(Products[Name]), [Total Sales], , DESC)
Top 5 Products Sales = CALCULATE([Total Sales], TOPN(5, ALL(Products[Name]), [Total Sales]))
// ... more iterators
```

**Part B: BigQuery SQL (2 hours)**
```sql
-- Equivalent calculations in SQL
SELECT
  SUM(Quantity * Price) as total_revenue,
  AVG(Quantity * Price) as average_line_value,
  SUM(Quantity * Price) / SUM(Quantity) as weighted_avg_price,
  COUNT(CASE WHEN Amount > 1000 THEN 1 END) as count_high_value,
  RANK() OVER (ORDER BY SUM(Sales) DESC) as product_rank,
  -- Top 5 products
  CASE WHEN
    RANK() OVER (ORDER BY SUM(Sales) DESC) <= 5
    THEN SUM(Sales)
  END as top5_sales
FROM sales_table
GROUP BY Product
```

Connect to Looker Studio

**Part C: Comparison (30 mins)**
- **DAX iterators** = row-by-row processing
- **SQL** = set-based operations
- Power BI iterators easier for BI logic
- SQL better for data preparation

**Deliverables**: Both implementations + comparison

---

#### Lab 007: Filter Context - CALCULATE vs WHERE/HAVING
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI CALCULATE (2.5 hours)**
```dax
Sales 2024 = CALCULATE([Total Sales], YEAR(Sales[Date]) = 2024)
Sales USA = CALCULATE([Total Sales], Products[Country] = "USA")
Sales ALL Regions = CALCULATE([Total Sales], ALL(Products[Region]))
Percent of Total = DIVIDE([Total Sales], CALCULATE([Total Sales], ALL(Sales)))
Sales High Value = CALCULATE([Total Sales], FILTER(Sales, Sales[Amount] > 1000))
// ... 10 more CALCULATE patterns
```

**Part B: BigQuery Filtering (2 hours)**
```sql
-- Equivalent filtering in SQL
SELECT
  SUM(Sales) as total_sales,
  SUM(CASE WHEN EXTRACT(YEAR FROM Date) = 2024 THEN Sales END) as sales_2024,
  SUM(CASE WHEN Country = 'USA' THEN Sales END) as sales_usa,
  SUM(Sales) / (SELECT SUM(Sales) FROM sales_table) as percent_of_total,
  SUM(CASE WHEN Amount > 1000 THEN Sales END) as sales_high_value
FROM sales_table
```

**Part C: Comparison**
- CALCULATE modifies filter context (BI concept)
- SQL uses WHERE/HAVING/CASE (data concept)
- DAX more intuitive for business logic
- SQL more explicit

**Deliverables**: Both implementations + comparison

---

#### Lab 008: Data Modeling - Star Schema Implementation
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Common Scenario**: Build dimensional model with Fact and Dimension tables

**Part A: Power BI Data Model (2.5 hours)**
1. Import 4 tables: Sales (fact), Products, Customers, Date (dimensions)
2. Create relationships in Model view
3. Configure relationship properties:
   - Cardinality (1:*, 1:1)
   - Cross-filter direction (single vs both)
   - Active vs inactive relationships
4. Create measures using relationships
5. Test cross-filtering behavior

**Part B: BigQuery Schema (2 hours)**
1. Create dimensional model in BigQuery:
```sql
-- Dimension tables
CREATE TABLE dim_products (
  product_id INT64,
  product_name STRING,
  category STRING,
  price FLOAT64
);

CREATE TABLE dim_customers (
  customer_id INT64,
  customer_name STRING,
  region STRING,
  segment STRING
);

CREATE TABLE dim_date (
  date DATE,
  year INT64,
  quarter INT64,
  month INT64
);

-- Fact table
CREATE TABLE fact_sales (
  sale_id INT64,
  date DATE,
  product_id INT64,
  customer_id INT64,
  quantity INT64,
  amount FLOAT64
);
```

2. Create joined view for Looker Studio:
```sql
CREATE VIEW vw_sales_analysis AS
SELECT
  f.sale_id,
  f.date,
  f.quantity,
  f.amount,
  p.product_name,
  p.category,
  c.customer_name,
  c.region,
  d.year,
  d.quarter,
  d.month
FROM fact_sales f
LEFT JOIN dim_products p ON f.product_id = p.product_id
LEFT JOIN dim_customers c ON f.customer_id = c.customer_id
LEFT JOIN dim_date d ON f.date = d.date;
```

3. Connect Looker Studio to view

**Part C: Comparison (30 mins)**
Compare:
- **Relationships**: Power BI visual, BigQuery via JOINs
- **Maintenance**: Power BI easier to modify relationships
- **Performance**: BigQuery pre-joined views faster for Looker Studio
- **Best practice**: Power BI for self-service, BigQuery for governed data

**Deliverables**:
- Power BI data model diagram
- BigQuery schema DDL
- `comparison-008.md`

---

#### Labs 009-011: Additional Calculation Patterns
I'll create brief outlines for these:

**Lab 009**: Dynamic calculations (parameters in both platforms)
**Lab 010**: Conditional formatting and visual calculations
**Lab 011**: Advanced filtering patterns

---

### Section C: Publishing & Collaboration (7 Labs)

#### Lab 012: Publishing & Sharing
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Power BI Service (2 hours)**
1. Sign in to Power BI Desktop
2. Create workspace in Power BI Service
3. Publish report from Desktop to Service
4. Explore Service interface
5. Share with users (assign roles)
6. Create App from workspace
7. View as different users

**Part B: Looker Studio Sharing (1 hour)**
1. Click "Share" in Looker Studio
2. Share options:
   - View link (anyone with link)
   - Edit link (collaborators)
   - Email specific users
3. Embed in website (iframe)
4. Download as PDF
5. Schedule email delivery

**Part C: Comparison**
Compare:
- **Workspace model**: Power BI (enterprise), Looker Studio (link-based)
- **Permissions**: Power BI granular, Looker Studio simpler
- **Governance**: Power BI better for large orgs
- **Ease**: Looker Studio easier for quick sharing

**Deliverables**: Both published, sharing configured

---

#### Lab 013: Scheduled Refresh & Data Updates
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Power BI Scheduled Refresh (2 hours)**
1. Publish report to Service
2. Configure data source credentials
3. Set up scheduled refresh (daily 8 AM)
4. Configure email notifications
5. Manually trigger refresh
6. View refresh history
7. Troubleshoot failures

**Part B: Looker Studio Data Freshness (1 hour)**
1. Data freshness options:
   - Auto-refresh (for Google Sheets)
   - BigQuery data is always live (no refresh needed!)
   - Manual refresh button
   - Scheduled queries in BigQuery (alternative)
2. Create scheduled query in BigQuery:
```sql
-- Scheduled to run daily at 8 AM
CREATE OR REPLACE TABLE dataset.daily_summary AS
SELECT
  DATE(timestamp) as date,
  SUM(sales) as total_sales,
  COUNT(DISTINCT customer_id) as unique_customers
FROM dataset.raw_sales
WHERE DATE(timestamp) = CURRENT_DATE() - 1
GROUP BY date;
```
3. Looker Studio automatically shows updated BigQuery data

**Part C: Comparison**
- **Power BI**: Needs scheduled refresh (imported data)
- **Looker Studio + BigQuery**: Always live (DirectQuery equivalent)
- **Pros**: BigQuery always current
- **Cons**: Power BI refresh gives you control over data processing

**Deliverables**: Both with refresh configured

---

#### Lab 014: Row-Level Security (RLS)
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI RLS (2.5 hours)**
1. In Desktop, Modeling → Manage Roles
2. Create roles:
   - `East Region: [Region] = "East"`
   - `West Region: [Region] = "West"`
   - `Manager: (no filter)`
3. Test in Desktop (View as Role)
4. Publish to Service
5. Assign users to roles
6. Test as different users
7. Dynamic RLS using USERNAME():
```dax
[Email] = USERNAME()
```

**Part B: Looker Studio RLS (2 hours)**
1. RLS in Looker Studio uses data source level security
2. **Option 1: BigQuery Row-Level Security**
```sql
-- Create row access policy
CREATE ROW ACCESS POLICY region_filter
ON dataset.sales_table
GRANT TO ('user:john@company.com')
FILTER USING (region = 'East');

-- View shows filtered data automatically
```

3. **Option 2: Data Credential-based**
   - Each user connects with their own Google credentials
   - BigQuery IAM controls data access
   - Looker Studio inherits permissions

4. **Option 3: Filter by viewer (built-in)**
   - Use "Filter by email" feature
   - Less powerful than Power BI

**Part C: Comparison**
- **Power BI RLS**: More flexible, defined in BI tool
- **BigQuery RLS**: More secure, defined at data level
- **Best practice**: BigQuery RLS for governance, Power BI RLS for flexibility

**Deliverables**: RLS implemented in both platforms

---

#### Labs 015-018: Additional collaboration features
**Lab 015**: Dashboards vs Reports
**Lab 016**: Alerts and subscriptions
**Lab 017**: Mobile layouts and responsive design
**Lab 018**: Embedding in websites (basic)

---

## Week 2: Cloud Data Integration (14 Labs)

### Section D: Azure SQL vs BigQuery (5 Labs)

#### Lab 019: Cloud Data Warehouse Setup
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Azure SQL Database (2 hours)**
1. Create Azure SQL Database (free/Basic tier)
2. Configure firewall
3. Connect via Azure Data Studio / SSMS
4. Create tables (Sales, Products, Customers)
5. Insert sample data
6. Connect Power BI to Azure SQL (Import vs DirectQuery)

**Part B: BigQuery Setup (1 hour)**
1. Enable BigQuery API (if not already)
2. Create dataset: `sales_dw`
3. Create tables using SQL:
```sql
CREATE TABLE sales_dw.sales (...);
CREATE TABLE sales_dw.products (...);
CREATE TABLE sales_dw.customers (...);
```
4. Load data from CSV in Cloud Storage
5. Connect Looker Studio to BigQuery dataset

**Part C: Comparison**
- **Setup**: Azure more complex, BigQuery simpler
- **Cost**: Azure per-database, BigQuery per-query
- **Scaling**: BigQuery auto-scales, Azure requires tier selection
- **BI Integration**: Power BI → Azure native, Looker Studio → BigQuery native

**Deliverables**: Both data warehouses operational

---

#### Lab 020: External Data Sources (PolyBase vs External Tables)
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Azure SQL PolyBase (2.5 hours)**
1. Create Azure Storage Account
2. Upload CSV files to Blob Storage
3. Configure PolyBase in Azure SQL:
```sql
CREATE EXTERNAL DATA SOURCE AzureBlobStorage
WITH (TYPE = BLOB_STORAGE, LOCATION = 'https://...');

CREATE EXTERNAL FILE FORMAT CSVFormat
WITH (FORMAT_TYPE = DELIMITEDTEXT, ...);

CREATE EXTERNAL TABLE ext_orders (...)
WITH (LOCATION = 'orders.csv', DATA_SOURCE = AzureBlobStorage, ...);

SELECT * FROM ext_orders;
```
4. Query external data
5. Connect Power BI to query using external tables

**Part B: BigQuery External Tables (1.5 hours)**
1. Upload CSV to Cloud Storage bucket
2. Create external table in BigQuery:
```sql
CREATE EXTERNAL TABLE sales_dw.ext_orders
OPTIONS (
  format = 'CSV',
  uris = ['gs://your-bucket/orders.csv'],
  skip_leading_rows = 1
);

SELECT * FROM sales_dw.ext_orders;
```
3. Query external data (billed per scan)
4. Connect Looker Studio to external table

**Part C: Comparison**
- **Concept**: Both query external data without importing
- **Performance**: Azure PolyBase caching, BigQuery scans on demand
- **Cost**: Azure included, BigQuery per-query pricing
- **Use case**: BigQuery better for massive CSV files (petabyte scale)

**Deliverables**: Both platforms querying external storage

---

#### Lab 021: Query Optimization for BI
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Azure SQL Optimization (2.5 hours)**
1. Create large fact table (1M rows)
2. Create slow queries (no indexes, complex joins)
3. Measure baseline performance
4. Optimize:
   - Create indexes on foreign keys
   - Create covering indexes
   - Implement columnstore index
   - Create aggregated tables
   - Use query store to monitor
5. Measure improvement
6. Connect Power BI in DirectQuery mode
7. Test dashboard performance

**Part B: BigQuery Optimization (1.5 hours)**
1. Create large table (1M+ rows)
2. Create slow queries (no partitioning, SELECT *)
3. Measure baseline (bytes scanned, time)
4. Optimize:
   - Partition by date
   - Cluster by common filter columns
   - Avoid SELECT *, specify columns
   - Use materialized views for aggregations
   - Denormalize where appropriate
```sql
-- Partitioned and clustered table
CREATE TABLE sales_dw.sales_optimized
PARTITION BY DATE(order_date)
CLUSTER BY customer_id, product_id
AS SELECT * FROM sales_dw.sales;

-- Materialized view
CREATE MATERIALIZED VIEW sales_dw.daily_summary AS
SELECT
  DATE(order_date) as date,
  customer_id,
  SUM(amount) as total_sales
FROM sales_dw.sales_optimized
GROUP BY date, customer_id;
```
5. Measure improvement (should be 10x+ faster)
6. Connect Looker Studio to optimized tables

**Part C: Comparison**
- **Indexes**: Azure uses B-tree indexes, BigQuery uses partitioning/clustering
- **Aggregations**: Both benefit from pre-aggregated tables
- **Best practice**: Azure SQL for transactional, BigQuery for analytical

**Deliverables**: Performance comparison document

---

#### Labs 022-023: Additional data integration patterns
**Lab 022**: Incremental data loading patterns
**Lab 023**: Change data capture (CDC) approaches

---

### Section E: ETL/ELT Pipelines (9 Labs)

#### Lab 024: Azure Data Factory vs Cloud Composer
⬜ **Status**: Not Started
**Time**: 5-6 hours

**Part A: Azure Data Factory Pipeline (3 hours)**
1. Create ADF instance
2. Create linked services (Blob Storage → Azure SQL)
3. Create datasets (source CSV, destination table)
4. Build pipeline:
   - Copy activity (CSV → Azure SQL)
   - Data flow for transformations
   - Stored procedure for post-processing
5. Schedule trigger (daily 6 AM)
6. Monitor execution
7. Power BI refreshes from updated Azure SQL

**Part B: Cloud Composer (Airflow) DAG (2-3 hours)**
1. Create Cloud Composer environment (note: expensive, ~$100/month)
   - *Alternative: Use local Airflow or skip if budget-constrained*
2. Write DAG in Python:
```python
from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from datetime import datetime

dag = DAG(
    'sales_etl_pipeline',
    start_date=datetime(2024, 1, 1),
    schedule_interval='0 6 * * *',  # Daily at 6 AM
)

# Task 1: Load CSV from GCS to BigQuery staging
load_csv = GCSToBigQueryOperator(
    task_id='load_csv_to_staging',
    bucket='your-bucket',
    source_objects=['sales/*.csv'],
    destination_project_dataset_table='sales_dw.staging_sales',
    dag=dag,
)

# Task 2: Transform and load to production table
transform = BigQueryInsertJobOperator(
    task_id='transform_and_load',
    configuration={
        'query': {
            'query': '''
                INSERT INTO sales_dw.production_sales
                SELECT * FROM sales_dw.staging_sales
                WHERE amount > 0
            ''',
            'useLegacySql': False,
        }
    },
    dag=dag,
)

load_csv >> transform
```
3. Deploy DAG
4. Monitor execution
5. Looker Studio shows updated BigQuery data

**Part C: Comparison**
- **Visual vs Code**: ADF visual pipeline, Airflow code-based
- **Flexibility**: Airflow more flexible (Python), ADF easier for simple ETL
- **Cost**: ADF pay-per-execution, Composer fixed monthly cost
- **Integration**: ADF + Power BI native, Composer + BigQuery native
- **Complexity**: ADF easier for non-developers, Airflow better for data engineers

**Deliverables**: Both pipelines running, feeding respective BI tools

---

#### Lab 025: SSIS vs Dataflow
⬜ **Status**: Not Started
**Time**: 5-6 hours

**Part A: SSIS Package (3 hours)**
1. Create SSIS project in Visual Studio
2. Build package:
   - Data flow: CSV → transformations → Azure SQL
   - Control flow: sequence tasks
   - Error handling
3. Deploy to SQL Server
4. Schedule via SQL Server Agent
5. Power BI connects to resulting data

**Part B: Dataflow (Apache Beam) (2-3 hours)**
1. Write Dataflow pipeline in Python:
```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery

def run():
    options = PipelineOptions(
        runner='DataflowRunner',
        project='your-project',
        region='us-central1',
        temp_location='gs://bucket/temp',
    )

    with beam.Pipeline(options=options) as pipeline:
        (pipeline
         | 'Read CSV' >> beam.io.ReadFromText('gs://bucket/sales.csv')
         | 'Parse CSV' >> beam.Map(parse_csv)
         | 'Transform' >> beam.Map(transform_row)
         | 'Write to BigQuery' >> WriteToBigQuery(
             'project:dataset.table',
             schema='date:DATE,amount:FLOAT64,...'
         ))

if __name__ == '__main__':
    run()
```
2. Run on Dataflow (cloud)
3. Monitor in GCP Console
4. Schedule via Cloud Scheduler
5. Looker Studio shows updated data

**Part C: Comparison**
- **Tool**: SSIS visual designer, Dataflow code (Python/Java)
- **Scalability**: SSIS limited, Dataflow auto-scales to petabytes
- **Cost**: SSIS license cost, Dataflow pay-per-use
- **Learning curve**: SSIS easier, Dataflow requires programming
- **Modern approach**: Dataflow is serverless/cloud-native

**Deliverables**: Both ETL solutions operational

---

#### Labs 026-032: Additional pipeline patterns
**Lab 026**: Real-time data streaming (Azure Stream Analytics vs Pub/Sub + Dataflow)
**Lab 027**: Incremental loading patterns
**Lab 028**: Error handling and logging
**Lab 029**: Data quality validation
**Lab 030**: Pipeline orchestration
**Lab 031**: Change data capture (CDC)
**Lab 032**: Complete end-to-end pipeline (source → warehouse → BI)

---

## Week 3: Embedded Analytics & APIs (10 Labs)

### Section F: Embedded Analytics (5 Labs)

#### Lab 033: Azure AD vs Google OAuth Setup
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Power BI Embedded - Azure AD (2 hours)**
1. Create Azure AD app registration
2. Configure API permissions for Power BI
3. Create client secret
4. Grant service principal access to Power BI workspace
5. Test authentication with Postman

**Part B: Looker Studio Embedding (1 hour)**
1. Looker Studio embedding is simpler (just iframe)
2. No OAuth needed for public dashboards
3. For private: Use Google OAuth:
   - Create OAuth client in GCP Console
   - Configure consent screen
   - Implement OAuth flow
4. Test embedding

**Part C: Comparison**
- **Complexity**: Power BI requires Azure AD setup, Looker Studio simpler
- **Security**: Power BI more enterprise-grade
- **Cost**: Power BI Embedded requires capacity ($1/hour), Looker Studio free
- **Use case**: Power BI for SaaS apps, Looker Studio for internal tools

---

#### Lab 034: Build Embedded Web Applications
⬜ **Status**: Not Started
**Time**: 6-8 hours

**Part A: Power BI Embedded Web App (4-5 hours)**
1. Create backend (Python Flask):
   - Authenticate to Azure AD
   - Generate Power BI embed token
   - Return embed config
2. Create frontend (HTML/JS):
   - Load Power BI JavaScript SDK
   - Embed report
   - Add dynamic filtering
3. Deploy to Azure Web App

**Part B: Looker Studio Embedded App (2-3 hours)**
1. Create web page (HTML):
```html
<iframe
  src="https://lookerstudio.google.com/embed/reporting/your-report-id"
  width="100%"
  height="600px"
  frameborder="0">
</iframe>
```
2. Add JavaScript for URL parameters (filtering):
```javascript
var iframe = document.getElementById('looker-iframe');
var region = document.getElementById('region-select').value;
iframe.src = baseUrl + '?params=%7B"region":"' + region + '"%7D';
```
3. Host on any web server (simpler than Power BI)

**Part C: Comparison**
- **Complexity**: Power BI requires backend, Looker Studio is iframe-only
- **Features**: Power BI SDK more powerful (programmatic control)
- **Licensing**: Power BI requires paid capacity, Looker Studio free
- **Enterprise**: Power BI better for ISV scenarios

**Deliverables**: Two web apps with embedded dashboards

---

#### Labs 035-037: Additional embedding scenarios
**Lab 035**: Dynamic filtering and report interaction
**Lab 036**: Row-level security in embedded scenarios
**Lab 037**: Mobile-responsive embedded analytics

---

### Section G: REST APIs & Automation (5 Labs)

#### Lab 038: Power BI REST API vs BigQuery API
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI REST API (2.5 hours)**
Create Python scripts for:
1. List workspaces
2. List reports in workspace
3. List datasets
4. Trigger dataset refresh
5. Get refresh history
6. Export report to PDF
7. Manage user access

```python
import requests
from msal import ConfidentialClientApplication

class PowerBIAPI:
    def __init__(self, client_id, client_secret, tenant_id):
        self.access_token = self._get_token(...)
        self.base_url = 'https://api.powerbi.com/v1.0/myorg'

    def refresh_dataset(self, workspace_id, dataset_id):
        url = f'{self.base_url}/groups/{workspace_id}/datasets/{dataset_id}/refreshes'
        headers = {'Authorization': f'Bearer {self.access_token}'}
        response = requests.post(url, headers=headers)
        return response.json()

    # ... more methods ...
```

**Part B: BigQuery API (1.5 hours)**
Create Python scripts for:
1. List datasets
2. List tables in dataset
3. Run queries programmatically
4. Schedule queries
5. Check job status
6. Export query results

```python
from google.cloud import bigquery

class BigQueryAPI:
    def __init__(self, project_id):
        self.client = bigquery.Client(project=project_id)

    def run_query(self, query):
        query_job = self.client.query(query)
        results = query_job.result()
        return results

    def list_tables(self, dataset_id):
        tables = self.client.list_tables(dataset_id)
        return [table.table_id for table in tables]

    # ... more methods ...
```

**Part C: Comparison**
- **Power BI API**: Manage BI assets (reports, dashboards, refresh)
- **BigQuery API**: Manage data warehouse (tables, queries, jobs)
- **Use case**: Power BI API for BI automation, BigQuery API for data automation
- **Authentication**: Power BI uses Azure AD, BigQuery uses service accounts

**Deliverables**: Automation script libraries for both platforms

---

#### Lab 039: Automated Refresh & Monitoring
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Part A: Power BI Automation (2.5 hours)**
Create system to:
1. Trigger dataset refresh on schedule (via API)
2. Monitor refresh status
3. Get refresh history
4. Send email on failure
5. Log all operations
6. Create monitoring dashboard

**Part B: BigQuery Automation (1.5 hours)**
Create system to:
1. Schedule SQL queries (materialized views refresh)
2. Monitor query jobs
3. Check for failed jobs
4. Send alerts via Cloud Monitoring
5. Log to BigQuery table
6. Create monitoring dashboard in Looker Studio

**Part C: Comparison**
- **Refresh**: Power BI needs manual refresh, BigQuery always live
- **Monitoring**: Both have robust APIs
- **Alerts**: Both support email/webhook alerts

---

#### Labs 040-042: Additional automation scenarios
**Lab 040**: Deployment automation (Dev → Test → Prod)
**Lab 041**: Usage analytics and monitoring
**Lab 042**: Backup and disaster recovery automation

---

## Week 4: Enterprise Integration & Portfolio (8 Labs)

### Section H: Salesforce Integration (3 Labs)

#### Lab 043: Salesforce + Power BI vs Salesforce + Looker Studio
⬜ **Status**: Not Started
**Time**: 6-8 hours

**Part A: Salesforce + Power BI (4-5 hours)**
1. Create Visualforce page
2. Create Apex controller for Azure AD authentication
3. Get Power BI embed token
4. Embed Power BI report in Salesforce
5. Pass Salesforce context (Account ID) to filter Power BI report
6. Test with different records

**Part B: Salesforce + Looker Studio (2-3 hours)**
1. Create Visualforce page with iframe
2. Embed Looker Studio report:
```html
<apex:page standardController="Account">
  <iframe
    src="https://lookerstudio.google.com/embed/reporting/your-report-id?params=%7B%22account_id%22%3A%22{!Account.Id}%22%7D"
    width="100%"
    height="600px">
  </iframe>
</apex:page>
```
3. Pass Salesforce context via URL parameters
4. Create BigQuery view that joins Salesforce data
5. Test with different records

**Part C: Comparison**
- **Complexity**: Power BI more complex (Apex + OAuth), Looker Studio simpler (iframe)
- **Features**: Power BI more interactive, Looker Studio sufficient for viewing
- **Cost**: Power BI Embedded requires capacity, Looker Studio free
- **Enterprise**: Power BI better for complex scenarios

**Deliverables**: Both Salesforce integrations working

---

#### Labs 044-045: Additional Salesforce scenarios
**Lab 044**: Salesforce data connector (pulling SF data into BI)
**Lab 045**: Context-aware dashboards and dynamic RLS

---

### Section I: Advanced Topics & Portfolio (5 Labs)

#### Lab 046: Report Templates & Themes
⬜ **Status**: Not Started
**Time**: 3-4 hours

**Part A: Power BI Templates (2 hours)**
1. Create custom theme JSON
2. Create .pbit template files
3. Build 3 reusable templates

**Part B: Looker Studio Templates (1 hour)**
1. Create report template (copy link)
2. Use "Make a copy" feature
3. Create reusable components

**Part C: Comparison**
- Power BI templates more powerful
- Looker Studio simpler to share

---

#### Lab 047: Performance Optimization Comparison
⬜ **Status**: Not Started
**Time**: 4-5 hours

**Compare both platforms:**
- Data model optimization
- Query optimization
- Visual optimization
- Incremental refresh
- Aggregations

**Deliverables**: Performance best practices guide for both

---

#### Lab 048: Cross-Cloud Integration - The Ultimate Lab
⬜ **Status**: Not Started
**Time**: 6-8 hours

**Objective**: Connect Power BI to BigQuery AND Looker Studio to Azure SQL

**Part A: Power BI → BigQuery (3-4 hours)**
1. Use your existing GCP Weather ETL BigQuery data
2. Connect Power BI Desktop to BigQuery:
   - Get Data → Google BigQuery
   - Sign in with Google account
   - Select Weather project/dataset
3. Import BigQuery tables to Power BI
4. Create comprehensive weather analytics dashboard:
   - Temperature trends
   - Precipitation analysis
   - YoY comparisons
   - Regional weather patterns
5. Add advanced DAX on top of BigQuery data
6. Publish to Power BI Service
7. Configure scheduled refresh (may need gateway)

**Part B: Looker Studio → Azure SQL (2-3 hours)**
1. Install Cloud SQL Proxy or use public IP (with firewall)
2. In Looker Studio:
   - Create data source → MySQL/SQL Server
   - Connect to Azure SQL Database
   - Authenticate
3. Create dashboard on Azure SQL data
4. Compare to Power BI version

**Part C: Architecture Documentation (1 hour)**
Document the complete cross-cloud architecture:
```
Multi-Cloud BI Architecture
├── Data Sources:
│   ├── GCP BigQuery (weather data)
│   └── Azure SQL (transactional data)
├── BI Tools:
│   ├── Power BI: Visualize BigQuery + Azure SQL
│   └── Looker Studio: Visualize BigQuery + Azure SQL
├── ETL:
│   ├── Azure Data Factory
│   └── Cloud Composer (Airflow)
└── Integration Points:
    ├── Power BI ↔ BigQuery connector
    └── Looker Studio ↔ Azure SQL connector
```

**Deliverables**:
- Power BI dashboard on BigQuery data ✅
- Looker Studio dashboard on Azure SQL data ✅
- Architecture diagram ✅
- Cross-cloud integration guide ✅

**Interview Value**: 🌟🌟🌟 Demonstrates true dual-cloud expertise!

---

#### Lab 049: Mobile & Responsive Design
⬜ **Status**: Not Started
**Time**: 3-4 hours

Compare mobile strategies:
- Power BI mobile layouts
- Looker Studio responsive design
- Mobile apps (Power BI has native app)

---

#### Lab 050: Final Portfolio Assembly
⬜ **Status**: Not Started
**Time**: 4-6 hours

**Assemble 5 Portfolio Projects:**

1. **Dual-Cloud Weather Analytics**
   - Power BI + BigQuery dashboard
   - Showcases cross-cloud capability

2. **Azure ETL Pipeline + Power BI**
   - ADF/SSIS → Azure SQL → Power BI
   - Traditional Microsoft stack

3. **GCP Data Pipeline + Looker Studio**
   - Dataflow → BigQuery → Looker Studio
   - Modern Google stack

4. **Embedded Analytics Application**
   - Power BI Embedded web app
   - Looker Studio embedded web app

5. **Salesforce BI Integration**
   - Salesforce + Power BI
   - Salesforce + Looker Studio

**For each project, create:**
- Architecture diagram
- Setup guide
- Demo script (what to say in interviews)
- Screenshots/videos
- GitHub repository (code)

---

## Portfolio Summary

After 50 labs, you'll have:

### ✅ Power BI Expertise (Job Requirement)
- DAX mastery (50+ formulas)
- Power BI Service and scheduling
- Power BI Embedded
- Azure Data Factory integration
- SSIS pipelines
- Salesforce integration
- REST API automation

### ✅ Looker Studio Expertise (Differentiator)
- Calculated fields
- BigQuery integration
- Data transformation in SQL
- Looker Studio embedding
- Cloud Composer pipelines
- Dataflow (Apache Beam)
- Cross-cloud connectors

### ✅ Dual-Cloud Architecture Knowledge
- When to use Power BI vs Looker Studio
- Azure SQL vs BigQuery
- ADF vs Cloud Composer
- SSIS vs Dataflow
- Cross-cloud data integration

### ✅ Unique Market Position
> "I'm one of the few professionals who can architect and deliver BI solutions on both Azure (Power BI) and GCP (Looker Studio/BigQuery), making me valuable for multi-cloud enterprises."

---

## Lab Completion Tracking

### Week 1: BI Fundamentals (18 labs)
- [ ] Labs 001-003: Getting Started (3)
- [ ] Labs 004-011: Calculations (8)
- [ ] Labs 012-018: Collaboration (7)

### Week 2: Data Integration (14 labs)
- [ ] Labs 019-023: DW & Optimization (5)
- [ ] Labs 024-032: ETL/ELT Pipelines (9)

### Week 3: Embedded & APIs (10 labs)
- [ ] Labs 033-037: Embedded Analytics (5)
- [ ] Labs 038-042: APIs & Automation (5)

### Week 4: Enterprise & Portfolio (8 labs)
- [ ] Labs 043-045: Salesforce Integration (3)
- [ ] Labs 046-050: Advanced & Portfolio (5)

**Total: 50 hands-on labs** 🎯

---

## Time Estimate

- **Single-platform approach**: 3-4 weeks (original plan)
- **Dual-platform approach**: 4-6 weeks
  - If 10 hours/day: ~5 weeks
  - If 12 hours/day: ~4 weeks

---

## Cost Estimate

| Platform | Service | Cost |
|----------|---------|------|
| **Azure** | Power BI Desktop | Free |
| | Power BI Service | Free tier |
| | Azure SQL | $5-15/month (Basic tier) |
| | Azure Data Factory | ~$10/month (light use) |
| | SQL Server Developer | Free |
| | **Azure Subtotal** | **~$15-25/month** |
| **GCP** | Looker Studio | Free |
| | BigQuery | Free tier (1TB queries/month) |
| | Cloud Storage | Free tier (5GB) |
| | Dataflow | Pay-per-use (~$10-20 for labs) |
| | Cloud Composer | $100/month (skip if budget-limited) |
| | **GCP Subtotal** | **~$10-50/month** |
| **Total** | | **$25-75/month** |

**With free tier credits**: $0-25/month for 4-6 weeks

---

## Ready to Start?

Your first lab is:

### **Lab 001: Dual-Cloud Environment Setup**
**Part A**: Install Power BI + Azure setup
**Part B**: Access Looker Studio + BigQuery setup
**Part C**: Compare both environments

**Shall I provide detailed step-by-step instructions for Lab 001?**

Just say: **"Let's start Lab 001"** and I'll guide you through every step!

---

This dual-cloud approach will make you **one of the most unique BI professionals in the market**. Most people know ONE platform deeply - you'll know TWO. 🚀
