import AppKit
import ArgumentParser

@main
struct MacAppPlay: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mac_app_play",
        abstract: "macOS CLI utility for screen capture, mouse/keyboard control, and accessibility inspection.",
        subcommands: [
            ScreenshotCommand.self,
            DisplayInfoCommand.self,
            MouseCommand.self,
            KeyboardCommand.self,
            AccessibilityCommand.self,
            FocusCommand.self,
            PermissionCommand.self,
        ]
    )

    static func main() async {
        // Initialize the window server connection before any ScreenCaptureKit
        // calls to prevent "CGS_REQUIRE_INIT" assertion failures in CLI processes.
        _ = NSApplication.shared
        do {
            var command = try parseAsRoot()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
}
