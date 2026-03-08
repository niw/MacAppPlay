import CoreGraphics
import ImageIO
import Foundation
import UniformTypeIdentifiers
import ScreenCaptureKit

enum ScreenCapture {
    struct WindowInfo {
        let windowID: CGWindowID
        let name: String
        let ownerName: String
        let bounds: CGRect
    }

    struct DisplayInfo {
        let displayID: CGDirectDisplayID
        let width: Int
        let height: Int
        let scaleFactor: Int
    }

    static func captureFullScreen(highResolution: Bool = false) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first else {
            throw ScreenCaptureError.captureFailure
        }
        let filter = SCContentFilter(display: display, excludingWindows: [])
        return try await captureWithFilter(filter, highResolution: highResolution)
    }

    static func captureWindow(id: CGWindowID, highResolution: Bool = false) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        guard let window = content.windows.first(where: { $0.windowID == id }) else {
            throw ScreenCaptureError.captureFailure
        }
        let filter = SCContentFilter(desktopIndependentWindow: window)
        return try await captureWithFilter(filter, highResolution: highResolution)
    }

    static func captureDisplay(id: CGDirectDisplayID, highResolution: Bool = false) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first(where: { $0.displayID == id }) else {
            throw ScreenCaptureError.captureFailure
        }
        let filter = SCContentFilter(display: display, excludingWindows: [])
        return try await captureWithFilter(filter, highResolution: highResolution)
    }

    static func getDisplayInfo() async throws -> [DisplayInfo] {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        return content.displays.map { display in
            let filter = SCContentFilter(display: display, excludingWindows: [])
            return DisplayInfo(
                displayID: display.displayID,
                width: Int(filter.contentRect.width),
                height: Int(filter.contentRect.height),
                scaleFactor: Int(filter.pointPixelScale)
            )
        }
    }

    private static func captureWithFilter(_ filter: SCContentFilter, highResolution: Bool) async throws -> CGImage {
        let config = SCStreamConfiguration()
        let scale = highResolution ? Int(filter.pointPixelScale) : 1
        config.width = Int(filter.contentRect.width) * scale
        config.height = Int(filter.contentRect.height) * scale
        config.captureResolution = highResolution ? .best : .nominal
        config.showsCursor = false

        let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
        return image
    }

    static func findWindows(appName: String) async throws -> [WindowInfo] {
        let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
        return content.windows.compactMap { window -> WindowInfo? in
            guard let app = window.owningApplication,
                  app.applicationName.localizedCaseInsensitiveContains(appName) else {
                return nil
            }
            return WindowInfo(
                windowID: window.windowID,
                name: window.title ?? "",
                ownerName: app.applicationName,
                bounds: window.frame
            )
        }
    }

    static func savePNG(image: CGImage, to path: String) throws {
        let url = URL(fileURLWithPath: path)
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw ScreenCaptureError.cannotCreateDestination
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ScreenCaptureError.cannotFinalize
        }
    }

    enum ScreenCaptureError: Error, CustomStringConvertible {
        case cannotCreateDestination
        case cannotFinalize
        case captureFailure

        var description: String {
            switch self {
            case .cannotCreateDestination: "Failed to create image destination"
            case .cannotFinalize: "Failed to write PNG file"
            case .captureFailure: "Screen capture failed"
            }
        }
    }
}
