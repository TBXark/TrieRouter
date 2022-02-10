# TrieRouter

An App-specific Simple Routing Library


### Usage

```swift
let r = Router()
r.addRoute(urlString: "tbx://index") { _ in
    print("root")
    return true
}
r.addRoute(urlString: "tbx://hello/:name") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
    return true
}
r.addRoute(urlString: "tbx://file/:name") { ctx in
    print("file \(ctx.params["name"] ?? "")")
    return true
}
r.addRoute(urlString: "tbx://long/long/:name/path") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
    return true
}
```