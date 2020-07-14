//
//  GetMasterPasswordView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-06-28.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct GetMasterPasswordView: View {
    let masterPassword: MasterPassword
    @Binding var showGetMasterPassword: Bool
    let onGotHashedPassword: (String) -> ()
    @State private var passwordText: String = ""
    @State private var passwordError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text("Enter Master Password")
            SecureField("Password", text: $passwordText)
                .autoCapitalizationOff()
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .validatedField(errorText: passwordError)
            HStack {
                Button(action: {
                    self.showGetMasterPassword = false
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    let doubleHashedPassword = MasterPassword.doubleHashPassword(self.passwordText)
                    if doubleHashedPassword != self.masterPassword.doubleHashedPassword {
                        self.passwordError = "Incorrect Password"
                        return
                    }
                    let hashedPassword = MasterPassword.hashPassword(self.passwordText)
                    self.onGotHashedPassword(hashedPassword)
                    self.showGetMasterPassword = false
                }) {
                    Text("Save")
                }
            }

        }
    }
}

struct GetMasterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        GetMasterPasswordView(masterPassword: Model.testModel().masterPasswords[0], showGetMasterPassword: Binding(get: { true }, set: { _ in }), onGotHashedPassword: {_ in })
    }
}
