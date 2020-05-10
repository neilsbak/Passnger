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

    enum PasswordName {
        case accountPassword(String)
        case masterPasswrod(String)

        var account: String {
            switch self {
            case .accountPassword(let name):
                return "accountPassword:\(name)"
            case .masterPasswrod(let name):
                return "masterPasswrod:\(name)"
            }
        }
    }

    let passwordName: PasswordName
    private let keychainPasswordItem: KeychainPasswordItem

    init(passwordName: PasswordName) {
        self.passwordName = passwordName
        self.keychainPasswordItem = KeychainPasswordItem(service: PassengerKeychainItem.service, account: passwordName.account)
    }


    func readPassword() throws -> String  {
        return try keychainPasswordItem.readPassword()
    }

    func savePassword(_ password: String) throws {
        try keychainPasswordItem.savePassword(password)
    }
}
