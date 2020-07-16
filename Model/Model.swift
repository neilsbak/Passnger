//
//  Model.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

public class Model: ObservableObject {

    private static func passwordKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.masterPasswordsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    private static func masterKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.passwordItemsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    let passwordKeychainItem: KeychainPasswordItem
    let masterKeychainItem: KeychainPasswordItem

    init(keychainService: String = PassengerKeychainItem.service) {
        passwordKeychainItem = Model.passwordKeychainItem(keychainService: keychainService)
        masterKeychainItem = Model.masterKeychainItem(keychainService: keychainService)
    }

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
        let masterPasswordData = try! JSONEncoder().encode(masterPasswords)
        let masterPasswordJson = String(data: masterPasswordData, encoding: .utf8)!
        try! masterKeychainItem.savePassword(masterPasswordJson)

        let passwordItemData = try! JSONEncoder().encode(passwordItems)
        let passwordItemJson = String(data: passwordItemData, encoding: .utf8)!
        try! passwordKeychainItem.savePassword(passwordItemJson)
    }

    static func loadModel(keychainService: String = PassengerKeychainItem.service) -> Model {
        let model = Model(keychainService: keychainService)

        let masterPasswordsKeychainItem = Model.masterKeychainItem(keychainService: keychainService)
        guard let masterPasswordsJson = try? masterPasswordsKeychainItem.readPassword() else {
            return model
        }
        model.masterPasswords = (try? JSONDecoder().decode([MasterPassword].self, from: masterPasswordsJson.data(using: .utf8)!)) ?? []

        let passwordItemsKeychainItem = Model.passwordKeychainItem(keychainService: keychainService)
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
