# docuwrite-base

A swiss army knife for converting text and images to professional documents and presentations. Contains pandoc, mermaid-cli, marp-cli, Puppeteer, Firefox and maintains the functionality in these. Works on AMD64 and ARM64. (Mac ARM CPU and on X86 CPU for Windows and Linux)

![DocuWrite Logo](tests/docuwrite-logo-min.png)

[docuwrite-base](https://github.com/terchris/docuwrite-base) is a lightweight, containerized base for generating documentation from Markdown files. It integrates three powerful tools:

1. [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli): Create PNG or SVG diagrams from Mermaid.js code blocks.
2. [Pandoc CLI](https://github.com/pandoc/dockerfiles): Convert Markdown into PDFs, Word documents, or other formats.
3. [Marp CLI](https://github.com/marp-team/marp-cli): Generate professional PDF or PowerPoint slide decks from Markdown.
4. [Puppeteer](https://github.com/puppeteer/puppeteer): Create PDFs from HTML.
5. [Firefox](https://www.mozilla.org/en-US/firefox/): Create PDFs from HTML.

Think about this image as your swiss army knife for converting text and images to professional documents and presentations. Refer to the [Pandoc website](https://pandoc.org/), [Mermaid website](https://mermaid.js.org/), [Marp](https://marp.app/) and [Puppeteer](https://github.com/puppeteer/puppeteer) for full howtos.

## Features

- **Preconfigured Environment**: Ready-to-use Docker container with all necessary tools.
- **Cross-Platform Compatibility**: Works seamlessly on x86 and ARM architectures.
- **Flexible Output Options**: Supports multiple formats like PDFs, DOCX, and slide decks.
- **Customizable**: Easy to integrate into existing workflows.

## Requirements

To use docuwrite-base Base, you need container runtime software installed on your machine. The system has been tested with the following:

- [Rancher Desktop](https://rancherdesktop.io/): A desktop Kubernetes and container management application.
- [Podman Desktop](https://podman.io/getting-started/installation): A lightweight container engine and Docker alternative.
- [Docker Desktop](https://www.docker.com/products/docker-desktop/): The popular containerization platform.

Make sure you have one of these installed and properly configured before using docuwrite-base Base.

## Architecture Support

docuwrite-base supports both x86_64 (AMD64) and ARM64 architectures. The container images are built automatically for both architectures and published to GitHub Container Registry. Docker will automatically select the correct architecture for your system.

## Installation

Pull the container from GitHub Container Registry:

```bash
# Latest version
docker pull ghcr.io/terchris/docuwrite-base:latest

# Specific version
docker pull ghcr.io/terchris/docuwrite-base:0.1.0
```

The container will automatically use the correct version for your system's architecture (AMD64 or ARM64).

After you have pulled the container we give it a tag so that it is easier to use.

```bash
docker tag ghcr.io/terchris/docuwrite-base:latest docuwrite-base
```

Once the container is installed, you can use the `docuwrite-base` container to generate diagrams, documents, and presentations. The container mounts your project directory and processes the input files based on the selected tool.

Test the container and display the help instructions

```bash
   docker run --rm docuwrite-base
```

You should see:

```plaintext
docuwrite-base Container Usage:
docker run [docker-options] docuwrite-base [tool] [tool-options]

Available tools:
  pandoc - Pandoc document converter
  mmdc   - Mermaid CLI diagram generator
  marp   - Marp slide deck converter
  test-install - Run container integration tests
  bash   - Start an interactive shell session

File Access:
  - Place your input files in the directory from which you run the container
  - Output files will appear in the same directory

Interactive Shell Access:
For Windows PowerShell:
  docker run --rm -it -v "${PWD}:/data" docuwrite-base bash

For Windows CMD:
  docker run --rm -it -v "%CD%:/data" docuwrite-base bash

For macOS/Linux (bash/zsh):
  docker run --rm -it -v "$(pwd):/data" --user $(id -u):$(id -g) docuwrite-base bash

Tool Usage Examples:

For Windows PowerShell:
  docker run --rm -v "${PWD}:/data" docuwrite-base pandoc input.md -o output.pdf
  docker run --rm -v "${PWD}:/data" docuwrite-base mmdc -i diagram.mmd -o diagram.png
  docker run --rm -v "${PWD}:/data" docuwrite-base marp slides.md -o presentation.html

For Windows CMD:
  docker run --rm -v "%CD%:/data" docuwrite-base pandoc input.md -o output.pdf
  docker run --rm -v "%CD%:/data" docuwrite-base mmdc -i diagram.mmd -o diagram.png
  docker run --rm -v "%CD%:/data" docuwrite-base marp slides.md -o presentation.html

For macOS/Linux (bash/zsh):
  docker run --rm -v "$(pwd):/data" --user $(id -u):$(id -g) docuwrite-base pandoc input.md -o output.pdf
  docker run --rm -v "$(pwd):/data" --user $(id -u):$(id -g) docuwrite-base mmdc -i diagram.mmd -o diagram.png
  docker run --rm -v "$(pwd):/data" --user $(id -u):$(id -g) docuwrite-base marp slides.md -o presentation.html

Run Integration Tests:
  docker run --rm docuwrite-base test-install

Notes:
  - Always use forward slashes (/) in file paths, even on Windows
  - Files must be in the current directory or its subdirectories
  - Windows users: Run from a directory where you have write permissions
  - macOS/Linux users: The --user flag ensures correct file ownership

For tool-specific options, run:
  docker run --rm docuwrite-base pandoc --help
  docker run --rm docuwrite-base mmdc --help
  docker run --rm docuwrite-base marp --help
```

**Note**:
As you can see there is a difference on how you map the drive on your machine depending on wether you are using Windows or Mac ( ${PWD} vs $(pwd) vs %CD% ).

## Usage

As docuwrite-base is just a merge of other great tools we refer you to their documentation for all details.
So this quick start is just to get you started and verify that docuwrite-base works.
In the quick start we assume you are on windows and use powershell. If you are on different OS/shell se the note above.

### Quick Start

1. Open poweshell and create a folder for test files

   ```bash
    cd $HOME
    mkdir test-files
    cd test-files
   ```

2. Copy some test files that we use to verify that it is working

   ```bash
   curl -o simple-markdown.md "https://raw.githubusercontent.com/terchris/docuwrite-base/main/tests/simple-markdown.md"
   curl -o docuwrite-logo.png "https://raw.githubusercontent.com/terchris/docuwrite-base/main/tests/docuwrite-logo.png"
   curl -o markdown-diagram.md "https://raw.githubusercontent.com/terchris/docuwrite-base/main/tests/markdown-diagram.md"
   curl -o mermaid-diagram.mmd "https://raw.githubusercontent.com/terchris/docuwrite-base/main/tests/mermaid-diagram.mmd"
   curl -o slide-deck.md "https://raw.githubusercontent.com/terchris/docuwrite-base/main/tests/slide-deck.md"
   curl -o pandoc-MANUAL.txt "https://pandoc.org/demo/MANUAL.txt"
   dir
   ```

3. Exampple usage of the tools in docuwrite-base container:
   - **Convert simple Markdown to PDF using pandoc**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base pandoc simple-markdown.md --pdf-engine=xelatex -o simple-markdown.pdf
     dir simple-markdown.pdf
     Start-Process simple-markdown.pdf
     ```

     Convert the simple-markdown file to pdf and open it in your pdf viewer.

   - **Convert the pandoc manual to a professional document in PDF using pandoc**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base pandoc -N --variable "geometry=margin=1.2in" --variable fontsize=12pt --variable version=2.0 pandoc-MANUAL.txt --pdf-engine=xelatex --toc -o pandoc-MANUAL.pdf
     dir pandoc-MANUAL.pdf
     Start-Process pandoc-MANUAL.pdf
     ```

     Convert the full pandoc user manual to a professional document with page numbering, table of content +++ file and open it in your pdf viewer.
     If you want it in M$ Word `docker run --rm -v ${PWD}:/data docuwrite-base pandoc -s pandoc-MANUAL.txt --toc -o pandoc-MANUAL.docx` Read more [about pandoc on their web](https://pandoc.org/)

   - **Convert Mermaid diagram file to PNG using mermaid**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base mmdc -i mermaid-diagram.mmd -o mermaid-diagram.png
     dir mermaid-diagram.png
     Start-Process mermaid-diagram.png
     ```

     Converts a mermaid diagram file mermaid-diagram.mmd to png file and view it.

   - **Convert Markdown that contains mermaid figure to markdown with png image using mermaid**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base mmdc -i markdown-diagram.md -o markdown-diagram-image.md --pdfFit --outputFormat png     
     dir markdown-diagram-image*
     ```

     Converts a markdown file that has a mermaid image so that the image is stored in png format and the output markdown file refers to the png file. This markdown file can now be converted to pdf or word

   - **Convert Markdown slide deck to PDF using marp**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base marp --pdf --allow-local-files slide-deck.md -o slide-deck.pdf
     dir slide-deck.pdf
     Start-Process slide-deck.pdf
     ```

     Convert the markdown slide-deck to pdf and open it in your pdf viewer

   - **Convert Markdown slide deck to PowerPoint PPTX using marp**:

     ```bash
     docker run --rm -v ${PWD}:/data docuwrite-base marp --pptx --allow-local-files slide-deck.md -o slide-deck.pptx
     dir slide-deck.pptx
     Start-Process slide-deck.pptx
     ```

     Convert the markdown slide-deck to PowerPoint and open it in your PowerPoint 

### Example Workflow

Write your documentation in Markdown, using Mermaid diagrams and presentation syntax where needed. Use the provided container to process files into the desired output formats.

## Troubleshooting

If something isn't working as expected, use the included test scripts to verify your setup:

### Self test

The self test is a script that tests the functionality of the tools in the container.

```bash
docker run --rm docuwrite-base test-install
```

A output example is listed in the file [trouble-notes.md](trouble-notes.md)

### Debugging Inside the Container

To debug or inspect the environment:

```bash
docker run --rm -it -v ${PWD}:/data docuwrite-base bash
```

You can manually run commands like `pandoc`, `mmdc`, or `marp` to identify any issues.

There is also a script that tests the functionality of the tools in the container. Once inside the container run it using:

```bash
test-install
```

You should see a list of all tests and get error messages if something is wrong. You can find more info about trouble shooting in the file [trouble-notes.md](trouble-notes.md)

## Development and Release Process

### Local Development Build

For local development and testing, you can build the container for your current architecture:

```bash
# Build for current architecture only
docker build -t docuwrite-base .

# Test after build
docker run --rm docuwrite-base
```

Note: Local builds will only work for your current architecture. For multi-architecture builds, use the GitHub Actions release process.
See the file [build.cmd](https://raw.githubusercontent.com/terchris/docuwrite-base/main/build.cmd)

### Release process

The container is built automatically by GitHub Actions when creating a new release. The build process creates images for both AMD64 and ARM64 architectures. Here's the process:

1. Make your changes and push them to main:

```bash
git add .
git commit -m "your changes"
git push origin main
```

2. Create and push a new version tag:

```bash
git tag v0.1.1  # Update version number as appropriate
git push origin v0.1.1  # This triggers the container build
```

3. Create a Release on GitHub:

- Go to: https://github.com/terchris/docuwrite-base/releases/new
- Choose the tag you just created
- Add a descriptive title (e.g., "Release v0.1.1")
- Add release notes describing changes
- Publish release

The GitHub Action will automatically:

- Build the container
- Push to GitHub Container Registry with tags:
  - Latest version (`:latest`)
  - Specific version (`:0.1.1`)
  - Major.Minor version (`:0.1`)

### Version Numbering

Following semantic versioning:

- MAJOR.MINOR.PATCH (e.g., 0.1.0)
- Increment PATCH (0.1.0 → 0.1.1) for bug fixes
- Increment MINOR (0.1.0 → 0.2.0) for new features
- Increment MAJOR (0.1.0 → 1.0.0) for breaking changes
- Use 0.x.x for initial development

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

MIT License
