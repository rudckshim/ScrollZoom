# ScrollZoom

Use `Control + Scroll` to zoom in and out on macOS, similar to the default Windows behavior.

ScrollZoom is a lightweight native macOS menu bar utility that converts:

- `Control + Scroll Up` → `⌘ +`
- `Control + Scroll Down` → `⌘ -`

This enables smooth zooming in browsers, editors, terminals, and many other apps using familiar Windows-style controls.

---

## Features

- Windows-style `Ctrl + Scroll` zooming on macOS
- Lightweight native Swift app
- Menu bar integration
- Start at Login support
- No Dock icon
- Accessibility-aware event handling
- Works across most macOS applications

---

## Installation

Download the latest release from the Releases page.

### First Launch

macOS may block the app initially.

If needed:

1. Right click `ScrollZoom.app`
2. Click **Open**

or run:

```bash
xattr -dr com.apple.quarantine /Applications/ScrollZoom.app
