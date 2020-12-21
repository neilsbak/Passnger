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
    @State private var errorMessage: String? = nil

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

    // handles any error that can happen when generating password
    // return true if there were no errors
    private func tryAddPassword(block: () throws -> Void) -> Bool {
        do {
            try block()
            return true
        } catch PasswordGenerator.PasswordGeneratorError.passwordError(_) {
            self.errorMessage = "Try incrementing the Renewal Number, or try a different password configuration."
        } catch {
            self.errorMessage = "There was an unexpected error."
        }
        return false
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
            CreatePasswordView(model: self.model, presentedAsModal: self.$toolbar.showCreatePassword) { passwordItem, hashedMasterPassword in
                return self.tryAddPassword {
                    try self.model.addPasswordItem(passwordItem, hashedMasterPassword: hashedMasterPassword)
                }
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
            PasswordItemSheet(
                passwordItem: self.toolbar.selectedPassword!,
                password: try? self.toolbar.selectedPassword!.getPassword(keychainService: self.model.keychainService).password,
                onCancel: {
                    self.toolbar.showInfo.wrappedValue.toggle()
                }) { passwordItem in
                let success = self.tryAddPassword {
                    try self.toolbar.changeInfoForPasswordItem(passwordItem)
                }
                if success {
                    self.toolbar.showInfo.wrappedValue.toggle()
                }
            }
        }
        .alert(isPresented: self.$toolbar.confirmDelete) { () -> Alert in
            Alert(title: Text("Delete Password?"), primaryButton: Alert.Button.destructive(Text("Delete")) {
                self.toolbar.deleteSelectedPassword()
            }, secondaryButton: Alert.Button.cancel())
        }
        .alert(isPresented: Binding<Bool>(get: { self.errorMessage != nil }, set: { p in self.errorMessage = p ? self.errorMessage : nil })) { () -> Alert in
            Alert(title: Text("Could Not Generate Password"), message: Text(self.errorMessage ?? "Error"), dismissButton: Alert.Button.cancel() {
                self.errorMessage = nil
            })
        }
    }
}

// Separate state for editing password item so that
// it only changes on submit
private struct PasswordItemSheet: View {
    @State var passwordItem: PasswordItem
    let password: String?
    let onCancel: () -> Void
    let onSave: (PasswordItem) -> Void

    var body: some View {
        SheetView(onCancel: {
            self.onCancel()
        }, onSave: {
            self.onSave(self.passwordItem)
        }) {
            PasswordInfoView(passwordItem: self.$passwordItem, password: self.password)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel(), toolbar: ToolbarObservable(model: Model.testModel()))
    }
}
