#!/bin/bash

echo "=== Hugo Deployment Diagnostics ==="
echo ""

echo "1. Checking hugo-site directory:"
ls -la hugo-site/

echo ""
echo "2. Checking hugo-site/public exists:"
ls -la hugo-site/public/ 2>&1 | head -15

echo ""
echo "3. Checking if index.html exists:"
if [ -f "hugo-site/public/index.html" ]; then
    echo "✓ index.html found"
    ls -lh hugo-site/public/index.html
    echo "First 10 lines:"
    head -10 hugo-site/public/index.html
else
    echo "✗ index.html NOT found!"
fi

echo ""
echo "4. Checking Docker containers:"
docker-compose ps

echo ""
echo "5. Checking Hugo image:"
docker inspect hugo --format='{{.Config.Image}}'

echo ""
echo "6. Checking Hugo container volume mounts:"
docker inspect hugo --format='{{range .Mounts}}{{.Source}} → {{.Destination}}{{println}}{{end}}'

echo ""
echo "7. Checking files inside Hugo container:"
echo "Trying /site/ (hugomods path):"
docker exec hugo ls -la /site/ 2>&1 | head -10

echo ""
echo "Trying /usr/share/nginx/html/ (nginx path):"
docker exec hugo ls -la /usr/share/nginx/html/ 2>&1 | head -10

echo ""
echo "8. Checking Hugo container logs:"
docker logs hugo --tail 20
