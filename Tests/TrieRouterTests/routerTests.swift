import XCTest
@testable import TrieRouter

final class routerTests: XCTestCase {
    func testExample() throws {
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
        XCTAssert(r.handle("tbx://index"))
        XCTAssert(r.handle("tbx://hello/world"))
        XCTAssert(r.handle("tbx://file/image.jpg"))
        XCTAssert(r.handle("tbx://long/long/world/path"))
    }
}
