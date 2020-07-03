//
//  PasswordItem.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import CryptoKit

struct PasswordItem: Identifiable, Equatable {

    init(userName: String, masterPassword: MasterPassword, url: String, serviceName: String) {
        self.userName = userName
        self.masterPassword = masterPassword
        self.url = url
        self.serviceName = serviceName
    }

    init(userName: String, masterPassword: MasterPassword, hashedMasterPassword: String, url: String, serviceName: String) {
        self.init(userName: userName, masterPassword: masterPassword, url: url, serviceName: serviceName)
        let key = SymmetricKey(data: Data(base64Encoded: hashedMasterPassword)!)
        let password = PasswordGenerator.genPassword(phrase: hashedMasterPassword)
        let sealBox = try! AES.GCM.seal(Data((password + userName + url).utf8), using: key)
        let combined = sealBox.combined!
        storePassword(combined.base64EncodedString())
    }

    var id: String { userName + url }
    let userName: String
    let url: String
    let serviceName: String
    let masterPassword: MasterPassword

    private var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(name: url + "::" + serviceName, type: .account, passcodeProtected: false) }

    private func storePassword(_ password: String) {
        try! passwordKeychainItem.savePassword(password)
    }

    /// Assumes the masterPassword is obtainable in from memory or disk
    /// or returns nil otherwise
    func getPassword() throws -> String? {
        guard let mPassword = try! masterPassword.getHashedPassword() else {
            return nil
        }
        return try getPassword(hashedMasterPassword: mPassword)
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
        case serviceName
        case masterPassword
    }
}
struct MasterPassword: Identifiable, Equatable {

    enum SecurityLevel: String, Codable {
        case save
        case protectedSave
        case noSave
    }

    init(name: String, securityLevel: SecurityLevel, doubleHashedPassword: String) {
        self.name = name
        self.securityLevel = securityLevel
        self.doubleHashedPassword = doubleHashedPassword
    }

    init(name: String, password: String, securityLevel: SecurityLevel) {
        let hashed = MasterPassword.hashPasswordToData(password: password)
        let doubleHashed = Data(SHA256.hash(data: hashed)).base64EncodedString()
        self.init(name: name, securityLevel: securityLevel, doubleHashedPassword: doubleHashed)
        savePassword(password, securityLevel: securityLevel)
    }

    var id: String { name }
    let name: String
    let securityLevel: SecurityLevel
    let doubleHashedPassword: String

    private var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(name: name, type: .master, passcodeProtected: securityLevel == .protectedSave) }

    private var inMemoryHashedPassword: String?

    /// Master Passwords may not have the password saved in the keychain if was created on another device.
    /// If this function returns nil, then it is up to the UI to get the master password from the user.
    func getHashedPassword() throws -> String? {
        if let inMemoryHashedPassword = inMemoryHashedPassword {
            return inMemoryHashedPassword
        }
        let hashedPassword: String?
        do {
            hashedPassword = try passwordKeychainItem.readPassword()
        } catch KeychainPasswordItem.KeychainError.noPassword {
            hashedPassword = nil
        }
        return hashedPassword
    }

    mutating func savePassword(_ password: String, securityLevel: SecurityLevel) {
        let hashedPassword = MasterPassword.hashPassword(password)
        inMemoryHashedPassword = hashedPassword
        if (securityLevel != .noSave) {
            try! passwordKeychainItem.savePassword(hashedPassword)
        }
    }

    static func hashPasswordToData(password: String) -> Data {
        return Data(SHA256.hash(data: Data(password.utf8)))
    }

    static func hashPassword(_ password: String) -> String {
        return hashPasswordToData(password: password).base64EncodedString()
    }
}

extension MasterPassword: Codable {
    enum CodingKeys: CodingKey {
        case name
        case securityLevel
        case doubleHashedPassword
    }
}

enum CharacterType: CaseIterable {
    case lowerCase
    case upperCase
    case symbol
    case number

    static private let lowerCaseCharacterSet = CharacterSet.lowercaseLetters
    static private let upperCaseCharacterSet = CharacterSet.uppercaseLetters
    static private let symbolCharacterSet = CharacterSet(charactersIn: "/@$?#%!^+:-_=")
    static private let numberCharacterSet = CharacterSet(charactersIn: "0123456789")

    var characterSet: CharacterSet {
        switch self {
        case .lowerCase:
            return CharacterType.lowerCaseCharacterSet
        case .upperCase:
            return CharacterType.upperCaseCharacterSet
        case .symbol:
            return CharacterType.symbolCharacterSet
        case .number:
            return CharacterType.numberCharacterSet
        }
    }

    static func characterTypeForCharacter(_ char: Character) -> CharacterType? {
        for characterType in CharacterType.allCases {
            if char.unicodeScalars.contains(where: {characterType.characterSet.contains($0)}) {
                return characterType
            }
        }
        return nil
    }
}

class PasswordGenerator {
    static private let symbolMap: [Character: Character] = [
        "A": "@",
        "B": "$",
        "C": "?",
        "D": "#",
        "E": "%",
        "F": "!",
        "G": "^",
        "H": "+",
        "I": ":",
        "K": "-"
    ]

    static func genPassword(phrase: String, characterCounts: [CharacterType: Int]? = nil) -> String {
        var charCounts = characterCounts ?? [
            .lowerCase: 2,
            .upperCase: 2,
            .symbol: 2,
            .number: 2
        ]
        var password: String?
        outer: for i in 0...200 {
            let hashed = SHA256.hash(data: Data((phrase + String(i)).utf8))
            let hashString = Data(hashed).base64EncodedString().prefix(16)
            print("str: " + hashString)
            var symbolizedHashString = ""
            for c in hashString {
                let char = symbolMap[c] ?? c
                symbolizedHashString.append(char)
                print(char)
                let characterType = CharacterType.characterTypeForCharacter(char)!
                charCounts[characterType] = charCounts[characterType]! - 1
            }
            for count in charCounts.values {
                if count > 0 {
                    continue outer
                }
            }
            password = symbolizedHashString
            break
        }
        return password!
    }
}
