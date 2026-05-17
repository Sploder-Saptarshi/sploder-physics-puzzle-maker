# AGENTS.md

## Purpose
- This file guides coding agents working in this repository.
- Follow repository conventions and prefer minimal-risk, incremental changes.
- Treat this as a legacy Flash/AS3 codebase with partial Haxe sources.

## Rule Sources
- Cursor rules: none found (`.cursor/rules/` missing, `.cursorrules` missing).
- Copilot rules: none found (`.github/copilot-instructions.md` missing).
- If these files appear later, treat them as higher-priority guidance and update this file.

## Repository Layout
- `as3/`: legacy ActionScript 3 project files and source.
- `as3/src/`: primary AS3 codebase.
- `as3/src/com/sploder/asui/`: custom in-house UI framework (not Flex).
- `haxe/`: Haxe sources for Nape/CX and a legacy Haxe project file.
- `haxe/src/nape/` and `haxe/src/cx/`: reusable core libraries.

## Entrypoints and Build Targets
- Game target: `as3/Game.as3proj` compiles `as3/src/Preloader.as` -> `Main`.
- Creator target: `as3/Creator.as3proj` compiles `as3/src/CreatorMain.as`.
- Wrapper target: `as3/Wrapper.as3proj` compiles `as3/src/Wrapper.as`.
- Haxe sample target: `haxe/NapeTest.hxproj` compiles `haxe/src/Main.hx`.

## Build Commands (Current State)
- There is no modern build tool (no `package.json`, no CI workflow, no `Makefile`).
- No repository-provided lint or test runner exists today.

## Build Commands (Practical/Manual)
- Build Game SWF (Flex SDK `mxmlc`, example):
  - `mxmlc -source-path+=as3/src -library-path+=as3/lib/"nape10 0.942c.p3.swc" -file-specs as3/src/Preloader.as -output as3/bin/fullgame5_b26s.swf`
- Build Creator SWF (example):
  - `mxmlc -source-path+=as3/src -library-path+=as3/lib/"nape10 0.942c.p3.swc" -file-specs as3/src/CreatorMain.as -output as3/bin/creator5_b21.swf`
- Build Wrapper SWF (example):
  - `mxmlc -source-path+=as3/src -file-specs as3/src/Wrapper.as -output as3/bin/game5.swf`
- Build Haxe SWF from legacy source (example):
  - `haxe -cp haxe/src -main Main -swf haxe/bin/NapeTest.swf -swf-version 10`

## Quick Commands for Agents
- Show current branch state: `git status --short`.
- Inspect local changes: `git diff`.
- Build-check game target quickly:
  - `mxmlc -source-path+=as3/src -library-path+=as3/lib/"nape10 0.942c.p3.swc" -file-specs as3/src/Preloader.as -output /tmp/fullgame-check.swf`
- Build-check creator target quickly:
  - `mxmlc -source-path+=as3/src -library-path+=as3/lib/"nape10 0.942c.p3.swc" -file-specs as3/src/CreatorMain.as -output /tmp/creator-check.swf`
- Build-check wrapper target quickly:
  - `mxmlc -source-path+=as3/src -file-specs as3/src/Wrapper.as -output /tmp/wrapper-check.swf`
- Verify Haxe core compiles in isolation:
  - `haxe -cp haxe/src -main DummyNapeMain --no-output`
  - `haxe -cp haxe/src -main DummyCxMain --no-output`

## Lint/Test Commands (Current State)
- Lint: not configured.
- Unit tests: not configured.
- Integration tests: not configured.
- Single-test execution: not available because no test harness exists.

## Testing Guidance Until a Harness Exists
- Prefer targeted smoke tests after each change:
  - Game boot path (`Preloader` -> `Main` -> first level load).
  - Creator boot path (`CreatorPreloader` -> `CreatorMain` -> UI initialize).
  - Wrapper load path (`Wrapper` failover/loading behavior).
- For migration work, validate both desktop and browser/OpenFL behavior.

## Suggested Future Test Contract (When Added)
- Add a Haxe test runner and document:
  - `haxe test/test.hxml` for full suite.
  - `haxe test/test.hxml -D test=ClassName` for a single test class.
- Keep this section updated once real commands exist.

## General Coding Principles
- Preserve behavior over refactoring style in legacy paths.
- Prefer small, reviewable commits and isolate risk by subsystem.
- Avoid broad renames unless needed for compatibility or correctness.
- Keep platform adapters thin; do not over-engineer replacements.

## AS3 Code Style Conventions
- Indentation: tabs are common in this codebase; preserve existing style per file.
- Braces: opening brace typically on same line for class/function declarations.
- Whitespace: keep existing spacing patterns instead of reformatting entire files.
- Naming:
  - Classes/interfaces: `PascalCase`.
  - Methods/fields: `camelCase`.
  - Constants/events: `UPPER_SNAKE_CASE`.
  - Private/protected fields often prefixed with `_` (preserve this pattern).
- Event constants are string literals centralized in classes (preserve names/values).

## Haxe Code Style Conventions
- Keep package/module names consistent with existing `nape`/`cx` structure.
- Use explicit types on public APIs where practical.
- Prefer `inline` only for performance-critical tiny methods.
- Maintain deterministic math/physics behavior; avoid accidental Float/Int coercion changes.

## Imports and Dependencies
- Keep imports explicit and grouped; avoid wildcard imports in new code.
- Remove unused imports only in files you touch.
- Do not introduce heavy dependencies without clear migration benefit.
- Favor reuse of existing `haxe/src/nape` and `haxe/src/cx` over reimplementation.

## Error Handling Guidelines
- Legacy AS3 often tolerates soft failures; preserve user-visible behavior.
- For network/load code, keep existing event-driven error paths intact.
- Add guard clauses for null/stage/loader assumptions in migrated code.
- Log actionable context in development paths; avoid noisy logging in hot loops.

## Type and API Compatibility Guidance
- Preserve public signatures when translating AS3 -> Haxe (`as3hx` output pass).
- Introduce compatibility wrappers for Flash-only APIs:
  - `ExternalInterface` -> JS bridge.
  - `SharedObject` -> localStorage-backed adapter.
  - `Security`/`LoaderContext` -> safe no-op or target-specific bridge.
- Keep adapter behavior minimal and documented in `docs/compatibility-ledger.md`.

## UI and Rendering Guidance
- This project uses `com.sploder.asui` (custom UI), not Flex.
- Port/modify ASUI incrementally by dependency centrality:
  - Start with `Component`, `Container`, `Style`, `Position`, common controls.
- Preserve event semantics and layout metrics before visual polish.

## Asset and Embed Guidance
- Several classes embed SWFs (`[Embed(...swf...)]`); treat these as migration risks.
- Prefer replacing SWF embeds with explicit assets/atlases/font files.
- Document each replacement in migration docs and keep fallback behavior if possible.

## Performance and Safety
- Do not allocate in tight update loops unless necessary.
- Preserve timing/order in simulation and collision-related code.
- Avoid changing frame-step logic without parity testing.

## Agent Workflow Expectations
- Before edits: inspect relevant files and neighboring call sites.
- During edits: keep diffs focused; avoid repo-wide formatting changes.
- After edits: run available build/smoke checks and report exact commands run.
- If a command/tool is unavailable, state that clearly and provide manual verification steps.

## Documentation Requirements for Agents
- Update docs when behavior contracts change.
- For migration work, keep these files in sync:
  - `docs/haxe-openfl-migration-plan.md`
  - `docs/asui-port-matrix.md`
  - `docs/compatibility-ledger.md`
  - `docs/as3hx-batch-order.md`

## Known Constraints
- Legacy Flash-era networking and domain-security behavior may not map 1:1 to HTML5.
- There is no canonical automated test suite yet.
- Build commands in this file may require local SDK/tool installation.

## When Unsure
- Choose the least invasive change that preserves runtime behavior.
- Prefer adding a small adapter over rewriting a whole subsystem.
- Leave concise notes in docs for follow-up instead of speculative rewrites.
