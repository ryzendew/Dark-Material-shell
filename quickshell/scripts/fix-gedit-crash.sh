#!/bin/bash
# Fix for gedit causing quickshell crashes when saving files
# This script configures gedit to not create backup files and temp files
# that could trigger quickshell's file watcher and cause crashes

echo "Configuring gedit to prevent quickshell crashes..."

# Disable backup file creation (prevents files like filename~ from being created)
gsettings set org.gnome.gedit.preferences.editor create-backup-copy false

# Disable auto-save to prevent frequent file writes
gsettings set org.gnome.gedit.preferences.editor auto-save false

# Set encoding to UTF-8 to avoid encoding issues
gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['UTF-8', 'CURRENT', 'ISO-8859-15', 'UTF-16']"

echo "Gedit configuration updated!"
echo ""
echo "Changes made:"
echo "  - Backup files disabled (no more filename~ files)"
echo "  - Auto-save disabled (prevents frequent writes)"
echo "  - UTF-8 encoding set as default"
echo ""
echo "Note: You may need to restart gedit for changes to take effect."
echo "If you still experience crashes, try using a different editor like vim, nano, or VS Code."









