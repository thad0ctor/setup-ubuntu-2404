#!/bin/bash

FILE="$1"
EXT="${FILE##*.}"
SCRIPT_DIR="$(cd "$(dirname "$FILE")" && pwd)"
SCRIPT_NAME="$(basename "$FILE")"

echo "Called with: $FILE" >> /tmp/sudo-runner.log

if [[ "$EXT" == "sh" ]]; then
    CMD="cd \"$SCRIPT_DIR\" && echo \"Changed to: \$(pwd)\" && sudo bash \"$SCRIPT_NAME\""
elif [[ "$EXT" == "py" ]]; then
    CMD="cd \"$SCRIPT_DIR\" && echo \"Changed to: \$(pwd)\" && sudo /usr/bin/python3 \"$SCRIPT_NAME\""
else
    notify-send "Unsupported file type: $EXT"
    exit 1
fi

# Use full path for gnome-terminal and fallback to konsole
if command -v /usr/bin/gnome-terminal &>/dev/null; then
    /usr/bin/gnome-terminal -- bash -c "$CMD; echo ''; echo 'Script finished.'; read -p 'Press Enter to close...'"
elif command -v /usr/bin/konsole &>/dev/null; then
    /usr/bin/konsole --noclose -e bash -c "$CMD"
else
    notify-send "No terminal found"
    exit 1
fi