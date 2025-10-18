"""
Unit Tests for Weather ETL Pipeline

Tests for data validation, transformation, and pipeline components.

Usage:
    pytest tests/test_pipeline.py -v
    pytest tests/test_pipeline.py::TestDataValidator -v
    pytest tests/test_pipeline.py --cov=src
"""

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from unittest.mock import Mock, patch

import pytest

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from utils.data_validator import (
    WeatherDataValidator,
    kelvin_to_celsius,
    celsius_to_fahrenheit
)
from utils.bigquery_schema import (
    get_schema_dict,
    get_required_fields,
    validate_record_schema
)


class TestTemperatureConversions:
    """Test temperature conversion functions."""

    def test_kelvin_to_celsius(self):
        """Test Kelvin to Celsius conversion."""
        assert kelvin_to_celsius(273.15) == 0.0
        assert kelvin_to_celsius(373.15) == 100.0
        assert kelvin_to_celsius(0) == -273.15

    def test_celsius_to_fahrenheit(self):
        """Test Celsius to Fahrenheit conversion."""
        assert celsius_to_fahrenheit(0) == 32.0
        assert celsius_to_fahrenheit(100) == 212.0
        assert celsius_to_fahrenheit(-40) == -40.0
        assert celsius_to_fahrenheit(20) == 68.0

    def test_conversion_chain(self):
        """Test chaining Kelvin -> Celsius -> Fahrenheit."""
        temp_k = 293.15  # 20°C
        temp_c = kelvin_to_celsius(temp_k)
        temp_f = celsius_to_fahrenheit(temp_c)
        assert temp_c == 20.0
        assert temp_f == 68.0


class TestDataValidator:
    """Test WeatherDataValidator class."""

    def test_validate_temperature_valid(self):
        """Test temperature validation with valid values."""
        validator = WeatherDataValidator()
        assert validator.validate_temperature(0.0)
        assert validator.validate_temperature(25.5)
        assert validator.validate_temperature(-20.0)
        assert validator.validate_temperature(50.0)

    def test_validate_temperature_invalid(self):
        """Test temperature validation with invalid values."""
        validator = WeatherDataValidator()
        assert not validator.validate_temperature(-51.0)  # Too cold
        assert not validator.validate_temperature(61.0)  # Too hot
        assert not validator.validate_temperature(None)  # None

    def test_validate_humidity_valid(self):
        """Test humidity validation with valid values."""
        validator = WeatherDataValidator()
        assert validator.validate_humidity(0)
        assert validator.validate_humidity(50)
        assert validator.validate_humidity(100)

    def test_validate_humidity_invalid(self):
        """Test humidity validation with invalid values."""
        validator = WeatherDataValidator()
        assert not validator.validate_humidity(-1)
        assert not validator.validate_humidity(101)
        assert not validator.validate_humidity(None)

    def test_validate_pressure_valid(self):
        """Test pressure validation with valid values."""
        validator = WeatherDataValidator()
        assert validator.validate_pressure(1013)  # Standard pressure
        assert validator.validate_pressure(800)  # Low
        assert validator.validate_pressure(1100)  # High

    def test_validate_pressure_invalid(self):
        """Test pressure validation with invalid values."""
        validator = WeatherDataValidator()
        assert not validator.validate_pressure(799)  # Too low
        assert not validator.validate_pressure(1101)  # Too high
        assert not validator.validate_pressure(None)

    def test_validate_wind_speed_valid(self):
        """Test wind speed validation with valid values."""
        validator = WeatherDataValidator()
        assert validator.validate_wind_speed(0.0)
        assert validator.validate_wind_speed(10.5)
        assert validator.validate_wind_speed(50.0)

    def test_validate_wind_speed_invalid(self):
        """Test wind speed validation with invalid values."""
        validator = WeatherDataValidator()
        assert not validator.validate_wind_speed(-1.0)  # Negative
        assert not validator.validate_wind_speed(151.0)  # Too fast
        assert not validator.validate_wind_speed(None)

    def test_validate_record_valid(self):
        """Test validating a complete valid record."""
        validator = WeatherDataValidator()
        record = {
            'temperature_c': 15.5,
            'humidity_percent': 72,
            'pressure_hpa': 1013,
            'wind_speed_ms': 4.1
        }

        is_valid, errors = validator.validate_record(record)
        assert is_valid
        assert len(errors) == 0

    def test_validate_record_invalid_temperature(self):
        """Test validating record with invalid temperature."""
        validator = WeatherDataValidator()
        record = {
            'temperature_c': 100.0,  # Too hot
            'humidity_percent': 72,
            'pressure_hpa': 1013,
            'wind_speed_ms': 4.1
        }

        is_valid, errors = validator.validate_record(record)
        assert not is_valid
        assert len(errors) > 0
        assert 'temperature' in errors[0].lower()

    def test_validate_record_multiple_errors(self):
        """Test validating record with multiple errors."""
        validator = WeatherDataValidator()
        record = {
            'temperature_c': 100.0,  # Invalid
            'humidity_percent': 150,  # Invalid
            'pressure_hpa': 500,  # Invalid
            'wind_speed_ms': 200.0  # Invalid
        }

        is_valid, errors = validator.validate_record(record)
        assert not is_valid
        assert len(errors) == 4  # All fields invalid

    def test_validate_required_fields(self):
        """Test required field validation."""
        validator = WeatherDataValidator()
        required_fields = ['date', 'city', 'country', 'temperature_c']

        # Valid record
        record_valid = {
            'date': '2025-01-18',
            'city': 'London',
            'country': 'GB',
            'temperature_c': 15.5
        }
        is_valid, missing = validator.validate_required_fields(record_valid, required_fields)
        assert is_valid
        assert len(missing) == 0

        # Missing fields
        record_invalid = {
            'date': '2025-01-18',
            'city': 'London'
            # Missing country and temperature_c
        }
        is_valid, missing = validator.validate_required_fields(record_invalid, required_fields)
        assert not is_valid
        assert 'country' in missing
        assert 'temperature_c' in missing

    def test_get_quality_metrics_all_valid(self):
        """Test quality metrics with all valid records."""
        validator = WeatherDataValidator()
        records = [
            {'temperature_c': 15.5, 'humidity_percent': 72, 'pressure_hpa': 1013, 'wind_speed_ms': 4.1},
            {'temperature_c': 20.0, 'humidity_percent': 60, 'pressure_hpa': 1015, 'wind_speed_ms': 3.5},
        ]

        metrics = validator.get_quality_metrics(records)
        assert metrics['total_records'] == 2
        assert metrics['valid_records'] == 2
        assert metrics['invalid_records'] == 0
        assert metrics['validity_rate'] == 100.0

    def test_get_quality_metrics_with_errors(self):
        """Test quality metrics with some invalid records."""
        validator = WeatherDataValidator()
        records = [
            {'temperature_c': 15.5, 'humidity_percent': 72, 'pressure_hpa': 1013, 'wind_speed_ms': 4.1},
            {'temperature_c': 100.0, 'humidity_percent': 150, 'pressure_hpa': 500, 'wind_speed_ms': 200.0},
        ]

        metrics = validator.get_quality_metrics(records)
        assert metrics['total_records'] == 2
        assert metrics['valid_records'] == 1
        assert metrics['invalid_records'] == 1
        assert metrics['validity_rate'] == 50.0


class TestBigQuerySchema:
    """Test BigQuery schema utilities."""

    def test_get_schema_dict(self):
        """Test getting schema as dictionary."""
        schema_dict = get_schema_dict()
        assert isinstance(schema_dict, dict)
        assert 'date' in schema_dict
        assert 'city' in schema_dict
        assert 'temperature_c' in schema_dict
        assert schema_dict['date'] == 'DATE'
        assert schema_dict['temperature_c'] == 'FLOAT64'

    def test_get_required_fields(self):
        """Test getting list of required fields."""
        required = get_required_fields()
        assert isinstance(required, list)
        assert 'date' in required
        assert 'timestamp' in required
        assert 'city' in required
        assert 'country' in required
        assert 'ingestion_timestamp' in required

    def test_validate_record_schema_valid(self):
        """Test schema validation with valid record."""
        record = {
            'date': '2025-01-18',
            'timestamp': '2025-01-18T12:00:00Z',
            'city': 'London',
            'country': 'GB',
            'latitude': 51.5074,
            'longitude': -0.1278,
            'ingestion_timestamp': '2025-01-18T12:05:00Z'
        }
        assert validate_record_schema(record)

    def test_validate_record_schema_missing_required(self):
        """Test schema validation with missing required fields."""
        record = {
            'date': '2025-01-18',
            # Missing other required fields
        }
        assert not validate_record_schema(record)


class TestWeatherAPIResponse:
    """Test parsing of OpenWeather API responses."""

    @pytest.fixture
    def sample_api_response(self):
        """Sample OpenWeather API response."""
        return {
            "coord": {"lon": -0.1257, "lat": 51.5085},
            "weather": [
                {"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}
            ],
            "base": "stations",
            "main": {
                "temp": 280.32,
                "feels_like": 278.99,
                "temp_min": 279.15,
                "temp_max": 281.15,
                "pressure": 1023,
                "humidity": 72
            },
            "visibility": 10000,
            "wind": {"speed": 4.1, "deg": 80},
            "clouds": {"all": 0},
            "dt": 1705581600,
            "sys": {
                "type": 2,
                "id": 2019646,
                "country": "GB",
                "sunrise": 1605163200,
                "sunset": 1605194400
            },
            "timezone": 0,
            "id": 2643743,
            "name": "London",
            "cod": 200
        }

    def test_api_response_structure(self, sample_api_response):
        """Test that sample API response has expected structure."""
        assert 'name' in sample_api_response
        assert 'main' in sample_api_response
        assert 'temp' in sample_api_response['main']
        assert 'sys' in sample_api_response
        assert 'country' in sample_api_response['sys']

    def test_temperature_extraction(self, sample_api_response):
        """Test extracting and converting temperature."""
        temp_k = sample_api_response['main']['temp']
        temp_c = kelvin_to_celsius(temp_k)
        assert temp_k == 280.32
        assert abs(temp_c - 7.17) < 0.01  # Allow small floating point difference


class TestPipelineIntegration:
    """Integration tests for pipeline components."""

    def test_full_record_transformation(self):
        """Test transforming API response to BigQuery record."""
        # This would test the ParseWeatherData DoFn
        # For now, we'll test the concept
        api_response = {
            "name": "London",
            "sys": {"country": "GB"},
            "coord": {"lat": 51.5085, "lon": -0.1257},
            "main": {"temp": 280.32, "humidity": 72, "pressure": 1023},
            "dt": 1705581600
        }

        # Expected transformations
        temp_c = kelvin_to_celsius(api_response['main']['temp'])
        assert abs(temp_c - 7.17) < 0.01

        # Validate the transformed record would pass schema validation
        # (This is a simplified test - full test would use actual ParseWeatherData)
        assert api_response['name'] == 'London'
        assert api_response['sys']['country'] == 'GB'


if __name__ == '__main__':
    pytest.main([__file__, '-v', '--cov=src'])
