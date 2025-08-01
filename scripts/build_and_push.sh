#!/bin/bash

# Exit immediately if a command fails
set -e

# Variables
IMAGE_NAME="varshitanukala/nodeapp"
TAG="latest"

# Login to DockerHub
echo "Logging in to DockerHub..."
echo "$DOCKERHUB_PASSWORD" | docker login -u "$varshitanukala" --password-stdin

# Build Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG myapp/

# Push Docker image
echo "Pushing Docker image to DockerHub..."
docker push $IMAGE_NAME:$TAG

echo "Docker image pushed successfully!"
