import ArgumentParser
import ApplicationServices

struct AccessibilityCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ax",
        abstract: "Inspect and interact with accessibility elements.",
        subcommands: [List.self, Tree.self, Children.self, Find.self, Attrs.self, Actions.self, Press.self, SetValue.self]
    )

    /// Resolve an AXUIElement from an app name and path.
    static func resolveElement(app: String, path: [Int]) throws -> AXUIElement {
        let root = try AccessibilityElement.appElement(for: app)
        let children = AccessibilityElement.getChildren(root)

        guard let firstIndex = path.first, firstIndex >= 0, firstIndex < children.count else {
            print("Invalid path.")
            throw ExitCode.failure
        }

        return try AccessibilityElement.navigate(
            from: children[firstIndex],
            path: Array(path.dropFirst())
        )
    }

    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List top-level elements with labels and positions."
        )

        @Option(help: "Application name.")
        var app: String

        func run() throws {
            let root = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(root)

            if children.isEmpty {
                print("No top-level elements found for \(app).")
                return
            }

            for (i, child) in children.enumerated() {
                AccessibilityElement.printTree(child, maxDepth: 1, depth: 0, index: i)
            }
        }
    }

    struct Tree: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print the full accessibility tree."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(help: "Maximum depth to traverse.")
        var depth: Int = 10

        func run() throws {
            let root = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(root)

            for (i, child) in children.enumerated() {
                AccessibilityElement.printTree(child, maxDepth: depth, depth: 0, index: i)
            }
        }
    }

    struct Children: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Get children of element at a tree path."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(
            help: "Comma-separated index path (e.g., 0,1,2).",
            transform: { $0.split(separator: ",").compactMap { Int($0) } }
        )
        var path: [Int]

        func run() throws {
            let target = try AccessibilityCommand.resolveElement(app: app, path: path)

            let targetChildren = AccessibilityElement.getChildren(target)
            if targetChildren.isEmpty {
                print("No children at this path.")
                return
            }

            for (i, child) in targetChildren.enumerated() {
                let info = AccessibilityElement.getInfo(child)
                let labelStr = info.label.map { " \"\($0)\"" } ?? ""
                let posStr = info.positionString.isEmpty ? "" : " \(info.positionString)"
                print("[\(i)] \(info.role)\(labelStr)\(posStr)")
            }
        }
    }

    struct Find: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Find elements by label (recursive search)."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(help: "Label text to search for.")
        var label: String

        func run() throws {
            let root = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(root)

            var results: [(path: [Int], info: ElementInfo)] = []
            for (i, child) in children.enumerated() {
                AccessibilityElement.findByLabel(child, label: label, path: [i], results: &results)
            }

            if results.isEmpty {
                print("No elements found matching \"\(label)\".")
                return
            }

            for result in results {
                let pathStr = result.path.map(String.init).joined(separator: ",")
                let labelStr = result.info.label.map { " \"\($0)\"" } ?? ""
                let posStr = result.info.positionString.isEmpty ? "" : " \(result.info.positionString)"
                print("[\(pathStr)] \(result.info.role)\(labelStr)\(posStr)")
            }
        }
    }

    struct Attrs: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Show all attributes of element at path."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(
            help: "Comma-separated index path (e.g., 0,1,2).",
            transform: { $0.split(separator: ",").compactMap { Int($0) } }
        )
        var path: [Int]

        func run() throws {
            let target = try AccessibilityCommand.resolveElement(app: app, path: path)

            let attrs = AccessibilityElement.getAllAttributes(target)
            if attrs.isEmpty {
                print("No attributes found.")
                return
            }

            for (name, value) in attrs {
                print("\(name): \(value)")
            }
        }
    }

    struct Actions: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List available actions for element at path."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(
            help: "Comma-separated index path (e.g., 0,1,2).",
            transform: { $0.split(separator: ",").compactMap { Int($0) } }
        )
        var path: [Int]

        func run() throws {
            let target = try AccessibilityCommand.resolveElement(app: app, path: path)

            var actionNames: CFArray?
            guard AXUIElementCopyActionNames(target, &actionNames) == .success,
                  let actions = actionNames as? [String] else {
                print("No actions available.")
                return
            }

            if actions.isEmpty {
                print("No actions available.")
                return
            }

            for action in actions {
                var description: CFString?
                AXUIElementCopyActionDescription(target, action as CFString, &description)
                let desc = (description as? String).map { " — \($0)" } ?? ""
                print("\(action)\(desc)")
            }
        }
    }

    struct Press: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Perform an action on element at path (default: AXPress)."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(
            help: "Comma-separated index path (e.g., 0,1,2).",
            transform: { $0.split(separator: ",").compactMap { Int($0) } }
        )
        var path: [Int]

        @Option(help: "Action name (default: AXPress).")
        var action: String = "AXPress"

        func run() throws {
            let target = try AccessibilityCommand.resolveElement(app: app, path: path)

            let result = AXUIElementPerformAction(target, action as CFString)
            guard result == .success else {
                print("Failed to perform \(action) (AX error: \(result.rawValue)).")
                throw ExitCode.failure
            }

            let info = AccessibilityElement.getInfo(target)
            let label = info.label.map { " \"\($0)\"" } ?? ""
            print("Performed \(action) on \(info.role)\(label).")
        }
    }

    struct SetValue: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "set-value",
            abstract: "Set the value of an element at path (e.g., text field)."
        )

        @Option(help: "Application name.")
        var app: String

        @Option(
            help: "Comma-separated index path (e.g., 0,1,2).",
            transform: { $0.split(separator: ",").compactMap { Int($0) } }
        )
        var path: [Int]

        @Option(help: "Value to set.")
        var value: String

        func run() throws {
            let target = try AccessibilityCommand.resolveElement(app: app, path: path)

            let result = AXUIElementSetAttributeValue(target, kAXValueAttribute as CFString, value as CFTypeRef)
            guard result == .success else {
                print("Failed to set value (AX error: \(result.rawValue)).")
                throw ExitCode.failure
            }

            let info = AccessibilityElement.getInfo(target)
            let label = info.label.map { " \"\($0)\"" } ?? ""
            print("Set value on \(info.role)\(label) to \"\(value)\".")
        }
    }
}
