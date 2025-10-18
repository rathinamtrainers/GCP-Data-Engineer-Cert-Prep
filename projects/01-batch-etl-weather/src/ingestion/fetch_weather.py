#!/usr/bin/env python3
"""
Weather Data Ingestion Script

Fetches current weather data from OpenWeather API for configured cities
and uploads to Google Cloud Storage.

Usage:
    python fetch_weather.py [--date YYYY-MM-DD] [--dry-run]

Environment Variables (from .env):
    OPENWEATHER_API_KEY: Your OpenWeather API key
    RAW_BUCKET: GCS bucket for raw data
    CITIES: Comma-separated list of cities
"""

import os
import sys
import json
import time
import logging
import argparse
from datetime import datetime, timezone
from typing import Dict, List, Optional
from pathlib import Path

import requests
from google.cloud import storage
from dotenv import load_dotenv
import colorlog


# Configure colored logging
handler = colorlog.StreamHandler()
handler.setFormatter(colorlog.ColoredFormatter(
    '%(log_color)s%(levelname)-8s%(reset)s %(message)s',
    log_colors={
        'DEBUG': 'cyan',
        'INFO': 'green',
        'WARNING': 'yellow',
        'ERROR': 'red',
        'CRITICAL': 'red,bg_white',
    }
))

logger = colorlog.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


class WeatherAPIClient:
    """Client for fetching weather data from OpenWeather API."""

    def __init__(self, api_key: str, base_url: str = "https://api.openweathermap.org/data/2.5/weather"):
        """
        Initialize the Weather API client.

        Args:
            api_key: OpenWeather API key
            base_url: API endpoint URL
        """
        self.api_key = api_key
        self.base_url = base_url
        self.session = requests.Session()

    def fetch_city_weather(self, city: str, max_retries: int = 3) -> Optional[Dict]:
        """
        Fetch weather data for a specific city.

        Args:
            city: City name
            max_retries: Maximum number of retry attempts

        Returns:
            Weather data as dictionary, or None if failed
        """
        params = {
            'q': city,
            'appid': self.api_key,
            'units': 'standard'  # Kelvin
        }

        for attempt in range(max_retries):
            try:
                logger.info(f"Fetching weather for {city} (attempt {attempt + 1}/{max_retries})")
                response = self.session.get(self.base_url, params=params, timeout=10)

                # Check rate limiting
                if response.status_code == 429:
                    retry_after = int(response.headers.get('Retry-After', 60))
                    logger.warning(f"Rate limited. Waiting {retry_after} seconds...")
                    time.sleep(retry_after)
                    continue

                response.raise_for_status()
                data = response.json()

                # Add metadata
                data['fetch_timestamp'] = datetime.now(timezone.utc).isoformat()
                data['api_source'] = 'OpenWeather'

                logger.info(f"✓ Successfully fetched weather for {city}")
                return data

            except requests.exceptions.Timeout:
                logger.warning(f"Timeout fetching {city}, retrying...")
                time.sleep(2 ** attempt)  # Exponential backoff

            except requests.exceptions.RequestException as e:
                logger.error(f"Error fetching {city}: {e}")
                if attempt < max_retries - 1:
                    time.sleep(2 ** attempt)
                else:
                    logger.error(f"Failed to fetch {city} after {max_retries} attempts")

        return None

    def fetch_multiple_cities(self, cities: List[str], delay_seconds: float = 1.0) -> List[Dict]:
        """
        Fetch weather data for multiple cities with rate limiting.

        Args:
            cities: List of city names
            delay_seconds: Delay between requests (for rate limiting)

        Returns:
            List of weather data dictionaries
        """
        weather_data = []

        for i, city in enumerate(cities):
            data = self.fetch_city_weather(city)
            if data:
                weather_data.append(data)

            # Rate limiting: Free tier allows 60 calls/minute
            if i < len(cities) - 1:
                logger.debug(f"Waiting {delay_seconds}s before next request...")
                time.sleep(delay_seconds)

        logger.info(f"Successfully fetched weather for {len(weather_data)}/{len(cities)} cities")
        return weather_data


class GCSUploader:
    """Handles uploading data to Google Cloud Storage."""

    def __init__(self, bucket_name: str):
        """
        Initialize GCS uploader.

        Args:
            bucket_name: Name of the GCS bucket
        """
        self.bucket_name = bucket_name
        self.client = storage.Client()
        self.bucket = self.client.bucket(bucket_name)

    def upload_json(self, data: List[Dict], blob_path: str) -> bool:
        """
        Upload JSON data to GCS.

        Args:
            data: List of weather data dictionaries
            blob_path: Path in GCS bucket (e.g., 'raw/20250118/weather-123456.json')

        Returns:
            True if successful, False otherwise
        """
        try:
            blob = self.bucket.blob(blob_path)

            # Convert to JSON
            json_data = json.dumps(data, indent=2, ensure_ascii=False)

            # Upload
            blob.upload_from_string(
                json_data,
                content_type='application/json'
            )

            logger.info(f"✓ Uploaded to gs://{self.bucket_name}/{blob_path}")
            logger.info(f"  Size: {len(json_data)} bytes ({len(data)} records)")
            return True

        except Exception as e:
            logger.error(f"Failed to upload to GCS: {e}")
            return False

    def save_local_copy(self, data: List[Dict], file_path: str):
        """
        Save a local copy of the data (for debugging).

        Args:
            data: List of weather data dictionaries
            file_path: Local file path
        """
        try:
            Path(file_path).parent.mkdir(parents=True, exist_ok=True)
            with open(file_path, 'w') as f:
                json.dump(data, f, indent=2)
            logger.info(f"✓ Saved local copy to {file_path}")
        except Exception as e:
            logger.error(f"Failed to save local copy: {e}")


def load_config() -> Dict:
    """
    Load configuration from environment variables.

    Returns:
        Configuration dictionary
    """
    # Load .env file
    env_path = Path(__file__).parent.parent.parent / 'config' / '.env'
    load_dotenv(env_path)

    # Required variables
    api_key = os.getenv('OPENWEATHER_API_KEY')
    if not api_key or api_key == 'YOUR_API_KEY_HERE':
        logger.error("OPENWEATHER_API_KEY not set in .env file")
        logger.error("Sign up at https://openweathermap.org/api to get your API key")
        sys.exit(1)

    bucket_name = os.getenv('RAW_BUCKET')
    if not bucket_name:
        logger.error("RAW_BUCKET not set in .env file")
        sys.exit(1)

    # Parse cities
    cities_str = os.getenv('CITIES', 'London,Paris,NewYork,Tokyo,Sydney')
    cities = [city.strip() for city in cities_str.split(',')]

    config = {
        'api_key': api_key,
        'bucket_name': bucket_name,
        'cities': cities,
        'project_id': os.getenv('GCP_PROJECT_ID'),
        'max_retries': int(os.getenv('MAX_RETRIES', '3')),
        'retry_delay': int(os.getenv('RETRY_DELAY_SECONDS', '5')),
        'local_data_dir': os.getenv('LOCAL_DATA_DIR', './data'),
    }

    logger.info(f"Configuration loaded: {len(cities)} cities, bucket: {bucket_name}")
    return config


def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(description='Fetch weather data from OpenWeather API')
    parser.add_argument('--date', help='Date for the data (YYYY-MM-DD), default: today')
    parser.add_argument('--dry-run', action='store_true', help='Save locally only, do not upload to GCS')
    parser.add_argument('--debug', action='store_true', help='Enable debug logging')
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    logger.info("=" * 70)
    logger.info("Weather Data Ingestion")
    logger.info("=" * 70)

    # Load configuration
    config = load_config()

    # Determine date
    if args.date:
        try:
            target_date = datetime.strptime(args.date, '%Y-%m-%d')
        except ValueError:
            logger.error(f"Invalid date format: {args.date}. Use YYYY-MM-DD")
            sys.exit(1)
    else:
        target_date = datetime.now(timezone.utc)

    date_str = target_date.strftime('%Y%m%d')
    timestamp_str = datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')

    # Initialize API client
    api_client = WeatherAPIClient(config['api_key'])

    # Fetch weather data
    logger.info(f"\nFetching weather data for {len(config['cities'])} cities...")
    weather_data = api_client.fetch_multiple_cities(
        config['cities'],
        delay_seconds=1.0  # Stay within rate limits
    )

    if not weather_data:
        logger.error("No weather data fetched. Exiting.")
        sys.exit(1)

    # Save local copy
    local_path = f"{config['local_data_dir']}/raw/{date_str}/weather-{timestamp_str}.json"
    uploader = GCSUploader(config['bucket_name'])
    uploader.save_local_copy(weather_data, local_path)

    # Upload to GCS
    if not args.dry_run:
        logger.info("\nUploading to Google Cloud Storage...")
        gcs_path = f"raw/{date_str}/weather-{timestamp_str}.json"
        success = uploader.upload_json(weather_data, gcs_path)

        if success:
            logger.info("\n" + "=" * 70)
            logger.info("✓ Data ingestion completed successfully!")
            logger.info("=" * 70)
            logger.info(f"Date: {date_str}")
            logger.info(f"Cities: {len(weather_data)}")
            logger.info(f"GCS Path: gs://{config['bucket_name']}/{gcs_path}")
            logger.info(f"Local Path: {local_path}")
        else:
            logger.error("\n✗ Upload to GCS failed")
            sys.exit(1)
    else:
        logger.info("\n(Dry run mode - skipped GCS upload)")
        logger.info(f"Data saved locally to: {local_path}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logger.warning("\n\nInterrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        sys.exit(1)
