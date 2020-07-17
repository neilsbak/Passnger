//
//  PassengerKeychainItem.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-06.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct PassengerKeychainItem {

    static let service = "com.nbakhle.passenger"

    enum PasswordType {
        case account
        case master
    }

    let name: String
    let type: PasswordType
    let passcodeProtected: Bool
    private let keychainPasswordItem: KeychainPasswordItem

    init(name: String, type: PasswordType, passcodeProtected: Bool, keychainService: String = PassengerKeychainItem.service) {
        self.name = name
        self.type = type
        self.passcodeProtected = passcodeProtected
        let accountName: String
        let sync: Bool
        switch type {
        case .account:
            accountName = "accountPassword:\(name)"
            sync = true
        case .master:
            accountName = "masterPasswrod:\(name)"
            sync = false
        }

        self.keychainPasswordItem = KeychainPasswordItem(service: keychainService, account: accountName, sync: sync, passcodeProtected: passcodeProtected)
    }


    func readPassword() throws -> String  {
        return try keychainPasswordItem.readPassword()
    }

    func savePassword(_ password: String) throws {
        try keychainPasswordItem.savePassword(password)
    }
}
