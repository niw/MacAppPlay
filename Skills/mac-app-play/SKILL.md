---
name: mac-app-play
description: >
  Control macOS GUI applications via screen capture, mouse/keyboard automation, and
  accessibility element inspection. Use when you need to interact with macOS app UIs,
  take screenshots, click buttons, type text, or inspect accessibility trees.
---

# mac-app-play

The `scripts/mac_app_play` CLI provides mouse control, keyboard input, screenshot capture, and accessibility tree inspection for macOS applications.

## Prerequisites

Before using any command, ensure permissions are granted:

```bash
scripts/mac_app_play permission check --all
scripts/mac_app_play permission request --accessibility
scripts/mac_app_play permission request --screen-recording
```

- **Accessibility**: required for mouse, keyboard, and ax commands.
- **Screen Recording**: required for screenshot command.

## Commands

### permission — Manage macOS permissions

```bash
# Check
scripts/mac_app_play permission check --all
scripts/mac_app_play permission check --accessibility
scripts/mac_app_play permission check --screen-recording

# Request (opens system prompt)
scripts/mac_app_play permission request --accessibility
scripts/mac_app_play permission request --screen-recording
```

### screenshot — Capture screen to PNG

By default, screenshots are captured at **point resolution (1x)** — pixel coordinates in the image match screen points used by mouse commands and AX positions directly. Use `--high-resolution` for full Retina pixel resolution.

```bash
scripts/mac_app_play screenshot --output /tmp/screen.png
scripts/mac_app_play screenshot --app Safari --output /tmp/safari.png
scripts/mac_app_play screenshot --window-id 1234 --output /tmp/win.png
scripts/mac_app_play screenshot --display 1 --output /tmp/display.png
scripts/mac_app_play screenshot --high-resolution --output /tmp/retina.png
```

| Option | Description |
|---|---|
| `--app <name>` | App name (case-insensitive partial match), captures first window |
| `--window-id <id>` | Capture specific window by CGWindowID |
| `--display <id>` | Capture specific display |
| `--output <path>` | Output PNG path (default: `screenshot.png`) |
| `--high-resolution` | Capture at full pixel resolution (Retina/2x). Default is 1x point resolution |

### display-info — Show display size and scale factor

```bash
scripts/mac_app_play display-info
```

Prints each display's point size, scale factor, and pixel size. Example output:

```
Display 1: 1440x900 points, scale factor 2x (2880x1800 pixels)
```

### mouse — Control mouse cursor

```bash
# Move
scripts/mac_app_play mouse move --x 500 --y 300
scripts/mac_app_play mouse move --x 500 --y 300 --duration 200

# Click
scripts/mac_app_play mouse click --x 500 --y 300
scripts/mac_app_play mouse click --x 500 --y 300 --button right
scripts/mac_app_play mouse click --x 500 --y 300 --double

# Drag
scripts/mac_app_play mouse drag --from-x 100 --from-y 100 --to-x 400 --to-y 400
scripts/mac_app_play mouse drag --from-x 100 --from-y 100 --to-x 400 --to-y 400 --duration 500
```

| Subcommand | Required options | Optional |
|---|---|---|
| `move` | `--x`, `--y` | `--duration <ms>` (animated move) |
| `click` | `--x`, `--y` | `--button left\|right`, `--double` |
| `drag` | `--from-x`, `--from-y`, `--to-x`, `--to-y` | `--button left\|right`, `--duration <ms>` |

### key — Simulate keyboard input

```bash
# Press key (down + up)
scripts/mac_app_play key press a
scripts/mac_app_play key press return
scripts/mac_app_play key press a --modifiers command
scripts/mac_app_play key press c --modifiers command,shift

# Hold/release separately
scripts/mac_app_play key down shift
scripts/mac_app_play key up shift

# Type a string (unicode, works with any character)
scripts/mac_app_play key type "Hello, world!"
scripts/mac_app_play key type "slow" --delay 100
```

| Subcommand | Arguments | Optional |
|---|---|---|
| `press` | `<key>` | `--modifiers shift,command,option,control` |
| `down` | `<key>` | `--modifiers ...` |
| `up` | `<key>` | `--modifiers ...` |
| `type` | `<string>` | `--delay <ms>` between keystrokes |

See [references/KEYS.md](references/KEYS.md) for the full list of key names and modifier names.

### focus — Switch application focus and raise windows

```bash
# Activate an application (bring to foreground)
scripts/mac_app_play focus app --app Safari

# List windows with titles and indices
scripts/mac_app_play focus list --app Safari

# Raise a specific window by index
scripts/mac_app_play focus window --app Safari
scripts/mac_app_play focus window --app Safari --index 1
```

| Subcommand | Required | Optional |
|---|---|---|
| `app` | `--app <name>` | |
| `list` | `--app <name>` | |
| `window` | `--app <name>` | `--index <n>` (default 0) |

`focus app` activates the application, bringing it to the foreground. `focus list` shows all windows with their titles, positions, and indices for use with `focus window`. `focus window` raises a specific window (filtered to AXWindow elements) and also activates the app.

### ax — Inspect and interact with accessibility elements

Use this to discover UI elements, find buttons/fields by label, read element attributes, and interact with elements directly.

```bash
# List top-level elements (windows + direct children)
scripts/mac_app_play ax list --app Safari

# Print full AX tree
scripts/mac_app_play ax tree --app Safari --depth 3

# Get children at a tree path
scripts/mac_app_play ax children --app Safari --path 0,0,1

# Search by label (recursive, matches title/description/identifier)
scripts/mac_app_play ax find --app Safari --label "Close"

# Show all attributes of element at path
scripts/mac_app_play ax attrs --app Safari --path 0,0,1

# List available actions for an element
scripts/mac_app_play ax actions --app Safari --path 0,0,1

# Press a button or perform an action on an element
scripts/mac_app_play ax press --app Safari --path 0,0,1
scripts/mac_app_play ax press --app Safari --path 0,0,1 --action AXShowMenu

# Set value of a text field
scripts/mac_app_play ax set-value --app Safari --path 0,0,3 --value "hello"
```

| Subcommand | Required | Optional |
|---|---|---|
| `list` | `--app <name>` | |
| `tree` | `--app <name>` | `--depth <n>` (default 10) |
| `children` | `--app <name>`, `--path <indices>` | |
| `find` | `--app <name>`, `--label <text>` | |
| `attrs` | `--app <name>`, `--path <indices>` | |
| `actions` | `--app <name>`, `--path <indices>` | |
| `press` | `--app <name>`, `--path <indices>` | `--action <name>` (default AXPress) |
| `set-value` | `--app <name>`, `--path <indices>`, `--value <text>` | |

**Path navigation**: `--path` takes comma-separated indices. `0` = first window, `0,2` = first window's third child, `0,2,0` = that child's first child.

**Output format**:

```
[index] AXRole "label" (x,y widthxheight)
```

`ax find` includes the full path: `[0,2,1] AXButton "Close" (10,10 20x20)`

`ax attrs` lists all attributes:

```
AXRole: "AXButton"
AXTitle: "Close"
AXPosition: (10, 10)
AXSize: 20x20
```

## Workflow

**Always prefer accessibility (AX) commands over mouse/keyboard.** AX interactions are more reliable — they don't depend on element visibility, screen position, or window overlap. Fall back to screenshot + mouse/keyboard only when AX cannot accomplish the task (e.g., the app doesn't expose AX elements, or you need pixel-level interaction like drawing).

### Primary: AX-based interaction

1. **Check permissions**: `scripts/mac_app_play permission check --all` — request if denied.
2. **Focus app**: `focus app --app <name>` to bring the target application to the foreground.
3. **Discover UI**: `ax list --app <name>` for overview, `ax tree --app <name> --depth 3` for structure.
4. **Find target**: `ax find --app <name> --label "Submit"` to locate an element, note its path.
5. **Check actions**: `ax actions --app <name> --path <path>` to see what the element supports.
6. **Interact via AX**: `ax press --app <name> --path <path>` to click buttons, `ax set-value --app <name> --path <path> --value "text"` to fill text fields.
7. **Verify**: `ax attrs --app <name> --path <path>` to check the element state after interaction, or use `screenshot` if visual confirmation is needed.

### Fallback: Screen capture + mouse/keyboard

Use this approach when AX interaction is not possible:

1. **Capture screen**: `screenshot --app <name> --output /tmp/screen.png` to see the current state.
2. **Identify coordinates**: Read the screenshot to find the target element's position.
3. **Interact**: `mouse click --x <x> --y <y>` to click, `key type "text"` to enter text, `key press return` to confirm.
4. **Verify**: `screenshot --app <name> --output /tmp/result.png` to confirm the result.

## Coordinate system

All coordinates (mouse, AX positions, default screenshots) use **screen points** — logical coordinates with origin at the top-left of the primary display. On Retina displays, 1 point = 2 pixels.

- **Default screenshots** are captured at 1x (point resolution), so pixel coordinates in the image correspond directly to screen points — use them as-is with mouse commands.
- **High-resolution screenshots** (`--high-resolution`) are captured at full Retina resolution. Divide pixel coordinates by the scale factor (use `display-info` to check) to get screen points for mouse commands.
- **AX positions** are in screen points and can be used directly with mouse commands.

## Edge cases

- If `ax list` returns no elements, the app may not expose AX data or accessibility permission is missing. Fall back to screenshot + mouse/keyboard.
- `--app` matching is case-insensitive and partial: `--app safari` matches "Safari".
- `key type` uses unicode input and works for any character including non-ASCII. Use `key press` with `--modifiers` for keyboard shortcuts.
