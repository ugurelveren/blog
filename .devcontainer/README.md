# Hugo Blog DevContainer

This DevContainer provides a complete Hugo development environment for your blog with all necessary tools pre-installed.

## What's Included

- **Hugo Extended** (latest version) - Static site generator
- **Node.js 18** - For theme development and npm packages
- **Git** - Version control with submodule support
- **VS Code Extensions**:
  - Hugo syntax highlighting and themes
  - Markdown editing and preview
  - TOML/YAML configuration support
  - Markdown linting

## Quick Start

1. Open this repository in VS Code
2. Click "Reopen in Container" when prompted (or use Command Palette: "Dev Containers: Reopen in Container")
3. Wait for the container to build and setup to complete
4. Run `./dev.sh` to start the development server
5. Open http://localhost:1313 in your browser

## Development Commands

```bash
# Start development server with drafts
./dev.sh

# Start production preview (no drafts)
blog-serve

# Build static site
blog-build

# Create new blog post
hugo new post/my-new-post.md

# Check Hugo version
hugo version
```

## Features

- 🔄 **Auto-reload** - Changes are reflected immediately
- 📝 **Draft support** - Preview unpublished posts
- 🎨 **Theme development** - Full access to theme customization
- 🔍 **Markdown linting** - Catch formatting issues early
- 📦 **Git submodules** - Automatic theme initialization

## Port Forwarding

The DevContainer automatically forwards port 1313 so you can access your blog at:
- http://localhost:1313 (from your host machine)

## Customization

- Edit `.devcontainer/devcontainer.json` to add more VS Code extensions
- Modify `.devcontainer/setup.sh` to install additional tools
- Update Hugo version in the setup script as needed

## Troubleshooting

If you encounter issues:

1. **Rebuild container**: Command Palette → "Dev Containers: Rebuild Container"
2. **Check Hugo version**: Run `hugo version` to ensure it's installed
3. **Submodule issues**: Run `git submodule update --init --recursive`
4. **Port conflicts**: Change port in `devcontainer.json` and restart

Happy blogging! 🚀
