"""
BigQuery Schema Definition

Provides BigQuery schema for the weather data table, used by Apache Beam pipeline.
"""

import json
import os
from typing import Dict, List


def load_schema_from_file() -> List[Dict]:
    """
    Load BigQuery schema from schema.json file.

    Returns:
        List of schema field definitions
    """
    schema_path = os.path.join(
        os.path.dirname(__file__),
        '../../sql/schema.json'
    )

    with open(schema_path, 'r') as f:
        return json.load(f)


def get_bigquery_schema() -> str:
    """
    Get BigQuery schema as comma-separated string for Apache Beam.

    Returns:
        Schema string in format "field1:TYPE,field2:TYPE,..."
    """
    schema_fields = load_schema_from_file()

    # Convert to Beam format
    beam_fields = []
    for field in schema_fields:
        name = field['name']
        field_type = field['type']
        mode = field.get('mode', 'NULLABLE')

        if mode == 'REQUIRED':
            beam_fields.append(f"{name}:{field_type}:required")
        else:
            beam_fields.append(f"{name}:{field_type}")

    return ','.join(beam_fields)


def get_schema_dict() -> Dict:
    """
    Get schema as dictionary mapping field names to types.

    Returns:
        Dictionary of {field_name: field_type}
    """
    schema_fields = load_schema_from_file()
    return {field['name']: field['type'] for field in schema_fields}


def get_required_fields() -> List[str]:
    """
    Get list of required field names.

    Returns:
        List of required field names
    """
    schema_fields = load_schema_from_file()
    return [
        field['name']
        for field in schema_fields
        if field.get('mode') == 'REQUIRED'
    ]


def validate_record_schema(record: Dict) -> bool:
    """
    Validate that a record has all required fields.

    Args:
        record: Dictionary containing weather data

    Returns:
        True if valid, False otherwise
    """
    required = get_required_fields()
    return all(field in record and record[field] is not None for field in required)


# Pre-load schema for performance
SCHEMA_FIELDS = load_schema_from_file()
SCHEMA_DICT = get_schema_dict()
REQUIRED_FIELDS = get_required_fields()


if __name__ == "__main__":
    # Test schema loading
    print("BigQuery Schema:")
    print(json.dumps(SCHEMA_FIELDS, indent=2))
    print(f"\nTotal fields: {len(SCHEMA_FIELDS)}")
    print(f"Required fields: {REQUIRED_FIELDS}")
    print(f"\nBeam schema string:\n{get_bigquery_schema()}")
