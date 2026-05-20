#!/bin/bash
# StereoMaster - Cross-Linux Portable Launch Script
# This script works on any modern Linux distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_NAME="${VENV_NAME:-stereomaster_env}"
VENV_DIR="${SCRIPT_DIR}/${VENV_NAME}"
PYTHON_CMD=""

echo "============================================================="
echo "      StereoMaster - Cross-Linux Launch Script"
echo "============================================================="
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect Python version
detect_python() {
    local python_cmd=""
    
    # Try different Python commands in order of preference
    for cmd in "python3.12" "python3.11" "python3.10" "python3" "python"; do
        if command_exists "$cmd"; then
            local version=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
            local major=$(echo "$version" | cut -d. -f1)
            local minor=$(echo "$version" | cut -d. -f2)
            
            # Require Python 3.10 or higher
            if [ "$major" -ge 3 ] && [ "$minor" -ge 10 ]; then
                python_cmd="$cmd"
                echo "[OK] Found suitable Python: $cmd (version $version)"
                break
            fi
        fi
    done
    
    if [ -z "$python_cmd" ]; then
        echo "[ERROR] No suitable Python found. Please install Python 3.10 or higher."
        exit 1
    fi
    
    echo "$python_cmd"
}

# Check if virtual environment exists
if [ -d "$VENV_DIR" ]; then
    echo "[OK] Virtual environment found: $VENV_DIR"
    
    # Activate virtual environment
    if [ -f "$VENV_DIR/bin/activate" ]; then
        source "$VENV_DIR/bin/activate"
        PYTHON_CMD="python"
        echo "[OK] Virtual environment activated."
    else
        echo "[WARNING] Virtual environment activation script not found."
    fi
else
    echo "[INFO] Virtual environment not found. Creating..."
    
    # Detect Python
    PYTHON_CMD=$(detect_python)
    
    # Create virtual environment
    "$PYTHON_CMD" -m venv "$VENV_DIR"
    
    # Activate it
    source "$VENV_DIR/bin/activate"
    PYTHON_CMD="python"
    echo "[OK] Virtual environment created and activated."
fi

echo ""
echo "[INFO] Starting StereoMaster..."
echo ""

# Launch StereoMaster with python (not pythonw which is Windows-specific)
"$PYTHON_CMD" StereoMaster.py

exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "[ERROR] StereoMaster exited with code $exit_code"
    exit $exit_code
fi

echo "[OK] StereoMaster finished successfully."
