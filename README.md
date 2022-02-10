# TrieRouter

An App-specific Simple Routing Library


### Usage

```swift
let r = Router()
r.addRoute("tbx://index") { _ in
    print("root")
}
r.addRoute("tbx://intTest/:value") { ctx in
    guard let v = ctx.params.getInt("value") else {
        throw RouterHandleError.paramsIsInvalid("value")
    }
    print("hello \(v)")
}
r.addRoute("tbx://file/:name") { ctx in
    print("file \(ctx.params["name"] ?? "")")
}
r.addRoute("tbx://long/long/:name/path") { ctx in
    print("hello \(ctx.params["name"] ?? "")")
}
```

## Requirements

Swift, iOS 9.0+, maxOS 10.10+


## Installation

FlexLayout is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TrieRouter'
```

## Author

tbxark, tbxark@outlook.com

## License

FlexLayout is available under the MIT license. See the LICENSE file for more info.
