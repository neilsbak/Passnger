//
//  CreatePasswordView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-25.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    typealias OnSave = (_ passwordItem: PasswordItem, _ hashedMasterPassword: String) -> Void

    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State private var formModel: CreatePasswordFormModel
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showCreateMasterPassword = false
    @State private var showGetMasterPassword = false
    let onSave: OnSave

    init(model: Model, presentedAsModal: Binding<Bool>, onSave: @escaping OnSave) {
        self.model = model
        self._presentedAsModal = presentedAsModal
        self.onSave = onSave
        var formModel = CreatePasswordFormModel()
        if model.masterPasswords.count == 1 {
            formModel.selectedMasterPassword = model.masterPasswords[0]
        }
        self._formModel = State(initialValue: formModel)
    }

    var body: some View {
        NavigationView {
            CreatePasswordFormView(model: model, formModel: $formModel, includePadding: true) {
                self.masterPasswordFormModel = MasterPasswordFormModel()
                self.showCreateMasterPassword = true
            }.sheet(isPresented: $showCreateMasterPassword) {
                NavigationView {
                    VStack {
                        MasterPasswordView(formModel: self.$masterPasswordFormModel)
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("Create Master Password", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button(action: {
                            self.showCreateMasterPassword = false
                        }) {
                            Text("Cancel")
                        },
                        trailing: Button(action: {
                            self.masterPasswordFormModel.hasSubmitted = true
                            if (self.masterPasswordFormModel.validate()) {
                                let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, securityLevel: .protectedSave)
                                self.model.addMasterPassword(masterPassword, passwordText: self.masterPasswordFormModel.password)
                                self.formModel.selectedMasterPassword = masterPassword
                                self.showCreateMasterPassword = false
                            }
                        }) {
                            Text("Save")
                    })
                }
            }.alert(isPresented: $showGetMasterPassword, TextAlert(title: "Enter Master Password", placeholder: "Master Password") { passwordText in
                let doubleHashedPassword = MasterPassword.doubleHashPassword(passwordText ?? "")
                if doubleHashedPassword != self.formModel.selectedMasterPassword!.doubleHashedPassword {
                    return false
                }
                let hashedPassword = MasterPassword.hashPassword(passwordText!)
                let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName)
                self.onSave(passwordItem, hashedPassword)
                return true
            })
                .navigationBarTitle("Create Password", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        self.presentedAsModal = false
                    }) {
                        Text("Cancel")
                    },
                    trailing: Button(action: {
                        self.formModel.hasSubmitted = true
                        if self.formModel.validate()  {
                            self.presentedAsModal = false
                            guard let selectedMasterPassword = self.formModel.selectedMasterPassword else { return }
                            let fetched = try! selectedMasterPassword.getHashedPassword()
                            switch fetched {
                            case .cancelled:
                                return
                            case .value(let hashedMasterPassword):
                                guard let hashedMasterPassword = hashedMasterPassword else {
                                    self.showGetMasterPassword = true
                                    return
                                }
                                let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName)
                                self.onSave(passwordItem, hashedMasterPassword)
                            }
                        }
                    }) {
                        Text("Save")
                    }
            )

        }
    }

}


struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _, _ in }
    }
}
