//
//  PassngerTests.swift
//  PassngerTests
//
//  Created by Neil Bakhle on 2020-07-14.
//  Copyright © 2020 Neil. All rights reserved.
//

import XCTest
import CryptoKit
@testable import Passnger

class PassngerTests: XCTestCase {

    static let keychainService = "PassngerTest"
    static let masterPassword = "masterpassword"
    static var hashedMasterPassword: String { MasterPassword.hashPassword(masterPassword) }

    var model: Model!

    override func setUpWithError() throws {
        // this creates an empty model
        model = Model(keychainService: PassngerTests.keychainService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let items = try! KeychainPasswordItem.passwordItems(forService: PassngerTests.keychainService)
        for item in items {
            try! item.deleteItem()
        }
    }

    func getMasterPassword(securityLevel: MasterPassword.SecurityLevel) -> MasterPassword {
        return MasterPassword(name: "TestPassword", password: PassngerTests.masterPassword, securityLevel: securityLevel)
    }

    func getPasswordItem(securityLevel: MasterPassword.SecurityLevel) -> PasswordItem {
        let masterPassword = getMasterPassword(securityLevel: securityLevel)
        let passwordItem = PasswordItem(userName: "tester", masterPassword: masterPassword, url: "test.com", resourceDescription: "Test Service", passwordScheme: PasswordScheme())
        return passwordItem
    }

    func getMasterPassword2(securityLevel: MasterPassword.SecurityLevel) -> MasterPassword {
        return MasterPassword(name: "TestPassword2", password: PassngerTests.masterPassword, securityLevel: securityLevel)
    }

    func getPasswordItem2(securityLevel: MasterPassword.SecurityLevel) -> PasswordItem {
        let masterPassword = getMasterPassword(securityLevel: securityLevel)
        let passwordItem = PasswordItem(userName: "tester2", masterPassword: masterPassword, url: "test.com", resourceDescription: "Test Service", passwordScheme: PasswordScheme())
        return passwordItem
    }


    func testAddPassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        let passwordItem2 = getPasswordItem2(securityLevel: .noSave)
        let expectation = XCTestExpectation(description: "Generating password")
        model.addPasswordItem(passwordItem, hashedMasterPassword: PassngerTests.hashedMasterPassword) { [self] _ in
            XCTAssert(model.passwordItems[0].userName == "tester")
            model.addPasswordItem(passwordItem2, hashedMasterPassword: PassngerTests.hashedMasterPassword) { [self] _ in
                XCTAssert(model.passwordItems[0].userName == "tester" && model.passwordItems[1].userName == "tester2" && model.passwordItems.count == 2)
                model.saveModel()
                XCTAssert(model.passwordItems[0].userName == "tester" && model.passwordItems.count == 2)
                let loadedModel = Model.loadModel(keychainService: PassngerTests.keychainService)
                XCTAssert(loadedModel.passwordItems[0].userName == "tester")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testUpdatePassword() throws {
        let expectation = XCTestExpectation(description: "Generating password")
        model.addPasswordItem(getPasswordItem(securityLevel: .noSave), hashedMasterPassword: PassngerTests.hashedMasterPassword) { [self] _ in
            var passwordItem = getPasswordItem2(securityLevel: .noSave)
            XCTAssert(passwordItem.numRenewals == 0)
            model.addPasswordItem(passwordItem, hashedMasterPassword: PassngerTests.hashedMasterPassword){ [self] _ in
                passwordItem.numRenewals = 1
                model.addPasswordItem(passwordItem, hashedMasterPassword: PassngerTests.hashedMasterPassword){ [self] _ in
                    XCTAssert(model.passwordItems.count == 2)
                    XCTAssert(model.passwordItems[1].numRenewals == 1)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testRemovePassword() throws {
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        let passwordItem2 = getPasswordItem2(securityLevel: .noSave)
        let expectation = XCTestExpectation(description: "Generating password")
        model.addPasswordItem(passwordItem, hashedMasterPassword: PassngerTests.hashedMasterPassword) { [self] _ in
            model.addPasswordItem(passwordItem2, hashedMasterPassword: PassngerTests.hashedMasterPassword) { [self] _ in
                model.removePasswordItem(passwordItem2)
                XCTAssert(model.passwordItems.count == 1 && model.passwordItems[0].userName == "tester")
                model.removePasswordItem(passwordItem)
                XCTAssert(model.passwordItems.count == 0)
                model.saveModel()
                XCTAssert(model.passwordItems.count == 0)
                let loadedModel = Model.loadModel(keychainService: PassngerTests.keychainService)
                XCTAssert(loadedModel.passwordItems.count == 0)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAddMasterPassword() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        let masterPassword2 = getMasterPassword2(securityLevel: .noSave)
        model.addMasterPassword(masterPassword, passwordText: PassngerTests.masterPassword)
        XCTAssert(model.masterPasswords[0].name == "TestPassword")
        model.addMasterPassword(masterPassword2, passwordText: PassngerTests.masterPassword)
        XCTAssert(model.masterPasswords[0].name == "TestPassword" && model.masterPasswords[1].name == "TestPassword2" && model.masterPasswords.count == 2)
        model.saveModel()
        XCTAssert(model.masterPasswords[0].name == "TestPassword")
        let loadedModel = Model.loadModel(keychainService: PassngerTests.keychainService)
        XCTAssert(loadedModel.masterPasswords[0].name == "TestPassword" && loadedModel.masterPasswords.count == 2)
    }

    func testRemoveMasterPassword() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        let masterPassword2 = getMasterPassword2(securityLevel: .noSave)
        model.addMasterPassword(masterPassword, passwordText: PassngerTests.masterPassword)
        model.addMasterPassword(masterPassword2, passwordText: PassngerTests.masterPassword)
        model.removeMasterPassword(masterPassword2)
        XCTAssert(model.masterPasswords.count == 1 && model.masterPasswords[0].name == "TestPassword")
        model.removeMasterPassword(masterPassword)
        XCTAssert(model.masterPasswords.count == 0)
        model.saveModel()
        XCTAssert(model.masterPasswords.count == 0)
        let loadedModel = Model.loadModel(keychainService: PassngerTests.keychainService)
        XCTAssert(loadedModel.masterPasswords.count == 0)
    }

    func testMasterPasswordDoubleHashing() throws {
        let masterPassword = getMasterPassword(securityLevel: .noSave)
        XCTAssert(masterPassword.doubleHashedPassword == "ilRa7Wjelqioy9Yuiay7cn6wUvp8eNT0Z7m2KpuKgqw=")
    }

    func genPassword(passwordItem: PasswordItem, masterPassword: String) -> String {
        let hashedMasterPassword = Data(SHA256.hash(data: Data(masterPassword.utf8))).base64EncodedString()
        return try! PasswordGenerator.genPassword(phrase: hashedMasterPassword + passwordItem.userName + passwordItem.url + String(passwordItem.numRenewals), scheme: PasswordScheme(passwordLength: passwordItem.passwordLength, symbols: passwordItem.symbols, minSymbols: passwordItem.minSymbols, minLowerCase: passwordItem.minLowerCase, minUpperCase: passwordItem.minUpperCase, minNumeric: passwordItem.minNumeric))
    }

    func testGetSavedPasswordItem() throws {
        let masterPasswordText = PassngerTests.masterPassword
        let hashedMasterPassword = MasterPassword.hashPassword(masterPasswordText)
        let passwordItem = getPasswordItem(securityLevel: .save)
        var masterPasswordItem = passwordItem.masterPassword
        // simulate the user entering master password and the system saving it
        try! masterPasswordItem.savePassword(PassngerTests.masterPassword, keychainService: PassngerTests.keychainService)
        try! passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword, keychainService: PassngerTests.keychainService)
        // this will load the master password from memory
        print(try! passwordItem.getPassword(keychainService: PassngerTests.keychainService))
        XCTAssert(try! passwordItem.getPassword(keychainService: PassngerTests.keychainService) == .value(genPassword(passwordItem: passwordItem, masterPassword: masterPasswordText)))
        // simulate loading passwordItem from disk when restarting app
        let passwordItemCopy = getPasswordItem(securityLevel: .save)
        // this will load the master password from keychain
        XCTAssert(try! passwordItemCopy.getPassword(keychainService: PassngerTests.keychainService) == .value(genPassword(passwordItem: passwordItemCopy, masterPassword: masterPasswordText)))
    }

    func testGetUnsavedPasswordItem() throws {
        let masterPasswordText = PassngerTests.masterPassword
        let hashedMasterPassword = MasterPassword.hashPassword(masterPasswordText)
        let passwordItem = getPasswordItem(securityLevel: .noSave)
        try! passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword, keychainService: PassngerTests.keychainService)
        // this will try to load the master password from memory but it can't
        XCTAssert(try! passwordItem.getPassword(keychainService: PassngerTests.keychainService) == .value(nil))
        // simulate loading passwordItem from disk when restarting app
        let passwordItemCopy = getPasswordItem(securityLevel: .noSave)
        // this will load the master password from keychain
        XCTAssert(try! passwordItemCopy.getPassword(keychainService: PassngerTests.keychainService) == .value(nil))
    }

    func testGeneratedPassword() throws {
        XCTAssert(try! PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme()) == "G08OmFG?G@jnMgeF")
        XCTAssert(try! PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme(passwordLength: 8)) == "G08OmFG?")
        XCTAssert(try! PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme(passwordLength: 7)) == "$DA64iu")
        XCTAssert((try? PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme(passwordLength: 7, symbols: "!", minSymbols: 2, minLowerCase: 2, minUpperCase: 2, minNumeric: 2))) == nil)
        XCTAssert((try? PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme(passwordLength: 7, symbols: "", minSymbols: 1, minLowerCase: 2, minUpperCase: 2, minNumeric: 2))) == nil)
        XCTAssert((try! PasswordGenerator.genPassword(phrase: "test", scheme: PasswordScheme(passwordLength: 8, symbols: "", minSymbols: 0, minLowerCase: 7, minUpperCase: 0, minNumeric: 0))) == "zvrvdm3m")
    }
}
