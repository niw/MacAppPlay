import ArgumentParser

struct KeyboardCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "key",
        abstract: "Simulate keyboard input.",
        subcommands: [Press.self, Down.self, Up.self, TypeText.self]
    )

    struct Press: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Press and release a key."
        )

        @Argument(help: "Key name (e.g., a, return, f1, space).")
        var key: String

        @Option(
            name: .long,
            help: "Comma-separated modifiers (shift,command,option,control).",
            transform: { $0.split(separator: ",").map(String.init) }
        )
        var modifiers: [String] = []

        @Option(help: "Delay between keystrokes in milliseconds.")
        var delay: Int = 10

        func run() throws {
            guard let code = KeyCodeMap.keyCode(for: key) else {
                print("Unknown key: \(key)")
                throw ExitCode.failure
            }
            let flags = KeyboardModifier.flags(from: modifiers)
            KeyboardControl.press(keyCode: code, modifiers: flags, delayMs: delay)
            print("Pressed \(key)\(modifiers.isEmpty ? "" : " with \(modifiers.joined(separator: "+"))")")
        }
    }

    struct Down: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Press a key down (without releasing)."
        )

        @Argument(help: "Key name.")
        var key: String

        @Option(
            name: .long,
            help: "Comma-separated modifiers.",
            transform: { $0.split(separator: ",").map(String.init) }
        )
        var modifiers: [String] = []

        func run() throws {
            guard let code = KeyCodeMap.keyCode(for: key) else {
                print("Unknown key: \(key)")
                throw ExitCode.failure
            }
            let flags = KeyboardModifier.flags(from: modifiers)
            KeyboardControl.keyDown(keyCode: code, modifiers: flags)
            print("Key down: \(key)")
        }
    }

    struct Up: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Release a key."
        )

        @Argument(help: "Key name.")
        var key: String

        @Option(
            name: .long,
            help: "Comma-separated modifiers.",
            transform: { $0.split(separator: ",").map(String.init) }
        )
        var modifiers: [String] = []

        func run() throws {
            guard let code = KeyCodeMap.keyCode(for: key) else {
                print("Unknown key: \(key)")
                throw ExitCode.failure
            }
            let flags = KeyboardModifier.flags(from: modifiers)
            KeyboardControl.keyUp(keyCode: code, modifiers: flags)
            print("Key up: \(key)")
        }
    }

    struct TypeText: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "type",
            abstract: "Type a string of text."
        )

        @Argument(help: "The string to type.")
        var string: String

        @Option(help: "Delay between keystrokes in milliseconds.")
        var delay: Int = 10

        func run() throws {
            KeyboardControl.typeString(string, delayMs: delay)
            print("Typed: \(string)")
        }
    }
}
