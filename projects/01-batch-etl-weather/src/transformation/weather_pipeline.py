#!/usr/bin/env python3
"""
Weather Data Transformation Pipeline

Apache Beam pipeline to transform raw weather JSON data into BigQuery format.

Usage:
    # Local testing (DirectRunner)
    python weather_pipeline.py \
        --input gs://bucket/raw/20250118/*.json \
        --output PROJECT:DATASET.TABLE \
        --runner DirectRunner

    # Production (DataflowRunner)
    python weather_pipeline.py \
        --input gs://bucket/raw/20250118/*.json \
        --output data-engineer-475516:weather_data.daily \
        --runner DataflowRunner \
        --project data-engineer-475516 \
        --region us-central1 \
        --temp_location gs://bucket/temp \
        --staging_location gs://bucket/staging
"""

import argparse
import json
import logging
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery, BigQueryDisposition
from apache_beam.io.filesystems import FileSystems
from apache_beam.io import fileio

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.data_validator import (
    WeatherDataValidator,
    kelvin_to_celsius,
    celsius_to_fahrenheit
)
from utils.bigquery_schema import SCHEMA_FIELDS


class ReadJSONArray(beam.DoFn):
    """
    Read and parse JSON array files from GCS.
    """

    def process(self, file_path):
        """
        Read JSON file and yield individual records.

        Args:
            file_path: Path to JSON file

        Yields:
            Individual JSON records from array
        """
        try:
            with FileSystems.open(file_path) as f:
                content = f.read().decode('utf-8')
                data = json.loads(content)

                # Handle both arrays and single objects
                if isinstance(data, list):
                    for record in data:
                        yield record
                else:
                    yield data

        except Exception as e:
            logging.error(f"Error reading file {file_path}: {e}")


class ParseWeatherData(beam.DoFn):
    """
    Parse and transform raw weather API response to BigQuery format.
    """

    def process(self, element):
        """
        Transform raw weather JSON to BigQuery record.

        Args:
            element: JSON string from file

        Yields:
            Dictionary matching BigQuery schema
        """
        try:
            # Parse JSON (element is already a dict from ReadFromJson)
            if isinstance(element, str):
                data = json.loads(element)
            else:
                data = element

            # Extract timestamp
            dt_unix = data.get('dt')
            if not dt_unix:
                logging.warning(f"Missing timestamp in record: {data.get('name')}")
                return

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

            yield record

        except Exception as e:
            logging.error(f"Error parsing weather data: {e}")
            logging.error(f"Problematic record: {element}")


class ValidateWeatherData(beam.DoFn):
    """
    Validate weather data quality and filter invalid records.
    """

    def __init__(self):
        self.validator = WeatherDataValidator()
        self.valid_count = beam.metrics.Metrics.counter('validation', 'valid_records')
        self.invalid_count = beam.metrics.Metrics.counter('validation', 'invalid_records')

    def process(self, element):
        """
        Validate weather record.

        Args:
            element: Weather record dictionary

        Yields:
            Valid weather record
        """
        is_valid, errors = self.validator.validate_record(element)

        if is_valid:
            self.valid_count.inc()
            yield element
        else:
            self.invalid_count.inc()
            city = element.get('city', 'Unknown')
            logging.warning(f"Invalid record for {city}: {', '.join(errors)}")


def get_bigquery_schema():
    """
    Get BigQuery schema as dictionary for WriteToBigQuery.

    Returns:
        Dictionary of table schema
    """
    table_schema = {'fields': SCHEMA_FIELDS}
    return table_schema


def run(argv=None, save_main_session=True):
    """
    Run the pipeline.

    Args:
        argv: Command line arguments
        save_main_session: Whether to save main session for workers
    """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--input',
        dest='input',
        required=True,
        help='Input file pattern (e.g., gs://bucket/raw/*/*.json)'
    )

    parser.add_argument(
        '--output',
        dest='output',
        required=True,
        help='Output BigQuery table (PROJECT:DATASET.TABLE)'
    )

    known_args, pipeline_args = parser.parse_known_args(argv)

    # Set up pipeline options
    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = save_main_session

    # Get runner from pipeline options
    runner = pipeline_options.get_all_options().get('runner', 'DirectRunner')

    # Log pipeline configuration
    logging.info("=" * 70)
    logging.info("Weather Data Transformation Pipeline")
    logging.info("=" * 70)
    logging.info(f"Input: {known_args.input}")
    logging.info(f"Output: {known_args.output}")
    logging.info(f"Runner: {runner}")
    logging.info("=" * 70)

    # Get matching files
    match_results = FileSystems.match([known_args.input])[0]
    file_paths = [metadata.path for metadata in match_results.metadata_list]

    logging.info(f"Found {len(file_paths)} files to process")

    # Create and run pipeline
    with beam.Pipeline(options=pipeline_options) as pipeline:
        (
            pipeline
            | 'CreateFilePaths' >> beam.Create(file_paths)
            | 'ReadAndParseJSON' >> beam.ParDo(ReadJSONArray())
            | 'TransformWeatherData' >> beam.ParDo(ParseWeatherData())
            | 'ValidateData' >> beam.ParDo(ValidateWeatherData())
            | 'WriteToBigQuery' >> WriteToBigQuery(
                table=known_args.output,
                schema=get_bigquery_schema(),
                write_disposition=BigQueryDisposition.WRITE_TRUNCATE,
                create_disposition=BigQueryDisposition.CREATE_IF_NEEDED
            )
        )

    logging.info("\n" + "=" * 70)
    logging.info("✓ Pipeline completed successfully!")
    logging.info("=" * 70)


def main():
    """Main entry point."""
    logging.getLogger().setLevel(logging.INFO)
    run()


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logging.warning("\n\nPipeline interrupted by user")
        sys.exit(130)
    except Exception as e:
        logging.exception(f"Pipeline failed: {e}")
        sys.exit(1)
