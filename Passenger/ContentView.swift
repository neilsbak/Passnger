//
//  ContentView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // but is swiftUi? Add nav button not clickable after dismiss unless we have this
    // see https://stackoverflow.com/questions/58512344
    @Environment(\.presentationMode) var presentation

    @ObservedObject var model: Model
    @State private var showCreatePassword = false
    @State private var passwordItemWithoutMasterPassword: PasswordItem?
    @State private var showGetMasterPassword = false
    @State private var masterPasswordFormModel = MasterPasswordFormModel()

    lazy var blah = model.$passwordItems

    var body: some View {
        NavigationView {
            Group {
                if self.model.masterPasswords.count == 0 {
                    VStack {
                        Text("Enter you master password to get started. This will be the only password you need to remember, but should only be known by you and not written down anywhere.")
                        MasterPasswordView(formModel: self.$masterPasswordFormModel)
                        Button(action: {
                            if self.masterPasswordFormModel.validate() {
                                let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, securityLevel: .protectedSave)
                                self.model.addMasterPassword(masterPassword)
                                self.masterPasswordFormModel = MasterPasswordFormModel()
                            }
                        }) {
                            Text("Submit")
                        }
                        Spacer()
                    }.padding()
                } else if model.passwordItems.count == 0 {
                    Text("You have no saved passwords.")
                } else {
                    PasswordsView(model: model) { selectedPasswordItem in
                        guard let password = try! selectedPasswordItem.getPassword() else {
                            self.passwordItemWithoutMasterPassword = selectedPasswordItem
                            self.showGetMasterPassword = true
                            return
                        }
                        UIPasteboard.general.string = password
                    }
                }
            }.alert(isPresented: $showGetMasterPassword, TextAlert(title: "Enter Master Password", placeholder: "Master Password") { passwordText in
                let doubleHashedPassword = MasterPassword.doubleHashPassword(passwordText ?? "")
                if doubleHashedPassword != self.passwordItemWithoutMasterPassword!.masterPassword.doubleHashedPassword {
                    return false
                }
                let hashedPassword = MasterPassword.hashPassword(passwordText!)
                UIPasteboard.general.string = try! self.passwordItemWithoutMasterPassword?.getPassword(hashedMasterPassword: hashedPassword)
                self.passwordItemWithoutMasterPassword = nil
                return true
            })
                .navigationBarTitle(model.masterPasswords.count == 0 ? "Master Password" : "Passwords")
                .navigationBarItems(trailing: Button(action: {
                    self.showCreatePassword = true;
                }) {
                    if model.masterPasswords.count > 0 {
                        Image(systemName: "plus")
                    }
                }.sheet(isPresented: $showCreatePassword) {
                    CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword) { passwordItem in
                        self.model.addPasswordItem(passwordItem)
                    }
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView(model: Model.testModel())
        }
    }
}
