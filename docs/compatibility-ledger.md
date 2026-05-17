# Compatibility Ledger (Flash -> Haxe/OpenFL)

## Purpose
- Track Flash-era APIs and behaviors that need explicit compatibility treatment.
- Keep this ledger current as adapters are added or behavior is validated.

## Status Key
- `open`: not started.
- `in_progress`: adapter under implementation.
- `validated`: implemented and parity-checked.
- `waived`: intentionally unsupported with documented reason.

## Platform/API Compatibility Table
| Area | Flash API / Behavior | Example file(s) | Proposed adapter strategy | Status |
|---|---|---|---|---|
| JS bridge | `ExternalInterface` callbacks/calls | `as3/src/com/sploder/util/ScrollHelper.as` | `compat.external.ExternalBridge` wrapping `js.Browser` | open |
| Local storage | `SharedObject.getLocal`, `flush`, `clear` | `as3/src/com/sploder/util/Settings.as` | `compat.storage.SharedObjectAdapter` over localStorage | open |
| Domain policy | `Security.allowDomain`, `loadPolicyFile` | `as3/src/Preloader.as`, `as3/src/CreatorMain.as` | no-op shim + optional logging in debug builds | open |
| Loader context | `LoaderContext`, `ApplicationDomain`, `SecurityDomain` | `as3/src/Wrapper.as`, `as3/src/com/sploder/asui/Clip.as` | `compat.loader.LoaderContextAdapter` with target-safe defaults | open |
| URL JS calls | `navigateToURL("javascript:...")` | `as3/src/com/sploder/builder/CreatorUIController.as` | replace with typed JS interop functions | open |
| SWF embeds | `[Embed(...swf...)]` symbol loading | `as3/src/Preloader.as`, `as3/src/com/sploder/game/Game.as` | asset extraction + atlas/font replacement | open |
| Runtime SWF load | `Loader.loadBytes` + SWF symbol assumptions | `as3/src/com/sploder/builder/ui/DialogueTextureGen.as` | replace with native Haxe/OpenFL module | open |
| LocalConnection | process-style in-player comms | `as3/src/com/sploder/game/Game.as` | optional bus adapter or feature gate for web | open |
| Stage semantics | stage align/scale/quality defaults | `as3/src/Preloader.as`, `as3/src/com/sploder/game/Game.as` | normalize stage init in shared bootstrap | open |
| Text metrics | Flash TextField wrapping/clipping quirks | `as3/src/com/sploder/asui/HTMLField.as` | per-font metric calibration and test baselines | open |

## Asset Compatibility Ledger
| Asset usage | Source path | Replacement target | Status |
|---|---|---|---|
| Preloader symbol | `as3/lib/preloader.swf` via `Preloader.as` | extracted animation/atlas | open |
| Game UI library | `as3/lib/library.swf` via `Game.as` | atlas + symbol map in OpenFL | open |
| Creator UI library | `as3/lib/creator_library.swf` via `CreatorUI.as` | atlas + symbol map in OpenFL | open |
| Embedded font | `as3/lib/font_myriad.swf` via `CreatorUI.as` | web-safe equivalent or converted font | open |
| Texture generator SWF | `as3/lib/TextureGen.swf` via `DialogueTextureGen.as` | native texturegen port | open |

## Behavior Parity Ledger
| Behavior | Baseline source | HTML5 parity criteria | Status |
|---|---|---|---|
| Preloader progress display | `Preloader.as` | percent text + placement matches | open |
| Wrapper server failover | `Wrapper.as` | same retry/failover ordering and timing | open |
| Creator init gates | `CreatorMain.as` | allow/local checks and init sequencing match | open |
| Button interaction states | `asui/BButton.as`, `asui/Create.as` | hover/press/selected visuals identical | open |
| Dialog layout | `builder/ui/Dialogue*.as` + ASUI | no spacing/text clipping drift | open |

## Validation Procedure
- For each `open` row, add an implementation PR that includes:
  - adapter/module path,
  - files updated,
  - parity test evidence (screenshots/logs),
  - known caveats.
- Move status to `validated` only after side-by-side Flash vs HTML5 review.
- Do not mark `waived` without explicit stakeholder approval.

## Notes
- Keep adapter APIs narrow to avoid hidden behavior changes.
- Prefer centralized compatibility modules over scattered inline patches.
- Update this file whenever migration assumptions change.
