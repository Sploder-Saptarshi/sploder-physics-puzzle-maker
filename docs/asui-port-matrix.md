# ASUI Port Matrix

## Objective
- Track class-by-class porting of `as3/src/com/sploder/asui` to Haxe/OpenFL.
- Prioritize by dependency centrality and strict 1:1 UI parity impact.

## Status Key
- `P0`: required for first creator/game UI boot.
- `P1`: required for core editing/gameplay workflows.
- `P2`: required for advanced workflows.
- `P3`: can defer until parity hardening.

## Core Matrix
| Class | Priority | Why it matters | Notes |
|---|---:|---|---|
| `Component` | P0 | Base event + positioning behavior | Must preserve event constants and dispatch order |
| `Container` | P0 | Common wrapping and display composition | Preserve clip attach/remove semantics |
| `Style` | P0 | Shared visual contract | No default style drift allowed |
| `Position` | P0 | Alignment and layout math | Match rounding behavior exactly |
| `Cell` | P0 | Parent-child layout hub | Validate nested layout parity |
| `BButton` | P0 | Most common command control | Press/release/selected visuals must match |
| `HTMLField` | P0 | Core text/link rendering | Ensure line-break and hit-area parity |
| `CheckBox` | P1 | Common toggle UI | Keep checked state and icon metrics |
| `FormField` | P1 | Input-heavy dialogs | Keyboard focus behavior must match |
| `ComboBox` | P1 | Selection and menu flows | Dropdown positioning parity required |
| `DialogueBox` | P1 | Modal shell used widely | Overlay + z-order behavior parity |
| `Clip` | P1 | Asset clip binding | Maintain loader and symbol behavior |
| `Library` | P1 | Symbol/asset access central point | Critical for embed replacement path |
| `ObjectEvent` | P1 | Typed event payloads | Keep event names and payload shape |
| `ScrollBar` | P1 | Scrolling interaction | Delta behavior and drag speed parity |
| `Slider` | P1 | Numeric input controls | Pointer mapping and snapping parity |
| `RadioButton` | P1 | Exclusive choice groups | Group membership logic must match |
| `Prompt` | P1 | Tooltips/prompt interactions | Timing and placement parity |
| `Tagtip` | P1 | Hover hints | Respect debounce/repeat behavior |
| `ProgressBar` | P2 | Loading/progress display | Visual parity during preload flows |
| `Collection` | P2 | Data-driven UI list container | Selection index semantics |
| `CollectionItem` | P2 | Cell-level list items | Focus/selection visual states |
| `DataGrid` | P2 | Tabular editor views | Column sizing and clipping parity |
| `MenuGroup` | P2 | Grouped menu interactions | Navigation behavior consistency |
| `TabGroup` | P2 | Tab state management | Active/inactive transitions parity |
| `ToggleButton` | P2 | Toggle-capable button states | Ensure toggled label/icon parity |
| `Divider` | P2 | Section layout utility | Pixel alignment with existing panels |
| `HRule` | P2 | Horizontal separators | Style and alpha parity |
| `ColorPicker` | P2 | Color authoring tool | Cursor and preview behavior |
| `ColorSpectrum` | P2 | Color picker internals | Gradient + sampling parity |
| `ColorChip` | P2 | Color display unit | Border/alpha behavior |
| `ColorClipChooser` | P2 | Color + clip hybrid selection | Keep selection events unchanged |
| `ClipChooser` | P2 | Asset chooser widget | Grid and hover behavior parity |
| `ClipButton` | P2 | Clip-oriented control | Selection and icon states |
| `Create` | P2 | Core drawing helper factory | Major source of visual parity risk |
| `DrawingMethods` | P2 | Primitive rendering utilities | Corner radius and gradient parity |
| `Tween` | P2 | Animation easing primitive | Timing curve parity critical |
| `TweenManager` | P2 | Global animation updates | Frame-step parity critical |
| `LibraryObject` | P2 | Library entry abstraction | Keep metadata and retrieval behavior |
| `ASUIObject` | P2 | Shared object base contract | Property/event semantics |
| `IComponent` | P2 | Interface contract | Keep method signatures stable |
| `Key` | P2 | Keyboard helper utility | Keycode mapping consistency |
| `ColorTools` | P3 | Color utilities | Verify tint math and rounding |
| `StringUtils` | P3 | String helpers | Mostly low-risk utility |
| `Template` | P3 | Template helper | Port when referenced by migrated flows |
| `VisualGrid` | P3 | Debug/visual aid | Defer unless required by flow |
| `ASUIEvent` | P3 | Event wrapper | Keep constants if used externally |
| `ASUIML` | P3 | Markup utility/parser | Defer unless loading UI declaratively |

## Implementation Sequence
1. P0 complete before creator/game UI bootstrap claim.
2. P1 complete before save/publish and common dialog flows.
3. P2 complete before parity candidate milestone.
4. P3 complete during hardening unless dependencies pull them forward.

## 1:1 Parity Rules for ASUI Port
- Preserve constructor signatures and default argument behavior.
- Preserve event string constants and dispatch order.
- Preserve position rounding behavior (`Math.floor`/`Math.ceil` usage).
- Preserve style defaults and alpha/color calculations.
- Preserve text baseline, clipping, and button hit areas.

## Validation Checklist per Class
- Visual snapshot comparison against Flash baseline.
- Mouse/keyboard event sequence comparison.
- Layout coordinates and dimensions checked at multiple resolutions.
- Regression check in one game flow and one creator flow.
