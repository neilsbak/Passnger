//
//  Model.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

class Model: ObservableObject {

    @Published private(set) var passwordItems = [PasswordItem]()

    @Published private(set) var masterPasswords = [MasterPassword]()


    static let masterPasswordsKeychainAccountName = "MasterPasswords"
    static let passwordItemsKeychainAccountName = "PasswordItems"

    func addPasswordItem(_ passwordItem: PasswordItem) {
        passwordItems.append(passwordItem)
        saveModel()
    }

    func addMasterPassword(_ masterPassword: MasterPassword) {
        masterPasswords.append(masterPassword);
        saveModel()
    }

    func removePasswordItem(_ passwordItem: PasswordItem) {
        guard let index = passwordItems.firstIndex(of: passwordItem) else { return }
        removePasswordItems(atOffsets: IndexSet(integer: index))
    }

    func removeMasterPassword(_ masterPassword: MasterPassword) {
        guard let index = masterPasswords.firstIndex(of: masterPassword) else { return }
        removeMasterPasswords(atOffsets: IndexSet(integer: index))
    }

    func removePasswordItems(atOffsets indexSet: IndexSet) {
        passwordItems.remove(atOffsets: indexSet)
        saveModel()
    }

    func removeMasterPasswords(atOffsets indexSet: IndexSet) {
        masterPasswords.remove(atOffsets: indexSet)
        saveModel()
    }

    func saveModel() {
        let masterPasswordsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: Model.masterPasswordsKeychainAccountName, sync: true, passcodeProtected: false)
        let masterPasswordData = try! JSONEncoder().encode(masterPasswords)
        let masterPasswordJson = String(data: masterPasswordData, encoding: .utf8)!
        try! masterPasswordsKeychainItem.savePassword(masterPasswordJson)

        let passwordItemsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: Model.passwordItemsKeychainAccountName, sync: true, passcodeProtected: false)
        let passwordItemData = try! JSONEncoder().encode(passwordItems)
        let passwordItemJson = String(data: passwordItemData, encoding: .utf8)!
        try! passwordItemsKeychainItem.savePassword(passwordItemJson)
    }

    static func loadModel() -> Model {
        let model = Model()

        let masterPasswordsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: masterPasswordsKeychainAccountName, sync: true, passcodeProtected: false)
        guard let masterPasswordsJson = try? masterPasswordsKeychainItem.readPassword() else {
            return model
        }
        model.masterPasswords = (try? JSONDecoder().decode([MasterPassword].self, from: masterPasswordsJson.data(using: .utf8)!)) ?? []

        let passwordItemsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: passwordItemsKeychainAccountName, sync: true, passcodeProtected: false)
        guard let passwordItemsJson = try? passwordItemsKeychainItem.readPassword() else {
            return model
        }
        model.passwordItems = (try? JSONDecoder().decode([PasswordItem].self, from: passwordItemsJson.data(using: .utf8)!)) ?? []

        return model
    }

    static func testModel() -> Model {
        let model = Model()
        model.masterPasswords = [
            MasterPassword(name: "Test 1", password: "asdf", securityLevel: .noSave),
            MasterPassword(name: "Test 2", password: "jklj", securityLevel: .noSave)
        ]
        model.passwordItems = [
            PasswordItem(userName: "neil", masterPassword: model.masterPasswords[0], url: "apple.com", serviceName: "Apple"),
            PasswordItem(userName: "neil123", masterPassword: model.masterPasswords[1], url: "google.com", serviceName: "Google")
        ]
        return model
    }
}
