
#!/bin/bash

# Hugo Blog DevContainer Setup Script
echo "🚀 Setting up Hugo blog development environment..."

# Install Hugo using Alpine package manager
echo "📦 Installing Hugo..."

# Update package index and install Hugo extended version from Alpine packages
apk update && apk add --no-cache hugo

# Verify Hugo installation
echo "✅ Hugo version:"
hugo version

# Install additional tools for blog development
echo "📦 Installing additional development tools..."

# Install npm packages globally for potential theme development (if npm is available)
if command -v npm &> /dev/null; then
    npm install -g markdownlint-cli
fi

# Set up git submodules (themes)
echo "🎨 Initializing git submodules..."
cd /workspaces/blog
git submodule update --init --recursive

# Create useful aliases in the current user's shell config
echo "⚙️  Setting up development aliases..."

# Handle different environments (DevContainer vs Codespace)
if [ "$USER" = "vscode" ] && [ "$HOME" = "/home/codespace" ]; then
    # Codespace environment - user is vscode but HOME is /home/codespace
    SHELL_RC="/home/vscode/.bashrc"
    # Also create aliases in the actual home directory
    SHELL_RC_ALT="$HOME/.bashrc"
elif [ "$USER" = "vscode" ]; then
    # Standard DevContainer environment
    SHELL_RC="/home/vscode/.bashrc"
else
    # Fallback to current user's home
    SHELL_RC="$HOME/.bashrc"
fi

# Create the bashrc file if it doesn't exist
if [ ! -f "$SHELL_RC" ]; then
    mkdir -p "$(dirname "$SHELL_RC")"
    touch "$SHELL_RC"
fi

# Add aliases to the bashrc
echo 'alias blog-serve="hugo server --bind 0.0.0.0 --port 1313 --disableFastRender"' >> "$SHELL_RC"
echo 'alias blog-build="hugo --cleanDestinationDir"' >> "$SHELL_RC"
echo 'alias blog-draft="hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender"' >> "$SHELL_RC"

# Also add to alternative location if it exists
if [ -n "$SHELL_RC_ALT" ] && [ "$SHELL_RC_ALT" != "$SHELL_RC" ]; then
    if [ ! -f "$SHELL_RC_ALT" ]; then
        mkdir -p "$(dirname "$SHELL_RC_ALT")"
        touch "$SHELL_RC_ALT"
    fi
    echo 'alias blog-serve="hugo server --bind 0.0.0.0 --port 1313 --disableFastRender"' >> "$SHELL_RC_ALT"
    echo 'alias blog-build="hugo --cleanDestinationDir"' >> "$SHELL_RC_ALT"
    echo 'alias blog-draft="hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender"' >> "$SHELL_RC_ALT"
fi

# Create a simple development script
cat > /workspaces/blog/dev.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting Hugo development server..."
echo "📝 Your blog will be available at: http://localhost:1313"
echo "🔄 Server will auto-reload on file changes"
echo ""
hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender
EOF

chmod +x /workspaces/blog/dev.sh

echo "✅ DevContainer setup complete!"
echo ""
echo "🎉 Ready to develop your Hugo blog!"
echo "📋 Available commands:"
echo "  ./dev.sh              - Start development server"
echo "  blog-serve             - Start production preview"
echo "  blog-draft             - Start server with drafts"
echo "  blog-build             - Build static site"
echo "  hugo new post/my-post  - Create new blog post"
echo ""
echo "🌐 Your blog will be available at http://localhost:1313"
