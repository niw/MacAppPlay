import ApplicationServices
import AppKit

enum AccessibilityError: Error, CustomStringConvertible {
    case appNotFound(String)
    case elementError(AXError)
    case invalidPath

    var description: String {
        switch self {
        case .appNotFound(let name): "Application not found: \(name)"
        case .elementError(let error): "AX error: \(error.rawValue)"
        case .invalidPath: "Invalid element path"
        }
    }
}

struct ElementInfo: Sendable {
    let role: String
    let title: String?
    let description: String?
    let identifier: String?
    let position: CGPoint?
    let size: CGSize?

    var label: String? {
        title ?? description ?? identifier
    }

    var positionString: String {
        guard let pos = position, let sz = size else { return "" }
        return "(\(Int(pos.x)),\(Int(pos.y)) \(Int(sz.width))x\(Int(sz.height)))"
    }
}

enum AccessibilityElement {
    static func findAppPID(name: String) -> pid_t? {
        NSWorkspace.shared.runningApplications
            .first { app in
                app.localizedName?.localizedCaseInsensitiveContains(name) == true
            }?
            .processIdentifier
    }

    static func appElement(for appName: String) throws -> AXUIElement {
        guard let pid = findAppPID(name: appName) else {
            throw AccessibilityError.appNotFound(appName)
        }
        return AXUIElementCreateApplication(pid)
    }

    static func getInfo(_ element: AXUIElement) -> ElementInfo {
        ElementInfo(
            role: attribute(element, kAXRoleAttribute) as? String ?? "Unknown",
            title: attribute(element, kAXTitleAttribute) as? String,
            description: attribute(element, kAXDescriptionAttribute) as? String,
            identifier: attribute(element, kAXIdentifierAttribute) as? String,
            position: pointAttribute(element, kAXPositionAttribute),
            size: sizeAttribute(element, kAXSizeAttribute)
        )
    }

    static func getChildren(_ element: AXUIElement) -> [AXUIElement] {
        guard let children = attribute(element, kAXChildrenAttribute) as? [AXUIElement] else {
            return []
        }
        return children
    }

    static func navigate(from root: AXUIElement, path: [Int]) throws -> AXUIElement {
        var current = root
        for index in path {
            let children = getChildren(current)
            guard index >= 0, index < children.count else {
                throw AccessibilityError.invalidPath
            }
            current = children[index]
        }
        return current
    }

    static func getAllAttributes(_ element: AXUIElement) -> [(String, String)] {
        var names: CFArray?
        guard AXUIElementCopyAttributeNames(element, &names) == .success,
              let attrNames = names as? [String] else {
            return []
        }

        return attrNames.compactMap { name in
            var value: CFTypeRef?
            guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
                return nil
            }
            return (name, describeValue(value!))
        }
    }

    static func printTree(
        _ element: AXUIElement,
        maxDepth: Int = Int.max,
        depth: Int = 0,
        index: Int = 0
    ) {
        guard depth <= maxDepth else { return }
        let info = getInfo(element)
        let indent = String(repeating: "  ", count: depth)
        let labelStr = info.label.map { " \"\($0)\"" } ?? ""
        let posStr = info.positionString.isEmpty ? "" : " \(info.positionString)"
        let actions = getActionNames(element)
        let actionsStr = actions.isEmpty ? "" : " {\(actions.joined(separator: ", "))}"
        print("\(indent)[\(index)] \(info.role)\(labelStr)\(posStr)\(actionsStr)")

        let children = getChildren(element)
        for (i, child) in children.enumerated() {
            printTree(child, maxDepth: maxDepth, depth: depth + 1, index: i)
        }
    }

    static func findByLabel(
        _ element: AXUIElement,
        label: String,
        path: [Int] = [],
        results: inout [(path: [Int], info: ElementInfo, actions: [String])]
    ) {
        let info = getInfo(element)
        let labelLower = label.lowercased()
        let matches = [info.title, info.description, info.identifier]
            .compactMap { $0?.lowercased() }
            .contains { $0.contains(labelLower) }

        if matches {
            results.append((path: path, info: info, actions: getActionNames(element)))
        }

        let children = getChildren(element)
        for (i, child) in children.enumerated() {
            findByLabel(child, label: label, path: path + [i], results: &results)
        }
    }

    static func getActionNames(_ element: AXUIElement) -> [String] {
        var actionNames: CFArray?
        guard AXUIElementCopyActionNames(element, &actionNames) == .success,
              let actions = actionNames as? [String] else {
            return []
        }
        return actions
    }

    // MARK: - Private helpers

    private static func attribute(_ element: AXUIElement, _ attr: String) -> CFTypeRef? {
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(element, attr as CFString, &value)
        return value
    }

    private static func pointAttribute(_ element: AXUIElement, _ attr: String) -> CGPoint? {
        guard let value = attribute(element, attr) else { return nil }
        var point = CGPoint.zero
        guard AXValueGetValue(value as! AXValue, .cgPoint, &point) else { return nil }
        return point
    }

    private static func sizeAttribute(_ element: AXUIElement, _ attr: String) -> CGSize? {
        guard let value = attribute(element, attr) else { return nil }
        var size = CGSize.zero
        guard AXValueGetValue(value as! AXValue, .cgSize, &size) else { return nil }
        return size
    }

    private static func describeValue(_ value: CFTypeRef) -> String {
        if let str = value as? String { return "\"\(str)\"" }
        if let num = value as? NSNumber { return num.stringValue }
        if let arr = value as? [Any] { return "[\(arr.count) items]" }
        if CFGetTypeID(value) == AXValueGetTypeID() {
            let axValue = value as! AXValue
            var point = CGPoint.zero
            if AXValueGetValue(axValue, .cgPoint, &point) {
                return "(\(Int(point.x)), \(Int(point.y)))"
            }
            var size = CGSize.zero
            if AXValueGetValue(axValue, .cgSize, &size) {
                return "\(Int(size.width))x\(Int(size.height))"
            }
            var rect = CGRect.zero
            if AXValueGetValue(axValue, .cgRect, &rect) {
                return "(\(Int(rect.origin.x)),\(Int(rect.origin.y)) \(Int(rect.width))x\(Int(rect.height)))"
            }
        }
        return String(describing: value)
    }
}
