#!/bin/bash

#######################################################################
# DocuWrite Container Entrypoint Script
#
# File: /usr/local/bin/docker-entrypoint
#
# Purpose: Routes commands to appropriate document processing tools
# (Pandoc, Mermaid-CLI, or Marp) while maintaining their original
# command-line interfaces and allows interactive shell access.
#######################################################################

# Set default permissions for output files
umask 0002

# Function to show usage
show_usage() {
    echo "DocuWrite Container Usage:"
    echo "docker run [docker-options] docuwrite [tool] [tool-options]"
    echo ""
    echo "Available tools:"
    echo "  pandoc - Pandoc document converter"
    echo "  mmdc   - Mermaid CLI diagram generator"
    echo "  marp   - Marp slide deck converter"
    echo "  bash   - Start an interactive shell session"
    echo ""
    echo "File Access:"
    echo "  - Place your input files in the directory from which you run the container"
    echo "  - Output files will appear in the same directory"
    echo ""
    echo "Interactive Shell Access:"
    echo "For Windows PowerShell:"
    echo "  docker run --rm -it -v \"\${PWD}:/data\" docuwrite bash"
    echo ""
    echo "For Windows CMD:"
    echo "  docker run --rm -it -v \"%CD%:/data\" docuwrite bash"
    echo ""
    echo "For macOS/Linux (bash/zsh):"
    echo "  docker run --rm -it -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite bash"
    echo ""
    echo "Tool Usage Examples:"
    echo ""
    echo "For Windows PowerShell:"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"\${PWD}:/data\" docuwrite marp slides.md -o presentation.html"
    echo ""
    echo "For Windows CMD:"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"%CD%:/data\" docuwrite marp slides.md -o presentation.html"
    echo ""
    echo "For macOS/Linux (bash/zsh):"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite pandoc input.md -o output.pdf"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite mmdc -i diagram.mmd -o diagram.png"
    echo "  docker run --rm -v \"\$(pwd):/data\" --user \$(id -u):\$(id -g) docuwrite marp slides.md -o presentation.html"
    echo ""
    echo "Notes:"
    echo "  - Always use forward slashes (/) in file paths, even on Windows"
    echo "  - Files must be in the current directory or its subdirectories"
    echo "  - Windows users: Run from a directory where you have write permissions"
    echo "  - macOS/Linux users: The --user flag ensures correct file ownership"
    echo "  - Use -it flags when starting an interactive shell"
    echo ""
    echo "For tool-specific options, run:"
    echo "  docker run --rm docuwrite pandoc --help"
    echo "  docker run --rm docuwrite mmdc --help"
    echo "  docker run --rm docuwrite marp --help"
    exit 1
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    show_usage
fi

# Get the tool name from first argument
TOOL="$1"
shift

# Export common environment variables needed by the tools
export PUPPETEER_CONFIG="/usr/local/etc/puppeteer-config.json"
export NODE_PATH="/usr/local/app/node_modules:$NODE_PATH"

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
    bash)
        exec bash "$@"
        ;;
    *)
        echo "Error: Unknown tool '$TOOL'"
        show_usage
        ;;
esac