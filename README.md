<img src="icon.png" width="200" alt="App icon" align="left"/>

<div>
<h3>ScrollZoom</h3>
<p>Use <b>Control + Scroll</b> to zoom in and out on macOS, similar to the default Windows behavior.</p>
<p>Created by <b>Rudckshim</b>.</p>
<a href="https://github.com/rudckshim/ScrollZoom/releases">
  <img src="macos_badge_noborder.png" width="175" alt="Download for macOS"/>
</a>
</div>

<br/><br/>

<div align="center">

<img src="https://img.shields.io/github/downloads/rudckshim/ScrollZoom/total.svg?style=flat" alt="downloads"/>

<img src="https://img.shields.io/github/release-pre/rudckshim/ScrollZoom.svg?style=flat" alt="latest version"/>

<img src="https://img.shields.io/github/license/rudckshim/ScrollZoom.svg?style=flat" alt="license"/>

<img src="https://img.shields.io/badge/platform-macOS-blue.svg?style=flat" alt="platform"/>

</div>

<hr>

## Download

Go to [Releases](https://github.com/rudckshim/ScrollZoom/releases) and download the latest `ScrollZoom.zip`.

## Features

- Windows-style `Control + Scroll` zooming on macOS
- Lightweight native Swift menu bar app
- Start at Login support
- No Dock icon
- Accessibility-aware event handling
- Works across most macOS applications

## How to install and use the app

1. [Download the app](https://github.com/rudckshim/ScrollZoom/releases)
2. Unzip `ScrollZoom.zip`
3. Move `ScrollZoom.app` to your Applications folder
4. Open `ScrollZoom.app`
5. Allow Accessibility and Input Monitoring permissions when prompted
6. Hold `Control` and scroll up or down to zoom

## Required permissions

ScrollZoom requires:

- Accessibility
- Input Monitoring

You can manage them under:

`System Settings` → `Privacy & Security`

## Build

```sh
swiftc scrollzoom.swift \
-framework Cocoa \
-framework ApplicationServices \
-framework ServiceManagement \
-o ScrollZoom
```

## License

MIT License