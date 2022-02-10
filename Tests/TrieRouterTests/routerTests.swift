import XCTest
@testable import TrieRouter

final class routerTests: XCTestCase {
    func testExample() throws {
        let r = Router()
        r.addRoute("tbx://index") { _ in
            print("root")
        }
        r.addRoute("tbx://intTest/:value") { ctx in
            let v = try ctx.params.getInt("value")
            print("hello \(v)")
        }
        r.addRoute("tbx://file/:name") { ctx in
            print("file \(ctx.params["name"] ?? "")")
        }
        r.addRoute("tbx://long/long/:name/path") { ctx in
            print("hello \(ctx.params["name"] ?? "")")
        }
        r.addRoute("http://*path") { ctx in
            print("http \(ctx.url)")
        }
        r.addRoute("https://*path") { ctx in
            print("https \(ctx.url)")
        }
        r.addRoute("tbx://two/parms/:first/and/:second") { ctx in
            print("two parms \(ctx.params)")
        }
        r.printAllNodes()
        XCTAssert(r.handle("tbx://index"))
        XCTAssert(r.handle("tbx://intTest/123"))
        XCTAssert(r.handle("tbx://file/image.jpg"))
        XCTAssert(r.handle("tbx://long/long/world/path"))
        XCTAssert(r.handle("tbx://two/parms/1234/and/five"))
        XCTAssert(r.handle("http://github.com/TBXark/TrieRouter"))
        XCTAssert(r.handle("https://github.com/TBXark/TrieRouter"))

    }
}
