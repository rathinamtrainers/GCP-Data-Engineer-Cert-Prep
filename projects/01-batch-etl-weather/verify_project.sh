#!/bin/bash

################################################################################
# Project 1: Weather ETL Pipeline - Comprehensive Verification
################################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="data-engineer-475516"
DATASET="weather_data"
TABLE="daily"

# Success tracking
TOTAL_CHECKS=0
PASSED_CHECKS=0

check_pass() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    echo -e "   ${GREEN}✓${NC} $1"
}

check_fail() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -e "   ${RED}✗${NC} $1"
}

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Project 1: Weather ETL Pipeline Verification           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# 1. File Structure Check
################################################################################
echo -e "${YELLOW}[1/10] Checking File Structure...${NC}"

file_count=$(find . -name "*.py" -type f 2>/dev/null | wc -l)
if [ "$file_count" -ge 11 ]; then
    check_pass "Python files: $file_count (expected: 11+)"
else
    check_fail "Python files: $file_count (expected: 11+)"
fi

if [ -f "config/.env" ]; then
    check_pass "Configuration file exists"
else
    check_fail "Configuration file missing"
fi

if [ -f "sql/schema.json" ]; then
    check_pass "BigQuery schema exists"
else
    check_fail "BigQuery schema missing"
fi

################################################################################
# 2. Unit Tests
################################################################################
echo -e "\n${YELLOW}[2/10] Running Unit Tests...${NC}"

if command -v pytest &> /dev/null; then
    test_output=$(pytest tests/test_pipeline.py -q 2>&1)
    if echo "$test_output" | grep -q "passed"; then
        passed=$(echo "$test_output" | grep -oP '\d+(?= passed)' | tail -1)
        check_pass "Unit tests: $passed passed"
    else
        check_fail "Unit tests: Failed or not run"
    fi
else
    check_fail "pytest not installed"
fi

################################################################################
# 3. GCP Authentication
################################################################################
echo -e "\n${YELLOW}[3/10] Checking GCP Authentication...${NC}"

if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    check_pass "Service account credentials set"
else
    check_fail "GOOGLE_APPLICATION_CREDENTIALS not set"
fi

current_project=$(gcloud config get-value project 2>/dev/null)
if [ "$current_project" = "$PROJECT_ID" ]; then
    check_pass "GCP project: $PROJECT_ID"
else
    check_fail "GCP project mismatch: $current_project (expected: $PROJECT_ID)"
fi

################################################################################
# 4. Cloud Storage Buckets
################################################################################
echo -e "\n${YELLOW}[4/10] Checking Cloud Storage Buckets...${NC}"

bucket_count=$(gsutil ls -p $PROJECT_ID 2>/dev/null | grep -c weather || echo 0)
if [ "$bucket_count" -eq 3 ]; then
    check_pass "Weather buckets: $bucket_count/3"
else
    check_fail "Weather buckets: $bucket_count/3 (expected: 3)"
fi

# Check raw bucket specifically
if gsutil ls gs://${PROJECT_ID}-weather-raw &> /dev/null; then
    check_pass "Raw data bucket exists"
else
    check_fail "Raw data bucket missing"
fi

################################################################################
# 5. BigQuery Dataset and Table
################################################################################
echo -e "\n${YELLOW}[5/10] Checking BigQuery Resources...${NC}"

if bq show ${PROJECT_ID}:${DATASET} &> /dev/null; then
    check_pass "Dataset exists: $DATASET"
else
    check_fail "Dataset missing: $DATASET"
fi

if bq show ${PROJECT_ID}:${DATASET}.${TABLE} &> /dev/null; then
    check_pass "Table exists: $DATASET.$TABLE"
else
    check_fail "Table missing: $DATASET.$TABLE"
fi

# Check table structure
partition_info=$(bq show ${PROJECT_ID}:${DATASET}.${TABLE} 2>/dev/null | grep -i "DAY (field: date)")
if [ -n "$partition_info" ]; then
    check_pass "Table is partitioned by date"
else
    check_fail "Table partitioning not configured"
fi

cluster_info=$(bq show ${PROJECT_ID}:${DATASET}.${TABLE} 2>/dev/null | grep -i "city, country")
if [ -n "$cluster_info" ]; then
    check_pass "Table is clustered by city, country"
else
    check_fail "Table clustering not configured"
fi

################################################################################
# 6. Data in Cloud Storage
################################################################################
echo -e "\n${YELLOW}[6/10] Checking Data in Cloud Storage...${NC}"

file_count=$(gsutil ls gs://${PROJECT_ID}-weather-raw/raw/*/ 2>/dev/null | wc -l || echo 0)
if [ "$file_count" -gt 0 ]; then
    check_pass "Files in GCS: $file_count"

    # Show latest file
    latest_file=$(gsutil ls -l gs://${PROJECT_ID}-weather-raw/raw/*/*.json 2>/dev/null | grep -v "TOTAL:" | tail -1 | awk '{print $3}')
    if [ -n "$latest_file" ]; then
        echo -e "      Latest: ${latest_file##*/}"
    fi
else
    check_fail "No files in GCS raw bucket"
fi

################################################################################
# 7. Data in BigQuery
################################################################################
echo -e "\n${YELLOW}[7/10] Checking Data in BigQuery...${NC}"

record_count=$(bq query --use_legacy_sql=false --format=csv \
  "SELECT COUNT(*) FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`" 2>/dev/null | tail -1)

if [ -n "$record_count" ] && [ "$record_count" -gt 0 ]; then
    check_pass "Records in BigQuery: $record_count"
else
    check_fail "No records in BigQuery"
fi

city_count=$(bq query --use_legacy_sql=false --format=csv \
  "SELECT COUNT(DISTINCT city) FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`" 2>/dev/null | tail -1)

if [ -n "$city_count" ]; then
    echo -e "      Unique cities: $city_count"
fi

################################################################################
# 8. Data Quality Check
################################################################################
echo -e "\n${YELLOW}[8/10] Checking Data Quality...${NC}"

# Check for invalid temperatures
invalid_temp=$(bq query --use_legacy_sql=false --format=csv \
  "SELECT COUNT(*) FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`
   WHERE temperature_c < -50 OR temperature_c > 60" 2>/dev/null | tail -1)

if [ "$invalid_temp" = "0" ]; then
    check_pass "No invalid temperatures"
else
    check_fail "Found $invalid_temp records with invalid temperatures"
fi

# Check for missing required fields
missing_data=$(bq query --use_legacy_sql=false --format=csv \
  "SELECT COUNT(*) FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`
   WHERE city IS NULL OR country IS NULL" 2>/dev/null | tail -1)

if [ "$missing_data" = "0" ]; then
    check_pass "No missing required fields"
else
    check_fail "Found $missing_data records with missing fields"
fi

################################################################################
# 9. Temperature Statistics
################################################################################
echo -e "\n${YELLOW}[9/10] Temperature Statistics...${NC}"

stats=$(bq query --use_legacy_sql=false --format=csv \
  "SELECT
     ROUND(MIN(temperature_c), 1) as min_temp,
     ROUND(MAX(temperature_c), 1) as max_temp,
     ROUND(AVG(temperature_c), 1) as avg_temp
   FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`" 2>/dev/null | tail -1)

if [ -n "$stats" ]; then
    IFS=',' read -r min_temp max_temp avg_temp <<< "$stats"
    echo -e "      Min: ${min_temp}°C | Max: ${max_temp}°C | Avg: ${avg_temp}°C"
    check_pass "Statistics calculated"
else
    check_fail "Could not calculate statistics"
fi

################################################################################
# 10. Latest Weather Data
################################################################################
echo -e "\n${YELLOW}[10/10] Latest Weather Data (Sample)...${NC}"

bq query --use_legacy_sql=false --format=pretty \
  "SELECT city, ROUND(temperature_c,1) as temp_c, weather_main as weather
   FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`
   ORDER BY city LIMIT 5" 2>/dev/null

################################################################################
# Summary
################################################################################
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Verification Summary                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

percentage=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo -e "\nChecks Passed: ${GREEN}$PASSED_CHECKS${NC}/$TOTAL_CHECKS (${percentage}%)"

if [ "$PASSED_CHECKS" -eq "$TOTAL_CHECKS" ]; then
    echo -e "\n${GREEN}✓✓✓ Project 1 is COMPLETE and WORKING! ✓✓✓${NC}"
    echo -e "\n${GREEN}🎉 Congratulations! All systems operational. 🎉${NC}"
    exit 0
elif [ "$percentage" -ge 80 ]; then
    echo -e "\n${YELLOW}⚠ Project 1 is mostly complete with minor issues.${NC}"
    echo -e "Review the failed checks above."
    exit 1
else
    echo -e "\n${RED}✗ Project 1 has significant issues that need attention.${NC}"
    echo -e "Please review the failed checks and fix them."
    exit 2
fi
