import ArgumentParser

@main
struct MacAppPlay: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mac_app_play",
        abstract: "macOS CLI utility for screen capture, mouse/keyboard control, and accessibility inspection.",
        subcommands: [
            ScreenshotCommand.self,
            MouseCommand.self,
            KeyboardCommand.self,
            AccessibilityCommand.self,
            FocusCommand.self,
            PermissionCommand.self,
        ]
    )
}
