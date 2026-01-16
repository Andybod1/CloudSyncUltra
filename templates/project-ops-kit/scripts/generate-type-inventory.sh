#!/bin/bash
#
# Generate Type Inventory
# Creates a reference of all types in the project for workers
#
# Usage: ./scripts/generate-type-inventory.sh [source-dir]
#

SOURCE_DIR="${1:-src}"  # Default to src/, adjust for your project
OUTPUT_FILE=".claude-team/TYPE_INVENTORY.md"

echo "Generating type inventory..."

cat > "$OUTPUT_FILE" << HEADER
# Project Type Inventory

> **Reference for Workers** - These types exist and can be used.
> Run \`./scripts/generate-type-inventory.sh\` to refresh this list.

---

## Quick Lookup

Before using a type, verify it exists:
\`\`\`bash
grep -r "struct TypeName" $SOURCE_DIR/
grep -r "class ClassName" $SOURCE_DIR/
\`\`\`

---

## Types Found

\`\`\`
HEADER

# Find all type definitions
grep -rh "^struct\|^class\|^enum\|^protocol\|^interface\|^type " "$SOURCE_DIR" 2>/dev/null | \
    grep -v "^//" | \
    sort -u >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << FOOTER
\`\`\`

---

*Generated: $(date +%Y-%m-%d)*
FOOTER

TYPE_COUNT=$(grep -c "^struct\|^class\|^enum\|^protocol" "$OUTPUT_FILE" 2>/dev/null || echo "0")
echo "✅ Type inventory written to $OUTPUT_FILE"
echo ""
echo "Types found:"
echo "$TYPE_COUNT"
