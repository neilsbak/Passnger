//
//  File.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

class Model: ObservableObject {

    @Published var passwordItems = [PasswordItem]()

    @Published var masterPasswords = [MasterPassword]()

    static let masterPasswordsKeychainAccountName = "MasterPasswords"
    static let passwordItemsKeychainAccountName = "PasswordItems"

    func saveModel() {
        let masterPasswordsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: Model.masterPasswordsKeychainAccountName)
        let masterPasswordData = try! JSONEncoder().encode(masterPasswords)
        let masterPasswordJson = String(data: masterPasswordData, encoding: .utf8)!
        try! masterPasswordsKeychainItem.savePassword(masterPasswordJson)

        let passwordItemsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: Model.passwordItemsKeychainAccountName)
        let passwordItemData = try! JSONEncoder().encode(passwordItems)
        let passwordItemJson = String(data: passwordItemData, encoding: .utf8)!
        try! passwordItemsKeychainItem.savePassword(passwordItemJson)
    }

    static func loadModel() -> Model {
        let model = Model()

        let masterPasswordsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: masterPasswordsKeychainAccountName)
        guard let masterPasswordsJson = try? masterPasswordsKeychainItem.readPassword() else {
            return model
        }
        model.masterPasswords = (try? JSONDecoder().decode([MasterPassword].self, from: masterPasswordsJson.data(using: .utf8)!)) ?? []

        let passwordItemsKeychainItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: passwordItemsKeychainAccountName)
        guard let passwordItemsJson = try? passwordItemsKeychainItem.readPassword() else {
            return model
        }
        model.passwordItems = (try? JSONDecoder().decode([PasswordItem].self, from: passwordItemsJson.data(using: .utf8)!)) ?? []

        return model
    }

    static func testModel() -> Model {
        let model = Model()
        model.passwordItems = [
            PasswordItem(userName: "neil", password: "asdf", url: "apple.com", serviceName: "Apple"),
            PasswordItem(userName: "neil123", password: "jklj", url: "google.com", serviceName: "Google")
        ]
        model.masterPasswords = [
            MasterPassword(name: "Test 1", password: "asdf"),
            MasterPassword(name: "Test 2", password: "jklj")
        ]
        return model
    }
}
