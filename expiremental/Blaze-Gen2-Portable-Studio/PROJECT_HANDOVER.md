# Project handover — Blaze Gen2 Portable Studio

**Version:** 1.0.0 Experimental  
**Repo:** BlazingSystems/BlazingSystems-Experiments  
**Source:** expiremental/Blaze-Gen2-Portable-Studio/ (intentional spelling)  
**Status:** Source candidate prepared; workflow execution and compiled release NOT YET VERIFIED at time of this initial handover. Do not claim publication until independent checks pass.

## Completed in source
WPF native UI, application selection, registry discovery, static scan/PE import inventory, compatibility classification, copy-first package builder, reusable launcher, writable data modes, numeric version directory resolver, synthetic test fixtures, docs.

## Partial / excluded
Automatic profile application not implemented; only profile JSON editing/import/export. Registry/settings capture, DLL dynamic import discovery, shortcut scan, installed services, reversible junction compatibility, official updaters, automatic studio update, read-only share enforcement, process-tree lifetime, GUI automation and diskless hardware testing are not implemented/verified.

## Key sources
src/Studio/StudioWindow.cs; src/Analyzer/Analyzer.cs; src/PackageBuilder/PackageBuilder.cs; src/PortableLauncher/Program.cs; src/Shared/Models.cs; tests/Integration/Program.cs.

## CI
Workflow at actual repo root .github/workflows/blaze-gen2-v100-release.yml; Windows 2025; .NET 10 LTS; self-contained publish for both executables; console synthetic fixture; upload zip/checksum; guarded prerelease publishing if tests pass.

## Handover protocol
1. Read this file and inspect latest GitHub commit and source files.
2. Inspect Actions run and job logs before describing any build result.
3. Fix compilation/functional failures; keep failing tests intact; rerun through a new main-branch commit.
4. Verify actual release contains the required ZIP and SHA256SUMS.txt; inspect archive and PE signatures.
5. Update this handover after every substantial milestone, including commit SHA, Actions run ID, test outcome, defects, release asset names and observed status.
6. Do not touch unrelated projects/workflows. Never redistribute proprietary apps or games.


## QA milestone 1 — 2026-10-10 (Asia/Manila)
- Commit 6ed34a103789da50bcdfb758305c4391a1614303 created native source and workflow.
- GitHub Actions run 37995390932 (windows-2025) **FAILED in Studio compilation** due to missing System.IO import in StudioWindow.cs (File, Path, InvalidDataException unresolved).
- PortableLauncher self-contained compilation was successful within this run; standalone Studio, integration tests and release were not reached.
- Corrective commit under preparation: add System.IO, make shared analysis target Windows, verify copy digest from destination bytes; rerun required.
- No pre-release has been claimed.
