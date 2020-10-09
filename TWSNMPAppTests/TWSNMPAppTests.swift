//
//  TWSNMPAppTests.swift
//  TWSNMPAppTests
//
//  Created by twsnmp on 2020/10/04.
//

import XCTest
@testable import TWSNMPApp

class TWSNMPAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetMapStatus() throws {
      let exp = expectation(description: "Wait TWSNMP")
      let d = TwsnmpDataStore()
      let twsnmp = Twsnmp(name:"test", url: "https://192.168.1.250:8192", user: "a", password: "a")
      d.add(twsnmp: twsnmp)
      d.getMapStatus(id: twsnmp.id.uuidString){ r in
        XCTAssertEqual(r,true)
        exp.fulfill()
      }
      wait(for: [exp], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
