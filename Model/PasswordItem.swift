//
//  PasswordItem.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import CryptoKit

enum CancellablePasswordText: Equatable {
    case cancelled
    case value(String?)
}

struct PasswordItem: Identifiable, Equatable {

    init(userName: String, masterPassword: MasterPassword, url: String, resourceDescription: String, keychainService: String = PassengerKeychainItem.service, created: Date = Date(), numRenewals: Int = 0, passwordLength: Int) {
        self.userName = userName
        self.masterPassword = masterPassword
        self.url = url
        self.resourceDescription = resourceDescription
        self.keychainService = keychainService
        self.created = created
        self.numRenewals = numRenewals
        self.passwordLength = passwordLength
    }

    var id: String { userName + url }
    let userName: String
    let url: String
    let resourceDescription: String
    let created: Date
    var numRenewals: Int
    let passwordLength: Int
    let masterPassword: MasterPassword
    var keychainService: String = PassengerKeychainItem.service

    private var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(name: url + "::" + userName, type: .account, passcodeProtected: false, keychainService: keychainService) }

    func storePasswordFromHashedMasterPassword(_ hashedMasterPassword: String) {
        assert(MasterPassword.hashPasswordData(Data(base64Encoded: hashedMasterPassword)!) == masterPassword.doubleHashedPassword)
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let password = try! PasswordGenerator.genPassword(phrase: hashedMasterPassword + userName + url + String(numRenewals), length: passwordLength)
        let sealBox = try! AES.GCM.seal(Data((password).utf8), using: key)
        let combined = sealBox.combined!
        try! passwordKeychainItem.savePassword(combined.base64EncodedString())
    }

    /// Assumes the masterPassword is obtainable in from memory or disk
    /// or returns nil otherwise
    func getPassword() throws -> CancellablePasswordText {
        let mPassword = try masterPassword.getHashedPassword()
        switch mPassword {
        case .cancelled:
            return .cancelled
        case .value(let val):
            guard let val = val else { return .value(nil) }
            return .value(try getPassword(hashedMasterPassword: val))
        }
    }

    func getPassword(hashedMasterPassword: String) throws -> String {
        let encryptedPassword = try! passwordKeychainItem.readPassword()
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let sealBox = try! AES.GCM.SealedBox(combined: Data(base64Encoded: encryptedPassword)!)
        let textData = try AES.GCM.open(sealBox, using: key)
        return String(data: textData, encoding: .utf8)!
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
    }
}


struct MasterPassword: Identifiable, Equatable {

    enum MasterPasswordError: Error {
        case PassowordDoesNotMatch
    }

    enum SecurityLevel: String, Codable {
        case save
        case protectedSave
        case memorySave
        case noSave
    }

    init(name: String, securityLevel: SecurityLevel, doubleHashedPassword: String, keychainService: String = PassengerKeychainItem.service) {
        self.name = name
        self.securityLevel = securityLevel
        self.doubleHashedPassword = doubleHashedPassword
        self.keychainService = keychainService
    }

    init(name: String, password: String, securityLevel: SecurityLevel, keychainService: String = PassengerKeychainItem.service) {
        let doubleHashed = MasterPassword.doubleHashPassword(password)
        self.init(name: name, securityLevel: securityLevel, doubleHashedPassword: doubleHashed, keychainService: keychainService)
    }

    var id: String { name }
    let name: String
    let securityLevel: SecurityLevel
    let doubleHashedPassword: String
    var keychainService: String = PassengerKeychainItem.service

    private var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(name: name, type: .master, passcodeProtected: securityLevel == .protectedSave, keychainService: keychainService) }

    private var inMemoryHashedPassword: String?

    /// Master Passwords may not have the password saved in the keychain if was created on another device.
    /// If this function returns nil, then it is up to the UI to get the master password from the user.
    func getHashedPassword() throws -> CancellablePasswordText {
        if let inMemoryHashedPassword = inMemoryHashedPassword, securityLevel != .noSave{
            return .value(inMemoryHashedPassword)
        }
        let hashedPassword: CancellablePasswordText
        do {
            hashedPassword = .value(try passwordKeychainItem.readPassword())
        } catch KeychainPasswordItem.KeychainError.noPassword {
            hashedPassword = .value(nil)
        } catch KeychainPasswordItem.KeychainError.cancelled {
            hashedPassword = .cancelled
        }
        return hashedPassword
    }

    mutating func savePassword(_ password: String) throws {
        let doubleHashedPassword = MasterPassword.doubleHashPassword(password)
        if doubleHashedPassword != self.doubleHashedPassword {
            throw MasterPasswordError.PassowordDoesNotMatch
        }
        let hashedPassword = MasterPassword.hashPassword(password)
        if securityLevel != .noSave {
            inMemoryHashedPassword = hashedPassword
        }
        if (securityLevel != .noSave) {
            try! passwordKeychainItem.savePassword(hashedPassword)
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
