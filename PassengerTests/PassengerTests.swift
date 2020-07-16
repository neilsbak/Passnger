//
//  PassengerTests.swift
//  PassengerTests
//
//  Created by Neil Bakhle on 2020-07-14.
//  Copyright © 2020 Neil. All rights reserved.
//

import XCTest
@testable import Passenger

class PassengerTests: XCTestCase {

    static let keychainService = "com.nbakhle.passengertests"

    var model: Model!

    override func setUpWithError() throws {
        // this creates an empty model
        model = Model(keychainService: PassengerTests.keychainService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        model.removePasswordItem(passwordItem)
        model.saveModel()
    }

    var passwordItem: PasswordItem {
        let masterPassword = MasterPassword(name: "TestPassword", password: "test", securityLevel: .noSave)
        let passwordItem = PasswordItem(userName: "tester", masterPassword: masterPassword, url: "test.com", serviceName: "Test Service")
        return passwordItem
    }

    func testAddPassword() throws {
        model.addPasswordItem(passwordItem)
        XCTAssert(model.passwordItems[0].userName == "tester")
        model.saveModel()
        XCTAssert(model.passwordItems[0].userName == "tester")
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.passwordItems[0].userName == "tester")
    }

    func testRemovePassword() throws {
        model.addPasswordItem(passwordItem)
        model.removePasswordItem(passwordItem)
        XCTAssert(model.passwordItems.count == 0)
        model.saveModel()
        XCTAssert(model.passwordItems.count == 0)
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.passwordItems.count == 0)
    }

    func testAddMasterPassword() throws {

    }

    func testRemoveMasterPassword() throws {

    }

    func testMasterPasswordDoubleHashing() throws {

    }

    
}
