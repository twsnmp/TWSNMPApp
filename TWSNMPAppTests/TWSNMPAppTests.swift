//
//  TWSNMPAppTests.swift
//  TWSNMPAppTests
//
//  Created by twsnmp on 2020/10/04.
//

import XCTest
@testable import TWSNMPApp

class TWSNMPAppTests: XCTestCase {
  let d = TwsnmpDataStore()
  
  override func setUpWithError() throws {
    let twsnmp = Twsnmp(name:"test", url: "https://192.168.1.250:8192", user: "a", password: "a")
    d.add(twsnmp: twsnmp)
  }
  
  override func tearDownWithError() throws {
    while d.twsnmps.count > 0 {
      d.delete(at: 0)
    }
  }

  func testDataStore() throws {
    XCTAssertEqual(d.twsnmps.count,1)
    let twsnmp = Twsnmp(name:"test1", url: "https://192.168.1.250:8192", user: "a", password: "a")
    d.add(twsnmp: twsnmp)
    XCTAssertEqual(d.twsnmps.count,2)
    XCTAssertEqual(d.twsnmps[1].name,"test1")
    if var t = d.find(id: d.twsnmps[1].id.uuidString) {
      t.name = "test2"
      d.update(id:t.id.uuidString,twsnmp:t)
      XCTAssertEqual(d.twsnmps[1].name,"test2")
    } else {
      XCTAssert(false)
    }
    d.delete(at: 1)
    XCTAssertEqual(d.twsnmps.count,1)
  }

  func testGetMapStatus() throws {
    let exp = expectation(description: "Wait TWSNMP")
    d.getMapStatus(id: d.twsnmps[0].id.uuidString){ r in
      XCTAssertEqual(r,true)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 10.0)
  }

  func testGetMapData() throws {
    let exp = expectation(description: "Wait TWSNMP")
    d.getMapData(id: d.twsnmps[0].id.uuidString){ r in
      XCTAssertEqual(r,true)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 10.0)
  }

  func testPerformanceGetMapStatus() throws {
    self.measure {
      let exp = expectation(description: "Wait TWSNMP")
      d.getMapStatus(id: d.twsnmps[0].id.uuidString){ r in
        XCTAssertEqual(r,true)
        exp.fulfill()
      }
      wait(for: [exp], timeout: 10.0)
    }
  }

}
