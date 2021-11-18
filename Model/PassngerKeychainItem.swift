//
//  PassngerKeychainItem.swift
//  Passnger
//
//  Created by Neil Bakhle on 2020-05-06.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct PassngerKeychainItem {

    static let service = "Passnger"

    enum PasswordType {
        case account
        case master
    }

    let name: String
    let type: PasswordType
    let passcodeProtected: Bool
    private let keychainPasswordItem: KeychainPasswordItem

    init(name: String, type: PasswordType, passcodeProtected: Bool, keychainService: String = PassngerKeychainItem.service) {
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
            accountName = "masterPassword:\(name)"
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
    
    func isPasswordSaved() throws -> Bool {
        return try keychainPasswordItem.exists()
    }
    
    func deletePassword() throws {
        try keychainPasswordItem.deleteItem()
    }
}
