"""
Lab 1.1: Environment Setup Verification Script

This script verifies that your BigQuery environment is properly configured.
Run after completing the setup steps in README.md.
"""

import os
import sys


def print_header(title: str) -> None:
    """Print a formatted section header."""
    print(f"\n{'='*60}")
    print(f" {title}")
    print(f"{'='*60}")


def print_result(check: str, passed: bool, details: str = "") -> None:
    """Print check result with status."""
    status = "[PASS]" if passed else "[FAIL]"
    print(f"{status} {check}")
    if details:
        print(f"       {details}")


def check_environment_variable() -> bool:
    """Check if GOOGLE_CLOUD_PROJECT is set."""
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
    if project_id:
        print_result("Environment variable GOOGLE_CLOUD_PROJECT", True, f"Value: {project_id}")
        return True
    else:
        print_result("Environment variable GOOGLE_CLOUD_PROJECT", False,
                    "Set with: export GOOGLE_CLOUD_PROJECT=your-project-id")
        return False


def check_bigquery_import() -> bool:
    """Check if BigQuery library can be imported."""
    try:
        from google.cloud import bigquery
        print_result("BigQuery library import", True, f"Version: {bigquery.__version__}")
        return True
    except ImportError as e:
        print_result("BigQuery library import", False, f"Error: {e}")
        return False


def check_authentication() -> bool:
    """Check if Application Default Credentials work."""
    try:
        import google.auth
        credentials, project = google.auth.default()
        print_result("Authentication (ADC)", True, f"Project from ADC: {project}")
        return True
    except Exception as e:
        print_result("Authentication (ADC)", False,
                    f"Run: gcloud auth application-default login\nError: {e}")
        return False


def check_bigquery_connection() -> bool:
    """Check if we can connect to BigQuery."""
    try:
        from google.cloud import bigquery

        # Try to get project from environment or ADC
        project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

        if project_id:
            client = bigquery.Client(project=project_id)
        else:
            client = bigquery.Client()

        print_result("BigQuery client creation", True, f"Project: {client.project}")
        return True
    except Exception as e:
        print_result("BigQuery client creation", False, f"Error: {e}")
        return False


def check_public_dataset_access() -> bool:
    """Check if we can query public datasets."""
    try:
        from google.cloud import bigquery

        project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
        if project_id:
            client = bigquery.Client(project=project_id)
        else:
            client = bigquery.Client()

        query = """
            SELECT COUNT(*) as word_count
            FROM `bigquery-public-data.samples.shakespeare`
        """

        result = client.query(query).result()
        row = list(result)[0]
        word_count = row.word_count

        print_result("Public dataset query", True, f"Shakespeare word count: {word_count:,}")
        return True
    except Exception as e:
        print_result("Public dataset query", False, f"Error: {e}")
        return False


def check_pandas_integration() -> bool:
    """Check if BigQuery-Pandas integration works."""
    try:
        from google.cloud import bigquery
        import pandas as pd

        project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
        if project_id:
            client = bigquery.Client(project=project_id)
        else:
            client = bigquery.Client()

        query = """
            SELECT word, SUM(word_count) as total_count
            FROM `bigquery-public-data.samples.shakespeare`
            GROUP BY word
            ORDER BY total_count DESC
            LIMIT 5
        """

        df = client.query(query).to_dataframe()

        print_result("Pandas integration", True, f"DataFrame shape: {df.shape}")
        print(f"\n       Top 5 words in Shakespeare:")
        for _, row in df.iterrows():
            print(f"         - {row['word']}: {row['total_count']:,}")
        return True
    except Exception as e:
        print_result("Pandas integration", False, f"Error: {e}")
        return False


def main():
    """Run all verification checks."""
    print_header("BigQuery Environment Verification")
    print("Running checks to verify your setup...\n")

    checks = [
        ("Environment Variable", check_environment_variable),
        ("Library Import", check_bigquery_import),
        ("Authentication", check_authentication),
        ("BigQuery Connection", check_bigquery_connection),
        ("Public Dataset Access", check_public_dataset_access),
        ("Pandas Integration", check_pandas_integration),
    ]

    results = []
    for name, check_func in checks:
        print(f"\nChecking: {name}...")
        try:
            results.append(check_func())
        except Exception as e:
            print_result(name, False, f"Unexpected error: {e}")
            results.append(False)

    # Summary
    print_header("Summary")
    passed = sum(results)
    total = len(results)

    print(f"\nPassed: {passed}/{total} checks")

    if all(results):
        print("\n[SUCCESS] Your environment is fully configured!")
        print("You're ready to proceed to Lab 1.2: Dataset Operations")
        return 0
    else:
        print("\n[ACTION REQUIRED] Some checks failed. Please review the errors above.")
        print("\nCommon fixes:")
        print("  1. Run: gcloud auth application-default login")
        print("  2. Set: export GOOGLE_CLOUD_PROJECT=your-project-id")
        print("  3. Enable API: gcloud services enable bigquery.googleapis.com")
        return 1


if __name__ == "__main__":
    sys.exit(main())
