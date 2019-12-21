import XCTest
@testable import Alpacka

final class AlpackaTests: XCTestCase {
    struct Thing: Hashable, Sized {
        var packingSize: CGSize
        var origin = CGPoint(x: 0, y: 0)
        var uuid = UUID().uuidString
        func hash(into hasher: inout Hasher) {
            hasher.combine(origin.x)
            hasher.combine(origin.y)
            hasher.combine(uuid)
        }
    }
    var packer = Alpacka.Packer<Thing>()
    
    func testBreakOut() {
        var items = [
            Thing(packingSize: Size(w: 10, h: 10).cgSize),
            Thing(packingSize: Size(w: 10, h: 10).cgSize)
        ]
        packer.pack(&items, origin: \.origin, in: Size(w: 10, h: 10).cgSize)
        XCTAssert(items.count == 1)
    }
    
    func testAreaUsed() {
        let section: Section<Thing> = .space(Size(w: 10, h: 10))
        XCTAssert(section.areaUsed() == 0)
        let resultinSection = section.place(Thing(packingSize: Size(w: 1, h: 1).cgSize))
        XCTAssert(resultinSection.areaUsed() == 1)
    }

    static var allTests = [
        ("testBreakOut", testBreakOut),
        ("testAreaUsed", testAreaUsed)
    ]
}
