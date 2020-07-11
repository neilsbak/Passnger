//
//  CreatePasswordView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-25.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State private var formModel = CreatePasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showCreateMasterPassword = false
    @State private var showGetMasterPassword = false
    let onSave: (_ passwordItem: PasswordItem) -> Void

    var body: some View {
        NavigationView {
            CreatePasswordFormView(model: model, formModel: $formModel) {
                self.masterPasswordFormModel = MasterPasswordFormModel()
                self.showCreateMasterPassword = true
            }.sheet(isPresented: $showCreateMasterPassword) {
                NavigationView {
                    MasterPasswordView(formModel: self.$masterPasswordFormModel)
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
                                    self.model.addMasterPassword(masterPassword)
                                    self.formModel.selectedMasterPassword = masterPassword
                                    self.showCreateMasterPassword = false
                                }
                            }) {
                                Text("Save")
                        })
                }
            }.alert(isPresented: $showGetMasterPassword, TextAlert(title: "Enter Master Password", placeholder: "Master Password") { passwordText in
                let hashedPassword = MasterPassword.hashPassword(passwordText ?? "")
                let doubleHashedPassword = MasterPassword.hashPassword(hashedPassword)
                if doubleHashedPassword != self.formModel.selectedMasterPassword!.doubleHashedPassword {
                    return false
                }
                let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, hashedMasterPassword: hashedPassword, url: self.formModel.websiteUrl, serviceName: self.formModel.websiteName)
                self.onSave(passwordItem)
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
                            guard let hashedMasterPassword = try! self.formModel.selectedMasterPassword?.getHashedPassword() else {
                                self.showGetMasterPassword = true
                                return
                            }
                            let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, hashedMasterPassword: hashedMasterPassword, url: self.formModel.websiteUrl, serviceName: self.formModel.websiteName)
                            self.onSave(passwordItem)
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
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _ in }
    }
}
