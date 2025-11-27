#!/bin/bash
# create-symlink-here.sh - Step 2: Create symlink in current directory

TEMP_FILE="/tmp/nemo_symlink_source"

# Check if we have a saved source
if [ ! -f "$TEMP_FILE" ]; then
    zenity --error --title="No Source File" --text="No file selected for symlinking.\n\nFirst right-click on a file and select 'Save for Symlink'"
    exit 1
fi

# Read the source path
SOURCE_PATH=$(cat "$TEMP_FILE")

# Check if source still exists
if [ ! -e "$SOURCE_PATH" ]; then
    zenity --error --title="Source Not Found" --text="The saved file no longer exists:\n$SOURCE_PATH"
    rm "$TEMP_FILE"
    exit 1
fi

# Get current directory (where user right-clicked)
DEST_DIR="$1"
if [ -f "$1" ]; then
    DEST_DIR=$(dirname "$1")
fi

# Create the symlink
SOURCE_NAME=$(basename "$SOURCE_PATH")
DEST_PATH="$DEST_DIR/$SOURCE_NAME"

# Handle name conflicts
COUNTER=1
ORIGINAL_DEST_PATH="$DEST_PATH"
while [ -e "$DEST_PATH" ]; do
    DEST_PATH="${ORIGINAL_DEST_PATH}_$COUNTER"
    COUNTER=$((COUNTER + 1))
done

# Create the symlink
if ln -s "$SOURCE_PATH" "$DEST_PATH"; then
    zenity --info --title="Symlink Created" --text="Symlink created successfully:\n$(basename "$DEST_PATH") → $(basename "$SOURCE_PATH")"
    # Clean up temp file
    rm "$TEMP_FILE"
else
    zenity --error --title="Failed" --text="Failed to create symlink"
fi
