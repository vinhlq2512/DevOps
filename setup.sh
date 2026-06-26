#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Error: Docker daemon is not running. Please start Docker/OrbStack."
  exit 1
fi

SERVICE=$1
BASE_DIR="Docker Compose"

if [ -z "$SERVICE" ]; then
  echo "Usage: ./setup.sh [service_name]"
  echo "Available services:"
  ls -1 "$BASE_DIR" | sed 's/^/  - /'
  echo "  - all"
  exit 1
fi

echo "🚀 Setting up shared infrastructure..."

# Create shared network if it doesn't exist
if ! docker network ls | grep -q shared_network; then
  echo "🌐 Creating shared_network network..."
  docker network create shared_network
else
  echo "🌐 Network shared_network already exists."
fi

setup_service() {
  local srv=$1
  if [ -d "$BASE_DIR/$srv" ]; then
    echo "🔄 Starting $srv..."
    cd "$BASE_DIR/$srv" || exit
    if docker compose version > /dev/null 2>&1; then
      docker compose up -d
    else
      docker-compose up -d
    fi
    cd - > /dev/null || exit
  else
    echo "❌ Error: Service '$srv' not found in '$BASE_DIR/'"
    exit 1
  fi
}

if [ "$SERVICE" == "all" ]; then
  echo "🚀 Starting all services..."
  for dir in "$BASE_DIR"/*/; do
    srv_name=$(basename "$dir")
    setup_service "$srv_name"
  done
else
  setup_service "$SERVICE"
fi

echo "✅ Setup complete for: $SERVICE"
