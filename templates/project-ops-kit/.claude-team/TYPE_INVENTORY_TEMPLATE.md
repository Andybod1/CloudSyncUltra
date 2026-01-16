# Project Type Inventory

> **Reference for Workers** - These types exist and can be used.
> Run `./scripts/generate-type-inventory.sh` to refresh this list.

---

## Quick Lookup

Before using a type, verify it exists:
```bash
grep -r "struct TypeName" ProjectName/
grep -r "class ClassName" ProjectName/
```

---

## Models (ProjectName/Models/)

```swift
# Run generate-type-inventory.sh to populate
```

## ViewModels (ProjectName/ViewModels/)

```swift
# Run generate-type-inventory.sh to populate
```

## Managers

```swift
# Run generate-type-inventory.sh to populate
```

## Main Views

```swift
# Run generate-type-inventory.sh to populate
```

## Common Types (use these, not custom)

```swift
# Add project-specific common types here
```

---

## Types That Require Coordination

These types exist but modifying them affects multiple workers:

| Type | Owner | Notes |
|------|-------|-------|
| (Add shared types here) | | |

---

*Generated: YYYY-MM-DD*
*Run ./scripts/generate-type-inventory.sh to refresh*
