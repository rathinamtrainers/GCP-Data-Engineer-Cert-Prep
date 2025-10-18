#!/usr/bin/env python3
"""
Simple BigQuery Loader

Loads weather data from GCS JSON to BigQuery without Apache Beam.
This is a workaround for Python 3.13 compatibility issues.

Usage:
    python simple_loader.py gs://bucket/path/file.json
"""

import sys
import json
from datetime import datetime, timezone
from pathlib import Path

from google.cloud import storage, bigquery

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.data_validator import (
    WeatherDataValidator,
    kelvin_to_celsius,
    celsius_to_fahrenheit
)


def parse_gcs_path(gcs_path):
    """Parse GCS path into bucket and blob."""
    if not gcs_path.startswith('gs://'):
        raise ValueError(f"Invalid GCS path: {gcs_path}")

    path_parts = gcs_path[5:].split('/', 1)
    bucket_name = path_parts[0]
    blob_path = path_parts[1] if len(path_parts) > 1 else ''

    return bucket_name, blob_path


def download_json_from_gcs(gcs_path):
    """Download JSON file from GCS."""
    bucket_name, blob_path = parse_gcs_path(gcs_path)

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_path)

    json_str = blob.download_as_string()
    return json.loads(json_str)


def list_gcs_files(gcs_pattern):
    """List all files matching a GCS pattern with wildcards."""
    bucket_name, blob_prefix = parse_gcs_path(gcs_pattern)

    # Remove wildcard and get directory
    if '*' in blob_prefix:
        blob_prefix = blob_prefix.rsplit('*', 1)[0]

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blobs = bucket.list_blobs(prefix=blob_prefix)

    # Filter for JSON files only
    files = [f"gs://{bucket_name}/{blob.name}"
             for blob in blobs
             if blob.name.endswith('.json')]

    return files


def download_multiple_files(gcs_pattern):
    """Download and merge multiple JSON files from GCS matching a pattern."""
    files = list_gcs_files(gcs_pattern)

    if not files:
        print(f"   ✗ No files found matching pattern: {gcs_pattern}")
        return []

    print(f"   Found {len(files)} file(s) matching pattern")

    all_data = []
    for file_path in files:
        print(f"   - Downloading: {file_path.split('/')[-1]}")
        data = download_json_from_gcs(file_path)

        # Handle both list and single object responses
        if isinstance(data, list):
            all_data.extend(data)
        else:
            all_data.append(data)

    return all_data


def transform_weather_record(data):
    """Transform raw API response to BigQuery format."""
    try:
        # Extract timestamp
        dt_unix = data.get('dt')
        if not dt_unix:
            print(f"Warning: Missing timestamp in record for {data.get('name')}")
            return None

        timestamp = datetime.fromtimestamp(dt_unix, tz=timezone.utc)
        date = timestamp.date()

        # Extract temperatures (convert from Kelvin)
        main_data = data.get('main', {})
        temp_k = main_data.get('temp')
        temp_c = kelvin_to_celsius(temp_k) if temp_k else None
        temp_f = celsius_to_fahrenheit(temp_c) if temp_c else None

        feels_like_k = main_data.get('feels_like')
        feels_like_c = kelvin_to_celsius(feels_like_k) if feels_like_k else None

        temp_min_k = main_data.get('temp_min')
        temp_min_c = kelvin_to_celsius(temp_min_k) if temp_min_k else None

        temp_max_k = main_data.get('temp_max')
        temp_max_c = kelvin_to_celsius(temp_max_k) if temp_max_k else None

        # Extract weather conditions
        weather_list = data.get('weather', [])
        weather_main = weather_list[0].get('main') if weather_list else None
        weather_description = weather_list[0].get('description') if weather_list else None

        # Extract wind data
        wind_data = data.get('wind', {})

        # Extract sunrise/sunset
        sys_data = data.get('sys', {})
        sunrise_unix = sys_data.get('sunrise')
        sunset_unix = sys_data.get('sunset')

        sunrise_timestamp = datetime.fromtimestamp(sunrise_unix, tz=timezone.utc) if sunrise_unix else None
        sunset_timestamp = datetime.fromtimestamp(sunset_unix, tz=timezone.utc) if sunset_unix else None

        # Build BigQuery record
        record = {
            'date': str(date),
            'timestamp': timestamp.isoformat(),
            'city': data.get('name'),
            'country': sys_data.get('country'),
            'latitude': data.get('coord', {}).get('lat'),
            'longitude': data.get('coord', {}).get('lon'),
            'temperature_c': temp_c,
            'temperature_f': temp_f,
            'feels_like_c': feels_like_c,
            'temp_min_c': temp_min_c,
            'temp_max_c': temp_max_c,
            'pressure_hpa': main_data.get('pressure'),
            'humidity_percent': main_data.get('humidity'),
            'visibility_m': data.get('visibility'),
            'wind_speed_ms': wind_data.get('speed'),
            'wind_direction_deg': wind_data.get('deg'),
            'clouds_percent': data.get('clouds', {}).get('all'),
            'weather_main': weather_main,
            'weather_description': weather_description,
            'sunrise_timestamp': sunrise_timestamp.isoformat() if sunrise_timestamp else None,
            'sunset_timestamp': sunset_timestamp.isoformat() if sunset_timestamp else None,
            'data_source': data.get('api_source', 'OpenWeather'),
            'ingestion_timestamp': datetime.now(timezone.utc).isoformat(),
        }

        return record

    except Exception as e:
        print(f"Error transforming record: {e}")
        return None


def load_to_bigquery(records, table_id):
    """Load records to BigQuery."""
    bq_client = bigquery.Client()

    # Configure load job
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
    )

    # Insert rows
    errors = bq_client.insert_rows_json(table_id, records)

    if errors:
        print(f"Errors loading to BigQuery: {errors}")
        return False

    return True


def main():
    """Main execution."""
    if len(sys.argv) < 2:
        print("Usage: python simple_loader.py gs://bucket/path/file.json")
        sys.exit(1)

    gcs_path = sys.argv[1]
    table_id = "data-engineer-475516.weather_data.daily"

    print("=" * 70)
    print("Simple BigQuery Loader")
    print("=" * 70)
    print(f"Input: {gcs_path}")
    print(f"Output: {table_id}")
    print()

    # Download data from GCS
    print("1. Downloading data from GCS...")
    if '*' in gcs_path:
        weather_data = download_multiple_files(gcs_path)
        print(f"   ✓ Downloaded {len(weather_data)} records from multiple files")
    else:
        weather_data = download_json_from_gcs(gcs_path)
        print(f"   ✓ Downloaded {len(weather_data)} records")

    # Transform records
    print("2. Transforming records...")
    validator = WeatherDataValidator()
    records = []
    valid_count = 0
    invalid_count = 0

    for data in weather_data:
        record = transform_weather_record(data)
        if record:
            # Validate
            is_valid, errors = validator.validate_record(record)
            if is_valid:
                records.append(record)
                valid_count += 1
                city = record['city']
                temp = record['temperature_c']
                print(f"   ✓ {city}: {temp}°C")
            else:
                invalid_count += 1
                print(f"   ✗ Invalid: {errors}")

    print(f"   Valid: {valid_count}, Invalid: {invalid_count}")

    # Load to BigQuery
    print("3. Loading to BigQuery...")
    success = load_to_bigquery(records, table_id)

    if success:
        print(f"   ✓ Loaded {len(records)} records to {table_id}")
        print()
        print("=" * 70)
        print("✓ Pipeline completed successfully!")
        print("=" * 70)
    else:
        print("   ✗ Failed to load to BigQuery")
        sys.exit(1)


if __name__ == "__main__":
    main()
