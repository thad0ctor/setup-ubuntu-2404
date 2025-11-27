#!/bin/bash
# Wrapper to open Cursor with a target directory
APPIMAGE="$HOME/Applications/cursor.AppImage"
TARGET="${1:-$HOME}"

"$APPIMAGE" --no-sandbox "$TARGET"
