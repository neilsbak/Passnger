//
//  CreatePasswordView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-09.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    typealias OnSave = (_ passwordItem: PasswordItem, _ hashedMasterPassword: String, _ onComplete: @escaping (Bool) -> Void) -> Void
    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    @State var formModel = PasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showGetMasterPassword = false
    // need to store this to tell save button spinner to stop after getting master password
    @State private var onSaveComplete: (() -> Void)? = nil
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
        SheetScaffoldView(title: "Create Password", onCancel: { self.presentedAsModal = false },  onSaveComplete: { onComplete in
            self.formModel.hasSubmitted = true
            if self.formModel.validate()  {
                guard let selectedMasterPassword = self.formModel.selectedMasterPassword else {
                    onComplete()
                    return
                }
                switch selectedMasterPassword.getHashedPassword(keychainService: self.model.keychainService) {
                case .cancelled:
                    onComplete()
                    return
                case.value(let hashedMasterPassword):
                    if let hashedMasterPassword = hashedMasterPassword {
                        let passwordItem = PasswordItem(userName: self.formModel.username, masterPassword: self.formModel.selectedMasterPassword!, url: self.formModel.websiteUrl, resourceDescription: self.formModel.websiteName, passwordScheme: try! self.formModel.passwordScheme())
                        self.onSave(passwordItem, hashedMasterPassword) { success in
                            self.presentedAsModal = !success
                            onComplete()
                        }
                    } else {
                        // need to get master password in separate dialog, so save the onComplete
                        // until after we get that and call onSave
                        self.onSaveComplete = onComplete
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
                self.onSave(passwordItem, MasterPassword.hashPassword(passwordText)) { success in
                    self.onSaveComplete?()
                    self.onSaveComplete = nil
                    print("success: \(success)")
                    self.presentedAsModal = !success
                }
        }
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding.constant(true), onSave: {_,_,_ in })
    }
}
