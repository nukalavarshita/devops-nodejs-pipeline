#!/bin/bash
set -euo pipefail

echo "🧹 Starting Docker cleanup..."

echo "🔍 Removing dangling Docker images..."
docker image prune -f --filter "dangling=true"

echo "🔍 Pruning unused Docker containers..."
docker container prune -f

echo "🔍 Pruning unused Docker networks..."
docker network prune -f

echo "✅ Docker cleanup completed successfully!"
