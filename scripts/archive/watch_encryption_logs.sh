#!/bin/bash

# CloudSync Ultra - E2EE Debug Log Viewer
# This script shows real-time logs from the encryption setup process

echo "=========================================="
echo "CloudSync Ultra - E2EE Debug Log Viewer"
echo "=========================================="
echo ""
echo "Watching for encryption-related logs..."
echo "Press Ctrl+C to stop"
echo ""
echo "Now go to CloudSync Ultra > Settings > Security"
echo "and try to enable encryption."
echo ""
echo "=========================================="
echo ""

# Watch Console logs for CloudSyncApp with encryption-related messages
log stream --predicate 'processImagePath CONTAINS "CloudSyncApp"' --style compact | grep --line-buffered -E "\[EncryptionSettings\]|\[RcloneManager\]|setupEncryption|configureEncryption|obscurePassword"
