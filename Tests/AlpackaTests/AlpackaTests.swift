import XCTest
import Combine
@testable import Alpacka

final class AlpackaTests: XCTestCase {
    typealias Size = Alpacka.Size
    typealias Point = Alpacka.Point
    typealias Section = Alpacka.Section
    struct Thing: Hashable, Sized {
        var size: CGSize
        var packingSize: Alpacka.Size {
            Size(size)
        }
        var origin = CGPoint(x: 0, y: 0)
        var uuid = UUID().uuidString
        func hash(into hasher: inout Hasher) {
            hasher.combine(origin.x)
            hasher.combine(origin.y)
            hasher.combine(uuid)
        }
    }
    var cancellables = Set<AnyCancellable>()
    
    func testBreakOut() {
        let items = [
            Thing(size: CGSize(Size(w: 10, h: 10))),
            Thing(size: CGSize(Size(w: 10, h: 10)))
        ]
        Alpacka.pack(items, origin: \.origin, in: Size(w: 10, h: 10))
            .sink { result in
                switch result {
                case .packed:
                    XCTFail()
                case let .overFlow(itemsThatFit, overFlow: overFlow):
                    XCTAssert(itemsThatFit.count == 1 && itemsThatFit.first! == items.first)
                    XCTAssert(overFlow.count == 1 && overFlow.first! == items[1])
                }
            }
            .store(in: &cancellables)
    }
    
    func testAreaUsed() {
        let section: Section<Thing> = .space(Size(w: 10, h: 10))
        XCTAssert(section.areaUsed() == 0)
        let resultinSection = section.place(Thing(size: CGSize(Size(w: 1, h: 1))))
        XCTAssert(resultinSection.areaUsed() == 1)
    }
    
    func testAsync() {
        let items = generateRandomItems(count: 1000)
        measure {
            completionChecked(100) { exp in
                Alpacka.pack(items, origin: \.origin, in: Size(w: 100, h: 10000))
                    .sink { result in
                        exp.fulfill()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    func testPerformance() {
        let items = generateRandomItems(count: 1000)
        measure {
            completionChecked(100) { exp in
                Alpacka.pack(items, origin: \.origin, in: Size(w: 100, h: 10000))
                    .sink { _ in
                        exp.fulfill()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    func generateRandomItems(count: Int) -> [Thing] {
        var things = [Thing]()
        for _ in 0...count {
            things.append(Thing(size: CGSize(width: Double.random(in: 1...30), height: Double.random(in: 1...30))))
        }
        return things
    }

    static var allTests = [
        ("testBreakOut", testBreakOut),
        ("testAreaUsed", testAreaUsed),
        ("testAsync", testAsync),
        ("testPerformance", testPerformance)
    ]
}
