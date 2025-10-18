"""
Data Validation Module

Validates weather data quality and detects anomalies.
"""

from typing import Dict, List, Tuple
import logging


# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class WeatherDataValidator:
    """Validates weather data quality."""

    # Validation thresholds
    MIN_TEMP_C = -50.0
    MAX_TEMP_C = 60.0
    MIN_HUMIDITY = 0
    MAX_HUMIDITY = 100
    MIN_PRESSURE = 800
    MAX_PRESSURE = 1100
    MIN_WIND_SPEED = 0.0
    MAX_WIND_SPEED = 150.0  # ~540 km/h, extreme but possible

    @staticmethod
    def validate_temperature(temp_c: float) -> bool:
        """
        Validate temperature is within reasonable range.

        Args:
            temp_c: Temperature in Celsius

        Returns:
            True if valid, False otherwise
        """
        if temp_c is None:
            return False
        return WeatherDataValidator.MIN_TEMP_C <= temp_c <= WeatherDataValidator.MAX_TEMP_C

    @staticmethod
    def validate_humidity(humidity: int) -> bool:
        """
        Validate humidity is between 0-100%.

        Args:
            humidity: Humidity percentage

        Returns:
            True if valid, False otherwise
        """
        if humidity is None:
            return False
        return WeatherDataValidator.MIN_HUMIDITY <= humidity <= WeatherDataValidator.MAX_HUMIDITY

    @staticmethod
    def validate_pressure(pressure: int) -> bool:
        """
        Validate atmospheric pressure is reasonable.

        Args:
            pressure: Pressure in hPa

        Returns:
            True if valid, False otherwise
        """
        if pressure is None:
            return False
        return WeatherDataValidator.MIN_PRESSURE <= pressure <= WeatherDataValidator.MAX_PRESSURE

    @staticmethod
    def validate_wind_speed(wind_speed: float) -> bool:
        """
        Validate wind speed is reasonable.

        Args:
            wind_speed: Wind speed in m/s

        Returns:
            True if valid, False otherwise
        """
        if wind_speed is None:
            return False
        return WeatherDataValidator.MIN_WIND_SPEED <= wind_speed <= WeatherDataValidator.MAX_WIND_SPEED

    @staticmethod
    def validate_required_fields(record: Dict, required_fields: List[str]) -> Tuple[bool, List[str]]:
        """
        Validate that all required fields are present and not None.

        Args:
            record: Weather data record
            required_fields: List of required field names

        Returns:
            Tuple of (is_valid, list_of_missing_fields)
        """
        missing_fields = []

        for field in required_fields:
            if field not in record or record[field] is None:
                missing_fields.append(field)

        return len(missing_fields) == 0, missing_fields

    @classmethod
    def validate_record(cls, record: Dict) -> Tuple[bool, List[str]]:
        """
        Validate a complete weather record.

        Args:
            record: Weather data record

        Returns:
            Tuple of (is_valid, list_of_errors)
        """
        errors = []

        # Validate temperature
        if 'temperature_c' in record and record['temperature_c'] is not None:
            if not cls.validate_temperature(record['temperature_c']):
                errors.append(
                    f"Invalid temperature: {record['temperature_c']}°C "
                    f"(range: {cls.MIN_TEMP_C} to {cls.MAX_TEMP_C})"
                )

        # Validate humidity
        if 'humidity_percent' in record and record['humidity_percent'] is not None:
            if not cls.validate_humidity(record['humidity_percent']):
                errors.append(
                    f"Invalid humidity: {record['humidity_percent']}% "
                    f"(range: {cls.MIN_HUMIDITY} to {cls.MAX_HUMIDITY})"
                )

        # Validate pressure
        if 'pressure_hpa' in record and record['pressure_hpa'] is not None:
            if not cls.validate_pressure(record['pressure_hpa']):
                errors.append(
                    f"Invalid pressure: {record['pressure_hpa']} hPa "
                    f"(range: {cls.MIN_PRESSURE} to {cls.MAX_PRESSURE})"
                )

        # Validate wind speed
        if 'wind_speed_ms' in record and record['wind_speed_ms'] is not None:
            if not cls.validate_wind_speed(record['wind_speed_ms']):
                errors.append(
                    f"Invalid wind speed: {record['wind_speed_ms']} m/s "
                    f"(range: {cls.MIN_WIND_SPEED} to {cls.MAX_WIND_SPEED})"
                )

        return len(errors) == 0, errors

    @staticmethod
    def get_quality_metrics(records: List[Dict]) -> Dict:
        """
        Calculate data quality metrics for a batch of records.

        Args:
            records: List of weather data records

        Returns:
            Dictionary of quality metrics
        """
        total = len(records)
        if total == 0:
            return {
                'total_records': 0,
                'valid_records': 0,
                'invalid_records': 0,
                'validity_rate': 0.0
            }

        validator = WeatherDataValidator()
        valid_count = 0
        temp_issues = 0
        humidity_issues = 0
        pressure_issues = 0
        wind_issues = 0

        for record in records:
            is_valid, errors = validator.validate_record(record)
            if is_valid:
                valid_count += 1
            else:
                for error in errors:
                    if 'temperature' in error.lower():
                        temp_issues += 1
                    elif 'humidity' in error.lower():
                        humidity_issues += 1
                    elif 'pressure' in error.lower():
                        pressure_issues += 1
                    elif 'wind' in error.lower():
                        wind_issues += 1

        return {
            'total_records': total,
            'valid_records': valid_count,
            'invalid_records': total - valid_count,
            'validity_rate': round(valid_count / total * 100, 2),
            'temperature_issues': temp_issues,
            'humidity_issues': humidity_issues,
            'pressure_issues': pressure_issues,
            'wind_issues': wind_issues
        }


def kelvin_to_celsius(kelvin: float) -> float:
    """
    Convert Kelvin to Celsius.

    Args:
        kelvin: Temperature in Kelvin

    Returns:
        Temperature in Celsius
    """
    return round(kelvin - 273.15, 2)


def celsius_to_fahrenheit(celsius: float) -> float:
    """
    Convert Celsius to Fahrenheit.

    Args:
        celsius: Temperature in Celsius

    Returns:
        Temperature in Fahrenheit
    """
    return round((celsius * 9/5) + 32, 2)


if __name__ == "__main__":
    # Test validation
    validator = WeatherDataValidator()

    # Test valid record
    valid_record = {
        'temperature_c': 15.5,
        'humidity_percent': 72,
        'pressure_hpa': 1013,
        'wind_speed_ms': 4.1
    }

    is_valid, errors = validator.validate_record(valid_record)
    print(f"Valid record test: {is_valid}")
    if errors:
        print(f"Errors: {errors}")

    # Test invalid record
    invalid_record = {
        'temperature_c': 100.0,  # Too hot
        'humidity_percent': 150,  # Invalid
        'pressure_hpa': 500,  # Too low
        'wind_speed_ms': 200.0  # Too fast
    }

    is_valid, errors = validator.validate_record(invalid_record)
    print(f"\nInvalid record test: {is_valid}")
    print(f"Errors: {errors}")

    # Test temperature conversion
    print(f"\n0°C = {celsius_to_fahrenheit(0)}°F")
    print(f"273.15K = {kelvin_to_celsius(273.15)}°C")
