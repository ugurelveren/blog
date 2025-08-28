
#!/bin/bash

# Hugo Blog DevContainer Setup Script
echo "🚀 Setting up Hugo blog development environment..."

# Install Hugo using package manager
echo "📦 Installing Hugo..."

# Update package index and install Hugo extended version
sudo apt-get update
sudo apt-get install -y wget

# Download and install Hugo extended (latest stable version)
HUGO_VERSION="0.119.0"
wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" -O /tmp/hugo.deb
sudo dpkg -i /tmp/hugo.deb
rm /tmp/hugo.deb

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

# Use standard home directory for vscode user
SHELL_RC="/home/vscode/.bashrc"

# Create the bashrc file if it doesn't exist
if [ ! -f "$SHELL_RC" ]; then
    mkdir -p "$(dirname "$SHELL_RC")"
    touch "$SHELL_RC"
fi

# Add aliases to the bashrc
echo 'alias blog-serve="hugo server --bind 0.0.0.0 --port 1313 --disableFastRender"' >> "$SHELL_RC"
echo 'alias blog-build="hugo --cleanDestinationDir"' >> "$SHELL_RC"
echo 'alias blog-draft="hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender"' >> "$SHELL_RC"

# Also add to zshrc if it exists
SHELL_RC_ZSH="/home/vscode/.zshrc"
if [ -f "$SHELL_RC_ZSH" ]; then
    echo 'alias blog-serve="hugo server --bind 0.0.0.0 --port 1313 --disableFastRender"' >> "$SHELL_RC_ZSH"
    echo 'alias blog-build="hugo --cleanDestinationDir"' >> "$SHELL_RC_ZSH"
    echo 'alias blog-draft="hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender"' >> "$SHELL_RC_ZSH"
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
