# as3hx Batch Order and Workflow

## Why Batch Translation
- `as3hx` is effective for mechanical conversion but noisy on large one-shot runs.
- Batch order reduces compile-error churn and isolates regressions.
- This repository has interdependent AS3 + custom UI + Flash APIs, so ordering matters.

## Batch Strategy
- Keep translated output under `haxe-app/src/legacy`.
- Do not hand-edit generated files unless absolutely required.
- Put manual fixes in adapters or patch files that can be replayed.
- Re-run generation for each batch and reconcile only that batch's delta.

## Recommended Batch Order

### Batch 0: Utilities and low-risk shared code
- `as3/src/com/sploder/util/*` (excluding Flash-interop-heavy files first pass).
- `as3/src/com/sploder/data/*` core data parsing/loading structures.
- Goal: establish baseline translated helpers.

### Batch 1: Boot and entry path
- `as3/src/Preloader.as`
- `as3/src/Main.as`
- `as3/src/CreatorPreloader.as`
- `as3/src/CreatorMain.as`
- `as3/src/Wrapper.as`
- Goal: HTML5 startup flow compiles with stubs/adapters.

### Batch 2: ASUI core
- `as3/src/com/sploder/asui/Component.as`
- `as3/src/com/sploder/asui/Container.as`
- `as3/src/com/sploder/asui/Style.as`
- `as3/src/com/sploder/asui/Position.as`
- `as3/src/com/sploder/asui/Cell.as`
- Goal: foundational UI runtime available.

### Batch 3: ASUI controls (high usage)
- `BButton`, `HTMLField`, `CheckBox`, `FormField`, `ComboBox`, `DialogueBox`, `Library`.
- Goal: creator/game common panels can mount.

### Batch 4: Game domain modules
- `as3/src/com/sploder/game/*` in dependency order:
  - model/state helpers,
  - simulation and level loading,
  - widgets/UI glue.
- Goal: first playable level in HTML5.

### Batch 5: Creator domain modules
- `as3/src/com/sploder/builder/*` and `as3/src/com/sploder/builder/ui/*`.
- Goal: editor boot + place/edit/save flows.

### Batch 6: Third-party and edge packages
- `org/bytearray/gif/*`, `neoart/*`, and remaining utility namespaces.
- Goal: complete long-tail feature support.

## Per-Batch Command Template
- Run `as3hx` for selected package/file set.
- Compile Haxe target immediately after generation.
- Record errors and classify into:
  - syntax/translation issues,
  - missing API adapters,
  - behavior/parity concerns.

## Error Triage Rules
- Fix compile blockers in this order:
  1. Type/signature mismatches.
  2. Missing imports/module paths.
  3. Flash runtime API gaps.
  4. Behavior parity regressions.
- Avoid broad cleanup while batch is unstable.

## Adapter Injection Rules
- If multiple files fail for the same Flash API, create one adapter and patch callers.
- Keep adapter names explicit (`ExternalBridge`, `SharedObjectAdapter`, etc.).
- Add each adapter and affected files to `docs/compatibility-ledger.md`.

## 1:1 UI Parity Rules During as3hx Passes
- Do not alter layout constants to "make it look better."
- Preserve rounding behavior (`floor`/`ceil`) from original code.
- Preserve event dispatch ordering and default values.
- Treat visual differences as bugs, not acceptable drift.

## Exit Criteria Per Batch
- Target compiles for current batch scope.
- Smoke flow for that scope runs without fatal runtime errors.
- New adapters documented in ledger.
- No unrelated generated-file churn committed.

## Suggested Tracking Format
- Keep a running migration log table with columns:
  - batch id,
  - modules translated,
  - compile status,
  - blockers,
  - adapters added,
  - parity status.
