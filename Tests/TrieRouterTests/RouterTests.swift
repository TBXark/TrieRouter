import XCTest
@testable import TrieRouter

final class RouterTests: XCTestCase {
    func testExample() throws {
        let r = Router()
        var allCase = [String]()
        do {
            let tc = "tbx://index"
            r.addRoute("tbx://index") { ctx in
                XCTAssertEqual(ctx.url.absoluteString, tc)
            }
            allCase.append(tc)
        }
        
        do {
            let tc = "tbx://intTest/123"
            r.addRoute("tbx://intTest/:value") { ctx in
                let v = try ctx.params.getInt("value")
                XCTAssertEqual(v, 123)
            }
            allCase.append(tc)
        }
        
       
        do {
            let tc = "tbx://file/img/banner.png?size=123"
            r.addRoute("tbx://file/*name") { ctx in
                let v = try ctx.params.getString("name")
                XCTAssertEqual(v, "img/banner.png")
            }
            allCase.append(tc)
        }
        
        do {
            let tc = "tbx://long/long/long/path"
            r.addRoute("tbx://long/long/:name/path") { ctx in
                let v = try ctx.params.getString("name")
                XCTAssertEqual(v, "long")
            }
            allCase.append(tc)
        }
    
        do {
            let tc = "tbx://two/parms/123/and/abc"
            r.addRoute("tbx://two/parms/:first/and/:second") { ctx in
                let f = try ctx.params.getInt("first")
                let s = try ctx.params.getString("second")
                XCTAssertEqual(f, 123)
                XCTAssertEqual(s, "abc")
            }
            allCase.append(tc)
        }
        
        for c in allCase {
            try r.handle(c)
        }
        
        r.printAllNodes()

    }
}
