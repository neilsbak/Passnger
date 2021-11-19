//
//  MasterPasswordFormModel.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-06-01.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct MasterPasswordFormModel {

    var password: String = ""
    var confirmPassword: String = ""
    var hint: String = ""
    var saveOnDevice = true
    var hasSubmitted = false

    func validate() -> Bool {
        return (passwordError == nil && confirmedPasswordError == nil && hintError == nil)
    }

    var passwordError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (password == "") {
            return "This field is required"
        }
        if (password != confirmPassword) {
            return "The passwords do not match"
        }
        return nil
    }

    var confirmedPasswordError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (confirmPassword == "") {
            return "This field is required"
        }
        if (confirmPassword != password) {
            return "The passwords do not match"
        }
        return nil
    }

    var hintError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (hint == "") {
            return "This field is required"
        }
        return nil
    }

}
