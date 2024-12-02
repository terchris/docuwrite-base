@echo off
setlocal enabledelayedexpansion

REM Define test directory
set "testDir=win-test"
echo Creating test directory: %testDir%
mkdir "%testDir%" 2>nul

REM Change to test directory
cd "%testDir%"

REM Copy test files from container
echo Extracting test files from container...
docker run --rm -v "%cd%:/data" docuwrite-base bash -c "cp -r /usr/local/tests/* /data/"

echo Running conversion tests...

REM Test 1: Mermaid Diagram to PNG
echo Testing Mermaid Diagram to PNG...
docker run --rm -v "%cd%:/data" docuwrite-base mmdc -i mermaid-diagram.mmd -o mermaid-diagram.png -p /usr/local/etc/puppeteer-config.json

REM Test 2: Simple Markdown to PDF
echo Testing Simple Markdown to PDF...
docker run --rm -v "%cd%:/data" docuwrite-base pandoc simple-markdown.md --pdf-engine=xelatex -o simple-markdown.pdf

REM Test 3: Simple Markdown to DOCX
echo Testing Simple Markdown to DOCX...
docker run --rm -v "%cd%:/data" docuwrite-base pandoc simple-markdown.md --embed-resources --standalone -o simple-markdown.docx

REM Test 4: Markdown with Mermaid diagrams
echo Processing Markdown with Mermaid diagrams...
docker run --rm -v "%cd%:/data" docuwrite-base mmdc -i markdown-diagram.md -o markdown-diagram-image.md --pdfFit -b transparent --outputFormat png --puppeteerConfigFile /usr/local/etc/puppeteer-config.json

echo Converting processed Markdown to PDF...
docker run --rm -v "%cd%:/data" docuwrite-base pandoc markdown-diagram-image.md --pdf-engine=xelatex --resource-path=. --embed-resources --standalone -o markdown-diagram.pdf

echo Converting processed Markdown to DOCX...
docker run --rm -v "%cd%:/data" docuwrite-base pandoc markdown-diagram-image.md --resource-path=. --embed-resources --standalone -o markdown-diagram.docx

REM Test 5: Marp slide deck conversions
echo Testing Marp Slide Deck to PDF...
docker run --rm -v "%cd%:/data" docuwrite-base marp --allow-local-files --pdf slide-deck.md -o slide-deck.pdf

echo Testing Marp Slide Deck to PPTX...
docker run --rm -v "%cd%:/data" docuwrite-base marp --allow-local-files --pptx slide-deck.md -o slide-deck.pptx

REM List contents of the test directory
echo Test directory contents:
dir

REM Return to original directory
cd ..

echo Tests completed. Check the win-test directory for the generated files.
endlocal
