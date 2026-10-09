# Compatibility and limitations

The static assessment has five classification values. **FullyPortableCandidate** means only that current static heuristics found no blocking evidence; it is NOT a guarantee. **PartiallyPortable** signals limited evidence. **RequiresExternalDependencies** signals unresolved PE imports or runtime support. **HighRiskManualConfiguration** flags suspicious driver/anti-cheat indicators and blocks the automated GUI builder. **Unsupported** is reserved for explicit unsupported conditions and can be extended with profiles.

## In scope (experimental)
Files copied from one selected application subtree; directly imported DLL names where PE import directory is parseable; opt-in environment variables; relative launch paths; per-user writable data paths; version-directory selection by parseable numeric version folders and presence of executable.

## Out of scope
Services, driver installation, DRM, anti-cheat, machine-bound licenses, hardcoded paths, UWP/MSIX, dynamic runtime dependency discovery, capture/restore of registry changes, AppData Known Folder interception, real filesystem overlay, shared-configuration conflict locks, automatic app-specific update integration, symbolic-link redirection, injection, and executable patching.

Apps using registry, fixed paths, GPU middleware, redistributables, installers or activation may not work.

## Diskless modes

| Mode | Application path | Writable app data | Survives reboot? |
|---|---|---|---|
| PerClientWritable | Package can live on shared read-only drive | Client's LOCALAPPDATA | Only if client's local storage is persistent |
| FullyLocal | Package on local writable storage | Package/Data | Only if package storage persists |
| TemporarySession | Package can be shared | Unique system temporary directory | No; best-effort deletion when target exits |

A server share cannot guarantee read-only enforcement; configure file/share permissions externally. Child processes may outlive the tracked main process. There is no global session exclusion lock in 1.0.0. Changing APPDATA or LOCALAPPDATA is an optional per-child environment operation and does not intercept Known Folder APIs.

Roblox is a **future testing target only**, not an officially supported profile or a proven portable game.

