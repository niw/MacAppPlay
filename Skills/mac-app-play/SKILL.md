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

```bash
scripts/mac_app_play screenshot --output /tmp/screen.png
scripts/mac_app_play screenshot --app Safari --output /tmp/safari.png
scripts/mac_app_play screenshot --window-id 1234 --output /tmp/win.png
scripts/mac_app_play screenshot --display 1 --output /tmp/display.png
```

| Option | Description |
|---|---|
| `--app <name>` | App name (case-insensitive partial match), captures first window |
| `--window-id <id>` | Capture specific window by CGWindowID |
| `--display <id>` | Capture specific display |
| `--output <path>` | Output PNG path (default: `screenshot.png`) |

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

### ax — Inspect accessibility elements

Use this to discover UI elements, find buttons/fields by label, and read element attributes.

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
```

| Subcommand | Required | Optional |
|---|---|---|
| `list` | `--app <name>` | |
| `tree` | `--app <name>` | `--depth <n>` (default 10) |
| `children` | `--app <name>`, `--path <indices>` | |
| `find` | `--app <name>`, `--label <text>` | |
| `attrs` | `--app <name>`, `--path <indices>` | |

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

1. **Check permissions**: `scripts/mac_app_play permission check --all` — request if denied.
2. **Discover UI**: `ax list --app <name>` for overview, `ax tree --app <name> --depth 3` for structure.
3. **Find target**: `ax find --app <name> --label "Submit"` to locate an element, note its position.
4. **Interact**: `mouse click --x <x> --y <y>` to click, `key type "text"` to enter text, `key press return` to confirm.
5. **Verify**: `screenshot --app <name> --output /tmp/result.png` to confirm the result.

## Edge cases

- If `ax list` returns no elements, the app may not expose AX data or accessibility permission is missing.
- `--app` matching is case-insensitive and partial: `--app safari` matches "Safari".
- Mouse coordinates are in screen space (origin top-left of primary display).
- `key type` uses unicode input and works for any character including non-ASCII. Use `key press` with `--modifiers` for keyboard shortcuts.
