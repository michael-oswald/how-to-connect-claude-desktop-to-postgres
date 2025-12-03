#!/bin/bash
set -e

echo "🐘 Starting PostgreSQL with sample e-commerce data..."
echo ""

# Load environment variables if .env exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Use defaults if not set
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
POSTGRES_DB=${POSTGRES_DB:-mydb}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^postgres-mcp$"; then
    echo "ℹ️  Container 'postgres-mcp' already exists."

    # Check if it's running
    if docker ps --format '{{.Names}}' | grep -q "^postgres-mcp$"; then
        echo "✅ Container is already running."
        echo ""
        echo "Connection details:"
        echo "  Host: localhost"
        echo "  Port: $POSTGRES_PORT"
        echo "  Database: $POSTGRES_DB"
        echo "  Username: $POSTGRES_USER"
        exit 0
    else
        echo "🔄 Starting existing container..."
        docker start postgres-mcp
        sleep 3
        echo "✅ Container started!"
        echo ""
        echo "Connection details:"
        echo "  Host: localhost"
        echo "  Port: $POSTGRES_PORT"
        echo "  Database: $POSTGRES_DB"
        echo "  Username: $POSTGRES_USER"
        exit 0
    fi
fi

# Run PostgreSQL container
echo "🚀 Creating and starting new PostgreSQL container..."
docker run -d \
  --name postgres-mcp \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  -p "$POSTGRES_PORT:5432" \
  -v "$(pwd)/init-db:/docker-entrypoint-initdb.d:ro" \
  -v postgres-mcp-data:/var/lib/postgresql/data \
  postgres:16-alpine

echo "✅ PostgreSQL container started successfully!"
echo ""
echo "📋 Connection details:"
echo "  Host: localhost"
echo "  Port: $POSTGRES_PORT"
echo "  Database: $POSTGRES_DB"
echo "  Username: $POSTGRES_USER"
echo ""
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 5

# Test connection
if docker exec postgres-mcp pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready!"
    echo ""
    echo "📊 Sample data tables:"
    docker exec postgres-mcp psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\dt" 2>/dev/null || echo "   (Initializing... run this script again in a few seconds to see tables)"
else
    echo "⚠️  PostgreSQL is still starting up. Give it a few more seconds..."
fi

echo ""
echo "🛠️  Management commands:"
echo "  Stop:   docker stop postgres-mcp"
echo "  Start:  docker start postgres-mcp"
echo "  Remove: docker rm -f postgres-mcp"
echo "  Logs:   docker logs postgres-mcp"
