#!/bin/bash
# Forward-Warp Installation Script for Linux
# Cross-distribution compatible

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================="
echo "      Forward-Warp Installation - Cross-Linux Script"
echo "============================================================="
echo ""

# Install the base Forward_Warp package
echo "[INFO] Installing Forward_Warp base package..."
cd "${SCRIPT_DIR}"
python setup.py install

# Build and install CUDA extension
echo "[INFO] Building CUDA extension..."
cd "${SCRIPT_DIR}/Forward_Warp/cuda/"
python setup.py install

echo ""
echo "[OK] Forward-Warp installation completed successfully."
