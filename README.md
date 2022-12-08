## TrieRouter

TrieRouter is a URL router implemented in Swift, that uses a trie data structure to store and match URL patterns. It supports URL parameters and wildcards.

## Features

-  Support parsing URLs with path and query parameters
-  Support wildcard pattern matching for paths
-  Support for adding, searching, and printing all registered routes
-  Type-safe and intuitive API

## Requirements

- Swift 5.1+
- iOS 8.0+
- macOS 10.10+

## Installation

#### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/tbxark/TrieRouter.git", .upToNextMajor(from: "1.3.3"))
]
```

#### CocoaPods

```ruby
pod 'TrieRouter', '~> 7.0'
```

### 

## Usage

Here's an example of how to use TrieRouter in your code:

```swift
let router = Router()
router.addRoute("example://index") { _ in
    print("root")
}
router.addRoute("example://intTest/:value") { ctx in
    let v = try ctx.params.getInt("value")
    print("hello \(v)")
}
router.addRoute("example://file/*name") { ctx in
    let name = try ctx.params.getString("name")
    print("file \(name)")
}
router.addRoute("example://long/long/:name/path") { ctx in
    let name = try ctx.params.getString("name")
    print("hello \(name)")
}
```

## Author

tbxark, [tbxark@outlook.com](mailto:tbxark@outlook.com)

## License

TrieRouter is available under the MIT license. See the LICENSE file for more info.
