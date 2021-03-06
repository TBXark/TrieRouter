//
//  Router.swift
//  Router
//
//  Created by Tbxark on 2022/2/10.
//  Copyright © 2022 Tbxark. All rights reserved.
//

import Foundation

public class Router {

    public typealias HandlerFunc = (Context) throws -> Void

    public struct Context {
        public struct Params {
            var store: [String: String]
        }
        public var url: URL
        public var params: Params
        public var queryParams: Params {
            return Params(store: url.queryParameters)
        }
        public var context: Any?
    }

    public enum HandleError: Error {
        case roteNotFound(URL)
        case invalidURL(String)
        case missingParams(String)
        case paramsIsInvalid(String)
    }

    private var roots = [String: Node]()
    private var handlers = [String: HandlerFunc]()

    public init() {
    }

    public func printAllNodes() {
        for (k, v) in allPattern() {
            for p in v {
                print("\(k)://\(p)")
            }
        }
    }

    public func allPattern() -> [String: [String]] {
        return roots.mapValues({ $0.travel(list: []).map({ $0.pattern }) })
    }
    
    public func allNode() -> [String: [Node]] {
        return roots.mapValues({ $0.travel(list: []) })
    }

    private func parsePattern(pattern: String) -> [String] {
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

    private func buildKey(group: String, pattern: String) -> String {
        return "\(group)::\(pattern)"
    }

    @discardableResult public func addRoute(_ urlString: String, handler: @escaping HandlerFunc) -> Node? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return addRoute(url, handler: handler)
    }

    @discardableResult public func addRoute(_ url: URL, handler: @escaping HandlerFunc) -> Node? {
        return addRoute(group: url.scheme ?? "", pattern: url.hostAndPath, handler: handler)
    }

    @discardableResult public func addRoute(group: String, pattern: String, handler: @escaping HandlerFunc) -> Node? {
        let parts = parsePattern(pattern: pattern)
        let key = buildKey(group: group, pattern: pattern)
        let node = self.roots[group] ?? Node(pattern: "", part: "", isWild: false, children: [])
        node.insert(pattern: pattern, parts: parts, height: 0)
        self.roots[group] = node
        self.handlers[key] = handler
        return node.search(parts: parts, height: 0)
    }

    private func getRoute(group: String, path: String) -> (node: Node, params: [String: String])? {
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

    private func getRoutes(group: String) -> [Node] {
        if let n = self.roots[group] {
            return n.travel(list: [])
        } else {
            return []
        }
    }

    public func handle(_ urlString: String, context: Any? = nil) throws {
        guard let url = URL(string: urlString) else {
            throw HandleError.invalidURL(urlString)
        }
        return try handle(url, context: context)
    }

    public func handle(_ url: URL, context: Any? = nil) throws {
        let group = url.scheme ?? ""
        guard  let res = self.getRoute(group: group, path: url.hostAndPath),
               let handler =  self.handlers[buildKey(group: group, pattern: res.node.pattern)]  else {
                   throw HandleError.roteNotFound(url)
               }
        let ctx = Context(url: url, params: Context.Params(store: res.params), context: context)
        try handler(ctx)
    }

}
 

extension Router {
    public class Node: CustomDebugStringConvertible {
        public private(set) var pattern: String
        private var part: String
        private var isWild: Bool
        private var children: [Node]
        public var remark: String?

        init(pattern: String, part: String, isWild: Bool, children: [Node]) {
            self.pattern = pattern
            self.part = part
            self.isWild = isWild
            self.children = children
        }

        public var debugDescription: String {
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

        private func matchChild(part: String) -> Node? {
            return self.children.first(where: { $0.part == part || $0.isWild })
        }

        private func matchChildren(part: String) -> [Node] {
            return self.children.filter({  $0.part == part || $0.isWild })
        }
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

extension Router.Context.Params {
    public func getOptionalString(_ key: String) -> String? {
        if let v = self.store[key] {
            return v
        }
        return nil
    }

    public func getOptionalInt(_ key: String) -> Int? {
        guard let raw = self.store[key], let v = Int(raw) else {
            return nil
        }
        return v
    }

    public func getOptionalFloat(_ key: String) -> Float? {
        guard let raw = self.store[key], let v = Float(raw) else {
            return nil
        }
        return v
    }

    public func getString(_ key: String) throws -> String {
        if let v = self.store[key] {
            return v
        }
        throw Router.HandleError.missingParams(key)
    }

    public func getInt(_ key: String) throws -> Int {
        guard let raw = self.store[key] else {
            throw Router.HandleError.missingParams(key)
        }
        guard let v = Int(raw) else {
            throw Router.HandleError.paramsIsInvalid(key)
        }
        return v
    }

    public func getFloat(_ key: String) throws -> Float {
        guard let raw = self.store[key] else {
            throw Router.HandleError.missingParams(key)
        }
        guard let v = Float(raw) else {
            throw Router.HandleError.paramsIsInvalid(key)
        }
        return v
    }
}
