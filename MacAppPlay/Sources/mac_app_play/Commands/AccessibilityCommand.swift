import ArgumentParser

struct AccessibilityCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ax",
        abstract: "Inspect accessibility elements.",
        subcommands: [List.self, Tree.self, Children.self, Find.self, Attrs.self]
    )

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
            let root = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(root)

            guard let firstIndex = path.first, firstIndex < children.count else {
                print("Invalid path.")
                throw ExitCode.failure
            }

            let target = try AccessibilityElement.navigate(
                from: children[firstIndex],
                path: Array(path.dropFirst())
            )

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
            let root = try AccessibilityElement.appElement(for: app)
            let children = AccessibilityElement.getChildren(root)

            guard let firstIndex = path.first, firstIndex < children.count else {
                print("Invalid path.")
                throw ExitCode.failure
            }

            let target = try AccessibilityElement.navigate(
                from: children[firstIndex],
                path: Array(path.dropFirst())
            )

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
}
