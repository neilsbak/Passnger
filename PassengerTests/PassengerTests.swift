//
//  PassengerTests.swift
//  PassengerTests
//
//  Created by Neil Bakhle on 2020-07-14.
//  Copyright © 2020 Neil. All rights reserved.
//

import XCTest
import CryptoKit
@testable import Passenger

class PassengerTests: XCTestCase {

    static let keychainService = "com.nbakhle.passengertests"
    static let masterPassword = "masterpassword"

    var model: Model!

    override func setUpWithError() throws {
        // this creates an empty model
        model = Model(keychainService: PassengerTests.keychainService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let items = try! KeychainPasswordItem.passwordItems(forService: PassengerTests.keychainService)
        print("ITEMS: \(items)")
        for item in items {
            try! item.deleteItem()
        }
        let items2 = try! KeychainPasswordItem.passwordItems(forService: PassengerTests.keychainService)
        print("ITEMS: \(items2)")
    }

    func getPasswordItem(securityLevel: MasterPassword.SecurityLevel) -> PasswordItem {
        let masterPassword = MasterPassword(name: "TestPassword", password: PassengerTests.masterPassword, securityLevel: securityLevel, keychainService: PassengerTests.keychainService)
        let passwordItem = PasswordItem(userName: "tester", masterPassword: masterPassword, url: "test.com", serviceName: "Test Service", keychainService: PassengerTests.keychainService)
        return passwordItem
    }

    func testAddPassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        model.addPasswordItem(passwordItem)
        XCTAssert(model.passwordItems[0].userName == "tester")
        model.saveModel()
        XCTAssert(model.passwordItems[0].userName == "tester")
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.passwordItems[0].userName == "tester")
    }

    func testRemovePassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
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

    //simulates loading a passwordItem from disk
    func copyPasswordItem(_ passwordItem: PasswordItem) -> PasswordItem {
        return PasswordItem(userName: passwordItem.userName, masterPassword: MasterPassword(name: passwordItem.masterPassword.name, securityLevel: passwordItem.masterPassword.securityLevel, doubleHashedPassword: passwordItem.masterPassword.doubleHashedPassword, keychainService: PassengerTests.keychainService), url: passwordItem.url, serviceName: passwordItem.serviceName, keychainService: passwordItem.keychainService)
    }

    func genPassword(passwordItem: PasswordItem, masterPassword: String) -> String {
        let hashedMasterPassword = Data(SHA256.hash(data: Data(masterPassword.utf8))).base64EncodedString()
        return PasswordGenerator.genPassword(phrase: hashedMasterPassword + passwordItem.userName + passwordItem.url)
    }

    func testSavedPasswordItem() throws {
        let masterPasswordText = PassengerTests.masterPassword
        let hashedMasterPassword = MasterPassword.hashPassword(masterPasswordText)
        let passwordItem = getPasswordItem(securityLevel: .save)
        passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword)
        // this will load the master password from memory
        assert(try! passwordItem.getPassword() == genPassword(passwordItem: passwordItem, masterPassword: masterPasswordText))
        let passwordItemCopy = copyPasswordItem(passwordItem)
        // this will load the master password from keychain
        assert(try! passwordItemCopy.getPassword() == genPassword(passwordItem: passwordItemCopy, masterPassword: masterPasswordText))
    }


    func testMultipleServiceAccountPasswordItems() throws {

    }

    func testGeneratedPassword() throws {

    }
}
