#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Starting Docker cleanup..."

echo "🗑️ Removing dangling Docker images..."
docker image prune -f

echo "🚽 Pruning unused containers and networks..."
docker system prune --volumes -f

echo "✅ Docker cleanup completed successfully!"

