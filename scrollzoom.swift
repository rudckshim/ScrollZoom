//
//  scrollzoom.swift
//  scrollzoom
//

import Cocoa
import ApplicationServices
import ServiceManagement

let options = [
    kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
] as CFDictionary

AXIsProcessTrustedWithOptions(options)

enum Key: CGKeyCode {
    case minus = 27
    case plus = 24

    func press(_ down: Bool, _ command: Bool) {
        if let source = CGEventSource(stateID: .privateState),
           let event = CGEvent(keyboardEventSource: source, virtualKey: rawValue, keyDown: down) {

            if command {
                event.flags = CGEventFlags.maskCommand
            }

            event.type = down ? .keyDown : .keyUp
            event.post(tap: .cghidEventTap)
        }
    }
}

class EventTap {

    static var rloop_source: CFRunLoopSource! = nil
    static var controlDown = false

    // Trackpad sensitivity control
    static var trackpadAccumulator: Int64 = 0
    static let trackpadThreshold: Int64 = 18

    class func create() {
        if rloop_source != nil {
            EventTap.remove()
        }

        let tap = CGEventTap.create(callback: tap_callback)!

        rloop_source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, CFIndex(0))
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rloop_source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    class func remove() {
        if rloop_source != nil {
            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                rloop_source,
                .commonModes
            )
            rloop_source = nil
        }
    }

    @objc class func handle_event(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event immutable_event: CGEvent!,
        refcon: UnsafeMutableRawPointer?
    ) -> CGEvent? {

        guard let event = immutable_event else { return nil }

        switch type {

        case .flagsChanged:
            EventTap.controlDown = event.flags.contains(.maskControl)

            if !EventTap.controlDown {
                EventTap.trackpadAccumulator = 0
            }

            return event

        case .scrollWheel:
            let controlPressed = EventTap.controlDown || event.flags.contains(.maskControl)

            guard controlPressed else {
                EventTap.trackpadAccumulator = 0
                return event
            }

            let lineDelta = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
            let pointDelta = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
            let fixedDelta = event.getIntegerValueField(.scrollWheelEventFixedPtDeltaAxis1)

            let isLikelyMouseWheel = lineDelta != 0 && abs(pointDelta) >= 10

            if isLikelyMouseWheel {
                EventTap.trackpadAccumulator = 0

                let key: Key = lineDelta > 0 ? .plus : .minus

                key.press(true, true)
                key.press(false, true)

                return nil
            }

            let trackpadDelta: Int64

            if pointDelta != 0 {
                trackpadDelta = pointDelta
            } else if fixedDelta != 0 {
                trackpadDelta = fixedDelta / 65536
            } else {
                trackpadDelta = lineDelta
            }

            if trackpadDelta == 0 {
                return nil
            }

            if EventTap.trackpadAccumulator.signum() != trackpadDelta.signum() {
                EventTap.trackpadAccumulator = 0
            }

            EventTap.trackpadAccumulator += trackpadDelta

            if abs(EventTap.trackpadAccumulator) >= EventTap.trackpadThreshold {
                let key: Key = EventTap.trackpadAccumulator > 0 ? .plus : .minus

                key.press(true, true)
                key.press(false, true)

                EventTap.trackpadAccumulator = 0
            }

            return nil

        case .keyDown, .keyUp:
            return event

        default:
            return event
        }
    }
}

func exit_program() {
    EventTap.remove()
    exit(0)
}

private typealias CGEventTap = CFMachPort

extension CGEventTap {

    fileprivate class func create(
        callback: @escaping CGEventTapCallBack
    ) -> CGEventTap? {

        let mask: UInt32 =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.scrollWheel.rawValue)

        let tap: CFMachPort! = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: nil
        )

        assert(tap != nil, "Failed to create event tap")
        return tap
    }
}

let tap_callback: CGEventTapCallBack = {
    proxy, type, event, refcon in

    guard let event = EventTap.handle_event(
        proxy: proxy,
        type: type,
        event: event,
        refcon: refcon
    ) else {
        return nil
    }

    return Unmanaged.passRetained(event)
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var loginItem: NSMenuItem!
    var permissionTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "plus.magnifyingglass",
                accessibilityDescription: "ScrollZoom"
            )
        }

        let menu = NSMenu()

        loginItem = NSMenuItem(
            title: "Start at login",
            action: #selector(toggleStartAtLogin),
            keyEquivalent: ""
        )
        loginItem.target = self
        menu.addItem(loginItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(
            NSMenuItem(
                title: "Quit ScrollZoom",
                action: #selector(quit),
                keyEquivalent: "q"
            )
        )

        statusItem.menu = menu

        updateLoginItemState()

        requestAccessibilityPermissionIfNeeded()

        if AXIsProcessTrusted() {
            EventTap.create()
        }

        permissionTimer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(checkAccessibilityPermission),
            userInfo: nil,
            repeats: true
        )
    }

    func requestAccessibilityPermissionIfNeeded() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        AXIsProcessTrustedWithOptions(options)
    }

    @objc func checkAccessibilityPermission() {
        if !AXIsProcessTrusted() {
            EventTap.remove()

            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(
                    withLength: NSStatusItem.variableLength
                )
            }

            if let button = statusItem.button {
                button.image = NSImage(
                    systemSymbolName: "plus.magnifyingglass",
                    accessibilityDescription: "ScrollZoom"
                )
            }

            return
        }

        if EventTap.rloop_source == nil {
            EventTap.create()
        }
    }

    @objc func toggleStartAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }

            updateLoginItemState()
        } catch {
            print("Failed to update Start at Login: \(error)")
        }
    }

    func updateLoginItemState() {
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc func quit() {
        EventTap.remove()
        NSApplication.shared.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()