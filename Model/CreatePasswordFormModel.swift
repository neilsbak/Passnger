//
//  CreatePasswordFormModel.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-24.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct CreatePasswordFormModel {

    var websiteName: String
    var websiteUrl: String
    var username: String
    var passwordLength: Int
    var selectedMasterPassword: MasterPassword?
    var symbols: String
    var hasSubmitted: Bool
    var minSymbols: Int
    var minUpperCase: Int
    var minNumeric: Int
    var minLowerCase: Int

    init(websiteName: String, websiteUrl: String, username: String, passwordLength: Int, selectedMasterPassword: MasterPassword?, symbols: String, hasSubmitted: Bool) {
        let scheme = try! PasswordScheme(passwordLength: passwordLength)
        self.websiteName = websiteName
        self.websiteUrl = websiteUrl
        self.username = username
        self.passwordLength = passwordLength
        self.selectedMasterPassword = selectedMasterPassword
        self.symbols = symbols
        self.hasSubmitted = hasSubmitted

        self.minSymbols = scheme.minSymbols
        self.minNumeric = scheme.minNumeric
        self.minUpperCase = scheme.minUpperCase
        self.minLowerCase = scheme.minLowerCase
    }

    init() {
        self.init(websiteName: "", websiteUrl: "", username: "", passwordLength: PasswordScheme.defaultPasswordLength, selectedMasterPassword: nil, symbols: PasswordScheme.defaultSymbols, hasSubmitted: false)
    }

    func passwordScheme() throws -> PasswordScheme {
        return try PasswordScheme(passwordLength: passwordLength, symbols: symbols, minSymbols: minSymbols, minLowerCase: minLowerCase, minUpperCase: minUpperCase, minNumeric: minNumeric)
    }

    func validate() -> Bool {
        return self.websiteUrlError == nil && self.websiteNameError == nil && self.usernameError == nil && self.masterPasswordError == nil && self.passwordLengthError == nil && self.symbolsError == nil;
    }

    var websiteNameError: String? {
        if !hasSubmitted {
            return nil
        }
        if websiteName == "" {
            return "This field is required"
        }
        return nil
    }

    var websiteUrlError: String? {
        if !hasSubmitted {
            return nil
        }
        if websiteUrl == "" {
            return "This field is required"
        }
        return nil
    }

    var usernameError: String? {
        if !hasSubmitted {
            return nil
        }
        if username == "" {
            return "This field is required"
        }
        return nil
    }

    var masterPasswordError: String? {
        if !hasSubmitted {
            return nil;
        }
        if selectedMasterPassword == nil {
            return "This field is required"
        }
        return nil
    }

    var passwordLengthError: String? {
        if !hasSubmitted {
            return nil;
        }
        do {
            _ = try passwordScheme()
        } catch PasswordScheme.SchemeError.passwordLengthError(let errorMessage) {
            return errorMessage
        } catch {
            return nil
        }
        return nil
    }

    var symbolsError: String? {
        if !hasSubmitted {
            return nil;
        }
        do {
            _ = try passwordScheme()
        } catch PasswordScheme.SchemeError.symbolsError(let errorMessage) {
            return errorMessage
        } catch {
            return nil
        }
        return nil
    }

}

