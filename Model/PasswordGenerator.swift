//
//  PasswordGenerator.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-18.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import CryptoKit

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

    struct NotGeneratedError: Error {}

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

    static func genPassword(phrase: String, length: Int = 16, characterCounts: [CharacterType: Int]? = nil) throws -> String {
        var password: String?
        outer: for i in 0...500 {
            var charCounts = characterCounts ?? [
                .lowerCase: 2,
                .upperCase: 2,
                .symbol: 2,
                .number: 2
            ]
            let hashed = SHA256.hash(data: Data((phrase + String(i)).utf8))
            let hashString = Data(hashed).base64EncodedString().prefix(length)
            var symbolizedHashString = ""
            for c in hashString {
                let char = symbolMap[c] ?? c
                symbolizedHashString.append(char)
                let characterType = CharacterType.characterTypeForCharacter(char)!
                if let charCount = charCounts[characterType] {
                    charCounts[characterType] = charCount - 1
                }
            }
            for count in charCounts.values {
                if count > 0 {
                    continue outer
                }
            }
            password = symbolizedHashString
            break
        }
        guard let generatedPassword = password else {
            throw NotGeneratedError()
        }
        return generatedPassword
    }
}
