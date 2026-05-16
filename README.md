<img src="icon.png" width="180" alt="ScrollZoom app icon" align="left"/>

<div>
<h3>ScrollZoom</h3>
<p>Use <b>Control + Scroll</b> to zoom in and out on macOS, similar to the default Windows behavior.</p>
<p>Created by <b>Rudckshim</b>.</p>
<a href="https://github.com/rudckshim/ScrollZoom/releases">
  <img src="https://img.shields.io/badge/Download%20app%20for-macOS-black?style=for-the-badge&logo=apple&logoColor=white" alt="Download for macOS"/>
</a>
</div>

<br/><br/><br/>

<div align="center">

<a href="https://github.com/rudckshim/ScrollZoom/releases">
  <img src="https://img.shields.io/github/downloads/rudckshim/ScrollZoom/total.svg?style=flat&label=downloads" alt="downloads"/>
</a>

<a href="https://github.com/rudckshim/ScrollZoom/releases">
  <img src="https://img.shields.io/github/v/release/rudckshim/ScrollZoom?style=flat&label=release" alt="release"/>
</a>

<a href="https://github.com/rudckshim/ScrollZoom/blob/main/LICENSE">
  <img src="https://img.shields.io/github/license/rudckshim/ScrollZoom.svg?style=flat" alt="license"/>
</a>

<a href="https://github.com/rudckshim/ScrollZoom">
  <img src="https://img.shields.io/badge/platform-macOS-blue.svg?style=flat" alt="platform"/>
</a>

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

## How to use

1. Download `ScrollZoom.zip` from [Releases](https://github.com/rudckshim/ScrollZoom/releases)
2. Unzip the file
3. Move `ScrollZoom.app` to your Applications folder
4. Open `ScrollZoom.app`
5. Allow the required permissions when prompted

Required permissions:

- Accessibility
- Input Monitoring

You can manage them in:

`System Settings → Privacy & Security`

## Usage

Hold `Control` and scroll up or down to zoom in and out.

ScrollZoom converts:

- `Control + Scroll Up` → `⌘ +`
- `Control + Scroll Down` → `⌘ -`

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