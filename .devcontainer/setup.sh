#!/bin/bash

# Hugo Blog DevContainer Setup Script
echo "🚀 Setting up Hugo blog development environment..."

# Install Hugo extended version
HUGO_VERSION="0.119.0"
echo "📦 Installing Hugo v${HUGO_VERSION}..."

# Download and install Hugo
cd /tmp
wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
tar -xzf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
sudo mv hugo /usr/local/bin/

# Verify Hugo installation
echo "✅ Hugo version:"
hugo version

# Install additional tools for blog development
echo "📦 Installing additional development tools..."

# Install npm packages globally for potential theme development
npm install -g markdownlint-cli

# Set up git submodules (themes)
echo "🎨 Initializing git submodules..."
cd /workspaces/blog
git submodule update --init --recursive

# Create useful aliases
echo "⚙️  Setting up development aliases..."
echo 'alias blog-serve="hugo server --bind 0.0.0.0 --port 1313 --disableFastRender"' >> ~/.bashrc
echo 'alias blog-build="hugo --cleanDestinationDir"' >> ~/.bashrc
echo 'alias blog-draft="hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender"' >> ~/.bashrc

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
