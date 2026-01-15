# ADR-001: Use rclone as Sync Backend

## Status

Accepted

## Context

CloudSync Ultra needs to support 40+ cloud storage providers with features like:
- Bidirectional sync
- Encryption
- Bandwidth throttling
- Resume support
- Parallel transfers

Building native integrations for each provider would require:
- Maintaining 40+ OAuth implementations
- Understanding each provider's API quirks
- Years of development time
- Ongoing maintenance burden

## Decision

Use rclone as the sync backend engine. CloudSync Ultra provides a native macOS UI that orchestrates rclone commands.

## Consequences

### Positive

- Instant support for 40+ providers (rclone's existing work)
- Battle-tested sync algorithms
- Active open-source community
- Built-in encryption (crypt remote)
- Bandwidth throttling support
- Resume and checksum verification
- Regular updates and bug fixes from rclone team

### Negative

- Dependency on external binary
- Need to bundle rclone with app
- Limited control over sync internals
- Must parse rclone output for progress
- Version compatibility concerns

### Neutral

- Users familiar with rclone may recognize the backend
- Configuration stored in rclone format

## Alternatives Considered

1. **Native Swift implementations per provider**
   - Rejected: Too much development time, maintenance burden

2. **Cloud sync SDK (e.g., Dropbox SDK)**
   - Rejected: Only covers single provider, not multi-cloud

3. **restic or other backup tools**
   - Rejected: Focused on backup, not bidirectional sync

## References

- https://rclone.org/
- https://rclone.org/overview/
- rclone MIT License compatibility verified
