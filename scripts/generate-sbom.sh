#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CloudSync Ultra - SBOM Generator                                           ║
# ║  Generate Software Bill of Materials for releases                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Usage: ./scripts/generate-sbom.sh [output-dir]
#
# Generates:
# - sbom.json (CycloneDX format)
# - sbom.txt (human-readable)
# - dependencies.md (markdown summary)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

OUTPUT_DIR="${1:-$PROJECT_ROOT/build/sbom}"

cd "$PROJECT_ROOT"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║     SBOM Generator                                            ║${NC}"
echo -e "${BLUE}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get project info
VERSION=$(cat VERSION.txt 2>/dev/null | tr -d '[:space:]' || echo "unknown")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo -e "${BOLD}Generating SBOM for CloudSync Ultra v$VERSION...${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Generate CycloneDX JSON SBOM
# ─────────────────────────────────────────────────────────────────────────────
echo -e "[1/3] Generating CycloneDX JSON..."

cat > "$OUTPUT_DIR/sbom.json" << EOF
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:$(uuidgen | tr '[:upper:]' '[:lower:]')",
  "version": 1,
  "metadata": {
    "timestamp": "$BUILD_DATE",
    "tools": [
      {
        "vendor": "CloudSync Ultra",
        "name": "sbom-generator",
        "version": "1.0.0"
      }
    ],
    "component": {
      "type": "application",
      "name": "CloudSync Ultra",
      "version": "$VERSION",
      "description": "Cloud backup and sync application for macOS",
      "licenses": [
        {
          "license": {
            "id": "Proprietary"
          }
        }
      ],
      "purl": "pkg:swift/cloudsync-ultra@$VERSION"
    }
  },
  "components": [
    {
      "type": "application",
      "name": "rclone",
      "version": "$(rclone version 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown")",
      "description": "Command line program to sync files and directories",
      "licenses": [
        {
          "license": {
            "id": "MIT"
          }
        }
      ],
      "purl": "pkg:github/rclone/rclone",
      "externalReferences": [
        {
          "type": "website",
          "url": "https://rclone.org"
        },
        {
          "type": "vcs",
          "url": "https://github.com/rclone/rclone"
        }
      ]
    },
    {
      "type": "framework",
      "name": "SwiftUI",
      "version": "$(sw_vers -productVersion || echo "unknown")",
      "description": "Apple's declarative UI framework",
      "licenses": [
        {
          "license": {
            "id": "Apple-EULA"
          }
        }
      ]
    },
    {
      "type": "framework",
      "name": "StoreKit",
      "version": "$(sw_vers -productVersion || echo "unknown")",
      "description": "Apple's in-app purchase framework",
      "licenses": [
        {
          "license": {
            "id": "Apple-EULA"
          }
        }
      ]
    }
  ]
}
EOF

echo -e "  ${GREEN}✓${NC} $OUTPUT_DIR/sbom.json"

# ─────────────────────────────────────────────────────────────────────────────
# Generate human-readable SBOM
# ─────────────────────────────────────────────────────────────────────────────
echo -e "[2/3] Generating human-readable SBOM..."

cat > "$OUTPUT_DIR/sbom.txt" << EOF
================================================================================
CloudSync Ultra - Software Bill of Materials (SBOM)
================================================================================

Application: CloudSync Ultra
Version:     $VERSION
Build Date:  $BUILD_DATE
Commit:      $COMMIT

================================================================================
DEPENDENCIES
================================================================================

1. rclone
   Version:     $(rclone version 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown")
   License:     MIT
   Website:     https://rclone.org
   Source:      https://github.com/rclone/rclone
   Description: Command line program to sync files and directories to/from
                cloud storage providers.

2. SwiftUI (Apple Framework)
   Version:     macOS $(sw_vers -productVersion || echo "unknown")
   License:     Apple EULA
   Description: Apple's declarative UI framework for building user interfaces.

3. StoreKit (Apple Framework)
   Version:     macOS $(sw_vers -productVersion || echo "unknown")
   License:     Apple EULA
   Description: Apple's framework for in-app purchases and subscriptions.

4. CryptoKit (Apple Framework)
   Version:     macOS $(sw_vers -productVersion || echo "unknown")
   License:     Apple EULA
   Description: Apple's framework for cryptographic operations.

================================================================================
SWIFT PACKAGE DEPENDENCIES
================================================================================

EOF

# Add SPM dependencies if they exist
PACKAGE_RESOLVED="CloudSyncApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [[ -f "$PACKAGE_RESOLVED" ]]; then
    cat "$PACKAGE_RESOLVED" | jq -r '.pins[]? // .object.pins[]? | "- \(.identity // .package): \(.state.version // .state.revision // "unknown")"' 2>/dev/null >> "$OUTPUT_DIR/sbom.txt" || echo "No SPM dependencies found" >> "$OUTPUT_DIR/sbom.txt"
else
    echo "No Swift Package dependencies" >> "$OUTPUT_DIR/sbom.txt"
fi

cat >> "$OUTPUT_DIR/sbom.txt" << EOF

================================================================================
Generated by CloudSync Ultra SBOM Generator
EOF

echo -e "  ${GREEN}✓${NC} $OUTPUT_DIR/sbom.txt"

# ─────────────────────────────────────────────────────────────────────────────
# Generate Markdown summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "[3/3] Generating Markdown summary..."

cat > "$OUTPUT_DIR/dependencies.md" << EOF
# CloudSync Ultra Dependencies

**Version:** $VERSION
**Generated:** $BUILD_DATE

## Core Dependencies

| Component | Version | License | Description |
|-----------|---------|---------|-------------|
| rclone | $(rclone version 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown") | MIT | Cloud sync backend |
| SwiftUI | macOS $(sw_vers -productVersion || echo "unknown") | Apple EULA | UI Framework |
| StoreKit | macOS $(sw_vers -productVersion || echo "unknown") | Apple EULA | In-App Purchases |
| CryptoKit | macOS $(sw_vers -productVersion || echo "unknown") | Apple EULA | Cryptography |

## Swift Package Dependencies

EOF

if [[ -f "$PACKAGE_RESOLVED" ]]; then
    echo "| Package | Version |" >> "$OUTPUT_DIR/dependencies.md"
    echo "|---------|---------|" >> "$OUTPUT_DIR/dependencies.md"
    cat "$PACKAGE_RESOLVED" | jq -r '.pins[]? // .object.pins[]? | "| \(.identity // .package) | \(.state.version // .state.revision // "unknown") |"' 2>/dev/null >> "$OUTPUT_DIR/dependencies.md" || echo "None" >> "$OUTPUT_DIR/dependencies.md"
else
    echo "No Swift Package dependencies" >> "$OUTPUT_DIR/dependencies.md"
fi

cat >> "$OUTPUT_DIR/dependencies.md" << EOF

## License Summary

- **MIT**: rclone
- **Apple EULA**: SwiftUI, StoreKit, CryptoKit, Foundation
- **Proprietary**: CloudSync Ultra application code

---
*Generated by CloudSync Ultra SBOM Generator*
EOF

echo -e "  ${GREEN}✓${NC} $OUTPUT_DIR/dependencies.md"

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}─────────────────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}✓ SBOM generated successfully${NC}"
echo ""
echo -e "Output files:"
echo -e "  $OUTPUT_DIR/sbom.json      (CycloneDX format)"
echo -e "  $OUTPUT_DIR/sbom.txt       (Human readable)"
echo -e "  $OUTPUT_DIR/dependencies.md (Markdown summary)"
