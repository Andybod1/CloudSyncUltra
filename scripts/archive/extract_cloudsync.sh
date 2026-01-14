#!/bin/bash

# CloudSync Project Installer
# Extracts the complete project to your Mac

echo "📦 CloudSync Project Extractor"
echo "=============================="
echo ""

# Create the project directory
DEST_DIR="$HOME/CloudSyncApp"

if [ -d "$DEST_DIR" ]; then
    echo "⚠️  Directory $DEST_DIR already exists!"
    read -p "Delete and recreate? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$DEST_DIR"
    else
        echo "Aborted."
        exit 1
    fi
fi

echo "📁 Creating directory: $DEST_DIR"
mkdir -p "$DEST_DIR"

echo ""
echo "The CloudSync project files are in your Claude chat interface."
echo "Claude has created them and they are ready to download."
echo ""
echo "Next steps:"
echo "1. Claude will copy each file to: $HOME/CloudSyncApp/"
echo "2. Or you can find them in the files Claude shared above"
echo ""
echo "Would you like Claude to copy them now? (Reply in chat)"
