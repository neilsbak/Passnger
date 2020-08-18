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
        for item in items {
            try! item.deleteItem()
        }
    }

    func getMasterPassword(securityLevel: MasterPassword.SecurityLevel) -> MasterPassword {
        return MasterPassword(name: "TestPassword", password: PassengerTests.masterPassword, securityLevel: securityLevel, keychainService: PassengerTests.keychainService)
    }

    func getPasswordItem(securityLevel: MasterPassword.SecurityLevel) -> PasswordItem {
        let masterPassword = getMasterPassword(securityLevel: securityLevel)
        let passwordItem = PasswordItem(userName: "tester", masterPassword: masterPassword, url: "test.com", resourceDescription: "Test Service", keychainService: PassengerTests.keychainService)
        return passwordItem
    }

    func getMasterPassword2(securityLevel: MasterPassword.SecurityLevel) -> MasterPassword {
        return MasterPassword(name: "TestPassword2", password: PassengerTests.masterPassword, securityLevel: securityLevel, keychainService: PassengerTests.keychainService)
    }

    func getPasswordItem2(securityLevel: MasterPassword.SecurityLevel) -> PasswordItem {
        let masterPassword = getMasterPassword(securityLevel: securityLevel)
        let passwordItem = PasswordItem(userName: "tester2", masterPassword: masterPassword, url: "test.com", resourceDescription: "Test Service", keychainService: PassengerTests.keychainService)
        return passwordItem
    }


    func testAddPassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        let passwordItem2 = getPasswordItem2(securityLevel: .noSave)
        model.addPasswordItem(passwordItem)
        XCTAssert(model.passwordItems[0].userName == "tester")
        model.addPasswordItem(passwordItem2)
        XCTAssert(model.passwordItems[0].userName == "tester" && model.passwordItems[1].userName == "tester2" && model.passwordItems.count == 2)
        model.saveModel()
        XCTAssert(model.passwordItems[0].userName == "tester" && model.passwordItems.count == 2)
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.passwordItems[0].userName == "tester")
    }

    func testUpdatePassword() throws {
        model.addPasswordItem(getPasswordItem(securityLevel: .noSave))
        var passwordItem = getPasswordItem2(securityLevel: .noSave)
        XCTAssert(passwordItem.numRenewals == 0)
        model.addPasswordItem(passwordItem)
        passwordItem.numRenewals = 1
        model.addPasswordItem(passwordItem)
        XCTAssert(model.passwordItems.count == 2)
        XCTAssert(model.passwordItems[1].numRenewals == 1)
    }

    func testRemovePassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        let passwordItem2 = getPasswordItem2(securityLevel: .noSave)
        model.addPasswordItem(passwordItem)
        model.addPasswordItem(passwordItem2)
        model.removePasswordItem(passwordItem2)
        XCTAssert(model.passwordItems.count == 1 && model.passwordItems[0].userName == "tester")
        model.removePasswordItem(passwordItem)
        XCTAssert(model.passwordItems.count == 0)
        model.saveModel()
        XCTAssert(model.passwordItems.count == 0)
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.passwordItems.count == 0)
    }

    func testAddMasterPassword() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        let masterPassword2 = getMasterPassword2(securityLevel: .noSave)
        model.addMasterPassword(masterPassword)
        XCTAssert(model.masterPasswords[0].name == "TestPassword")
        model.addMasterPassword(masterPassword2)
        XCTAssert(model.masterPasswords[0].name == "TestPassword" && model.masterPasswords[1].name == "TestPassword2" && model.masterPasswords.count == 2)
        model.saveModel()
        XCTAssert(model.masterPasswords[0].name == "TestPassword")
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.masterPasswords[0].name == "TestPassword" && loadedModel.masterPasswords.count == 2)
    }

    func testRemoveMasterPassword() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        let masterPassword2 = getMasterPassword2(securityLevel: .noSave)
        model.addMasterPassword(masterPassword)
        model.addMasterPassword(masterPassword2)
        model.removeMasterPassword(masterPassword2)
        XCTAssert(model.masterPasswords.count == 1 && model.masterPasswords[0].name == "TestPassword")
        model.removeMasterPassword(masterPassword)
        XCTAssert(model.masterPasswords.count == 0)
        model.saveModel()
        XCTAssert(model.masterPasswords.count == 0)
        let loadedModel = Model.loadModel(keychainService: PassengerTests.keychainService)
        XCTAssert(loadedModel.masterPasswords.count == 0)
    }

    func testMasterPasswordDoubleHashing() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        XCTAssert(masterPassword.doubleHashedPassword == "ilRa7Wjelqioy9Yuiay7cn6wUvp8eNT0Z7m2KpuKgqw=")
    }

    func genPassword(passwordItem: PasswordItem, masterPassword: String) -> String {
        let hashedMasterPassword = Data(SHA256.hash(data: Data(masterPassword.utf8))).base64EncodedString()
        return try! PasswordGenerator.genPassword(phrase: hashedMasterPassword + passwordItem.userName + passwordItem.url)
    }

    func testGetSavedPasswordItem() throws {
        let masterPasswordText = PassengerTests.masterPassword
        let hashedMasterPassword = MasterPassword.hashPassword(masterPasswordText)
        let passwordItem = getPasswordItem(securityLevel: .save)
        passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword)
        // this will load the master password from memory
        XCTAssert(try! passwordItem.getPassword() == genPassword(passwordItem: passwordItem, masterPassword: masterPasswordText))
        // simulate loading passwordItem from disk when restarting app
        let passwordItemCopy = getPasswordItem(securityLevel: .save)
        // this will load the master password from keychain
        XCTAssert(try! passwordItemCopy.getPassword() == genPassword(passwordItem: passwordItemCopy, masterPassword: masterPasswordText))
    }

    func testGetUnsavedPasswordItem() throws {
        let masterPasswordText = PassengerTests.masterPassword
        let hashedMasterPassword = MasterPassword.hashPassword(masterPasswordText)
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword)
        // this will try to load the master password from memory but it can't
        XCTAssert(try! passwordItem.getPassword() == nil)
        // simulate loading passwordItem from disk when restarting app
        let passwordItemCopy = getPasswordItem(securityLevel: .noSave)
        // this will load the master password from keychain
        XCTAssert(try! passwordItemCopy.getPassword() == nil)
    }

    func testGeneratedPassword() throws {
        let charCounts: [CharacterType: Int] = [
            .lowerCase: 2,
            .upperCase: 2,
            .symbol: 2,
            .number: 2
        ]
        XCTAssert(try! PasswordGenerator.genPassword(phrase: "test", length: 16, characterCounts: charCounts) == "WQyfh##+Q1g+34up")
        XCTAssert(try! PasswordGenerator.genPassword(phrase: "test", length: 4, characterCounts: [.lowerCase: 4]) == "zvrv")
    }
}
