import XCTest
@testable import FileHelper

final class FileHelperTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FileHelper().text, "Hello, World!")
    }
}
