#!/usr/bin/env python3
"""
Test GCP Connection and Setup

This script verifies that your GCP environment is properly configured and
that you can connect to GCP services.

Usage:
    python test_connection.py

Requirements:
    - gcloud CLI installed and authenticated
    - GOOGLE_APPLICATION_CREDENTIALS environment variable set (or ADC configured)
    - GCP_PROJECT_ID environment variable set (or gcloud default project)
"""

import os
import sys
from typing import Optional

# Try to import google.auth
try:
    from google.auth import default
    from google.auth.exceptions import DefaultCredentialsError
except ImportError:
    print("❌ ERROR: google-auth is not installed")
    print("   Run: pip install -r requirements.txt")
    sys.exit(1)

# Try to import other GCP libraries
try:
    from google.cloud import bigquery
    from google.cloud import storage
    from google.cloud import pubsub_v1
except ImportError as e:
    print(f"❌ ERROR: Missing GCP library: {e}")
    print("   Run: pip install -r requirements.txt")
    sys.exit(1)


def print_header(text: str):
    """Print a formatted section header."""
    print(f"\n{'=' * 70}")
    print(f"  {text}")
    print('=' * 70)


def print_success(text: str):
    """Print a success message."""
    print(f"✓ {text}")


def print_error(text: str):
    """Print an error message."""
    print(f"❌ {text}")


def print_warning(text: str):
    """Print a warning message."""
    print(f"⚠️  {text}")


def print_info(text: str):
    """Print an info message."""
    print(f"ℹ️  {text}")


def check_authentication() -> tuple[Optional[str], Optional[str]]:
    """
    Check if authentication is properly configured.

    Returns:
        Tuple of (project_id, credentials_type) or (None, None) if failed
    """
    print_header("Checking Authentication")

    try:
        # Try to get project from environment variable first
        project_id = os.getenv('GCP_PROJECT_ID')

        if project_id:
            # Use explicit project from environment
            credentials, _ = default()
            cred_type = type(credentials).__name__
            print_success(f"Authentication successful")
            print_info(f"Credentials type: {cred_type}")
            print_info(f"Using project from GCP_PROJECT_ID: {project_id}")
        else:
            # Fall back to default project
            credentials, project_id = default()
            cred_type = type(credentials).__name__
            print_success(f"Authentication successful")
            print_info(f"Credentials type: {cred_type}")

            if project_id:
                print_info(f"Default project: {project_id}")
            else:
                print_error("No project ID found. Set GCP_PROJECT_ID or use: gcloud config set project PROJECT_ID")
                return None, None

        return project_id, cred_type

    except DefaultCredentialsError as e:
        print_error(f"Authentication failed: {e}")
        print_info("To fix this:")
        print("  1. Run: gcloud auth application-default login")
        print("  2. Or set: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json")
        return None, None


def check_environment_variables():
    """Check if recommended environment variables are set."""
    print_header("Checking Environment Variables")

    env_vars = {
        'GCP_PROJECT_ID': 'Your GCP project ID',
        'GOOGLE_APPLICATION_CREDENTIALS': 'Path to service account key (optional if using ADC)',
        'GCP_REGION': 'Default GCP region',
    }

    missing = []

    for var, description in env_vars.items():
        value = os.getenv(var)
        if value:
            # Mask sensitive values
            if 'CREDENTIALS' in var and value:
                display_value = f"{value[:20]}..." if len(value) > 20 else value
            else:
                display_value = value
            print_success(f"{var} = {display_value}")
        else:
            if var == 'GOOGLE_APPLICATION_CREDENTIALS':
                print_warning(f"{var} not set (OK if using ADC)")
            else:
                print_warning(f"{var} not set - {description}")
                missing.append(var)

    if missing:
        print_info("\nTo set environment variables:")
        print("  export GCP_PROJECT_ID='your-project-id'")
        print("  export GCP_REGION='us-central1'")


def test_bigquery_connection(project_id: str) -> bool:
    """Test connection to BigQuery."""
    print_header("Testing BigQuery Connection")

    try:
        client = bigquery.Client(project=project_id)

        # Try a simple query
        query = "SELECT 1 as test"
        query_job = client.query(query)
        results = list(query_job.result())

        if results[0].test == 1:
            print_success("BigQuery connection successful")
            print_info(f"BigQuery location: {client.location}")
            return True
        else:
            print_error("BigQuery query returned unexpected result")
            return False

    except Exception as e:
        print_error(f"BigQuery connection failed: {e}")
        print_info("Make sure BigQuery API is enabled:")
        print("  gcloud services enable bigquery.googleapis.com")
        return False


def test_storage_connection(project_id: str) -> bool:
    """Test connection to Cloud Storage."""
    print_header("Testing Cloud Storage Connection")

    try:
        client = storage.Client(project=project_id)

        # List buckets (this tests the connection)
        buckets = list(client.list_buckets(max_results=5))

        print_success("Cloud Storage connection successful")

        if buckets:
            print_info(f"Found {len(buckets)} bucket(s):")
            for bucket in buckets[:5]:
                print(f"  • {bucket.name}")
        else:
            print_info("No buckets found in project")

        return True

    except Exception as e:
        print_error(f"Cloud Storage connection failed: {e}")
        print_info("Make sure Cloud Storage API is enabled:")
        print("  gcloud services enable storage.googleapis.com")
        return False


def test_pubsub_connection(project_id: str) -> bool:
    """Test connection to Pub/Sub."""
    print_header("Testing Pub/Sub Connection")

    try:
        publisher = pubsub_v1.PublisherClient()

        # List topics (this tests the connection)
        project_path = f"projects/{project_id}"
        topics = list(publisher.list_topics(request={"project": project_path}))

        print_success("Pub/Sub connection successful")

        if topics:
            print_info(f"Found {len(topics)} topic(s):")
            for topic in topics[:5]:
                topic_name = topic.name.split('/')[-1]
                print(f"  • {topic_name}")
        else:
            print_info("No topics found in project")

        return True

    except Exception as e:
        print_error(f"Pub/Sub connection failed: {e}")
        print_info("Make sure Pub/Sub API is enabled:")
        print("  gcloud services enable pubsub.googleapis.com")
        return False


def check_installed_packages():
    """Check which GCP packages are installed."""
    print_header("Checking Installed GCP Packages")

    packages = [
        'google-auth',
        'google-cloud-bigquery',
        'google-cloud-storage',
        'google-cloud-pubsub',
        'google-cloud-dataflow',
        'apache-beam',
        'pandas',
        'python-dotenv',
    ]

    for package in packages:
        try:
            __import__(package.replace('-', '_'))
            print_success(f"{package} is installed")
        except ImportError:
            print_warning(f"{package} is NOT installed")


def print_summary(results: dict):
    """Print a summary of all tests."""
    print_header("Summary")

    total = len(results)
    passed = sum(1 for v in results.values() if v)
    failed = total - passed

    print(f"\nTests passed: {passed}/{total}")

    if failed == 0:
        print_success("All tests passed! Your GCP environment is ready.")
        print_info("\nNext steps:")
        print("  1. Review the configuration in config/.env")
        print("  2. Proceed to Project 1: Batch ETL Pipeline")
    else:
        print_error(f"{failed} test(s) failed.")
        print_info("\nPlease fix the issues above before proceeding.")
        print_info("Common fixes:")
        print("  • Run: gcloud auth application-default login")
        print("  • Enable required APIs")
        print("  • Set GCP_PROJECT_ID environment variable")


def main():
    """Main function to run all tests."""
    print("=" * 70)
    print("  GCP Environment Test")
    print("=" * 70)
    print("\nThis script will verify your GCP setup is working correctly.\n")

    results = {}

    # Check environment variables
    check_environment_variables()

    # Check authentication
    project_id, cred_type = check_authentication()
    results['authentication'] = project_id is not None

    if not project_id:
        print_error("\n❌ Cannot proceed without authentication and project ID")
        sys.exit(1)

    # Check installed packages
    check_installed_packages()

    # Test service connections
    results['bigquery'] = test_bigquery_connection(project_id)
    results['storage'] = test_storage_connection(project_id)
    results['pubsub'] = test_pubsub_connection(project_id)

    # Print summary
    print_summary(results)

    # Exit with appropriate code
    if all(results.values()):
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
