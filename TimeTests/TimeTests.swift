//
//  TimeTests.swift
//  TimeTests
//
//  Created by A on 10/07/2024.
//

import XCTest
@testable import Time

final class TimeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testRadixTransform() throws {
        // Test case 1: 100000 seconds
        let seconds1 = 100000
        let expected1 = [1, 3, 46, 40] // 1 day, 3 hours, 46 minutes, 40 seconds
        let result1 = RadixTransform(source: seconds1, radices: [60, 60, 24])
        XCTAssertEqual(result1, expected1, "RadixTransform did not return the expected result for 100000 seconds")

        // Test case 2: 86400 seconds (exactly 1 day)
        let seconds2 = 86400
        let expected2 = [1, 0, 0, 0] // 1 day, 0 hours, 0 minutes, 0 seconds
        let result2 = RadixTransform(source: seconds2, radices: [60, 60, 24])
        XCTAssertEqual(result2, expected2, "RadixTransform did not return the expected result for 86400 seconds")

        // Test case 3: 3661 seconds (1 hour, 1 minute, 1 second)
        let seconds3 = 3661
        let expected3 = [0, 1, 1, 1] // 0 days, 1 hour, 1 minute, 1 second
        let result3 = RadixTransform(source: seconds3, radices: [60, 60, 24])
        XCTAssertEqual(result3, expected3, "RadixTransform did not return the expected result for 3661 seconds")

        // Test case 4: 0 seconds
        let seconds4 = 0
        let expected4 = [0, 0, 0, 0] // 0 days, 0 hours, 0 minutes, 0 seconds
        let result4 = RadixTransform(source: seconds4, radices: [60, 60, 24])
        XCTAssertEqual(result4, expected4, "RadixTransform did not return the expected result for 0 seconds")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
            _ = RadixTransform(source: 100000, radices: [60, 60, 24])
        }
    }

}
