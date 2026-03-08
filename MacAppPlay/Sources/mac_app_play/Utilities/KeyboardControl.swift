import CoreGraphics
import Foundation

enum KeyboardModifier: String, CaseIterable {
    case shift, command, option, alt, control, ctrl

    var flag: CGEventFlags {
        switch self {
        case .shift: .maskShift
        case .command: .maskCommand
        case .option, .alt: .maskAlternate
        case .control, .ctrl: .maskControl
        }
    }

    static func flags(from names: [String]) -> CGEventFlags {
        var flags = CGEventFlags()
        for name in names {
            if let modifier = KeyboardModifier(rawValue: name.lowercased()) {
                flags.insert(modifier.flag)
            }
        }
        return flags
    }
}

enum KeyboardControl {
    static func press(keyCode: UInt16, modifiers: CGEventFlags = [], delayMs: Int = 0) {
        keyDown(keyCode: keyCode, modifiers: modifiers)

        if delayMs > 0 {
            usleep(UInt32(delayMs) * 1000)
        }

        keyUp(keyCode: keyCode, modifiers: modifiers)
    }

    static func keyDown(keyCode: UInt16, modifiers: CGEventFlags = []) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        if !modifiers.isEmpty {
            event?.flags = modifiers
        }
        event?.post(tap: .cghidEventTap)
    }

    static func keyUp(keyCode: UInt16, modifiers: CGEventFlags = []) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        if !modifiers.isEmpty {
            event?.flags = modifiers
        }
        event?.post(tap: .cghidEventTap)
    }

    static func typeString(_ string: String, delayMs: Int = 0) {
        let source = CGEventSource(stateID: .hidSystemState)
        for char in string {
            let utf16 = Array(String(char).utf16)
            let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            down?.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
            down?.post(tap: .cghidEventTap)

            let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
            up?.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
            up?.post(tap: .cghidEventTap)

            if delayMs > 0 {
                usleep(UInt32(delayMs) * 1000)
            }
        }
    }
}
