"""
Weather ETL DAG for Cloud Composer

This DAG orchestrates the daily weather data ETL pipeline:
1. Fetch weather data from OpenWeather API
2. Transform data with Dataflow
3. Validate data quality in BigQuery

Schedule: Daily at 6:00 AM UTC
"""

import os
from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.operators.dataflow import DataflowCreatePythonJobOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCheckOperator
from airflow.utils.dates import days_ago


# Default arguments
DEFAULT_ARGS = {
    'owner': 'data-engineer',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# Configuration from environment or defaults
PROJECT_ID = os.getenv('GCP_PROJECT_ID', 'data-engineer-475516')
REGION = os.getenv('GCP_REGION', 'us-central1')
RAW_BUCKET = os.getenv('RAW_BUCKET', 'data-engineer-475516-weather-raw')
STAGING_BUCKET = os.getenv('STAGING_BUCKET', 'data-engineer-475516-weather-staging')
TEMP_BUCKET = os.getenv('TEMP_BUCKET', 'data-engineer-475516-weather-temp')
DATASET = os.getenv('BIGQUERY_DATASET', 'weather_data')
TABLE = os.getenv('BIGQUERY_TABLE', 'daily')

# Paths
SCRIPTS_DIR = '/home/airflow/gcs/dags/scripts'  # Composer default location
INGESTION_SCRIPT = f'{SCRIPTS_DIR}/fetch_weather.py'
PIPELINE_SCRIPT = f'{SCRIPTS_DIR}/weather_pipeline.py'


def fetch_weather_data(**context):
    """
    Fetch weather data from API.

    This function is called by PythonOperator.
    In production, you'd import and call the fetch_weather module.
    """
    import subprocess
    import sys

    execution_date = context['ds']  # YYYY-MM-DD format
    cmd = [
        sys.executable,
        INGESTION_SCRIPT,
        f'--date={execution_date}'
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        raise Exception(f"Weather data fetch failed: {result.stderr}")

    print(result.stdout)
    return f"gs://{RAW_BUCKET}/raw/{execution_date.replace('-', '')}/*.json"


def validate_data_quality(**context):
    """
    Validate data quality after pipeline runs.

    Checks record counts and data quality metrics.
    """
    from google.cloud import bigquery

    client = bigquery.Client(project=PROJECT_ID)
    execution_date = context['ds']

    # Check record count
    query = f"""
    SELECT COUNT(*) as record_count
    FROM `{PROJECT_ID}.{DATASET}.{TABLE}`
    WHERE date = '{execution_date}'
    """

    result = client.query(query).result()
    record_count = list(result)[0].record_count

    print(f"Found {record_count} records for {execution_date}")

    if record_count == 0:
        raise Exception(f"No records found for {execution_date}")

    # Check data quality
    quality_query = f"""
    SELECT
        COUNT(*) as total_records,
        SUM(CASE WHEN temperature_c IS NULL THEN 1 ELSE 0 END) as missing_temp,
        SUM(CASE WHEN humidity_percent IS NULL THEN 1 ELSE 0 END) as missing_humidity,
        SUM(CASE WHEN temperature_c < -50 OR temperature_c > 60 THEN 1 ELSE 0 END) as invalid_temp
    FROM `{PROJECT_ID}.{DATASET}.{TABLE}`
    WHERE date = '{execution_date}'
    """

    result = client.query(quality_query).result()
    quality_metrics = list(result)[0]

    print(f"Data Quality Metrics:")
    print(f"  Total records: {quality_metrics.total_records}")
    print(f"  Missing temperature: {quality_metrics.missing_temp}")
    print(f"  Missing humidity: {quality_metrics.missing_humidity}")
    print(f"  Invalid temperature: {quality_metrics.invalid_temp}")

    # Alert if quality issues exceed threshold
    if quality_metrics.invalid_temp > 0:
        raise Exception(f"Found {quality_metrics.invalid_temp} records with invalid temperature")

    return quality_metrics


# Create DAG
with DAG(
    dag_id='weather_etl_daily',
    default_args=DEFAULT_ARGS,
    description='Daily weather data ETL pipeline',
    schedule_interval='0 6 * * *',  # 6:00 AM UTC daily
    catchup=False,  # Don't backfill
    max_active_runs=1,
    tags=['weather', 'etl', 'bigquery', 'dataflow'],
) as dag:

    # Task 1: Fetch weather data from API
    fetch_data = PythonOperator(
        task_id='fetch_weather_data',
        python_callable=fetch_weather_data,
        provide_context=True,
    )

    # Task 2: Transform data with Dataflow
    # Note: In Composer, use DataflowCreatePythonJobOperator
    # For simplicity, using BashOperator here
    transform_data = BashOperator(
        task_id='transform_weather_data',
        bash_command=f"""
        python {PIPELINE_SCRIPT} \
            --input gs://{RAW_BUCKET}/raw/{{{{ ds_nodash }}}}/*.json \
            --output {PROJECT_ID}:{DATASET}.{TABLE} \
            --runner DataflowRunner \
            --project {PROJECT_ID} \
            --region {REGION} \
            --temp_location gs://{TEMP_BUCKET}/dataflow/temp \
            --staging_location gs://{STAGING_BUCKET}/dataflow/staging \
            --max_num_workers 2 \
            --machine_type n1-standard-1
        """,
    )

    # Alternative: Use DataflowCreatePythonJobOperator (commented out)
    # transform_data = DataflowCreatePythonJobOperator(
    #     task_id='transform_weather_data',
    #     py_file=PIPELINE_SCRIPT,
    #     job_name='weather-transform-{{ ds_nodash }}',
    #     options={
    #         'input': f'gs://{RAW_BUCKET}/raw/{{{{ ds_nodash }}}}/*.json',
    #         'output': f'{PROJECT_ID}:{DATASET}.{TABLE}',
    #         'temp_location': f'gs://{TEMP_BUCKET}/dataflow/temp',
    #         'staging_location': f'gs://{STAGING_BUCKET}/dataflow/staging',
    #         'max_num_workers': 2,
    #         'machine_type': 'n1-standard-1',
    #     },
    #     project_id=PROJECT_ID,
    #     location=REGION,
    # )

    # Task 3: Validate data quality
    validate_quality = PythonOperator(
        task_id='validate_data_quality',
        python_callable=validate_data_quality,
        provide_context=True,
    )

    # Task 4: Check record count (using BigQueryCheckOperator)
    check_records = BigQueryCheckOperator(
        task_id='check_record_count',
        sql=f"""
        SELECT COUNT(*) > 0
        FROM `{PROJECT_ID}.{DATASET}.{TABLE}`
        WHERE date = '{{{{ ds }}}}'
        """,
        use_legacy_sql=False,
    )

    # Task dependencies
    fetch_data >> transform_data >> validate_quality >> check_records


# Documentation
dag.doc_md = """
# Weather ETL Pipeline

This DAG runs daily to fetch weather data from OpenWeather API, transform it with Dataflow,
and load it into BigQuery for analysis.

## Pipeline Steps

1. **Fetch Weather Data** - Calls OpenWeather API for configured cities
2. **Transform Data** - Apache Beam pipeline converts JSON to BigQuery format
3. **Validate Quality** - Checks data quality metrics
4. **Check Records** - Verifies records were loaded

## Configuration

- **Schedule**: Daily at 6:00 AM UTC
- **Cities**: Configured in .env (default: 10 major cities)
- **Retry**: 2 attempts with 5-minute delay
- **Dataflow**: Max 2 workers, n1-standard-1 machines

## BigQuery Table

Table: `{PROJECT_ID}.{DATASET}.{TABLE}`
- Partitioned by: date
- Clustered by: city, country

## Monitoring

Check Airflow logs for:
- API fetch success/failures
- Dataflow job status
- Data quality metrics
- Record counts

## Troubleshooting

- **API failures**: Check API key and rate limits
- **Dataflow errors**: Check logs in Cloud Logging
- **No records**: Verify bucket paths and permissions
"""
