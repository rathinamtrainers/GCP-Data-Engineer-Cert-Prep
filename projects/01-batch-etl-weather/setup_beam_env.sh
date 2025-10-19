#!/bin/bash

################################################################################
# Setup Apache Beam Environment with Python 3.11
################################################################################
#
# This script:
# 1. Installs Python 3.11 using pyenv
# 2. Creates a Python 3.11 virtual environment
# 3. Installs Apache Beam and dependencies
#
################################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Apache Beam Environment Setup (Python 3.11)           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Step 1: Check pyenv is installed
################################################################################

echo -e "${YELLOW}[1/6] Checking pyenv installation...${NC}"

if ! command -v pyenv &> /dev/null; then
    echo -e "${RED}ERROR: pyenv is not installed${NC}"
    echo "Install pyenv first: curl https://pyenv.run | bash"
    exit 1
fi

echo -e "${GREEN}✓ pyenv is installed${NC}"
echo ""

################################################################################
# Step 2: Install Python 3.11
################################################################################

echo -e "${YELLOW}[2/6] Installing Python 3.11.11...${NC}"

PYTHON_VERSION="3.11.11"

# Check if already installed
if pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
    echo -e "${GREEN}✓ Python ${PYTHON_VERSION} is already installed${NC}"
else
    echo "Installing Python ${PYTHON_VERSION} (this will take 5-10 minutes)..."
    pyenv install ${PYTHON_VERSION}
    echo -e "${GREEN}✓ Python ${PYTHON_VERSION} installed successfully${NC}"
fi

echo ""

################################################################################
# Step 3: Set Python 3.11 for this directory
################################################################################

echo -e "${YELLOW}[3/6] Setting Python 3.11 for this directory...${NC}"

pyenv local ${PYTHON_VERSION}

echo -e "${GREEN}✓ Python version set to ${PYTHON_VERSION} for this directory${NC}"
echo "   Created .python-version file"
echo ""

################################################################################
# Step 4: Create virtual environment
################################################################################

echo -e "${YELLOW}[4/6] Creating virtual environment (venv-beam)...${NC}"

VENV_DIR="venv-beam"

if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment already exists. Removing old one..."
    rm -rf "$VENV_DIR"
fi

python -m venv "$VENV_DIR"

echo -e "${GREEN}✓ Virtual environment created: ${VENV_DIR}${NC}"
echo ""

################################################################################
# Step 5: Activate and upgrade pip
################################################################################

echo -e "${YELLOW}[5/6] Activating environment and upgrading pip...${NC}"

source "${VENV_DIR}/bin/activate"

pip install --upgrade pip --quiet

echo -e "${GREEN}✓ pip upgraded${NC}"
echo ""

################################################################################
# Step 6: Install Apache Beam and dependencies
################################################################################

echo -e "${YELLOW}[6/6] Installing Apache Beam and dependencies...${NC}"
echo "This may take several minutes..."
echo ""

# Install Apache Beam with GCP support
pip install 'apache-beam[gcp]==2.53.0' --quiet

# Install other GCP libraries
pip install google-cloud-storage --quiet
pip install google-cloud-bigquery --quiet
pip install python-dotenv --quiet
pip install requests --quiet

# Install utilities
pip install pytest pytest-cov --quiet

echo -e "${GREEN}✓ All dependencies installed${NC}"
echo ""

################################################################################
# Verification
################################################################################

echo -e "${YELLOW}Verifying installation...${NC}"
echo ""

echo "Python version:"
python --version

echo ""
echo "Apache Beam version:"
python -c "import apache_beam; print(f'  Apache Beam {apache_beam.__version__}')"

echo ""
echo "Installed packages:"
pip list | grep -E "apache-beam|google-cloud" | sed 's/^/  /'

echo ""

################################################################################
# Summary
################################################################################

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Setup Complete!                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Python 3.11 environment is ready for Apache Beam!${NC}"
echo ""
echo "To activate the environment:"
echo -e "  ${BLUE}source venv-beam/bin/activate${NC}"
echo ""
echo "To test the Beam pipeline locally:"
echo -e "  ${BLUE}python src/transformation/weather_pipeline.py \\${NC}"
echo -e "  ${BLUE}  --input gs://\${PROJECT_ID}-weather-raw/raw/*/weather-*.json \\${NC}"
echo -e "  ${BLUE}  --output \${PROJECT_ID}:weather_data.daily \\${NC}"
echo -e "  ${BLUE}  --runner DirectRunner${NC}"
echo ""
echo "To deploy to Dataflow:"
echo -e "  ${BLUE}./run_dataflow_job.sh${NC}"
echo ""

################################################################################
# END
################################################################################
