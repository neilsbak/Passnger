//
//  CreatePasswordFormView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-23.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordFormView: View {
    static private let numberFormatter = NumberFormatter()

    @Binding var formModel: CreatePasswordFormModel
    let masterPasswords: [MasterPassword]
    let includePadding: Bool
    let removeMasterPasswords: (IndexSet) -> Void
    let createMasterPassword: () -> Void

    @State var passwordLength = 16
    var body: some View {
            AlignedForm {
                TextField("Website URL", text: $formModel.websiteUrl)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .validatedField(errorText: formModel.websiteUrlError)
                TextField("Description", text: $formModel.websiteName)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .validatedField(errorText: formModel.websiteNameError)
                TextField("Username", text: $formModel.username)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .validatedField(errorText: formModel.usernameError)
                Picker(selection: self.$formModel.passwordLength, label: Text("Password Length")) {
                    ForEach(1..<50, id: \.self) {
                        Text(String($0))
                    }
                }
                .validatedField(errorText: formModel.usernameError)
                Picker(selection: self.$formModel.selectedMasterPassword, label: Text("Master Password")) {
                    ForEach(self.masterPasswords) {
                        Text($0.name).tag($0 as MasterPassword?)
                    }
                }
                .validatedField(errorText: formModel.usernameError)
            }
        }
}

struct CreatePasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordFormView(formModel: Binding.constant(CreatePasswordFormModel()), masterPasswords: Model.testModel().masterPasswords, includePadding: true, removeMasterPasswords: {_ in}, createMasterPassword: {})
    }
}
