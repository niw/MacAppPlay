import CoreGraphics
import Foundation

enum MouseButton: String, CaseIterable {
    case left, right
}

enum MouseControl {
    static func move(to point: CGPoint, duration: Int = 0) {
        if duration > 0 {
            animateMove(to: point, durationMs: duration)
        } else {
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: .mouseMoved,
                mouseCursorPosition: point,
                mouseButton: .left
            )
            event?.post(tap: .cghidEventTap)
        }
    }

    static func click(at point: CGPoint, button: MouseButton = .left, doubleClick: Bool = false) {
        let (downType, upType): (CGEventType, CGEventType) = switch button {
        case .left: (.leftMouseDown, .leftMouseUp)
        case .right: (.rightMouseDown, .rightMouseUp)
        }
        let cgButton: CGMouseButton = button == .left ? .left : .right

        let clickCount = doubleClick ? 2 : 1
        for i in 1...clickCount {
            let down = CGEvent(
                mouseEventSource: nil,
                mouseType: downType,
                mouseCursorPosition: point,
                mouseButton: cgButton
            )
            down?.setIntegerValueField(.mouseEventClickState, value: Int64(i))
            down?.post(tap: .cghidEventTap)

            let up = CGEvent(
                mouseEventSource: nil,
                mouseType: upType,
                mouseCursorPosition: point,
                mouseButton: cgButton
            )
            up?.setIntegerValueField(.mouseEventClickState, value: Int64(i))
            up?.post(tap: .cghidEventTap)
        }
    }

    static func drag(
        from start: CGPoint,
        to end: CGPoint,
        button: MouseButton = .left,
        durationMs: Int = 300
    ) {
        let (downType, upType, dragType): (CGEventType, CGEventType, CGEventType) = switch button {
        case .left: (.leftMouseDown, .leftMouseUp, .leftMouseDragged)
        case .right: (.rightMouseDown, .rightMouseUp, .rightMouseDragged)
        }
        let cgButton: CGMouseButton = button == .left ? .left : .right

        let down = CGEvent(
            mouseEventSource: nil,
            mouseType: downType,
            mouseCursorPosition: start,
            mouseButton: cgButton
        )
        down?.post(tap: .cghidEventTap)

        let steps = max(durationMs / 16, 1)
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            let drag = CGEvent(
                mouseEventSource: nil,
                mouseType: dragType,
                mouseCursorPosition: CGPoint(x: x, y: y),
                mouseButton: cgButton
            )
            drag?.post(tap: .cghidEventTap)
            usleep(16_000)
        }

        let up = CGEvent(
            mouseEventSource: nil,
            mouseType: upType,
            mouseCursorPosition: end,
            mouseButton: cgButton
        )
        up?.post(tap: .cghidEventTap)
    }

    private static func animateMove(to target: CGPoint, durationMs: Int) {
        guard let currentEvent = CGEvent(source: nil) else { return }
        let current = currentEvent.location

        let steps = max(durationMs / 16, 1)
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = current.x + (target.x - current.x) * t
            let y = current.y + (target.y - current.y) * t
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: .mouseMoved,
                mouseCursorPosition: CGPoint(x: x, y: y),
                mouseButton: .left
            )
            event?.post(tap: .cghidEventTap)
            usleep(16_000)
        }
    }
}
