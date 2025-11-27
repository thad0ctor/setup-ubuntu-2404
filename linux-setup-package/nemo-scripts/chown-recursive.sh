#!/bin/bash

# Nemo action script to recursively change ownership to current user
# Usage: chown-recursive.sh <directory_path>

TARGET_DIR="$1"
CURRENT_USER=$(whoami)

if [ -z "$TARGET_DIR" ]; then
    zenity --error --text="No directory specified"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    zenity --error --text="'$TARGET_DIR' is not a directory"
    exit 1
fi

# Confirm action with user
if zenity --question --text="Change ownership of '$TARGET_DIR' and all its contents to user '$CURRENT_USER'?"; then
    # Use sudo to run chown (passwordless via sudoers rule)
    sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$TARGET_DIR"
    
    if [ $? -eq 0 ]; then
        zenity --info --text="Successfully changed ownership of '$TARGET_DIR' to $CURRENT_USER"
    else
        zenity --error --text="Failed to change ownership. Operation cancelled or insufficient privileges."
    fi
else
    zenity --info --text="Operation cancelled"
fi