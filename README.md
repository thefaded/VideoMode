# VideoMode

A macOS menu bar app for consistent browser window sizing during screen recordings.

## Problem

When creating tutorial videos, you often need to record multiple segments. If window sizes vary between recordings, merging them in video editing becomes difficult.

## Solution

VideoMode lets you save window size + position presets and apply them instantly to Safari, Chrome, or Brave with a single click or keyboard shortcut.

## Features

- **Menu bar app** - Always accessible, no dock icon
- **Browser support** - Safari, Chrome, and Brave
- **Custom presets** - Save any size with named presets
- **Quick Place** - Raycast-style instant positioning:
  - Center
  - Left/Right/Top/Bottom Half
  - Corners (Top Left, Top Right, Bottom Left, Bottom Right)
  - Almost Maximize
- **Global hotkeys** - Cmd+Shift+1 through 9 for quick preset application
- **Window activation** - Browser comes to front after applying preset

## Installation

1. Open `VideoMode.xcodeproj` in Xcode
2. Build and run (Cmd+R)
3. Grant Automation permission when prompted (to control browser windows)

Or use the pre-built app:
```bash
open VideoMode.app
```

## Usage

### Apply a Preset
1. Click the VideoMode icon in menu bar
2. Select browser (Safari/Chrome/Brave)
3. Click a preset

### Quick Place (keeps current size)
1. Have a browser window open
2. Click VideoMode → Quick Place → Center (or other position)
3. Window moves to that position

### Create a Preset
1. Click VideoMode → Manage Presets
2. Click + to add new preset
3. Set name, size, and placement
4. Click "Apply to Safari/Chrome/Brave" to test

### Capture Current Window
1. Resize your browser window manually to desired size
2. Click VideoMode → Save Current Window → From Safari/Chrome/Brave
3. Edit the captured preset name in Manage Presets

### Keyboard Shortcuts
- **Cmd+Shift+1** - Apply first preset to frontmost browser
- **Cmd+Shift+2** - Apply second preset
- ... up to Cmd+Shift+9

## Default Presets

- **Full HD** - 1920x1080, centered
- **HD 720p** - 1280x720, centered

## Requirements

- macOS 13.0 or later
- Xcode 15+ (for building)

## Tech Stack

- Swift / SwiftUI
- AppleScript (for window control)
- Carbon (for global hotkeys)

## License

MIT
