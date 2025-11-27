#!/bin/bash
#
# Create Portable Archive
# Packages this setup into a tarball for easy transfer
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_NAME="linux-setup-package"
OUTPUT_DIR="$HOME/Desktop"

echo "Creating portable archive..."

cd "$( dirname "$SCRIPT_DIR" )"

# Create tarball
tar --exclude="*.tar.gz" \
    --exclude=".git" \
    --exclude="node_modules" \
    -czf "$OUTPUT_DIR/${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME/"

if [ $? -eq 0 ]; then
    echo "✓ Archive created successfully!"
    echo ""
    echo "Location: $OUTPUT_DIR/${PACKAGE_NAME}.tar.gz"
    echo "Size: $(du -h "$OUTPUT_DIR/${PACKAGE_NAME}.tar.gz" | cut -f1)"
    echo ""
    echo "To use on a new PC:"
    echo "  1. Copy the .tar.gz file to the new PC"
    echo "  2. Extract: tar -xzf ${PACKAGE_NAME}.tar.gz"
    echo "  3. Run: cd ${PACKAGE_NAME} && ./install.sh"
else
    echo "✗ Failed to create archive"
    exit 1
fi
