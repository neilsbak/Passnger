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

    init(userName: String, url: String, serviceName: String) {
        self.userName = userName
        self.url = url
        self.serviceName = serviceName
    }

    init(userName: String, password: String, url: String, serviceName: String) {
        self.init(userName: userName, url: url, serviceName: serviceName)
        hashAndStorePassword(password: password)
    }

    var id: String { userName + url }
    let userName: String
    let url: String
    let serviceName: String

    var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(passwordName: .accountPassword(url + "::" + serviceName)) }

    private func hashAndStorePassword(password: String) {
        try! passwordKeychainItem.savePassword(PasswordGenerator.genPassword(phrase: password))
    }
}

extension PasswordItem: Codable {
    enum CodingKeys: CodingKey {
        case userName
        case url
        case serviceName
    }
}

struct MasterPassword: Identifiable, Equatable {

    init(name: String) {
        self.name = name
    }

    init(name: String, password: String) {
        self.init(name: name)
        hashAndStorePassword(password: password)
    }

    var id: String { name }
    let name: String

    var passwordKeychainItem: PassengerKeychainItem { PassengerKeychainItem(passwordName: .masterPasswrod(name)) }

    private func hashAndStorePassword(password: String) {
        let hashed = SHA256.hash(data: Data(password.utf8))
        try! passwordKeychainItem.savePassword(Data(hashed).base64EncodedString())
    }
}

extension MasterPassword: Codable {
    enum CodingKeys: CodingKey {
        case name
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
