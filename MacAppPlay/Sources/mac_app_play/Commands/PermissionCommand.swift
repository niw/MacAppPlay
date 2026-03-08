import ArgumentParser

struct PermissionCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "permission",
        abstract: "Check or request macOS permissions.",
        subcommands: [Check.self, Request.self]
    )

    struct Check: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Check permission status."
        )

        @Flag(help: "Check accessibility permission.")
        var accessibility = false

        @Flag(help: "Check screen recording permission.")
        var screenRecording = false

        @Flag(help: "Check all permissions.")
        var all = false

        func run() throws {
            let checkAccessibility = all || accessibility || (!accessibility && !screenRecording)
            let checkScreenRecording = all || screenRecording || (!accessibility && !screenRecording)

            if checkAccessibility {
                let granted = Permissions.checkAccessibility()
                print("Accessibility: \(granted ? "granted" : "denied")")
            }
            if checkScreenRecording {
                let granted = Permissions.checkScreenRecording()
                print("Screen Recording: \(granted ? "granted" : "denied")")
            }
        }
    }

    struct Request: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Request permissions (opens system prompt)."
        )

        @Flag(help: "Request accessibility permission.")
        var accessibility = false

        @Flag(help: "Request screen recording permission.")
        var screenRecording = false

        func run() throws {
            if !accessibility && !screenRecording {
                print("Specify --accessibility and/or --screen-recording.")
                return
            }
            if accessibility {
                let result = Permissions.requestAccessibility()
                print("Accessibility: \(result ? "granted" : "requested (check System Settings)")")
            }
            if screenRecording {
                let result = Permissions.requestScreenRecording()
                print("Screen Recording: \(result ? "granted" : "requested (check System Settings)")")
            }
        }
    }
}
