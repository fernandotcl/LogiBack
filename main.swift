// LogiBack: turns mouse side buttons into ⌘[ (back) and ⌘] (forward).

import ApplicationServices
import Carbon.HIToolbox

let backButton: Int64 = 3
let forwardButton: Int64 = 4

func postCommandKey(_ keyCode: Int) {
    let source = CGEventSource(stateID: .hidSystemState)
    for keyDown in [true, false] {
        let event = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: keyDown)
        event?.flags = .maskCommand
        event?.post(tap: .cghidEventTap)
    }
}

var tap: CFMachPort?

let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
        return Unmanaged.passUnretained(event)
    }

    let button = event.getIntegerValueField(.mouseEventButtonNumber)
    guard button == backButton || button == forwardButton else {
        return Unmanaged.passUnretained(event)
    }

    if type == .otherMouseDown {
        postCommandKey(button == backButton ? kVK_ANSI_LeftBracket : kVK_ANSI_RightBracket)
    }
    return nil // Swallow both down and up so apps don't see the original click.
}

let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
if !AXIsProcessTrustedWithOptions(options) {
    fputs("LogiBack needs Accessibility permission (System Settings › Privacy & Security › Accessibility).\n", stderr)
}

let mask = (1 << CGEventType.otherMouseDown.rawValue) | (1 << CGEventType.otherMouseUp.rawValue)
tap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(mask),
    callback: callback,
    userInfo: nil
)

guard let tap else {
    fputs("Failed to create event tap. Grant Accessibility permission and try again.\n", stderr)
    exit(1)
}

let runLoopSource = CFMachPortCreateRunLoopSource(nil, tap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
CGEvent.tapEnable(tap: tap, enable: true)
CFRunLoopRun()
