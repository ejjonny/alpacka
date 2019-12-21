import XCTest
@testable import Alpacka

final class AlpackaTests: XCTestCase {
    var packer = Alpacka.Packer<Thing>()
    
    func testBreakOut() {
        let items = [
            Thing(packingSize: Size(w: 10, h: 10).cgSize),
            Thing(packingSize: Size(w: 10, h: 10).cgSize)
        ]
        let result = packer.pack(items, origin: \.origin, in: Size(w: 10, h: 10).cgSize)
        switch result {
        case .success:
            XCTFail()
        case let .overFlow(itemsThatFit, overFlow: overFlow):
            XCTAssert(itemsThatFit.count == 1 && itemsThatFit.first! == items.first)
            XCTAssert(overFlow.count == 1 && overFlow.first! == items[1])
        }
    }
    
    func testAreaUsed() {
        let section: Section<Thing> = .space(Size(w: 10, h: 10))
        XCTAssert(section.areaUsed() == 0)
        let resultinSection = section.place(Thing(packingSize: Size(w: 1, h: 1).cgSize))
        XCTAssert(resultinSection.areaUsed() == 1)
    }
    
    func testAsync() {
        let items = generateRandomItems(count: 1000)
        measure {
            completionChecked(100) { exp in
                packer.pack(items, origin: \.origin, in: CGSize(width: 100, height: 10000), qos: .background) { result in
                    exp.fulfill()
                }
            }
        }
    }
    
    func testPerformance() {
        let items = generateRandomItems(count: 1000)
        measure {
            packer.pack(items, origin: \.origin, in: CGSize(width: 100, height: 10000))
        }
    }
    
    func generateRandomItems(count: Int) -> [Thing] {
        var things = [Thing]()
        for _ in 0...count {
            things.append(Thing(packingSize: CGSize(width: Double.random(in: 1...30), height: Double.random(in: 1...30))))
        }
        return things
    }
    
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

    static var allTests = [
        ("testBreakOut", testBreakOut),
        ("testAreaUsed", testAreaUsed),
        ("testAsync", testAsync),
        ("testPerformance", testPerformance)
    ]
}
