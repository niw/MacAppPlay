import ArgumentParser
import CoreGraphics

struct MouseCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mouse",
        abstract: "Control mouse cursor.",
        subcommands: [Move.self, Click.self, Drag.self]
    )

    struct Move: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Move mouse cursor to a position."
        )

        @Option(help: "X coordinate.")
        var x: Int

        @Option(help: "Y coordinate.")
        var y: Int

        @Option(help: "Animation duration in milliseconds.")
        var duration: Int = 0

        func run() throws {
            MouseControl.move(to: CGPoint(x: x, y: y), duration: duration)
            print("Moved mouse to (\(x), \(y))")
        }
    }

    struct Click: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Click at a position."
        )

        @Option(help: "X coordinate.")
        var x: Int

        @Option(help: "Y coordinate.")
        var y: Int

        @Option(help: "Mouse button (left or right).")
        var button: String = "left"

        @Flag(help: "Double click.")
        var double = false

        func run() throws {
            let btn: MouseButton = button == "right" ? .right : .left
            MouseControl.click(at: CGPoint(x: x, y: y), button: btn, doubleClick: self.double)
            print("Clicked at (\(x), \(y)) with \(button) button\(self.double ? " (double)" : "")")
        }
    }

    struct Drag: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Drag from one position to another."
        )

        @Option(help: "Start X coordinate.")
        var fromX: Int

        @Option(help: "Start Y coordinate.")
        var fromY: Int

        @Option(help: "End X coordinate.")
        var toX: Int

        @Option(help: "End Y coordinate.")
        var toY: Int

        @Option(help: "Mouse button (left or right).")
        var button: String = "left"

        @Option(help: "Duration in milliseconds.")
        var duration: Int = 300

        func run() throws {
            let btn: MouseButton = button == "right" ? .right : .left
            MouseControl.drag(
                from: CGPoint(x: fromX, y: fromY),
                to: CGPoint(x: toX, y: toY),
                button: btn,
                durationMs: duration
            )
            print("Dragged from (\(fromX), \(fromY)) to (\(toX), \(toY))")
        }
    }
}
