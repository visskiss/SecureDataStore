import XCTest
@testable import SecureDataStore

final class SecureDataStoreTests: XCTestCase {
    
    
    func test1 () {
        let sel = "asdifuhiuheaw".data(using: .utf8)!
        let data = String("Test").data(using: .utf8)!
        let digest = data.HSHA(key: sel)
        print (digest.hex())
        let sel2 = "osdafouoaew".data(using: .utf8)!
        let data2 = String("Test").data(using: .utf8)!
        let digest2 = data2.HSHA(key: sel2)
        print (digest2.hex())
        XCTAssert(digest != digest2)
    }
    
}
