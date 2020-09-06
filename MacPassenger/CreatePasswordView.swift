//
//  CreatePasswordView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-05-30.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    typealias OnSave = (_ passwordItem: PasswordItem, _ hashedMasterPassword: String) -> Void

    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State var formModel = CreatePasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showCreateMasterPassword = false
    @State private var showGetMasterPassword = false
    let onSave: OnSave

    init(model: Model, presentedAsModal: Binding<Bool>, onSave: @escaping OnSave) {
        self.model = model
        self._presentedAsModal = presentedAsModal
        self.onSave = onSave
        var formModel = CreatePasswordFormModel()
        if model.masterPasswords.count > 0 {
            formModel.selectedMasterPassword = model.masterPasswords[0]
        }
        self._formModel = State(initialValue: formModel)
    }


    var body: some View {
        SheetView(onSave: {
            self.formModel.hasSubmitted = true
            if self.formModel.validate()  {
                self.presentedAsModal = false
                guard let selectedMasterPassword = self.formModel.selectedMasterPassword else {
                    return
                }
                switch try! selectedMasterPassword.getHashedPassword() {
                case .cancelled:
                    return
                case.value(let hashedMasterPassword):
                    if let hashedMasterPassword = hashedMasterPassword {
                        let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName, passwordScheme: try! self.formModel.passwordScheme())
                        self.onSave(passwordItem, hashedMasterPassword)
                    } else {
                        self.showGetMasterPassword = true
                    }
                }
            }
        }, onCancel: {
            self.presentedAsModal = false
        }) {
            CreatePasswordFormView(formModel: $formModel, masterPasswords: self.model.masterPasswords, includePadding: false, removeMasterPasswords: { self.model.removeMasterPasswords(atOffsets: $0) }) {
                self.masterPasswordFormModel = MasterPasswordFormModel()
                self.showCreateMasterPassword = true
            }
        }
        .background(EmptyView().sheet(isPresented: $showCreateMasterPassword) {
            SheetView(onSave: {
                self.masterPasswordFormModel.hasSubmitted = true
                if (self.masterPasswordFormModel.validate()) {
                    let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, securityLevel: .protectedSave)
                    self.model.addMasterPassword(masterPassword, passwordText: self.masterPasswordFormModel.password)
                    self.formModel.selectedMasterPassword = masterPassword
                    self.showCreateMasterPassword = false
                }
            }, onCancel: {
                self.showCreateMasterPassword = false
            }) {
                VStack {
                    Text("Create Master Password")
                    MasterPasswordView(formModel: self.$masterPasswordFormModel)
                }
            }
        }.background(EmptyView().sheet(isPresented: $showGetMasterPassword) {
            GetMasterPasswordView(masterPassword: self.formModel.selectedMasterPassword!, showGetMasterPassword: self.$showGetMasterPassword) { (masterPassword, passwordText) in
                self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName, passwordScheme: try! self.formModel.passwordScheme())
                self.onSave(passwordItem, MasterPassword.hashPassword(passwordText))
            }
        }))
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _, _ in }
    }
}
