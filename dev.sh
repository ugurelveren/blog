#!/bin/bash
echo "🌐 Starting Hugo development server..."
echo "📝 Your blog will be available at: http://localhost:1313"
echo "🔄 Server will auto-reload on file changes"
echo ""
hugo server --bind 0.0.0.0 --port 1313 --buildDrafts --disableFastRender
