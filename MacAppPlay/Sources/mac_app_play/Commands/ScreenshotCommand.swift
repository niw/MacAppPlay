import ArgumentParser
import CoreGraphics

struct ScreenshotCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "screenshot",
        abstract: "Capture a screenshot."
    )

    @Option(help: "App name to capture.")
    var app: String?

    @Option(help: "Window ID to capture.")
    var windowId: UInt32?

    @Option(help: "Display ID to capture.")
    var display: UInt32?

    @Option(help: "Output file path.")
    var output: String = "screenshot.png"

    @Flag(help: "Capture at full pixel resolution (Retina). Default is point resolution (1x).")
    var highResolution = false

    func run() async throws {
        let image: CGImage

        if let windowId {
            image = try await ScreenCapture.captureWindow(id: windowId, highResolution: highResolution)
        } else if let app {
            let windows = try await ScreenCapture.findWindows(appName: app)
            guard let first = windows.first else {
                print("No windows found for app: \(app)")
                throw ExitCode.failure
            }
            let bounds = first.bounds
            print("Capturing window: \(first.name) (ID: \(first.windowID)) at (\(Int(bounds.origin.x)),\(Int(bounds.origin.y)) \(Int(bounds.width))x\(Int(bounds.height)))")
            image = try await ScreenCapture.captureWindow(id: first.windowID, highResolution: highResolution)
        } else if let display {
            image = try await ScreenCapture.captureDisplay(id: display, highResolution: highResolution)
        } else {
            image = try await ScreenCapture.captureFullScreen(highResolution: highResolution)
        }

        try ScreenCapture.savePNG(image: image, to: output)
        print("Screenshot saved to \(output) (\(image.width)x\(image.height))")
    }
}

struct DisplayInfoCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "display-info",
        abstract: "Show display size and scale factor."
    )

    func run() async throws {
        let displays = try await ScreenCapture.getDisplayInfo()
        if displays.isEmpty {
            print("No displays found.")
            return
        }
        for info in displays {
            print("Display \(info.displayID): \(info.width)x\(info.height) points, scale factor \(info.scaleFactor)x (\(info.width * info.scaleFactor)x\(info.height * info.scaleFactor) pixels)")
        }
    }
}
