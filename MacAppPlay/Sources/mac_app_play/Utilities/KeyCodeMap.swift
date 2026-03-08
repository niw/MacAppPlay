// Key name to virtual key code mapping (Carbon HIToolbox Events.h constants)
enum KeyCodeMap {
    static let map: [String: UInt16] = [
        // Letters
        "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03, "h": 0x04,
        "g": 0x05, "z": 0x06, "x": 0x07, "c": 0x08, "v": 0x09,
        "b": 0x0B, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F,
        "y": 0x10, "t": 0x11, "u": 0x20, "i": 0x22, "p": 0x23,
        "l": 0x25, "j": 0x26, "k": 0x28, "n": 0x2D, "m": 0x2E,
        "o": 0x1F,

        // Numbers
        "0": 0x1D, "1": 0x12, "2": 0x13, "3": 0x14, "4": 0x15,
        "5": 0x17, "6": 0x16, "7": 0x1A, "8": 0x1C, "9": 0x19,

        // Special keys
        "return": 0x24, "enter": 0x24, "tab": 0x30, "space": 0x31,
        "delete": 0x33, "backspace": 0x33, "escape": 0x35, "esc": 0x35,

        // Modifiers (as keys)
        "command": 0x37, "shift": 0x38, "capslock": 0x39,
        "option": 0x3A, "alt": 0x3A, "control": 0x3B, "ctrl": 0x3B,

        // Function keys
        "f1": 0x7A, "f2": 0x78, "f3": 0x63, "f4": 0x76,
        "f5": 0x60, "f6": 0x61, "f7": 0x62, "f8": 0x64,
        "f9": 0x65, "f10": 0x6D, "f11": 0x67, "f12": 0x6F,

        // Arrow keys
        "left": 0x7B, "right": 0x7C, "down": 0x7D, "up": 0x7E,

        // Punctuation
        "minus": 0x1B, "-": 0x1B,
        "equal": 0x18, "=": 0x18,
        "leftbracket": 0x21, "[": 0x21,
        "rightbracket": 0x1E, "]": 0x1E,
        "backslash": 0x2A, "\\": 0x2A,
        "semicolon": 0x29, ";": 0x29,
        "quote": 0x27, "'": 0x27,
        "comma": 0x2B, ",": 0x2B,
        "period": 0x2F, ".": 0x2F,
        "slash": 0x2C, "/": 0x2C,
        "grave": 0x32, "`": 0x32,

        // Navigation
        "home": 0x73, "end": 0x77, "pageup": 0x74, "pagedown": 0x79,
        "forwarddelete": 0x75,
    ]

    static func keyCode(for name: String) -> UInt16? {
        map[name.lowercased()]
    }
}
