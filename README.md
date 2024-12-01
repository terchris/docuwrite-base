# DocuWrite Base

Container for creating documents and presentations. Contains pandoc, mermaid-cli, marp-cli and maintains the functionality in these. I use it to build my stuff on top of this.

## Installation

Pull the container from GitHub Container Registry:

```bash
# Latest version
docker pull ghcr.io/terchris/docuwrite-base:latest

# Specific version
docker pull ghcr.io/terchris/docuwrite-base:0.1.0
```

## Development and Release Process

The container is only built when creating a new release. Here's the process:

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

## License

MIT License