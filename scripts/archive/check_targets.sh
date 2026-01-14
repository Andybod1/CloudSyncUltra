#!/bin/bash
cd /Users/antti/Claude
echo "Checking for CloudSyncAppUITests target..."
xcodebuild -project CloudSyncApp.xcodeproj -list 2>&1 | grep -A 10 "Targets:"
