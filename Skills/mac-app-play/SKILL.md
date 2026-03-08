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

```bash
scripts/mac_app_play permission check --all
scripts/mac_app_play permission request --accessibility
scripts/mac_app_play permission request --screen-recording
```

- **Accessibility**: required for mouse, keyboard, focus, and ax commands.
- **Screen Recording**: required for screenshot command.

## Coordinates and resolution

All coordinates use **screen points** — logical coordinates with origin at the **top-left of the primary display**. On Retina displays, 1 point = 2 pixels.

| Context | Coordinate space |
|---|---|
| **mouse** commands | Screen points |
| **ax** positions | Screen points |
| **screenshot** (default 1x) | Image pixels = screen points (full screen/display capture) |
| **screenshot** (`--high-resolution`) | Image pixels = screen points × scale factor |
| **screenshot** (`--app` / `--window-id`) | Window-local: (0,0) is the window's top-left corner |

**Converting window screenshot coordinates to screen points**: When capturing a window, the command prints the window's screen position (e.g., `at (100,200 800x600)`). Add the window origin to image coordinates to get screen points for mouse commands: screen_x = window_x + image_x, screen_y = window_y + image_y.

Use `display-info` to check the scale factor when working with `--high-resolution`.

## Commands

### screenshot — Capture screen or window to PNG

```bash
scripts/mac_app_play screenshot --output /tmp/screen.png
scripts/mac_app_play screenshot --app Safari --output /tmp/safari.png
scripts/mac_app_play screenshot --window-id 1234 --output /tmp/win.png
scripts/mac_app_play screenshot --display 1 --output /tmp/display.png
scripts/mac_app_play screenshot --high-resolution --output /tmp/retina.png
```

| Option | Description |
|---|---|
| `--app <name>` | Capture first window of app (case-insensitive partial match) |
| `--window-id <id>` | Capture specific window by CGWindowID |
| `--display <id>` | Capture specific display |
| `--output <path>` | Output PNG path (default: `screenshot.png`) |
| `--high-resolution` | Capture at Retina pixel resolution. Default is 1x point resolution |

With `--app` or `--window-id`, the image contains **only the window** (not the full screen). Without these options, the full screen or display is captured.

### display-info — Show display size and scale factor

```bash
scripts/mac_app_play display-info
# Display 1: 1440x900 points, scale factor 2x (2880x1800 pixels)
```

### mouse — Control mouse cursor

Coordinates are **screen points**.

```bash
scripts/mac_app_play mouse move --x 500 --y 300
scripts/mac_app_play mouse move --x 500 --y 300 --duration 200
scripts/mac_app_play mouse click --x 500 --y 300
scripts/mac_app_play mouse click --x 500 --y 300 --button right
scripts/mac_app_play mouse click --x 500 --y 300 --double
scripts/mac_app_play mouse drag --from-x 100 --from-y 100 --to-x 400 --to-y 400
scripts/mac_app_play mouse drag --from-x 100 --from-y 100 --to-x 400 --to-y 400 --duration 500
```

| Subcommand | Required | Optional |
|---|---|---|
| `move` | `--x`, `--y` | `--duration <ms>` |
| `click` | `--x`, `--y` | `--button left\|right`, `--double` |
| `drag` | `--from-x`, `--from-y`, `--to-x`, `--to-y` | `--button left\|right`, `--duration <ms>` |

### key — Simulate keyboard input

```bash
scripts/mac_app_play key press a
scripts/mac_app_play key press return
scripts/mac_app_play key press a --modifiers command
scripts/mac_app_play key press c --modifiers command,shift
scripts/mac_app_play key down shift
scripts/mac_app_play key up shift
scripts/mac_app_play key type "Hello, world!"
scripts/mac_app_play key type "slow" --delay 100
```

| Subcommand | Arguments | Optional |
|---|---|---|
| `press` | `<key>` | `--modifiers shift,command,option,control` |
| `down` | `<key>` | `--modifiers ...` |
| `up` | `<key>` | `--modifiers ...` |
| `type` | `<string>` | `--delay <ms>` between keystrokes |

`key type` uses unicode input (works with any character). Use `key press` with `--modifiers` for keyboard shortcuts. See [references/KEYS.md](references/KEYS.md) for key names.

### focus — Switch application focus and raise windows

```bash
scripts/mac_app_play focus app --app Safari
scripts/mac_app_play focus list --app Safari
scripts/mac_app_play focus window --app Safari
scripts/mac_app_play focus window --app Safari --index 1
```

| Subcommand | Required | Optional |
|---|---|---|
| `app` | `--app <name>` | |
| `list` | `--app <name>` | |
| `window` | `--app <name>` | `--index <n>` (default 0) |

`focus app` activates the app. `focus list` shows windows with titles, positions, and indices. `focus window` raises a specific window by index.

### ax — Inspect and interact with accessibility elements

Positions reported by ax commands are **screen points**.

```bash
scripts/mac_app_play ax list --app Safari
scripts/mac_app_play ax tree --app Safari --depth 3
scripts/mac_app_play ax children --app Safari --path 0,0,1
scripts/mac_app_play ax find --app Safari --label "Close"
scripts/mac_app_play ax attrs --app Safari --path 0,0,1
scripts/mac_app_play ax actions --app Safari --path 0,0,1
scripts/mac_app_play ax press --app Safari --path 0,0,1
scripts/mac_app_play ax press --app Safari --path 0,0,1 --action AXShowMenu
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

**Path**: `--path` takes comma-separated child indices. `0` = first window, `0,2` = first window's third child.

**Output**: `[index] AXRole "label" (x,y widthxheight)`. `ax find` includes full path: `[0,2,1] AXButton "Close" (10,10 20x20)`.

## Workflow

**Prefer ax commands over mouse/keyboard** — they don't depend on element visibility or window position. Fall back to screenshot + mouse/keyboard only when AX cannot accomplish the task.

### Primary: AX-based interaction

1. `permission check --all` — request if denied.
2. `focus app --app <name>` — bring app to foreground.
3. `ax tree --app <name> --depth 3` or `ax find --app <name> --label "Submit"` — discover elements.
4. `ax press --app <name> --path <path>` or `ax set-value` — interact.
5. Verify with `ax attrs` or `screenshot`.

### Fallback: Screenshot + mouse/keyboard

1. `screenshot --app <name> --output /tmp/screen.png` — see current state.
2. Read screenshot, identify coordinates. For window captures, add window origin offset to get screen points.
3. `mouse click --x <x> --y <y>`, `key type "text"`, `key press return` — interact.
4. `screenshot` again to verify.

## Notes

- `--app` matching is case-insensitive and partial: `--app safari` matches "Safari".
- If `ax list` returns no elements, the app may not expose AX data — fall back to screenshot + mouse/keyboard.
