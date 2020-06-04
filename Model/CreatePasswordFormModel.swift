//
//  CreatePasswordFormModel.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-24.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation

struct CreatePasswordFormModel {

    var websiteName: String = "";
    var websiteUrl: String = ""
    var username: String = ""
    var selectedMasterPassword: MasterPassword?
    var hasSubmitted = false

    func validate() -> Bool {
        return self.websiteUrlError == nil && self.websiteNameError == nil && self.usernameError == nil && self.masterPasswordError == nil;
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

}

