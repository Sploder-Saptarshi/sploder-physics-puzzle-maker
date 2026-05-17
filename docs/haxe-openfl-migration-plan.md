# Haxe + OpenFL Migration Plan

## Goals
- Port the AS3 game and creator to Haxe targeting HTML5 with OpenFL.
- Preserve gameplay and editor behavior with strict visual parity.
- Use `as3hx` for fast first-pass translation, then harden with targeted adapters.
- Avoid framework rewrites (no Flex port); use minimal compatibility layers.

## Non-Negotiable Parity Requirement
- Flash and HTML5 output must be indistinguishable in layout, timing, animation, and interaction.
- No intentional UI redesign, spacing changes, color tweaks, typography substitutions, or motion changes.
- If OpenFL defaults differ from Flash behavior, implement compatibility code until parity is restored.
- Treat parity failures as defects, not enhancements.

## Current State Snapshot
- AS3 source: `as3/src` (legacy Flash runtime assumptions).
- Custom UI: `as3/src/com/sploder/asui` (48 classes).
- Existing Haxe core: `haxe/src/nape` and `haxe/src/cx`.
- Entrypoints:
  - Game: `as3/src/Preloader.as` -> `Main.as`
  - Creator: `as3/src/CreatorMain.as` (+ `CreatorPreloader.as`)
  - Wrapper: `as3/src/Wrapper.as`
- No automated lint/test harness yet.

## Migration Principles
- Preserve runtime behavior; avoid broad refactors.
- Preserve exact UI metrics and interaction sequencing.
- Translate in vertical slices (bootable states) rather than file-type batches only.
- Prefer adapters over rewrites for Flash-only APIs.
- Keep generated `as3hx` output separate from hand-maintained compatibility code.
- Establish compile and smoke-check gates for every phase.

## Target Architecture
- `haxe-app/src/app/` for new app entrypoints and orchestration.
- `haxe-app/src/legacy/` for `as3hx` translated code.
- `haxe-app/src/compat/` for Flash/OpenFL bridge adapters.
- `haxe-app/src/asui/` for ported ASUI runtime.
- `haxe-app/assets/` for extracted SWF replacements (images, fonts, atlases).

## Phased Plan

### Phase 0 - Baseline and Tooling
- Install and validate Haxe + OpenFL toolchain.
- Add a minimal OpenFL HTML5 project that boots to a blank stage.
- Document local commands for game/creator/wrapper targets.
- Deliverable: reproducible empty HTML5 build.

### Phase 1 - as3hx Translation Pipeline
- Translate AS3 in controlled batches into `haxe-app/src/legacy`.
- Keep translation scripts repeatable and idempotent.
- Record translation warnings and unsupported constructs.
- Deliverable: translated code tree with a tracked compile error backlog.

### Phase 2 - Boot Path Port (No Full Features Yet)
- Port preloaders and root startup chain.
- Replace Flash security/domain calls with no-op adapters where safe.
- Stub legacy SWF loading paths to avoid hard crashes.
- Deliverable: HTML5 app boots and reaches main shell.

### Phase 3 - Reuse Existing Haxe Core
- Route physics/core dependencies to `haxe/src/nape` and `haxe/src/cx`.
- Avoid dual-maintaining generated and native implementations.
- Validate deterministic behavior with sample levels.
- Deliverable: game simulation pipeline compiles and steps in browser.

### Phase 4 - ASUI Core Port
- Port highest-centrality ASUI classes first:
  - `Component`, `Container`, `Style`, `Position`, `Cell`, `BButton`, `HTMLField`.
- Keep event names/semantics compatible with current callers.
- Deliverable: creator/game UI panels render with pixel-level parity.

### Phase 5 - Platform Compatibility Layer
- Implement adapters for:
  - `ExternalInterface` -> JS bridge.
  - `SharedObject` -> localStorage.
  - `navigateToURL("javascript:...")` -> explicit JS calls.
  - `LoaderContext`/`Security*` -> target-safe wrappers.
- Deliverable: no critical Flash-runtime-only API blockers.

### Phase 6 - Asset and Embed Replacement
- Replace `[Embed(...swf...)]` dependencies with explicit assets.
- Convert or re-author font/library symbols used by game and creator.
- Deliverable: runtime no longer depends on embedded SWF symbols.

### Phase 7 - Feature Parity Pass
- Migrate creator dialogs/tools and game widgets by user flow.
- Verify save/load/publish and gameplay result submission paths.
- Deliverable: parity candidate build with documented known gaps.

### Phase 8 - Stabilization and Performance
- Fix layout/metrics edge cases and browser-specific input quirks.
- Optimize hot paths after parity is stable.
- Add smoke checks and early test harness scaffolding.
- Deliverable: production-ready HTML5 branch candidate.

## Parity Validation Contract
- Snapshot baseline Flash renders for representative screens/states.
- Capture HTML5 renders under equivalent inputs and viewport sizes.
- Enforce numeric tolerances:
  - Layout positions/sizes: exact integer match where possible.
  - Text metrics: line breaks and clipping must match; no overflow drift.
  - Animation timing: frame progression and duration must match perceptually and numerically.
  - Input behavior: hover/focus/drag/click semantics must match event order.
- Block merges when parity checks fail on critical screens.

## Smoke Test Checklist (Per PR)
- Game boot path reaches first playable level.
- Creator boot path reaches main editor canvas.
- Wrapper fallback/load flow does not error.
- Keyboard, mouse, and focus interactions behave correctly.
- One save/load cycle succeeds in creator workflow.
- Core editor/game screens pass side-by-side parity review.

## Risks and Mitigations
- SWF embeds and symbol linkage risk parity regressions.
  - Mitigation: replacement ledger + staged fallback behavior.
- Text rendering/layout drift may alter editor UI metrics.
  - Mitigation: lock baseline screenshots and compare key dialogs.
- Flash domain/security semantics do not map 1:1.
  - Mitigation: centralize in adapters, avoid scattered hacks.
- as3hx output may include non-idiomatic Haxe.
  - Mitigation: keep generated code isolated, patch at boundaries.

## Suggested Milestones
- M1: HTML5 shell booting with preloaders.
- M2: game simulation stepping with reused Haxe core.
- M3: ASUI core controls functional.
- M4: creator core workflows (edit + save).
- M5: full feature parity candidate.

## Deliverables to Keep Updated
- `docs/asui-port-matrix.md`
- `docs/compatibility-ledger.md`
- `docs/as3hx-batch-order.md`
- `AGENTS.md`
