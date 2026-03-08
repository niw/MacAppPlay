import ArgumentParser
import AppKit
import ApplicationServices

struct FocusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "focus",
        abstract: "Switch application focus and raise windows.",
        subcommands: [App.self, Window.self, List.self]
    )

    struct App: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Activate an application, bringing it to the foreground."
        )

        @Option(help: "Application name.")
        var app: String

        func run() throws {
            guard let runningApp = NSWorkspace.shared.runningApplications.first(where: {
                $0.localizedName?.localizedCaseInsensitiveContains(app) == true
            }) else {
                throw AccessibilityError.appNotFound(app)
            }
            guard runningApp.activate() else {
                print("Failed to activate \(runningApp.localizedName ?? app).")
                throw ExitCode.failure
            }
            print("Activated \(runningApp.localizedName ?? app).")
        }
    }

    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List windows of an application with their titles and indices."
        )

        @Option(help: "Application name.")
        var app: String

        func run() throws {
            let appElement = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(appElement)

            let windows = children.filter {
                AccessibilityElement.getInfo($0).role == "AXWindow"
            }

            if windows.isEmpty {
                print("No windows found for \(app).")
                return
            }

            for (i, window) in windows.enumerated() {
                let info = AccessibilityElement.getInfo(window)
                let title = info.title ?? "(untitled)"
                let posStr = info.positionString.isEmpty ? "" : " \(info.positionString)"
                print("[\(i)] \(title)\(posStr)")
            }
        }
    }

    struct Window: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Raise a specific window of an application."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(help: "Window index (0-based).")
        var index: Int = 0

        func run() throws {
            let appElement = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(appElement)

            let windows = children.filter {
                let role = AccessibilityElement.getInfo($0).role
                return role == "AXWindow"
            }

            guard index >= 0, index < windows.count else {
                print("Window index \(index) out of range (app has \(windows.count) window(s)).")
                throw ExitCode.failure
            }

            let window = windows[index]
            let result = AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            guard result == .success else {
                print("Failed to raise window (AX error: \(result.rawValue)).")
                throw ExitCode.failure
            }

            // Also activate the app to bring it to the foreground
            if let runningApp = NSWorkspace.shared.runningApplications.first(where: {
                $0.localizedName?.localizedCaseInsensitiveContains(app) == true
            }) {
                runningApp.activate()
            }

            let info = AccessibilityElement.getInfo(window)
            let label = info.label.map { " \"\($0)\"" } ?? ""
            print("Raised window [\(index)]\(label).")
        }
    }
}
