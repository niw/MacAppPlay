import ApplicationServices
import CoreGraphics

enum Permissions {
    static func checkAccessibility() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestAccessibility() -> Bool {
        // "AXTrustedCheckOptionPrompt" is the value of kAXTrustedCheckOptionPrompt
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func checkScreenRecording() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    static func requestScreenRecording() -> Bool {
        CGRequestScreenCaptureAccess()
    }
}
