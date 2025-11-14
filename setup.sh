#!/bin/bash

echo "🎮 Codex MCP - Docker Setup"
echo "============================"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed. Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for docker compose (new) or docker-compose (old)
if docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo "❌ Docker Compose not installed. Install from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker found"
echo ""

# Fix Docker credential helper issue if present
if [ -f ~/.docker/config.json ] && grep -q "docker-credential-desktop" ~/.docker/config.json 2>/dev/null; then
    echo "⚙️  Fixing Docker credential helper..."
    # Backup config
    cp ~/.docker/config.json ~/.docker/config.json.backup 2>/dev/null
    # Remove credential helper using sed (works on both macOS and Linux)
    sed -i.bak 's/"credsStore"[[:space:]]*:[[:space:]]*"[^"]*",\?//g' ~/.docker/config.json 2>/dev/null || \
    sed -i '' 's/"credsStore"[[:space:]]*:[[:space:]]*"[^"]*",\?//g' ~/.docker/config.json 2>/dev/null
    echo "✅ Config fixed"
    echo ""
fi

# Build image
echo "🔨 Building Docker image..."
$DOCKER_COMPOSE build
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    echo ""
    echo "💡 Troubleshooting tips:"
    echo "   1. Make sure Docker is running (check Docker Desktop)"
    echo "   2. Try: docker login"
    echo "   3. If using colima: colima start"
    exit 1
fi
echo "✅ Build complete"
echo ""

# Start container
echo "🚀 Starting Codex server..."
$DOCKER_COMPOSE up -d
if [ $? -ne 0 ]; then
    echo "❌ Failed to start"
    exit 1
fi
echo "✅ Server started"
echo ""

# Wait for health check
echo "⏳ Waiting for server..."
sleep 5

# Test health
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ Server healthy!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Codex MCP is running!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📊 Server: http://localhost:3001"
    echo "🏥 Health: http://localhost:3001/health"
    echo ""
    echo "Next steps:"
    echo "  1. Configure Claude Desktop (see README.md)"
    echo "  2. Restart Claude Desktop"
    echo "  3. Start using Codex!"
    echo ""
    echo "Note: Codex creates a default user automatically on first use"
    echo ""
    echo "Commands:"
    echo "  • Check status: $DOCKER_COMPOSE ps"
    echo "  • View logs: $DOCKER_COMPOSE logs -f"
    echo "  • Restart: $DOCKER_COMPOSE restart"
    echo "  • Stop: $DOCKER_COMPOSE down"
    echo ""
else
    echo "⚠️  Server started but not responding"
    echo "Check logs: $DOCKER_COMPOSE logs"
    exit 1
fi
