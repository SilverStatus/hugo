#!/bin/bash

set -e  # Exit on any error

PROJECT_DIR=$(pwd)

echo "========================================"
echo "Hugo Build and Deploy Script"
echo "========================================"
echo ""

# Step 1: Check if hugo-site directory exists
if [ ! -d "hugo-site" ]; then
    echo "✗ Error: hugo-site directory not found!"
    exit 1
fi

# Step 2: Check if hugo config exists
if [ ! -f "hugo-site/hugo.toml" ] && [ ! -f "hugo-site/config.toml" ]; then
    echo "✗ Error: Hugo configuration file not found!"
    exit 1
fi

echo "Step 1: Building Hugo site..."
echo "----------------------------------------"

# Build the Hugo site
docker run --rm -v "$PROJECT_DIR/hugo-site:/src" \
  hugomods/hugo:latest \
  hugo --minify 

echo ""
echo "Step 2: Verifying build output..."
echo "----------------------------------------"

# Check if index.html was created
if [ ! -f "hugo-site/public/index.html" ]; then
    echo "✗ Error: Hugo build failed - index.html not found!"
    echo ""
    echo "Contents of hugo-site/public:"
    ls -laR hugo-site/public/ || echo "Directory doesn't exist"
    exit 1
fi

echo "✓ index.html found"

# Show generated files
echo ""
echo "Generated files:"
ls -lh hugo-site/public/ | head -10

# Count total files
FILE_COUNT=$(find hugo-site/public -type f | wc -l)
echo ""
echo "✓ Total files generated: $FILE_COUNT"

echo ""
echo "Step 3: Fixing permissions..."
echo "----------------------------------------"

# Fix permissions
chmod -R 755 hugo-site/public/
find hugo-site/public -type f -exec chmod 644 {} \;

echo "✓ Permissions fixed"

echo ""
echo "Step 4: Deploying containers..."
echo "----------------------------------------"

# Stop existing containers
docker-compose down

# Start containers
docker-compose up -d

# Wait for containers to start
sleep 3

echo ""
echo "Step 5: Verifying deployment..."
echo "----------------------------------------"

# Check container status
echo "Container status:"
docker-compose ps

echo ""
echo "Checking Hugo container files:"
# Check which image is being used and verify files accordingly
HUGO_IMAGE=$(docker inspect hugo --format='{{.Config.Image}}')

if [[ $HUGO_IMAGE == *"hugomods"* ]]; then
    echo "Using hugomods/hugo:nginx - checking /site/"
    docker exec hugo ls -lah /site/ | head -10
else
    echo "Using nginx:alpine - checking /usr/share/nginx/html/"
    docker exec hugo ls -lah /usr/share/nginx/html/ | head -10
fi

echo ""
echo "========================================"
echo "✓ Deployment Complete!"
echo "========================================"
echo ""
echo "Access your services:"
echo "  • Hugo Blog: http://44.202.65.12/apps/"
echo "  • Portainer: http://44.202.65.12/portainer/"
echo ""
echo "To check logs:"
echo "  docker-compose logs hugo"
echo "  docker-compose logs nginx"
echo ""
