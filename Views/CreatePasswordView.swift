//
//  CreatePasswordView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-09.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    typealias OnSave = (_ passwordItem: PasswordItem, _ hashedMasterPassword: String) -> Void
    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State var formModel = PasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showGetMasterPassword = false
    let onSave: OnSave

    init(model: Model, presentedAsModal: Binding<Bool>, onSave: @escaping OnSave) {
        self.model = model
        self._presentedAsModal = presentedAsModal
        self.onSave = onSave
        var formModel = PasswordFormModel()
        if model.masterPasswords.count > 0 {
            formModel.selectedMasterPassword = model.masterPasswords[0]
        }
        self._formModel = State(initialValue: formModel)
    }


    var body: some View {
        SheetScaffoldView(title: "Create Password", onCancel: { self.presentedAsModal = false },  onSave: {
            self.formModel.hasSubmitted = true
            if self.formModel.validate()  {
                guard let selectedMasterPassword = self.formModel.selectedMasterPassword else {
                    return
                }
                switch selectedMasterPassword.getHashedPassword(keychainService: self.model.keychainService) {
                case .cancelled:
                    return
                case.value(let hashedMasterPassword):
                    if let hashedMasterPassword = hashedMasterPassword {
                        let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName, passwordScheme: try! self.formModel.passwordScheme())
                        self.onSave(passwordItem, hashedMasterPassword)
                        self.presentedAsModal = false
                    } else {
                        self.showGetMasterPassword = true
                    }
                }
            }
        }) {
            PasswordFormView(
                formModel: $formModel,
                masterPasswords: self.model.masterPasswords,
                includePadding: false,
                removeMasterPasswords: { self.model.removeMasterPasswords(atOffsets: $0) },
                createMasterPassword: { masterPassword, passwordText in
                    self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                }
            )}
        .getMasterPassword(masterPassword: self.formModel.selectedMasterPassword, isPresented: self.$showGetMasterPassword) { (masterPassword, passwordText) in
                self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName, passwordScheme: try! self.formModel.passwordScheme())
                self.onSave(passwordItem, MasterPassword.hashPassword(passwordText))
                self.presentedAsModal = false
        }
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding.constant(true), onSave: { _, _ in })
    }
}
