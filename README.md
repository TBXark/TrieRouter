# TrieRouter

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
pod 'TrieRouter', '~> 1.3.3'
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


## Best Practice

### UIKit

```Swift
// 1. Adding base protocols
typealias RouterContext = Router.Context
typealias RouterNode = Router.Node

protocol NavigatorRegisterType {
    static func urlOpenHandlerFactory(_ context: RouterContext) throws
}

extension NavigatorRegisterType {
    @discardableResult static func register(byRouter router: Router, urlPattern: String) -> RouterNode? {
        return router.addRoute(urlPattern, handler: { ctx in
            try urlOpenHandlerFactory(ctx)
        })
    }
}

protocol ControllerNavigatorRegisterType: NavigatorRegisterType {
    static func viewControllerFactory(_ context: RouterContext) throws -> UIViewController
}

final class ControllerStackService {
    static func open(controller vc: UIViewController, forcePresent: Bool = false) {
        // Implement this function according to your app
    }
}

extension ControllerNavigatorRegisterType {
    static func urlOpenHandlerFactory(_ context: RouterContext) throws {
        let vc = try viewControllerFactory(context)
        var forcePresent = false
        if let ctx = context.context as? JSONElement {
            forcePresent = ctx.forcePresent.boolValue ?? false
        }
        
        ControllerStackService.open(controller: vc, forcePresent: forcePresent) 
    }
}


// 2. UIViewController implements ControllerNavigatorRegisterType.
class UserDetailViewController: UIViewController, ControllerNavigatorRegisterType  {
    let id: Int
    
    init(id: Int) {
        self.id = id
        // ...
    }
    
    // ...
    
    
    // MARK： - ControllerNavigatorRegisterType
    static func viewControllerFactory(_ context: RouterContext) throws -> UIViewController {
        let id = try context.params.getInt("id")
        return UserDetailViewController(id: id)
    }
}


// 3. Initializing Routes
let router = Router()
UserDetailViewController.register(byRouter: router, urlPattern: "example://user/:id")

    
```

## Author

tbxark, [tbxark@outlook.com](mailto:tbxark@outlook.com)

## License

TrieRouter is available under the MIT license. See the LICENSE file for more info.
