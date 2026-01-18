#!/bin/bash

echo "Building cfetch..."

VERSION=$(cat VERSION)
echo "Version: $VERSION"

# Create dist directory
mkdir -p dist

# Package files
tar -czf "dist/cfetch-${VERSION}.tar.gz" \
    cfetch \
    src/ \
    config/ \
    LICENSE \
    README.md \
    VERSION

echo "✓ Built dist/cfetch-${VERSION}.tar.gz"
echo "Build complete!"