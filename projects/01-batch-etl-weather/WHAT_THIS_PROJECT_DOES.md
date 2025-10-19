# What This Project Does - Simple Explanation

## The Big Picture

This project builds an automated weather data pipeline that collects temperature and weather information from cities around the world, processes it, and makes it available for analysis and visualization.

Think of it like a news aggregator, but for weather data - it automatically fetches fresh data daily, organizes it in a database, and prepares it for creating dashboards and reports.

---

## What Problem Does This Solve?

**Before this pipeline**:
- Weather data is scattered across different APIs
- Data comes in messy formats (JSON with nested fields)
- Hard to compare weather across multiple cities
- Can't easily track trends over time
- Manual data collection is time-consuming

**After this pipeline**:
- Automated daily data collection (no manual work)
- Clean, structured data in a database
- Easy to query: "What was the temperature in London last week?"
- Data ready for dashboards and charts
- Historical trends tracked automatically

---

## How It Works (Non-Technical)

### Step 1: Fetch Weather Data
Every day, the pipeline connects to OpenWeather API and asks: "What's the current weather in these cities?"
- Cities tracked: London, Paris, New York, Tokyo, Sydney, Mumbai, Cairo, São Paulo, Moscow
- Data collected: Temperature, humidity, wind speed, weather conditions, etc.

### Step 2: Store Raw Data
The original data gets saved in Cloud Storage (think of it as Google Drive for data)
- Organized by date: `2025-01-19/weather.json`
- Never modified or deleted
- Serves as backup and audit trail

### Step 3: Clean and Transform
An Apache Beam pipeline (fancy data processing tool) cleans up the data:
- Converts temperatures: Kelvin → Celsius → Fahrenheit
- Extracts important fields: city, temperature, humidity, pressure
- Validates data: "Is this temperature realistic? (-50°C to 60°C)"
- Removes bad or duplicate data

### Step 4: Load into Database
Clean data goes into BigQuery (Google's data warehouse):
- Organized in a table: `weather_data.daily`
- Optimized for fast queries
- Partitioned by date for efficiency
- Clustered by city for speed

### Step 5: Visualize (Coming Soon)
Looker Studio dashboards will show:
- Temperature trends over time
- Compare weather across cities
- See patterns: "Paris is usually colder than Cairo"

### Step 6: Automate Everything (Coming Soon)
Cloud Composer (like a robot scheduler) will:
- Run the pipeline every day at 6:00 AM UTC
- Handle errors automatically
- Send alerts if something breaks

---

## Real-World Example

**Scenario**: You want to know "How has the temperature in London changed over the last month?"

**Without this pipeline**:
1. Manually call the API 30 times (once per day)
2. Download 30 separate files
3. Open each file and find the temperature field
4. Copy-paste into Excel
5. Clean up the data
6. Create a chart
7. Time spent: 2-3 hours

**With this pipeline**:
1. Run this SQL query in BigQuery:
   ```sql
   SELECT date, temperature_c
   FROM weather_data.daily
   WHERE city = 'London'
     AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
   ORDER BY date
   ```
2. Click "Explore in Looker Studio" → Instant chart
3. Time spent: 30 seconds

---

## Technologies Used (What They Do)

| Technology | What It Does | Everyday Analogy |
|------------|--------------|------------------|
| **OpenWeather API** | Provides weather data | Like asking Google for weather info |
| **Cloud Storage** | Stores raw data files | Like Google Drive for data files |
| **Apache Beam** | Processes and cleans data | Like a data factory assembly line |
| **Dataflow** | Runs Beam pipelines at scale | Like renting cloud computers to run your code |
| **BigQuery** | Stores and queries data | Like Excel, but for billions of rows |
| **Cloud Composer** | Schedules daily runs | Like a robot that runs your code at 6 AM |
| **Looker Studio** | Creates dashboards | Like Tableau or PowerBI for charts |

---

## What You Can Do With This Data

### Business Analytics
- **Retail**: "Should we stock more ice cream in cities with high temperatures?"
- **Insurance**: "Which cities have severe weather patterns?"
- **Travel**: "Best time to visit Paris based on weather history?"

### Personal Projects
- Plan vacations based on historical weather
- Track climate trends in your favorite cities
- Compare weather patterns across continents

### Learning
- Understand how data pipelines work
- Practice SQL queries on real data
- Learn cloud technologies (GCP)

---

## Current Status

### ✅ What's Working (Phase 1)
- **Data Collection**: Successfully fetched weather for 9 cities
- **Data Processing**: Apache Beam pipeline working perfectly
- **Data Storage**: 18 weather records loaded into BigQuery
- **Automation Script**: `run_dataflow_job.sh` makes deployment easy

### ⏳ In Progress (Phase 2)
- **Daily Automation**: Setting up Cloud Composer to run daily
- **Error Handling**: Automatic retries and alerts

### 📅 Planned (Phase 3)
- **Dashboard**: Visual charts and trends in Looker Studio
- **More Cities**: Expand to 50+ cities worldwide
- **Historical Data**: Backfill 1 year of historical weather

---

## How to Use It

### Quick Start
```bash
# 1. Navigate to project
cd projects/01-batch-etl-weather

# 2. Activate Python environment
source venv-beam/bin/activate

# 3. Set your GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your-key.json

# 4. Run the pipeline
bash run_dataflow_job.sh

# 5. Wait 3-4 minutes for completion

# 6. Query the data
bq query "SELECT * FROM weather_data.daily LIMIT 10"
```

### Query Examples

**Get today's weather**:
```sql
SELECT city, temperature_c, weather_main
FROM `weather_data.daily`
WHERE date = CURRENT_DATE()
```

**Compare temperatures across cities**:
```sql
SELECT
  city,
  AVG(temperature_c) as avg_temp,
  MIN(temperature_c) as min_temp,
  MAX(temperature_c) as max_temp
FROM `weather_data.daily`
GROUP BY city
ORDER BY avg_temp DESC
```

**Find coldest day in London**:
```sql
SELECT date, temperature_c, weather_main
FROM `weather_data.daily`
WHERE city = 'London'
ORDER BY temperature_c ASC
LIMIT 1
```

---

## Architecture Diagram (Simple Version)

```
┌─────────────┐
│   Internet  │
│  (Weather   │
│     API)    │
└──────┬──────┘
       │ 1. Fetch data daily
       ↓
┌─────────────┐
│   Storage   │  ← Raw data saved here
│  (Cloud     │
│   Storage)  │
└──────┬──────┘
       │ 2. Process data
       ↓
┌─────────────┐
│  Transform  │  ← Clean, validate, convert
│  (Dataflow) │
└──────┬──────┘
       │ 3. Load clean data
       ↓
┌─────────────┐
│  Database   │  ← Query-ready data
│  (BigQuery) │
└──────┬──────┘
       │ 4. Create charts
       ↓
┌─────────────┐
│  Dashboard  │  ← Visual reports
│   (Looker)  │
└─────────────┘

     Scheduled by Cloud Composer
         (Runs daily at 6 AM)
```

---

## Key Features

### 1. Automated Data Collection
- No manual work needed
- Runs daily without intervention
- Handles API failures gracefully

### 2. Data Quality Assurance
- Validates all temperature readings
- Checks for missing fields
- Rejects invalid data
- Logs all issues for review

### 3. Scalable Architecture
- Can handle 10 cities or 10,000 cities
- Automatically scales compute resources
- Cost-effective (only pay when running)

### 4. Optimized for Speed
- **Partitioning**: Data organized by date (query only what you need)
- **Clustering**: Sorted by city (faster city-specific queries)
- **Result**: Queries that would take minutes run in seconds

### 5. Cost-Effective
- Daily run costs: ~$0.05-0.10
- Monthly cost: ~$2-3 (without Composer)
- BigQuery free tier covers most queries
- Can process millions of records for pennies

---

## Learning Outcomes

By building this project, you learn:

### Technical Skills
- **APIs**: How to fetch data from external sources
- **Data Processing**: Transform messy data into clean data
- **Cloud Computing**: Deploy pipelines to Google Cloud
- **SQL**: Query and analyze data
- **Python**: Write data processing code
- **Automation**: Schedule recurring jobs

### Data Engineering Concepts
- **ETL Pipelines**: Extract, Transform, Load pattern
- **Data Lakes**: Store raw data for flexibility
- **Data Warehouses**: Store clean data for analytics
- **Idempotency**: Design safe-to-rerun pipelines
- **Partitioning**: Optimize large datasets
- **Orchestration**: Automate workflows

### GCP Services
- Cloud Storage (data lake)
- Dataflow (data processing)
- BigQuery (data warehouse)
- Cloud Composer (workflow scheduler)
- IAM (security and permissions)

---

## Why This Matters

### For Learning
This project teaches professional data engineering practices:
- Same tools used by companies like Spotify, Twitter, Airbnb
- Hands-on experience with Google Cloud Platform
- Portfolio project to show employers
- Covers 5 sections of GCP Data Engineer certification

### For Real-World Applications
The patterns you learn apply to:
- **E-commerce**: Process order data, track inventory
- **Finance**: Analyze stock prices, detect fraud
- **Healthcare**: Aggregate patient data, monitor trends
- **IoT**: Process sensor data from devices
- **Marketing**: Track user behavior, measure campaigns

The weather data is just an example - the same pipeline structure works for ANY data source.

---

## Common Questions

### Q: How much does it cost to run?
**A**: ~$2-3 per month if you run daily. Each pipeline run costs about $0.05.

### Q: How long does it take to set up?
**A**: 1-2 hours for first-time setup. Future runs take 3-4 minutes.

### Q: Do I need to be a programmer?
**A**: Basic Python and SQL knowledge helps, but the code is well-documented and you can learn as you go.

### Q: What if the pipeline fails?
**A**: The pipeline has error handling and logs. You can re-run it safely - it's idempotent (won't create duplicates).

### Q: Can I add more cities?
**A**: Yes! Just edit the city list in `fetch_weather.py` and re-run.

### Q: Can I use a different data source?
**A**: Absolutely! Replace the OpenWeather API with any other API (stock prices, COVID data, etc.) and adjust the transformation logic.

---

## Next Steps

### If You're New to This
1. Read the [README.md](README.md) for detailed setup
2. Follow [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for essential commands
3. Run the pipeline and explore the data in BigQuery
4. Try the example SQL queries above

### If You're Ready to Dig Deeper
1. Study [DATAFLOW_DEPLOYMENT_SUCCESS.md](DATAFLOW_DEPLOYMENT_SUCCESS.md) for technical details
2. Modify the code to add more cities or data fields
3. Set up Cloud Composer for daily automation
4. Create a Looker Studio dashboard

### If You Want to Extend This
1. Add forecasts (next 7 days weather prediction)
2. Send email alerts for extreme weather
3. Compare actual vs forecast accuracy
4. Add historical data (backfill past 365 days)
5. Build a simple web app to display data

---

## Summary

**What it does**: Automatically collects, processes, and stores weather data from cities worldwide.

**Why it's useful**: Makes messy API data clean and queryable in seconds.

**What you learn**: Real-world data engineering skills and GCP services.

**Time to run**: 3-4 minutes per day.

**Cost**: ~$2-3 per month.

**Difficulty**: Beginner to Intermediate.

**Status**: Working and production-ready for Phase 1 (data pipeline). Phase 2 (automation) in progress.

---

**Ready to explore?** Start with the [README.md](README.md) or jump straight to running the pipeline with `bash run_dataflow_job.sh`!
