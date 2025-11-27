#!/bin/bash
# save-for-symlink.sh - Step 1: Save the selected file/folder path

# Create temp file to store the path
TEMP_FILE="/tmp/nemo_symlink_source"
echo "$1" > "$TEMP_FILE"

# Show confirmation
zenity --info --title="Symlink Source Saved" --text="File saved for symlinking:\n$(basename "$1")\n\nNow right-click in the destination folder and select 'Create Symlink Here'"
