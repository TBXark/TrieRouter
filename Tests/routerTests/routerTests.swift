import XCTest
@testable import router

final class routerTests: XCTestCase {
    func testExample() throws {
        let r = Router()
        r.addRoute(urlString: "tbx://index"){ _ in
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
        XCTAssert(r.handle(urlString: "tbx://index"))
        XCTAssert(r.handle(urlString: "tbx://hello/world"))
        XCTAssert(r.handle(urlString: "tbx://file/image.jpg"))
    }
}
