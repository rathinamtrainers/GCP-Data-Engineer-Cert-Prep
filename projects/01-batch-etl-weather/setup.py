"""
Setup file for Apache Beam pipeline deployment.

This file is used by Dataflow to package and distribute the pipeline code.
"""

import setuptools

REQUIRED_PACKAGES = [
    'google-cloud-storage>=2.0.0',
    'google-cloud-bigquery>=3.0.0',
    'python-dotenv>=0.19.0',
]

setuptools.setup(
    name='weather-pipeline',
    version='1.0.0',
    description='Weather ETL Pipeline for Google Cloud Dataflow',
    author='Data Engineer',
    packages=setuptools.find_packages(where='src'),
    package_dir={'': 'src'},
    install_requires=REQUIRED_PACKAGES,
    python_requires='>=3.11',
)
