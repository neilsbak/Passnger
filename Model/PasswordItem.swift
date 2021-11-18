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

    static var keychainServiceUserInfoKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "paswordItemKeychainService")!
    }

    init(userName: String, masterPassword: MasterPassword, url: String, resourceDescription: String, created: Date = Date(), numRenewals: Int = 0, passwordScheme: PasswordScheme, keychainService: String) {
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
        self.keychainService = keychainService
    }

    init(from decoder: Decoder) throws {
        keychainService = decoder.userInfo[PasswordItem.keychainServiceUserInfoKey] as! String
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        url = try container.decode(String.self, forKey: .url)
        resourceDescription = try container.decode(String.self, forKey: .resourceDescription)
        created = try container.decode(Date.self, forKey: .created)
        numRenewals = try container.decode(Int.self, forKey: .numRenewals)
        passwordLength = try container.decode(Int.self, forKey: .passwordLength)
        symbols = try container.decode(String.self, forKey: .symbols)
        minSymbols = try container.decode(Int.self, forKey: .minSymbols)
        minNumeric = try container.decode(Int.self, forKey: .minNumeric)
        minUpperCase = try container.decode(Int.self, forKey: .minUpperCase)
        minLowerCase = try container.decode(Int.self, forKey: .minLowerCase)
        masterPassword = try container.decode(MasterPassword.self, forKey: .masterPassword)
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
    let keychainService: String

    private func passwordKeychainItem() -> PassngerKeychainItem {
        PassngerKeychainItem(name: url + "::" + userName, type: .account, passcodeProtected: false, keychainService: keychainService)
    }

    func passwordScheme() throws -> PasswordScheme {
        try PasswordScheme(passwordLength: passwordLength, symbols: symbols, minSymbols: minSymbols, minLowerCase: minLowerCase, minUpperCase: minUpperCase, minNumeric: minNumeric)
    }

    func storePasswordFromHashedMasterPassword(_ hashedMasterPassword: String) throws {
        assert(MasterPassword.hashPasswordData(Data(base64Encoded: hashedMasterPassword)!) == masterPassword.doubleHashedPassword)
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let password = try PasswordGenerator.genPasswordForDuration(phrase: hashedMasterPassword + userName + url + String(numRenewals), scheme: passwordScheme(), maxTimeInterval: 5)
        let sealBox = try! AES.GCM.seal(Data((password).utf8), using: key)
        let combined = sealBox.combined!
        try! passwordKeychainItem().savePassword(combined.base64EncodedString())
    }

    /// Assumes the masterPassword is obtainable in from memory or disk
    /// or returns nil otherwise
    func getPassword(keychainService: String) throws -> CancellablePasswordText {
        let mPassword = masterPassword.getHashedPassword()
        switch mPassword {
        case .cancelled:
            return .cancelled
        case .value(let val):
            guard let val = val else { return .value(nil) }
            return .value(try getPassword(hashedMasterPassword: val))
        }
    }

    func getPassword(hashedMasterPassword: String) throws -> String {
        let encryptedPassword = try! passwordKeychainItem().readPassword()
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let sealBox = try! AES.GCM.SealedBox(combined: Data(base64Encoded: encryptedPassword)!)
        let textData = try AES.GCM.open(sealBox, using: key)
        return String(data: textData, encoding: .utf8)!
    }

    func deletePassword() throws {
        try passwordKeychainItem().deletePassword()
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
    
    static var keychainServiceUserInfoKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "masterPasswordKeychainService")!
    }

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

    init(name: String, doubleHashedPassword: String, keychainService: String, securityLevel: SecurityLevel = .protectedSave) {
        self.name = name
        self.doubleHashedPassword = doubleHashedPassword
        self.keychainService = keychainService
        self.securityLevel = securityLevel
        self.passwordIsSaved = isPasswordSaved()
    }

    init(name: String, password: String, keychainService: String, securityLevel: SecurityLevel = .protectedSave) {
        let doubleHashed = MasterPassword.doubleHashPassword(password)
        self.init(name: name, doubleHashedPassword: doubleHashed, keychainService: keychainService, securityLevel: securityLevel)
    }
    
    init(from decoder: Decoder) throws {
        keychainService = decoder.userInfo[MasterPassword.keychainServiceUserInfoKey] as! String
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        doubleHashedPassword = try container.decode(String.self, forKey: .doubleHashedPassword)
        securityLevel = SecurityLevel(rawValue: try container.decode(String.self, forKey: .securityLevel)) ?? .protectedSave
        self.passwordIsSaved = isPasswordSaved()
    }

    var id: String { name }
    let name: String
    let securityLevel: SecurityLevel
    let doubleHashedPassword: String
    let keychainService: String
    var passwordIsSaved: Bool = false

    private func passwordKeychainItem() -> PassngerKeychainItem {
        PassngerKeychainItem(name: name, type: .master, passcodeProtected: securityLevel == .protectedSave, keychainService: keychainService)
    }

    /// Master Passwords may not have the password saved in the keychain if was created on another device.
    /// If this function returns nil, then it is up to the UI to get the master password from the user.
    func getHashedPassword() -> CancellablePasswordText {
        if let inMemoryHashedPassword = MasterPassword.getCachedPassword(forMasterPassword: self) {
            return .value(inMemoryHashedPassword)
        }
        let hashedPassword: CancellablePasswordText
        do {
            let password = try passwordKeychainItem().readPassword()
            hashedPassword = .value(password)
            MasterPassword.cachedMasterPassword = CachedMasterPassword(masterPassword: self, hashedPassword: password)
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

    mutating func savePassword(_ password: String) throws {
        let doubleHashedPassword = MasterPassword.doubleHashPassword(password)
        if doubleHashedPassword != self.doubleHashedPassword {
            throw MasterPasswordError.PassowordDoesNotMatch
        }
        let hashedPassword = MasterPassword.hashPassword(password)
        MasterPassword.cachedMasterPassword = CachedMasterPassword(masterPassword: self, hashedPassword: hashedPassword)
        do {
            try passwordKeychainItem().savePassword(hashedPassword)
            self.passwordIsSaved = true
        } catch _ {
            // Device probably doesn't have a passcode, which means the user will have
            // to enter their master password every time
        }
    }
    
    private func isPasswordSaved() -> Bool {
        return (try? passwordKeychainItem().isPasswordSaved()) ?? false
    }
    
    mutating func deletePassword() throws {
        MasterPassword.cachedMasterPassword = nil
        try passwordKeychainItem().deletePassword()
        self.passwordIsSaved = false
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

