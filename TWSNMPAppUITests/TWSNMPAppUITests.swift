//
//  TWSNMPAppUITests.swift
//  TWSNMPAppUITests
//
//  Created by twsnmp on 2020/10/04.
//

import XCTest

class TWSNMPAppUITests: XCTestCase {
  
  override func setUpWithError() throws {
    continueAfterFailure = false
  }
  
  override func tearDownWithError() throws {
  }
  
  func testAddTwsnmp() throws {
    let app = XCUIApplication()
    app.launch()
    let addBtn = app.buttons["addBtn"]
    addBtn.tap()
    let nameTF = app.textFields["nameTextField"]
    let urlTF = app.textFields["urlTextField"]
    let userTF = app.textFields["userTextField"]
    let passwordSTF = app.secureTextFields["passwordSecureField"]
    
    nameTF.tap()
    nameTF.typeText("test2")
    urlTF.tap()
    urlTF.typeText("https://192.168.1.250:8192")
    userTF.tap()
    userTF.typeText("a")
    sleep(1)
    passwordSTF.tap()
    passwordSTF.typeText("a")
    let saveBtn = app.buttons["saveBtn"]
    saveBtn.tap()
  }
  
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
