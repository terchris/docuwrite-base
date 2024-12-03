#!/bin/bash

#######################################################################
# docuwrite-base Integration Test Suite
#
# File: /usr/local/tests/test-install.sh
#
# Purpose:
# Comprehensive test suite that validates the installation and functionality
# of all components in the docuwrite-base container environment. This script
# verifies that all document processing tools are correctly installed and
# can produce the expected outputs.
#
# Components Tested:
# - Node.js and NPM installation
# - Firefox Nightly installation and version
# - Puppeteer-core with Firefox WebDriver BiDi integration
# - Xvfb display functionality
# - Pandoc installation and conversion capabilities
# - Mermaid-CLI diagram generation
# - Marp CLI slide deck conversion
#
# Input Files Required (in /usr/local/tests/):
# - simple-markdown.md: Basic markdown test file
# - mermaid-diagram.mmd: Standalone mermaid diagram
# - markdown-diagram.md: Markdown with embedded mermaid
# - slide-deck.md: Marp slide deck
# - puppeteer-test.js: Puppeteer test script
#
# Output Files (all saved in /usr/local/tests/):
# Mermaid:
#   - mermaid-diagram.png: Standalone diagram conversion
#
# Markdown:
#   - simple-markdown.pdf: Basic PDF conversion
#   - simple-markdown.docx: Basic DOCX conversion
#   - markdown-diagram-image.md: Processed markdown with diagrams
#   - markdown-diagram.pdf: PDF with diagrams
#   - markdown-diagram.docx: DOCX with diagrams
#
# Marp:
#   - slide-deck.pdf: Slide deck PDF conversion
#   - slide-deck.pptx: Slide deck PowerPoint conversion
#
# Puppeteer:
#   - puppeteer-example-screenshot.png: Website screenshot
#   - puppeteer-example-page.pdf: Website PDF export
#   - puppeteer-test-page.pdf: Test page PDF export
#
# Environment Variables Required:
# - APP_DIR: Directory containing npm packages (/usr/local/app)
# - TEST_DIR: Directory containing test files (/usr/local/tests)
# - PUPPETEER_CONFIG: Path to Puppeteer configuration
# - NODE_PATH: Path to node modules for Puppeteer
# - DISPLAY: X display to use
#
# Usage:
# ./test-install.sh
#
# Exit Codes:
# 0 - All tests passed
# 1 - Test failure (error message will be displayed)
#######################################################################

# Check essential environment variables
required_vars=(
    "APP_DIR"
    "TEST_DIR"
    "PUPPETEER_CONFIG"
    "NODE_PATH"
    "DISPLAY"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# PDF engine setting
PDF_ENGINE="--pdf-engine=xelatex"

# Test files
MERMAID_FILE="mermaid-diagram.mmd"
MERMAID_OUTPUT="mermaid-diagram.png"

MD_FILE="simple-markdown.md"
MD_PDF="simple-markdown.pdf"
MD_DOCX="simple-markdown.docx"

MD_DIAGRAM_FILE="markdown-diagram.md"
MD_DIAGRAM_IMAGE="markdown-diagram-image.md"
MD_DIAGRAM_PDF="markdown-diagram.pdf"
MD_DIAGRAM_DOCX="markdown-diagram.docx"

MARP_FILE="slide-deck.md"
MARP_PDF="slide-deck.pdf"
MARP_PPTX="slide-deck.pptx"

# Puppeteer test outputs
PUPPETEER_EXAMPLE_SS="puppeteer-example-screenshot.png"
PUPPETEER_EXAMPLE_PDF="puppeteer-example-page.pdf"
PUPPETEER_TEST_PDF="puppeteer-test-page.pdf"

# Function to handle errors
handle_error() {
   echo "ERROR: $1"
   exit 1
}

# Function to check if a file exists and has content
check_file() {
   if [ ! -f "$1" ]; then
       handle_error "File $1 was not created"
   fi
   if [ ! -s "$1" ]; then
       handle_error "File $1 is empty"
   fi
   echo "✓ Successfully created $1"
}

# Function to verify Xvfb is running
verify_xvfb() {
    if ! ps aux | grep -v grep | grep -q "Xvfb ${DISPLAY}"; then
        handle_error "Xvfb is not running on display ${DISPLAY}"
    fi
    echo "✓ Xvfb is running on display ${DISPLAY}"
}

echo "=== Testing Installation ==="
echo ""

# Verify Xvfb is running
verify_xvfb

# Version checks
echo "=== Node.js Version ==="
node --version || handle_error "Node.js not installed"

echo -e "\n=== NPM Version ==="
npm --version || handle_error "NPM not installed"

echo -e "\n=== Firefox Version ==="
firefox-nightly --version || handle_error "Firefox Nightly not installed"

echo -e "\n=== Pandoc Version ==="
pandoc --version || handle_error "Pandoc not installed"

echo -e "\n=== Puppeteer Installation ==="
if [ ! -d "${NODE_PATH}/puppeteer-core" ]; then
   handle_error "Puppeteer-core not installed in ${NODE_PATH}"
fi
echo "✓ Puppeteer-core is installed"
PUPPETEER_VERSION=$(node -p "require('${NODE_PATH}/puppeteer-core/package.json').version")
echo "Puppeteer-core version: ${PUPPETEER_VERSION}"

echo -e "\n=== Mermaid-CLI Version ==="
mmdc --version || handle_error "Mermaid-CLI not installed"

echo -e "\n=== Marp CLI Version ==="
marp --version || handle_error "Marp CLI not installed"

echo -e "\n=== Directory Structure ==="
echo "Content of ${APP_DIR} (npm packages):"
ls -la ${APP_DIR} || handle_error "Cannot access ${APP_DIR}"
echo -e "\nContent of ${TEST_DIR} (test files):"
ls -la ${TEST_DIR} || handle_error "Cannot access ${TEST_DIR}"

echo -e "\n=== Testing Conversions ==="

cd ${TEST_DIR} || handle_error "Cannot access tests directory"

# Generate standalone Mermaid diagram
echo -e "\nTesting Mermaid Diagram to PNG..."
mmdc -i ${MERMAID_FILE} -o ${MERMAID_OUTPUT} -p ${PUPPETEER_CONFIG} || handle_error "Mermaid conversion failed"
check_file "${MERMAID_OUTPUT}"

# Convert simple markdown
echo -e "\nTesting Simple Pandoc Markdown to PDF..."
pandoc ${MD_FILE} ${PDF_ENGINE} --embed-resources --standalone -o ${MD_PDF} || handle_error "Pandoc PDF conversion failed"
check_file "${MD_PDF}"

echo -e "\nTesting Simple Pandoc Markdown to DOCX..."
pandoc ${MD_FILE} --embed-resources --standalone -o ${MD_DOCX} || handle_error "Pandoc DOCX conversion failed"
check_file "${MD_DOCX}"

# Process markdown with mermaid diagrams - Updated working version
echo -e "\nProcessing Markdown with Mermaid diagrams..."
mmdc -i ${MD_DIAGRAM_FILE} -o ${MD_DIAGRAM_IMAGE} --pdfFit --outputFormat png --puppeteerConfigFile ${PUPPETEER_CONFIG} || handle_error "Mermaid markdown processing failed"
check_file "${MD_DIAGRAM_IMAGE}"

# Convert processed markdown to PDF and DOCX
echo -e "\nConverting processed Markdown to PDF..."
pandoc ${MD_DIAGRAM_IMAGE} ${PDF_ENGINE} --resource-path=. --embed-resources --standalone -o ${MD_DIAGRAM_PDF} || handle_error "Pandoc PDF diagram conversion failed"
check_file "${MD_DIAGRAM_PDF}"

echo -e "\nConverting processed Markdown to DOCX..."
pandoc ${MD_DIAGRAM_IMAGE} --resource-path=. --embed-resources --standalone -o ${MD_DIAGRAM_DOCX} || handle_error "Pandoc DOCX diagram conversion failed"
check_file "${MD_DIAGRAM_DOCX}"

# Convert Marp slides
echo -e "\nTesting Marp Slide Deck to PDF..."
marp --allow-local-files --pdf ${MARP_FILE} -o ${MARP_PDF} || handle_error "Marp PDF conversion failed"
check_file "${MARP_PDF}"

echo -e "\nTesting Marp Slide Deck to PPTX..."
marp --allow-local-files --pptx ${MARP_FILE} -o ${MARP_PPTX} || handle_error "Marp PPTX conversion failed"
check_file "${MARP_PPTX}"

# Run Puppeteer tests
echo -e "\n=== Testing Puppeteer Integration ==="
node puppeteer-test.js || handle_error "Puppeteer tests failed"

# Verify Puppeteer outputs
echo -e "\nVerifying Puppeteer test outputs..."
check_file "${PUPPETEER_EXAMPLE_SS}"
check_file "${PUPPETEER_EXAMPLE_PDF}"
check_file "${PUPPETEER_TEST_PDF}"

# Final verification and summary
echo -e "\n=== Verifying All Generated Files ==="
echo "Checking file creation and sizes..."

# All output files to verify
FILES_TO_CHECK=(
   "${MERMAID_OUTPUT}"
   "${MD_PDF}"
   "${MD_DOCX}"
   "${MD_DIAGRAM_IMAGE}"
   "${MD_DIAGRAM_PDF}"
   "${MD_DIAGRAM_DOCX}"
   "${MARP_PDF}"
   "${MARP_PPTX}"
   "${PUPPETEER_EXAMPLE_SS}"
   "${PUPPETEER_EXAMPLE_PDF}"
   "${PUPPETEER_TEST_PDF}"
)

# Final verification of all files
for file in "${FILES_TO_CHECK[@]}"; do
   check_file "${file}"
done

# Show final file listing
echo -e "\nFinal file listing:"
ls -lh "${FILES_TO_CHECK[@]}"

echo -e "\n=== All tests completed successfully ==="
exit 0