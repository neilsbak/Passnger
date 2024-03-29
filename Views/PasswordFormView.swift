//
//  PasswordFormView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-23.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordFormView: View {
    static private let numberFormatter = NumberFormatter()

    @Binding var formModel: PasswordFormModel
    @ObservedObject var model: Model
    let includePadding: Bool

    @State private var showPasswordComponents = false
    @State private var showManageMasterPasswords = false

    @ViewBuilder
    var masterPasswordHeaderView: some View {
        VStack(alignment: .leading) {
            Button(action: { self.showManageMasterPasswords = true }) {
                Text("Manage Master Passwords")
            }.buttonStyle(BorderlessButtonStyle())
        }.padding(.top)
    }

    @ViewBuilder
    var passwordComponentsHeaderView: some View {
        VStack(alignment: .leading) {
            Button(action: { self.showPasswordComponents.toggle() }) {
                Text((self.showPasswordComponents ? "Hide" : "Show") + " Password Components")
            }.buttonStyle(BorderlessButtonStyle())
        }
    }

    var body: some View {
        let labelWidth: CGFloat = 200
        return AlignedForm {
            AlignedSection(header: masterPasswordHeaderView) {
                Picker(selection: self.$formModel.selectedMasterPassword, label: Text("Master Password")) {
                    ForEach(model.masterPasswords) {
                        Text($0.name).tag($0 as MasterPassword?)
                    }
                }.validatedField(errorText: formModel.masterPasswordError)
            }
            AlignedSection(header: EmptyView()) {
                TextField("Website URL", text: $formModel.websiteUrl)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                    .validatedField(errorText: formModel.websiteUrlError)
                TextField("Description", text: $formModel.websiteName)
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                    .validatedField(errorText: formModel.websiteNameError)
                TextField("Username", text: $formModel.username)
                    .autoCapitalizationOff()
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                    .validatedField(errorText: formModel.usernameError)
            }
            AlignedSection(header: passwordComponentsHeaderView) {
                if showPasswordComponents {
                    Picker(selection: self.$formModel.passwordLength, label: Text("Password Length").frame(minWidth: labelWidth, alignment: .leading)) {
                        ForEach(1..<50, id: \.self) {
                            Text(String($0))
                        }
                    }.validatedField(errorText: formModel.passwordLengthError)
                    HStack {
                        Text("Symbols").frame(minWidth: labelWidth, alignment: .leading)
                        TextField("", text: $formModel.symbols)
                            .multilineTextAlignment(.trailing)
                            .autoCapitalizationOff()
                            .disableAutocorrection(true)
                            .frame(maxWidth: .infinity)
                            .validatedField(errorText: formModel.symbolsError)
                    }
                    Picker(selection: self.$formModel.minSymbols, label: Text("Minimum Symbols").frame(minWidth: labelWidth, alignment: .leading)) {
                        ForEach(0..<10, id: \.self) {
                            Text(String($0))
                        }
                    }
                    Picker(selection: self.$formModel.minNumeric, label: Text("Minimum Numbers").frame(minWidth: labelWidth, alignment: .leading)) {
                        ForEach(0..<10, id: \.self) {
                            Text(String($0))
                        }
                    }
                    Picker(selection: self.$formModel.minUpperCase, label: Text("Minimum Upper Case").frame(minWidth: labelWidth, alignment: .leading)) {
                        ForEach(0..<10, id: \.self) {
                            Text(String($0))
                        }
                    }
                    Picker(selection: self.$formModel.minLowerCase, label: Text("Minimum Lower Case").frame(minWidth: labelWidth, alignment: .leading)) {
                        ForEach(0..<10, id: \.self) {
                            Text(String($0))
                        }
                    }
                }
            }.macSafeSheet(isPresented: self.$showManageMasterPasswords) {
                ManageMasterPasswordsView(model: model, onCancel: { self.showManageMasterPasswords = false })
            }
        }
        .keyboardObserving()
        .frame(minHeight: 340)
    }
}

struct PasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        PasswordFormView(formModel: Binding.constant(PasswordFormModel()), model: Model.testModel(), includePadding: true)
    }
}
