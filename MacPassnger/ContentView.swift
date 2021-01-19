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
    @State private var addPasswordResult: Result<Void, Error>? = nil

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
                VStack {
                    Text("Your Master Password").font(.title).padding(.top)
                    IntroSetupView() { masterPasswordFormModel in
                        let masterPassword = MasterPassword(name: masterPasswordFormModel.hint, password: masterPasswordFormModel.password, securityLevel: .protectedSave)
                        self.model.addMasterPassword(masterPassword, passwordText: masterPasswordFormModel.password)
                    }
                }
            } else if model.passwordItems.count == 0 {
                VStack {
                    Text("You have no saved passwords.")
                    HStack(spacing: 0) {
                        Text("Press the  ")
                        Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                        Text("  button to create a password.")
                    }
                }
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
            CreatePasswordView(model: self.model, presentedAsModal: self.$toolbar.showCreatePassword) { passwordItem, hashedMasterPassword, onComplete in
                self.model.addPasswordItem(passwordItem, hashedMasterPassword: hashedMasterPassword) { result in
                    self.addPasswordResult = result
                    switch result {
                    case .failure(_):
                        onComplete(false)
                    case .success(_):
                        onComplete(true)
                    }
                }
            }.passwordGeneratorAlert(result: self.$addPasswordResult)
        }.macSafeSheet(isPresented: self.showGetMasterPassword) {
            GetMasterPasswordView(
                masterPassword: self.toolbar.selectedPassword?.masterPassword,
                isPresented: self.showGetMasterPassword
            ) { (masterPassword, passwordText) in
                self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                self.toolbar.gotHashedMasterPassword(MasterPassword.hashPassword(passwordText))
            }
        }.macSafeSheet(isPresented: self.toolbar.showInfo) {
            SheetView(onCancel: { self.toolbar.showInfo.wrappedValue.toggle() } ) {
                PasswordInfoView(
                    passwordItem: self.toolbar.selectedPassword!,
                    hashedMasterPassword: self.toolbar.selectedPassword!.masterPassword.getHashedPassword(keychainService: self.model.keychainService).password ?? self.toolbar.showInfoHashedMasterPassword,
                    model: self.model
                )
            }
        }
        //mac workaround using .background for stacking alerts, similar to macSafeSheet stacking sheets
        .background(EmptyView().alert(isPresented: self.$toolbar.confirmDelete) { () -> Alert in
            Alert(title: Text("Delete Password?"), primaryButton: Alert.Button.destructive(Text("Delete")) {
                self.toolbar.deleteSelectedPassword()
            }, secondaryButton: Alert.Button.cancel())
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel(), toolbar: ToolbarObservable(model: Model.testModel()))
    }
}
