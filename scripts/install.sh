#!/bin/bash

echo "Installing cfetch..."

# Make executable
chmod +x cfetch

# Check if /usr/local/bin exists
if [ -d "/usr/local/bin" ]; then
    # Create symlink
    sudo ln -sf "$(pwd)/cfetch" /usr/local/bin/cfetch
    echo "✓ cfetch installed to /usr/local/bin/cfetch"
else
    echo "✗ /usr/local/bin does not exist"
    echo "Please add cfetch to your PATH manually"
fi

echo "Installation complete!"