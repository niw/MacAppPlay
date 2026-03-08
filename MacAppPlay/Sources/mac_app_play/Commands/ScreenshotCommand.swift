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

    func run() async throws {
        let image: CGImage

        if let windowId {
            image = try await ScreenCapture.captureWindow(id: windowId)
        } else if let app {
            let windows = try await ScreenCapture.findWindows(appName: app)
            guard let first = windows.first else {
                print("No windows found for app: \(app)")
                throw ExitCode.failure
            }
            print("Capturing window: \(first.name) (ID: \(first.windowID))")
            image = try await ScreenCapture.captureWindow(id: first.windowID)
        } else if let display {
            image = try await ScreenCapture.captureDisplay(id: display)
        } else {
            image = try await ScreenCapture.captureFullScreen()
        }

        try ScreenCapture.savePNG(image: image, to: output)
        print("Screenshot saved to \(output)")
    }
}
