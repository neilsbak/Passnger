//
//  Model.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import Combine

public class Model: ObservableObject {

    static let masterPasswordsKeychainAccountName = "MasterPasswords"
    static let passwordItemsKeychainAccountName = "PasswordItems"

    private static func passwordKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.passwordItemsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    private static func masterKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.masterPasswordsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    let passwordKeychainItem: KeychainPasswordItem
    let masterKeychainItem: KeychainPasswordItem
    @Published private(set) var passwordItems = [PasswordItem]()
    @Published private(set) var masterPasswords = [MasterPassword]()
    @Published var searchText: String = ""
    @Published private(set) var shownPasswordItems = [PasswordItem]()
    private var shownPasswordItemsCancellable: Cancellable? = nil
    private var shownSelectedPasswordCancellable: Cancellable? = nil

    private var shownPasswordItemsPublisher: AnyPublisher<[PasswordItem], Never> {
        Publishers.CombineLatest($passwordItems, $searchText)
        .debounce(for: 0.2, scheduler: RunLoop.main)
        .map { items, text in
            if text == "" {
                return items
            }
            return items.filter { ($0.userName + $0.resourceDescription + $0.url).range(of: text, options: .caseInsensitive) != nil }
        }.eraseToAnyPublisher()
    }

    init(keychainService: String = PassengerKeychainItem.service) {
        passwordKeychainItem = Model.passwordKeychainItem(keychainService: keychainService)
        masterKeychainItem = Model.masterKeychainItem(keychainService: keychainService)
        shownPasswordItemsCancellable = shownPasswordItemsPublisher.assign(to: \.shownPasswordItems, on: self)
    }

    func addPasswordItem(_ passwordItem: PasswordItem, hashedMasterPassword: String) {
        assert(MasterPassword.hashPasswordData(Data(base64Encoded: hashedMasterPassword)!) == passwordItem.masterPassword.doubleHashedPassword)
        if let index = passwordItems.firstIndex(where: { $0.id == passwordItem.id }) {
            passwordItems[index] = passwordItem
        } else {
            passwordItems.append(passwordItem)
        }
        passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword)
        saveModel()
    }

    func addMasterPassword(_ masterPassword: MasterPassword, passwordText: String) {
        if let index = masterPasswords.firstIndex(where: { $0.id == masterPassword.id }) {
            masterPasswords[index] = masterPassword
        } else {
            masterPasswords.append(masterPassword)
        }
        try! masterPasswords[masterPasswords.firstIndex(of: masterPassword)!].savePassword(passwordText)
        saveModel()
    }

    func removePasswordItem(_ passwordItem: PasswordItem) {
        guard let index = passwordItems.firstIndex(where: { $0.id == passwordItem.id }) else { return }
        removePasswordItems(atOffsets: IndexSet(integer: index))
    }

    func removeMasterPassword(_ masterPassword: MasterPassword) {
        guard let index = masterPasswords.firstIndex(where: { $0.id == masterPassword.id }) else { return }
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
            PasswordItem(userName: "neil", masterPassword: model.masterPasswords[0], url: "apple.com", resourceDescription: "Apple", passwordScheme: PasswordScheme()),
            PasswordItem(userName: "neil123", masterPassword: model.masterPasswords[1], url: "google.com", resourceDescription: "Google", passwordScheme: PasswordScheme())
        ]
        return model
    }
}
