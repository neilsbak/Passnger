//
//  CreatePasswordView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-05-30.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State var formModel = CreatePasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showCreateMasterPassword = false
    let onSave: (_ passwordItem: PasswordItem) -> Void

    var body: some View {
        VStack {
            CreatePasswordFormView(model: model, formModel: $formModel) {
                self.masterPasswordFormModel = MasterPasswordFormModel()
                self.showCreateMasterPassword = true
            }
            HStack {
                Button(action: {
                    self.presentedAsModal = false
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    self.formModel.hasSubmitted = true
                    if self.formModel.validate()  {
                        self.presentedAsModal = false
                        self.onSave(PasswordItem(userName: self.formModel.username, password: try! self.formModel.selectedMasterPassword!.passwordKeychainItem.readPassword(), url: self.formModel.websiteUrl, serviceName: self.formModel.websiteName))
                    }
                }) {
                    Text("Save")
                }
            }
            .padding()
            .sheet(isPresented: $showCreateMasterPassword) {
                VStack {
                    MasterPasswordView(formModel: self.$masterPasswordFormModel)
                    HStack {
                        Button(action: {
                            self.showCreateMasterPassword = false
                        }) {
                            Text("Cancel")
                        }
                        Spacer()
                        Button(action: {
                            self.masterPasswordFormModel.hasSubmitted = true
                            if (self.masterPasswordFormModel.validate()) {
                                let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password)
                                self.model.addMasterPassword(masterPassword)
                                self.formModel.selectedMasterPassword = masterPassword
                                self.showCreateMasterPassword = false
                            }
                        }) {
                            Text("Save")
                        }
                    }
                }
            }
        }
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _ in }
    }
}
