#!/bin/bash
#
# Generate Type Inventory
# Creates a reference of all existing types for worker briefings
#
# Usage: ./scripts/generate-type-inventory.sh
#

set -e
cd ~/Claude

OUTPUT=".claude-team/TYPE_INVENTORY.md"

echo "Generating type inventory..."

cat > "$OUTPUT" << 'HEADER'
# CloudSync Ultra - Type Inventory

> **Reference for Workers** - These types exist and can be used.
> Run `./scripts/generate-type-inventory.sh` to refresh this list.

---

## Quick Lookup

Before using a type, verify it exists:
```bash
grep -r "struct TypeName" CloudSyncApp/
grep -r "class ClassName" CloudSyncApp/
```

---

HEADER

echo "## Models (CloudSyncApp/Models/)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo '```swift' >> "$OUTPUT"
grep -rh "^struct\|^class\|^enum\|^protocol" CloudSyncApp/Models/ 2>/dev/null | grep -v "//" | sort -u >> "$OUTPUT"
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "## ViewModels (CloudSyncApp/ViewModels/)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo '```swift' >> "$OUTPUT"
grep -rh "^class\|^struct" CloudSyncApp/ViewModels/ 2>/dev/null | grep -v "//" | sort -u >> "$OUTPUT"
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "## Managers" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo '```swift' >> "$OUTPUT"
grep -rh "^class\|^struct\|^actor" CloudSyncApp/*Manager.swift CloudSyncApp/Managers/*.swift 2>/dev/null | grep -v "//" | sort -u >> "$OUTPUT"
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "## Main Views" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo '```swift' >> "$OUTPUT"
grep -rh "^struct.*View:" CloudSyncApp/Views/*.swift CloudSyncApp/*.swift 2>/dev/null | grep -v "//" | sort -u | head -40 >> "$OUTPUT"
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "## SwiftUI Colors (use these, not custom)" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo '```swift' >> "$OUTPUT"
cat >> "$OUTPUT" << 'COLORS'
Color.accentColor    // System blue (primary)
Color.green          // Success
Color.orange         // Warning
Color.red            // Error/destructive
Color.gray           // Secondary text
Color.primary        // Primary text (adapts to dark mode)
Color.secondary      // Secondary text (adapts to dark mode)
COLORS
echo '```' >> "$OUTPUT"
echo "" >> "$OUTPUT"

cat >> "$OUTPUT" << 'FOOTER'
---

## Types That Require Coordination

These types exist but modifying them affects multiple workers:

| Type | Owner | Notes |
|------|-------|-------|
| `CloudRemote` | Shared | Core model, coordinate changes |
| `SyncTask` | Shared | Used by multiple views |
| `RcloneManager` | Dev-2 | Engine layer |
| `SyncManager` | Dev-3 | Service layer |

---

*Generated: TIMESTAMP*
FOOTER

# Add timestamp
sed -i '' "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M')/" "$OUTPUT"

echo "✅ Type inventory written to $OUTPUT"
echo ""
echo "Types found:"
grep -c "^struct\|^class\|^enum" "$OUTPUT" || echo "  (count unavailable)"
