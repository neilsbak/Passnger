//
//  KeychainPasswordItem.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-06.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct KeychainPasswordItem {
    // MARK: Types

    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case cancelled
        case unhandledError(status: OSStatus)
    }

    // MARK: Properties

    let service: String?

    private(set) var account: String

    let accessGroup: String?

    let sync: Bool

    let passcodeProtected: Bool

    // MARK: Intialization

    init(service: String?, account: String, sync: Bool, passcodeProtected: Bool, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.sync = sync
        self.passcodeProtected = passcodeProtected
        self.accessGroup = accessGroup
    }

    // MARK: Keychain access

    func readPassword() throws -> String  {
        /*
            Build a query to find the item that matches the service, account and
            access group.
        */
        var query = KeychainPasswordItem.keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status != errSecUserCanceled else { throw KeychainError.cancelled }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }

        return password
    }

    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!

        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noPassword {
            /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = KeychainPasswordItem.keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }

    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?

        let query = KeychainPasswordItem.keychainQuery(withService: service, account: self.account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }

        self.account = newAccountName
    }

    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }

    static func passwordItems(forService service: String?, account: String? = nil, sync: Bool? = nil, passcodeProtected: Bool = false, accessGroup: String? = nil) throws -> [KeychainPasswordItem] {        // Build a query for all items that match the service and access group.

        var query = keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }

        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainPasswordItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            let sync = result[kSecAttrSynchronizable as String] as? Bool ?? false
            let passcodeProtected = query[kSecAttrAccessControl as String] != nil
            let service = query[kSecAttrService as String] as? String
            let passwordItem = KeychainPasswordItem(service: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }

        return passwordItems
    }
    
    func exists() throws -> Bool {
        var query = KeychainPasswordItem.keychainQuery(withService: service, account: account, sync: sync, passcodeProtected: passcodeProtected, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        // makes keychain to return errSecInteractionNotAllowed if the item exists
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        if status == errSecItemNotFound {
            return false
        }
        if (status == errSecInteractionNotAllowed) {
            return true
        }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        return true
    }
    
    // MARK: Convenience

    private static func keychainQuery(withService service: String?, account: String? = nil, sync: Bool?, passcodeProtected: Bool, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        if let service = service {
            query[kSecAttrService as String] = service as AnyObject?
        }
        if let sync = sync {
            query[kSecAttrSynchronizable as String] = sync as AnyObject
        } else {
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        }

        if passcodeProtected {
            let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .userPresence, nil)
            query[kSecAttrAccessControl as String] = access
        }

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }
}
