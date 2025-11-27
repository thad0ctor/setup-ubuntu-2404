#!/bin/bash
#
# Collect Scripts Helper
# This script collects Nemo and Nautilus scripts from your existing Ubuntu installation
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo ""
print_status "Nemo and Nautilus Script Collection Tool"
echo ""

# Default source location
DEFAULT_SOURCE="/mnt/samba/Ubuntu-Root"

read -p "Enter the path to your existing Ubuntu installation (default: $DEFAULT_SOURCE): " SOURCE_PATH
SOURCE_PATH=${SOURCE_PATH:-$DEFAULT_SOURCE}

if [ ! -d "$SOURCE_PATH" ]; then
    print_error "Source path does not exist: $SOURCE_PATH"
    print_error "Make sure your Samba share is mounted or provide the correct path"
    exit 1
fi

print_success "Found source directory: $SOURCE_PATH"
echo ""

#######################################
# Collect Nemo Scripts
#######################################

print_status "Searching for Nemo scripts..."

NEMO_SCRIPTS_FOUND=0

# Try multiple possible locations
NEMO_LOCATIONS=(
    "$SOURCE_PATH/.local/share/nemo/scripts"
    "$SOURCE_PATH/home/*/.local/share/nemo/scripts"
    "$SOURCE_PATH/.config/nemo/scripts"
)

for location in "${NEMO_LOCATIONS[@]}"; do
    # Use find to handle wildcards
    while IFS= read -r -d '' nemo_dir; do
        if [ -d "$nemo_dir" ] && [ "$(ls -A "$nemo_dir" 2>/dev/null)" ]; then
            print_status "Found Nemo scripts in: $nemo_dir"

            # Create destination directory
            mkdir -p "$SCRIPT_DIR/nemo-scripts"

            # Copy scripts
            cp -rv "$nemo_dir/"* "$SCRIPT_DIR/nemo-scripts/" 2>/dev/null || true

            NEMO_SCRIPTS_FOUND=1
            print_success "Nemo scripts copied!"
        fi
    done < <(find $(dirname "$location") -maxdepth 3 -type d -path "$location" -print0 2>/dev/null)
done

if [ $NEMO_SCRIPTS_FOUND -eq 0 ]; then
    print_warning "No Nemo scripts found in $SOURCE_PATH"
    print_warning "You may need to manually copy them later"
fi

echo ""

#######################################
# Collect Nautilus Scripts
#######################################

print_status "Searching for Nautilus scripts..."

NAUTILUS_SCRIPTS_FOUND=0

NAUTILUS_LOCATIONS=(
    "$SOURCE_PATH/.local/share/nautilus/scripts"
    "$SOURCE_PATH/home/*/.local/share/nautilus/scripts"
    "$SOURCE_PATH/.gnome2/nautilus-scripts"
)

for location in "${NAUTILUS_LOCATIONS[@]}"; do
    while IFS= read -r -d '' nautilus_dir; do
        if [ -d "$nautilus_dir" ] && [ "$(ls -A "$nautilus_dir" 2>/dev/null)" ]; then
            print_status "Found Nautilus scripts in: $nautilus_dir"

            mkdir -p "$SCRIPT_DIR/nautilus-scripts"

            cp -rv "$nautilus_dir/"* "$SCRIPT_DIR/nautilus-scripts/" 2>/dev/null || true

            NAUTILUS_SCRIPTS_FOUND=1
            print_success "Nautilus scripts copied!"
        fi
    done < <(find $(dirname "$location") -maxdepth 3 -type d -path "$location" -print0 2>/dev/null)
done

if [ $NAUTILUS_SCRIPTS_FOUND -eq 0 ]; then
    print_warning "No Nautilus scripts found in $SOURCE_PATH"
fi

echo ""

#######################################
# Analyze Script Dependencies
#######################################

print_status "Analyzing script dependencies..."

ALL_SCRIPTS=$(find "$SCRIPT_DIR/nemo-scripts" "$SCRIPT_DIR/nautilus-scripts" -type f 2>/dev/null)

if [ ! -z "$ALL_SCRIPTS" ]; then
    print_status "Checking for required programs in scripts..."

    # Create a dependencies file
    DEPS_FILE="$SCRIPT_DIR/SCRIPT_DEPENDENCIES.txt"
    echo "# Script Dependencies" > "$DEPS_FILE"
    echo "# Programs that may be required by the collected scripts" >> "$DEPS_FILE"
    echo "" >> "$DEPS_FILE"

    # Common programs to check for
    COMMON_PROGRAMS=(
        "zenity" "yad" "notify-send" "xdg-open"
        "ffmpeg" "imagemagick" "convert" "identify"
        "python" "python3" "perl" "bash"
        "zip" "unzip" "tar" "gzip"
        "rsync" "rclone" "git"
    )

    for prog in "${COMMON_PROGRAMS[@]}"; do
        if echo "$ALL_SCRIPTS" | xargs grep -h "$prog" 2>/dev/null | grep -q "$prog"; then
            echo "$prog" >> "$DEPS_FILE"
        fi
    done

    print_success "Dependency analysis saved to: SCRIPT_DEPENDENCIES.txt"

    if [ -s "$DEPS_FILE" ]; then
        echo ""
        print_warning "Scripts may require the following programs:"
        tail -n +4 "$DEPS_FILE" | while read dep; do
            echo "  - $dep"
        done
        echo ""
        print_status "These dependencies are not installed automatically."
        print_status "Install them manually as needed: sudo apt install <package>"
    fi
fi

echo ""

#######################################
# Collect GNOME Extension Settings
#######################################

print_status "Looking for GNOME extension data..."

GNOME_EXT_DIR="$SOURCE_PATH/.local/share/gnome-shell/extensions"

if [ -d "$GNOME_EXT_DIR" ]; then
    print_status "Found GNOME extensions directory"

    mkdir -p "$SCRIPT_DIR/gnome-extensions"

    # Create a list of extensions
    ls -1 "$GNOME_EXT_DIR" > "$SCRIPT_DIR/gnome-extensions/extension-list.txt" 2>/dev/null || true

    print_success "Extension list saved to: gnome-extensions/extension-list.txt"

    print_warning "Note: GNOME extensions should be installed from Extension Manager"
    print_warning "or extensions.gnome.org, not copied directly"
else
    print_warning "No GNOME extensions directory found"
fi

echo ""

#######################################
# Summary
#######################################

print_success "Collection complete!"
echo ""
echo "Summary:"
[ $NEMO_SCRIPTS_FOUND -eq 1 ] && echo "  ✓ Nemo scripts collected" || echo "  ✗ No Nemo scripts found"
[ $NAUTILUS_SCRIPTS_FOUND -eq 1 ] && echo "  ✓ Nautilus scripts collected" || echo "  ✗ No Nautilus scripts found"
echo ""

if [ $NEMO_SCRIPTS_FOUND -eq 1 ] || [ $NAUTILUS_SCRIPTS_FOUND -eq 1 ]; then
    print_status "Scripts have been copied to:"
    echo "  - $SCRIPT_DIR/nemo-scripts/"
    echo "  - $SCRIPT_DIR/nautilus-scripts/"
    echo ""

    # Make all scripts executable
    print_status "Making scripts executable..."
    find "$SCRIPT_DIR/nemo-scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
    find "$SCRIPT_DIR/nautilus-scripts" -type f -exec chmod +x {} \; 2>/dev/null || true
    print_success "All scripts are now executable"
    echo ""
fi

print_status "You can now run ./install.sh to install everything on a new PC"
echo ""
