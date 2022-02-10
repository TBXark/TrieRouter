# TrieRouter

An App-specific Simple Routing Library


### Usage

```swift
let r = Router()
r.addRoute("tbx://index") { _ in
    print("root")
}
r.addRoute("tbx://intTest/:value") { ctx in
    if let v = ctx.params.getInt("value") {
        print("hello \(v)")
    } else {
        throw RouterHandleError.paramsIsInvalid("value")
    }
}
r.addRoute("tbx://file/:name") { ctx in
    print("file \(ctx.params["name"] ?? "")")
}
r.addRoute("tbx://long/long/:name/path") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
}
```