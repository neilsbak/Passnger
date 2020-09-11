//
//  ContentView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @ObservedObject var toolbar: ToolbarObservable

    private var showGetMasterPassword: Binding<Bool> {
        Binding<Bool>(
            get: { self.toolbar.getMasterPasswordReason != .none },
            set: { showFlag in
                if (!showFlag) {
                    self.toolbar.getMasterPasswordReason = .none
                }
            }
        )
    }
    var body: some View {
        Group {
            if self.model.passwordItems.count == 0 && self.model.masterPasswords.count == 0 && !toolbar.showCreatePassword {
                IntroSetupView() { masterPasswordFormModel in
                    let masterPassword = MasterPassword(name: masterPasswordFormModel.hint, password: masterPasswordFormModel.password, securityLevel: .protectedSave)
                    self.model.addMasterPassword(masterPassword, passwordText: masterPasswordFormModel.password)
                }
            } else if model.passwordItems.count == 0 {
                Text("You have no saved passwords.")
            } else {
                PasswordsView(model: model, selectedPassword: toolbar.selectedPassword) { passwordItem in
                    if (self.toolbar.selectedPassword == passwordItem) {
                        self.toolbar.selectedPassword = nil
                    } else {
                        self.toolbar.selectedPassword = passwordItem
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .macSafeSheet(isPresented: $toolbar.showCreatePassword) {
            CreatePasswordView(model: self.model, presentedAsModal: self.$toolbar.showCreatePassword) { passwordItem, hashedMasterPassword in
                self.model.addPasswordItem(passwordItem, hashedMasterPassword: hashedMasterPassword)
            }
        }.macSafeSheet(isPresented: self.showGetMasterPassword) {
            GetMasterPasswordView(
                masterPassword: self.toolbar.selectedPassword?.masterPassword,
                isPresented: self.showGetMasterPassword
            ) { (masterPassword, passwordText) in
                self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                self.toolbar.gotHashedMasterPassword(MasterPassword.hashPassword(passwordText))
            }
        }.macSafeSheet(isPresented: self.toolbar.showInfo) {
            PasswordItemSheet(passwordItem: self.toolbar.selectedPassword!, onCancel: {
                self.toolbar.showInfo.wrappedValue.toggle()
            }) { passwordItem in
                self.toolbar.changeInfoForPasswordItem(passwordItem, toModel: self.model)
                self.toolbar.showInfo.wrappedValue.toggle()
            }
        }
        .alert(isPresented: self.$toolbar.confirmDelete) { () -> Alert in
            Alert(title: Text("Delete Password?"), primaryButton: Alert.Button.destructive(Text("Delete")) {
                self.toolbar.deleteSelectedPassword(fromModel: self.model)
            }, secondaryButton: Alert.Button.cancel())
        }
    }
}

// Separate state for editing password item so that
// it only changes on submit
private struct PasswordItemSheet: View {
    @State var passwordItem: PasswordItem
    let onCancel: () -> Void
    let onSave: (PasswordItem) -> Void

    var body: some View {
        SheetView(onCancel: {
            self.onCancel()
        }, onSave: {
            self.onSave(self.passwordItem)
        }) {
            PasswordInfoView(passwordItem: self.$passwordItem)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel(), toolbar: ToolbarObservable())
    }
}
