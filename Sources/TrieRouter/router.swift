import Foundation

class Node: CustomDebugStringConvertible {
    var pattern: String
    var part: String
    var isWild: Bool
    var children: [Node]

    init(pattern: String, part: String, isWild: Bool, children: [Node]) {
        self.pattern = pattern
        self.part = part
        self.isWild = isWild
        self.children = children
    }
    
    var debugDescription: String {
        return "Node { pattern=\(pattern), part=\(part), isWild=\(isWild) }"
    }

    func insert(pattern: String, parts: [String], height: Int) {
        if parts.count == height {
            self.pattern = pattern
            return
        }
        let part = parts[height]
        var child: Node? = self.matchChild(part: part)
        if child == nil {
            let isWild = part.hasPrefix(":") || part.hasPrefix("*")
            let _child = Node(pattern: "", part: part, isWild: isWild, children: [])
            self.children.append(_child)
            child = _child
        }
        child?.insert(pattern: pattern, parts: parts, height: height + 1)
    }

    func search(parts: [String], height: Int) -> Node? {
        if parts.count == height || self.part.hasPrefix("*") {
            if self.pattern == "" {
                return nil
            }
            return self
        }
        for c in  self.matchChildren(part: parts[height]) {
            if let r = c.search(parts: parts, height: height + 1) {
                return r
            }
        }
        return nil
    }

    func travel(list: [Node]) -> [Node] {
        var temp = list
        if self.pattern != "" {
            temp.append(self)
        }
        for c in self.children {
            temp = c.travel(list: temp)
        }
        return temp
    }

    func matchChild(part: String) -> Node? {
        return self.children.first(where: { $0.part == part || $0.isWild })
    }

    func  matchChildren(part: String) -> [Node] {
        return self.children.filter({  $0.part == part || $0.isWild })
    }
}

public struct Context {
    public struct Params {
        var store: [String: String]
        public subscript(key: String) -> String? {
            return store[key]
        }
    }
    public var url: URL
    public var params: Params
    public var context: Any?
}

extension Context.Params {
    public func getString(_ key: String) -> String? {
        return self.store[key]
    }

    public func getInt(_ key: String) -> Int? {
        return self.store[key].flatMap { Int($0) }
    }

    public func getFloat(_ key: String) -> Float? {
        return self.store[key].flatMap { Float($0) }
    }
}

extension URL {
    var hostAndPath: String {
        if let h = self.host {
            return "\(h)/\(self.path)"
        } else {
            return self.path
        }
    }

    @available(iOS 8.0, macOS 10.10, *)
    public var queryItems: [URLQueryItem]? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
    }

    @available(iOS 8.0, macOS 10.10, *)
    public var queryParameters: [String: String] {
        var params = [String: String]()
        for p in self.queryItems ?? [] {
            params[p.name] = p.value
        }
        return params
    }
}

public typealias HandlerFunc = (Context) throws -> Void

public enum RouterHandleError: Error {
    case canNotHandleUrl
    case missingParams(String)
    case paramsIsInvalid(String)
}

public class Router {
    var roots = [String: Node]()
    var handlers = [String: HandlerFunc]()
    public var errorHandler: ((Context, Error) -> Void )?

    public init() {
    }
    
    func printAllNodes() {
        for (g, n) in roots {
            n.travel(list: []).forEach({ print(g + " : " +  $0.debugDescription) })
        }
    }

    func parsePattern(pattern: String) -> [String] {
        let vs = pattern.split(separator: "/").map({ String($0) })
        var parts = [String]()
        for item in vs {
            if item != "" {
                parts.append(item)
                if item.hasPrefix("*") {
                    break
                }
            }
        }
        return parts
    }

    func buildKey(group: String, pattern: String) -> String {
        return "\(group)-\(pattern)"
    }

    public func addRoute(_ urlString: String, handler: @escaping HandlerFunc) {
        guard let url = URL(string: urlString) else {
            return
        }
        addRoute(url, handler: handler)
    }

    public func addRoute(_ url: URL, handler: @escaping HandlerFunc) {
        addRoute(group: url.scheme ?? "", pattern: url.hostAndPath, handler: handler)
    }

    func addRoute(group: String, pattern: String, handler: @escaping HandlerFunc) {
        let parts = parsePattern(pattern: pattern)
        let key = buildKey(group: group, pattern: pattern)
        let node = self.roots[group] ?? Node(pattern: "", part: "", isWild: false, children: [])
        node.insert(pattern: pattern, parts: parts, height: 0)
        self.roots[group] = node
        self.handlers[key] = handler
    }

    func getRoute(group: String, path: String) -> (node: Node, params: [String: String])? {
        let searchParts = parsePattern(pattern: path)
        var params = [String: String]()
        guard let root = self.roots[group],
              let n = root.search(parts: searchParts, height: 0) else {
                  return nil
              }
        let parts = parsePattern(pattern: n.pattern)
        for (index, part) in parts.enumerated() {
            if part.hasPrefix(":") {
                let name = String(part.suffix(from: part.index(after: part.startIndex)))
                params[name] = searchParts[index]
            } else if part.hasPrefix("*") && part.count > 1 {
                let name = String(part.suffix(from: part.index(after: part.startIndex)))
                params[name] = searchParts.suffix(from: index).joined(separator: "/")
                break
            }
        }
        return (n, params)
    }

    func getRoutes(group: String) -> [Node] {
        if let n = self.roots[group] {
            return n.travel(list: [])
        } else {
            return []
        }
    }

    public func handle(_ urlString: String, context: Any? = nil) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        return handle(url, context: context)
    }

    public func handle(_ url: URL, context: Any? = nil) -> Bool {
        let group = url.scheme ?? ""
        guard  let res = self.getRoute(group: group, path: url.hostAndPath),
               let handler =  self.handlers[buildKey(group: group, pattern: res.node.pattern)]  else {
                   return false
               }
        let ctx = Context(url: url, params: Context.Params(store: res.params), context: context)
        var didHandle = false
        do {
            try handler(ctx)
            didHandle = true
        } catch let error {
            self.errorHandler?(ctx, error)
        }
        return didHandle
    }

}
