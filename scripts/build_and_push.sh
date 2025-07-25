#!/usr/bin/env bash
set -euo pipefail

GIT_COMMIT=$(git rev-parse --short HEAD)
IMAGE="varshitanukala/devops-pipeline:$GIT_COMMIT"

echo "📦 Building Docker image: $IMAGE"
docker build -t $IMAGE myapp/

echo "📤 Pushing Docker image to DockerHub..."
docker push $IMAGE

echo "✅ Docker image pushed successfully!"
