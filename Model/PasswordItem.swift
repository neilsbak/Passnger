//
//  PasswordItem.swift
//  Passnger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import CryptoKit

enum CancellablePasswordText: Equatable {
    case cancelled
    case value(String?)

    var password: String? {
        switch self {
        case .value(let password):
            return password
        default:
            return nil
        }
    }
}

struct PasswordItem: Identifiable, Equatable {

    init(userName: String, masterPassword: MasterPassword, url: String, resourceDescription: String, created: Date = Date(), numRenewals: Int = 0, passwordScheme: PasswordScheme) {
        self.userName = userName
        self.masterPassword = masterPassword
        self.url = url
        self.resourceDescription = resourceDescription
        self.created = created
        self.numRenewals = numRenewals
        self.passwordLength = passwordScheme.passwordLength
        self.symbols = passwordScheme.symbols
        self.minSymbols = passwordScheme.minSymbols
        self.minNumeric = passwordScheme.minNumeric
        self.minUpperCase = passwordScheme.minUpperCase
        self.minLowerCase = passwordScheme.minLowerCase
    }

    var id: String { userName + url }
    let userName: String
    let url: String
    let resourceDescription: String
    let created: Date
    var numRenewals: Int
    let passwordLength: Int
    let symbols: String
    let minSymbols: Int
    let minNumeric: Int
    let minUpperCase: Int
    let minLowerCase: Int
    let masterPassword: MasterPassword

    private func passwordKeychainItem(keychainService: String) -> PassngerKeychainItem {
        PassngerKeychainItem(name: url + "::" + userName, type: .account, passcodeProtected: false, keychainService: keychainService)
    }

    func passwordScheme() throws -> PasswordScheme {
        try PasswordScheme(passwordLength: passwordLength, symbols: symbols, minSymbols: minSymbols, minLowerCase: minLowerCase, minUpperCase: minUpperCase, minNumeric: minNumeric)
    }

    func storePasswordFromHashedMasterPassword(_ hashedMasterPassword: String, keychainService: String) throws {
        assert(MasterPassword.hashPasswordData(Data(base64Encoded: hashedMasterPassword)!) == masterPassword.doubleHashedPassword)
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let password = try PasswordGenerator.genPasswordForDuration(phrase: hashedMasterPassword + userName + url + String(numRenewals), scheme: passwordScheme(), maxTimeInterval: 5)
        let sealBox = try! AES.GCM.seal(Data((password).utf8), using: key)
        let combined = sealBox.combined!
        try! passwordKeychainItem(keychainService: keychainService).savePassword(combined.base64EncodedString())
    }

    /// Assumes the masterPassword is obtainable in from memory or disk
    /// or returns nil otherwise
    func getPassword(keychainService: String) throws -> CancellablePasswordText {
        let mPassword = masterPassword.getHashedPassword(keychainService: keychainService)
        switch mPassword {
        case .cancelled:
            return .cancelled
        case .value(let val):
            guard let val = val else { return .value(nil) }
            return .value(try getPassword(hashedMasterPassword: val, keychainService: keychainService))
        }
    }

    func getPassword(hashedMasterPassword: String, keychainService: String) throws -> String {
        let encryptedPassword = try! passwordKeychainItem(keychainService: keychainService).readPassword()
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let sealBox = try! AES.GCM.SealedBox(combined: Data(base64Encoded: encryptedPassword)!)
        let textData = try AES.GCM.open(sealBox, using: key)
        return String(data: textData, encoding: .utf8)!
    }

    func deletePassword(keychainService: String) throws {
        try passwordKeychainItem(keychainService: keychainService).deletePassword()
    }
}

extension PasswordItem: Codable {
    enum CodingKeys: CodingKey {
        case userName
        case url
        case resourceDescription
        case masterPassword
        case created
        case numRenewals
        case passwordLength
        case symbols
        case minSymbols
        case minNumeric
        case minUpperCase
        case minLowerCase
    }
}


struct MasterPassword: Identifiable, Equatable, Hashable {

    private static var cachedMasterPassword: CachedMasterPassword?

    private static func getCachedPassword(forMasterPassword masterPassword: MasterPassword) -> String? {
        guard let cachedMasterPassword = cachedMasterPassword else {
            return nil
        }
        if cachedMasterPassword.masterPassword != masterPassword {
            return nil
        }
        if cachedMasterPassword.expiry < Date() {
            return nil
        }
        return cachedMasterPassword.hashedPassword
    }

    enum MasterPasswordError: Error {
        case PassowordDoesNotMatch
    }

    enum SecurityLevel: String, Codable {
        case save
        case protectedSave
        case memorySave
        case noSave
    }

    init(name: String, securityLevel: SecurityLevel, doubleHashedPassword: String) {
        self.name = name
        self.securityLevel = securityLevel
        self.doubleHashedPassword = doubleHashedPassword
    }

    init(name: String, password: String, securityLevel: SecurityLevel) {
        let doubleHashed = MasterPassword.doubleHashPassword(password)
        self.init(name: name, securityLevel: securityLevel, doubleHashedPassword: doubleHashed)
    }

    var id: String { name }
    let name: String
    let securityLevel: SecurityLevel
    let doubleHashedPassword: String

    private func passwordKeychainItem(keychainService: String) -> PassngerKeychainItem {
        PassngerKeychainItem(name: name, type: .master, passcodeProtected: securityLevel == .protectedSave, keychainService: keychainService)
        }

    /// Master Passwords may not have the password saved in the keychain if was created on another device.
    /// If this function returns nil, then it is up to the UI to get the master password from the user.
    func getHashedPassword(keychainService: String) -> CancellablePasswordText {
        if let inMemoryHashedPassword = MasterPassword.getCachedPassword(forMasterPassword: self), securityLevel != .noSave{
            return .value(inMemoryHashedPassword)
        }
        let hashedPassword: CancellablePasswordText
        do {
            let password = try passwordKeychainItem(keychainService: keychainService).readPassword()
            hashedPassword = .value(password)
            if securityLevel != .noSave {
                MasterPassword.cachedMasterPassword = CachedMasterPassword(masterPassword: self, hashedPassword: password)
            }
        } catch KeychainPasswordItem.KeychainError.noPassword {
            hashedPassword = .value(nil)
        } catch KeychainPasswordItem.KeychainError.cancelled {
            hashedPassword = .cancelled
        } catch (_) {
            // all other errors are unexpected, but we can return nil
            // to force the user to enter their master password instead.
            hashedPassword = .value(nil)
        }
        return hashedPassword
    }

    mutating func savePassword(_ password: String, keychainService: String) throws {
        let doubleHashedPassword = MasterPassword.doubleHashPassword(password)
        if doubleHashedPassword != self.doubleHashedPassword {
            throw MasterPasswordError.PassowordDoesNotMatch
        }
        let hashedPassword = MasterPassword.hashPassword(password)
        if securityLevel != .noSave {
            MasterPassword.cachedMasterPassword = CachedMasterPassword(masterPassword: self, hashedPassword: hashedPassword)
        }
        if (securityLevel != .noSave) {
            do {
                try passwordKeychainItem(keychainService: keychainService).savePassword(hashedPassword)
            } catch _ {
                // Device probably doesn't have a passcode, which means the user will have
                // to enter their master password every time
            }
        }
    }

    mutating func deletePassword(keychainService: String) throws {
        try passwordKeychainItem(keychainService: keychainService).deletePassword()
        if let _ = MasterPassword.getCachedPassword(forMasterPassword: self) {
            MasterPassword.cachedMasterPassword = nil
        }
    }

    static func hashPasswordDataToData(passwordData: Data) -> Data {
        return Data(SHA256.hash(data: passwordData))
    }

    static func hashPasswordToData(password: String) -> Data {
        return hashPasswordDataToData(passwordData: Data(password.utf8))
    }

    static func hashPasswordData(_ passwordData: Data) -> String {
        return hashPasswordDataToData(passwordData: passwordData).base64EncodedString()
    }

    static func hashPassword(_ password: String) -> String {
        return hashPasswordToData(password: password).base64EncodedString()
    }

    static func doubleHashPassword(_ password: String) -> String {
        let hashed = MasterPassword.hashPasswordToData(password: password)
        return hashPasswordData(hashed)
    }
}

extension MasterPassword: Codable {
    enum CodingKeys: CodingKey {
        case name
        case securityLevel
        case doubleHashedPassword
    }
}

struct CachedMasterPassword {
    let masterPassword: MasterPassword
    let hashedPassword: String
    let expiry: Date
}

extension CachedMasterPassword {
    init(masterPassword: MasterPassword, hashedPassword: String) {
        self.init(masterPassword: masterPassword, hashedPassword: hashedPassword, expiry: Date(timeIntervalSinceNow: 60 * 1))
    }
}

