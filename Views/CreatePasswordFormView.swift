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

    @State private var showPasswordComponents = false

    @ViewBuilder
    var masterPasswordHeaderView: some View {
        HStack {
            Button(action: {
                self.createMasterPassword()
            }) {
                Text("Manage Master Passwords")
            }.buttonStyle(BorderlessButtonStyle())
        }
    }

    @ViewBuilder
    var passwordComponentsHeaderView: some View {
        HStack {
            Button(action: { self.showPasswordComponents.toggle() }) {
                Text((self.showPasswordComponents ? "Hide" : "Show") + " Password Components")
            }.buttonStyle(BorderlessButtonStyle())
            Spacer()
        }
    }

    var body: some View {
            AlignedForm {
                AlignedSection(header: masterPasswordHeaderView) {
                    Picker(selection: self.$formModel.selectedMasterPassword, label: Text("Master Password")) {
                        ForEach(self.masterPasswords) {
                            Text($0.name).tag($0 as MasterPassword?)
                        }
                    }.validatedField(errorText: formModel.masterPasswordError)
                }
                AlignedSection(header: EmptyView()) {
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
                }

                    AlignedSection(header: passwordComponentsHeaderView) {
                        if showPasswordComponents {
                        Picker(selection: self.$formModel.passwordLength, label: Text("Password Length")) {
                            ForEach(1..<50, id: \.self) {
                                Text(String($0))
                            }
                        }.validatedField(errorText: formModel.passwordLengthError)
                        HStack {
                            Text("Symbols")
                            TextField("", text: $formModel.symbols)
                            .autoCapitalizationOff()
                            .disableAutocorrection(true)
                            .validatedField(errorText: formModel.symbolsError)
                        }
                        Picker(selection: self.$formModel.minSymbols, label: Text("Minimum Symbols")) {
                            ForEach(1..<10, id: \.self) {
                                Text(String($0))
                            }
                        }
                        Picker(selection: self.$formModel.minNumeric, label: Text("Minimum Numbers")) {
                            ForEach(1..<10, id: \.self) {
                                Text(String($0))
                            }
                        }
                        Picker(selection: self.$formModel.minUpperCase, label: Text("Minimum Upper Case")) {
                            ForEach(1..<10, id: \.self) {
                                Text(String($0))
                            }
                        }
                        Picker(selection: self.$formModel.minLowerCase, label: Text("Minimum Lower Case")) {
                            ForEach(1..<10, id: \.self) {
                                Text(String($0))
                            }
                        }
                    }
                }
            }
        }
}

struct CreatePasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordFormView(formModel: Binding.constant(CreatePasswordFormModel()), masterPasswords: Model.testModel().masterPasswords, includePadding: true, removeMasterPasswords: {_ in}, createMasterPassword: {})
    }
}
