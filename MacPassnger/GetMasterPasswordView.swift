//
//  GetMasterPasswordView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-06-28.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct GetMasterPasswordView: View {
    let masterPassword: MasterPassword?
    @Binding var isPresented: Bool
    let onGotPassword: (MasterPassword, String, Bool) -> ()
    @State private var passwordText: String = ""
    @State private var passwordError: String?
    @State private var saveOnDevice: Bool = true

    var body: some View {
        SheetView(onCancel: { self.isPresented = false }, onSave: {
            let doubleHashedPassword = MasterPassword.doubleHashPassword(self.passwordText)
            if doubleHashedPassword != self.masterPassword!.doubleHashedPassword {
                self.passwordError = "Incorrect Password"
                return
            }
            self.onGotPassword(self.masterPassword!, self.passwordText, saveOnDevice)
            self.isPresented = false

        }) {
            VStack(alignment: .leading, spacing: 12.0) {
                Text("Enter Master Password")
                SecureField(masterPassword?.name ?? "Password", text: $passwordText)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .validatedField(errorText: passwordError)
                Toggle("Remember on this device", isOn: $saveOnDevice)
            }
        }.frame(width: 300, height: 140)
    }
}

struct GetMasterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        GetMasterPasswordView(masterPassword: Model.testModel().masterPasswords[0], isPresented: Binding(get: { true }, set: { _ in }), onGotPassword: {_,_,_ in })
    }
}
