//
//  main.swift
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

    // Control 키가 눌려 있는지 추적
    static var controlDown = false

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
            return event

        case .scrollWheel:
            let delta_y = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)

            // Control 누른 상태에서는 스크롤 이벤트를 앱으로 넘기지 않음
            if EventTap.controlDown || event.flags.contains(.maskControl) {
                let key: Key = (delta_y > 0) ? .plus : .minus

                key.press(true, true)
                key.press(false, true)

                return nil
            }

            return event

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

        /*
            keyDown = 10
            keyUp = 11
            flagsChanged = 12
            scrollWheel = 22
        */

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
        if SMAppService.mainApp.status == .enabled {
            loginItem.state = .on
        } else {
            loginItem.state = .off
        }
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