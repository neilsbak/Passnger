//
//  PasswordGenerator.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-18.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import CryptoKit

struct PasswordScheme {

    enum SchemeError: Error {
        case passwordLengthError(String)
        case symbolsError(String)
    }

    static private let lowerCaseCharacterSet = CharacterSet.lowercaseLetters
    static private let upperCaseCharacterSet = CharacterSet.uppercaseLetters
    static private let numberCharacterSet = CharacterSet(charactersIn: "0123456789")

    static let defaultSymbols: String = "/+@$?#%!^_"
    static let defaultPasswordLength: Int = 16

    let passwordLength: Int
    let symbols: String
    let minSymbols: Int
    let minLowerCase: Int
    let minUpperCase: Int
    let minNumeric: Int
    private let symbolCharacterSet: CharacterSet

    init(passwordLength: Int, symbols: String, minSymbols: Int, minLowerCase: Int, minUpperCase: Int, minNumeric: Int) throws {
        self.passwordLength = passwordLength
        self.symbols = symbols
        self.minSymbols = minSymbols
        self.minLowerCase = minLowerCase
        self.minUpperCase = minUpperCase
        self.minNumeric = minNumeric
        self.symbolCharacterSet = CharacterSet(charactersIn: symbols)
        try validateScheme()
    }

    init(passwordLength: Int) throws {
        let minCharChount: Int = min(2, passwordLength / 6)
        try self.init(passwordLength: passwordLength, symbols: PasswordScheme.defaultSymbols, minSymbols: minCharChount, minLowerCase: minCharChount, minUpperCase: minCharChount, minNumeric: minCharChount)
    }

    init() {
        try! self.init(passwordLength: PasswordScheme.defaultPasswordLength)
    }

    private func validateScheme() throws {
        if passwordLength < 1 {
            throw SchemeError.passwordLengthError("Password is empty.")
        }
        //Can only have max 10 symbols
        if (symbols.count > 10) {
            throw SchemeError.symbolsError("Exceeded the 10 symbol maximum.")
        }
        let nonSymbolCharacterSet = PasswordScheme.lowerCaseCharacterSet.union(PasswordScheme.upperCaseCharacterSet).union(PasswordScheme.numberCharacterSet)
        // A symbol cannot be a regular character
        if (symbols.flatMap { $0.unicodeScalars}).filter({ nonSymbolCharacterSet.contains($0) }).count > 0 {
            throw SchemeError.symbolsError("A symbol cannot be alphanumeric.")
        }
        let totalMinCharCounts = minNumeric + minUpperCase + minLowerCase + minSymbols
        if totalMinCharCounts > passwordLength {
            throw SchemeError.passwordLengthError("The total of minimum characters exceeds the password length.")
        }
        if symbols.count == 0 && minSymbols > 0 {
            throw SchemeError.symbolsError("No symbols exist to meet minimum requirement.")
        }
    }

    func isValidPassword(_ password: String) -> Bool {
        if (password.count != passwordLength) {
            return false
        }
        var symbolCount = 0
        var lowerCaseCount = 0
        var upperCaseCount = 0
        var numericCount = 0
        for char in password {
            for unicodeScalar in char.unicodeScalars {
                if symbolCharacterSet.contains(unicodeScalar) {
                    symbolCount += 1
                } else if PasswordScheme.lowerCaseCharacterSet.contains(unicodeScalar) {
                    lowerCaseCount += 1
                } else if PasswordScheme.upperCaseCharacterSet.contains(unicodeScalar) {
                    upperCaseCount += 1
                } else if PasswordScheme.numberCharacterSet.contains(unicodeScalar) {
                    numericCount += 1
                }
                if symbolCount >= minSymbols && lowerCaseCount >= minLowerCase && upperCaseCount >= minUpperCase && numericCount >= minNumeric {
                    return true
                }
            }
        }
        return false
    }
}

class PasswordGenerator {

    enum PasswordGeneratorError: Error {
        case passwordError(String)
    }

    static private let symbolMapKeys: [Character] = ["/","+","Z","Y","X","W","V","U","T","S"]

    static private func getSymbolMap(fromSymbols symbols: String) throws -> [Character: String] {
        var symbolMap = [Character: String]()
        var i = 0
        for c in symbols {
            symbolMap[symbolMapKeys[i]] = String(c)
            i += 1
        }
        return symbolMap
    }

    static func genPassword(phrase: String, scheme: PasswordScheme) throws -> String {
        let symbolMap = try getSymbolMap(fromSymbols: scheme.symbols)
        var password: String?

        for i in 0...500 {
            let hashed = SHA256.hash(data: Data((phrase + String(i)).utf8))
            let symbolizedHashString = Data(hashed).base64EncodedString().prefix(scheme.passwordLength).reduce("") { $0 + (symbolMap[$1] ?? String($1)) }
            if scheme.isValidPassword(symbolizedHashString) {
                password = symbolizedHashString
                break
            }
        }
        guard let generatedPassword = password else {
            throw PasswordGeneratorError.passwordError("Could not generate a password for the given configuration")
        }
        return generatedPassword
    }
}
