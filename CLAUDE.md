# VideoMode - Claude Code Instructions

## Project Overview
macOS menu bar app for consistent browser window sizing during screen recordings.

## Tech Stack
- Swift / SwiftUI
- AppleScript for browser window control
- Carbon framework for global hotkeys

## Build & Run
```bash
# Build debug
xcodebuild -scheme VideoMode -configuration Debug build

# Build release
xcodebuild -scheme VideoMode -configuration Release build

# Run from DerivedData
open ~/Library/Developer/Xcode/DerivedData/VideoMode-*/Build/Products/Debug/VideoMode.app
```

## Key Files
- `VideoModeApp.swift` - Main app entry, menu bar UI
- `Models/WindowPreset.swift` - WindowPlacement enum and preset data model
- `Services/WindowController.swift` - AppleScript browser control
- `Storage/PresetStore.swift` - UserDefaults persistence
- `Views/PresetManagerView.swift` - Preset management UI

## Coordinate System
AppleScript uses Y=0 at top of screen (increasing downward). The `calculatePosition` function in `WindowPreset.swift` handles placement calculations accounting for menu bar height.

## Supported Browsers
Safari, Chrome, Brave - defined in `Browser` enum in `WindowController.swift`
