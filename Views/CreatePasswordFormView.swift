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

    @ObservedObject var model: Model
    @Binding var formModel: CreatePasswordFormModel
    let includePadding: Bool
    let createMasterPassword: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Website URL:")
                    TextField("example.com", text: $formModel.websiteUrl)
                        .autoCapitalizationOff()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .validatedField(errorText: formModel.websiteUrlError)
                }
                HStack {
                    Text("Description:")
                    TextField("Example", text: $formModel.websiteName)
                        .autoCapitalizationOff()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .validatedField(errorText: formModel.websiteNameError)
                }
                HStack {
                    Text("Username:")
                    TextField("username", text: $formModel.username)
                        .autoCapitalizationOff()
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .validatedField(errorText: formModel.usernameError)
                }
                HStack {
                    Text("Password Length:")
                    TextField("16", text: Binding<String>(get: { String(self.formModel.passwordLength) }, set: { self.formModel.passwordLength = Int($0) ?? 0}))
                        .keyboardNumeric()
                        .frame(width: 60)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .validatedField(errorText: formModel.passwordLengthError)
                        .multilineTextAlignment(.center)
                }
                Spacer().frame(height: 5)
                HStack {
                    Text("Choose Master Password")
                    Button(action: {
                        withAnimation {
                            self.createMasterPassword()
                        }
                    }) {
                        Image("plus.circle").resizable().frame(width: 24, height: 24).padding(EdgeInsets(top: 8, leading: 5, bottom: 8, trailing: 12))
                    }.buttonStyle(BorderlessButtonStyle())
                }.validatedField(errorText: formModel.masterPasswordError)
            }.padding(includePadding ? [.leading, .top, .trailing] : [])
            List {
                ForEach(model.masterPasswords) { masterPassword in
                    HStack {
                        //TODO: make the tap area larger
                        Text(masterPassword.name).frame(maxWidth: CGFloat.infinity, alignment: .leading)
                        Spacer()
                        if masterPassword.id == self.formModel.selectedMasterPassword?.id {
                            Image("checkmark").renderingMode(.template).resizable().frame(width: 16, height: 16).foregroundColor(Color(.label))
                        }
                    }.onTapGesture {
                        withAnimation {
                            self.formModel.selectedMasterPassword = masterPassword
                        }
                    }
                }
                .onDelete() { indexSet in
                    self.model.removeMasterPasswords(atOffsets: indexSet)
                }.padding(includePadding ? [.leading, .trailing] : [])
            }
        }
    }
}

struct CreatePasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordFormView(model: Model.testModel(), formModel: Binding<CreatePasswordFormModel>(get: { CreatePasswordFormModel() }, set: {_ in }), includePadding: true, createMasterPassword: {})
    }
}
