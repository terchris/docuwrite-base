#!/bin/bash

#######################################################################
# docuwrite-base Container Entrypoint Script
#
# File: /usr/local/bin/docker-entrypoint
#
# Purpose: 
# Routes commands to appropriate document processing tools (Pandoc, 
# Mermaid-CLI, or Marp) while maintaining their original command-line 
# interfaces and allows interactive shell access. Also provides access
# to integration tests.
#
# Environment Variables Required:
# - XVFB_DISPLAY: Virtual framebuffer display number (:99)
# - DISPLAY: X display to use (matches XVFB_DISPLAY)
# - PUPPETEER_CONFIG: Path to Puppeteer configuration
# - NODE_PATH: Path to node modules
#
# Available Tools:
# - pandoc: Document conversion
# - mmdc: Mermaid diagram generation
# - marp: Presentation creation
# - test-install: Run integration tests
# - bash: Interactive shell access
#######################################################################

# Set default permissions for output files
umask 0002

# Check essential environment variables
required_vars=(
    "DISPLAY"
    "PUPPETEER_CONFIG"
    "NODE_PATH"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# Function to verify Xvfb is running
verify_xvfb() {
    if ! ps aux | grep -v grep | grep -q "Xvfb ${DISPLAY}"; then
        echo "ERROR: Xvfb is not running on display ${DISPLAY}"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "docuwrite-base Container Usage:"
    echo "docker run [docker-options] docuwrite-base [tool] [tool-options]"
    echo ""
    echo "Available tools:"
    echo "  pandoc - Pandoc document converter"
    echo "  mmdc   - Mermaid CLI diagram generator"
    echo "  marp   - Marp slide deck converter"
    echo "  test-install - Run container integration tests"
    echo "  bash   - Start an interactive shell session"
    echo ""
    echo "File Access:"
    echo "  - Place your input files in the directory from which you run the container"
    echo "  - Output files will appear in the same directory"
    echo ""
    echo "Interactive Shell Access:"
    echo "For Windows PowerShell:"
    echo "  docker run --rm -it -v \"\${PWD}:/data\" docuwrite-base bash"
    echo ""
    echo "For Windows CMD:"
    echo "  docker run --rm -it -v \"%CD%:/data\" docuwrite-base bash"
    echo ""
    echo "For macOS/Linux (bash/zsh):"
    echo "  docker run --rm -it -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite-base bash"
    echo ""
    echo "Tool Usage Examples:"
    echo ""
    echo "For Windows PowerShell:"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite-base pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite-base mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite-base marp slides.md -o presentation.html"
    echo ""
    echo "For Windows CMD:"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite-base pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite-base mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite-base marp slides.md -o presentation.html"
    echo ""
    echo "For macOS/Linux (bash/zsh):"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite-base pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite-base mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite-base marp slides.md -o presentation.html"
    echo ""
    echo "Run Integration Tests:"
    echo "  docker run --rm docuwrite-base test-install"
    echo ""
    echo "Notes:"
    echo "  - Always use forward slashes (/) in file paths, even on Windows"
    echo "  - Files must be in the current directory or its subdirectories"
    echo "  - Windows users: Run from a directory where you have write permissions"
    echo "  - macOS/Linux users: The --user flag ensures correct file ownership"
    echo ""
    echo "For tool-specific options, run:"
    echo "  docker run --rm docuwrite-base pandoc --help"
    echo "  docker run --rm docuwrite-base mmdc --help"
    echo "  docker run --rm docuwrite-base marp --help"
    exit 1
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    show_usage
fi

# Get the tool name from first argument
TOOL="$1"
shift

# Verify Xvfb is running
verify_xvfb

# Export only necessary environment variables
export DISPLAY
export PUPPETEER_CONFIG
export NODE_PATH

# Execute the appropriate tool based on the first argument
case "$TOOL" in
    pandoc)
        exec pandoc "$@"
        ;;
    mmdc)
        # Always add the puppeteer config parameter for mmdc
        exec mmdc -p "${PUPPETEER_CONFIG}" "$@"
        ;;
    marp)
        exec marp "$@"
        ;;
    test-install)
        exec test-install
        ;;
    bash)
        exec bash "$@"
        ;;
    *)
        echo "Error: Unknown tool '$TOOL'"
        show_usage
        ;;
esac