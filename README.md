# Paint Buddy

Menu-bar color history for macOS. Part of the *-buddy suite.

## Setup

```bash
ln -sfn ../../shared-buddy Vendor/shared-buddy
xcodegen generate
open PaintBuddy.xcodeproj
```

## Features

- Saves colors copied to the clipboard (hex, rgb, rgba, named, tuples)
- History + Favorites in the menu bar, main window, and dual always-on-top floating panels
- One-shot eyedropper (no Screen Recording); per-channel copy and color suggestions
- Configurable capture + preferred copy formats (including hex without #)

See [MANIFEST.md](MANIFEST.md) and [FEATURES.md](FEATURES.md).
