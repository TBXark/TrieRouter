# TrieRouter

An App-specific Simple Routing Library


### Usage

```swift
let r = Router()
r.addRoute("tbx://index") { _ in
    print("root")
    return true
}
r.addRoute("tbx://hello/:name") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
    return true
}
r.addRoute("tbx://file/:name") { ctx in
    print("file \(ctx.params["name"] ?? "")")
    return true
}
r.addRoute("tbx://long/long/:name/path") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
    return true
}
```