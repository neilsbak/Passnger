//
//  ContentView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // Add nav button not clickable after dismiss unless we have this
    // see https://stackoverflow.com/questions/58512344
    @Environment(\.presentationMode) var presentation

    @ObservedObject var model: Model
    @State private var showCreatePassword = false
    @State private var passwordItemWithoutMasterPassword: PasswordItem?
    @State private var showGetMasterPassword = false
    @State private var showCopied = false

    lazy var blah = model.$passwordItems

    var body: some View {
        NavigationView {
            Group {
                if self.model.masterPasswords.count == 0 {
                    IntroSetupView() { masterPasswordFormModel in
                        let masterPassword = MasterPassword(name: masterPasswordFormModel.hint, password: masterPasswordFormModel.password, securityLevel: .protectedSave)
                        self.model.addMasterPassword(masterPassword)
                    }
                } else if model.passwordItems.count == 0 {
                    Text("You have no saved passwords.")
                } else {
                    PasswordsView(model: model) { selectedPasswordItem in
                        guard let password = try! selectedPasswordItem.getPassword() else {
                            self.passwordItemWithoutMasterPassword = selectedPasswordItem
                            self.showGetMasterPassword = true
                            return
                        }
                        withAnimation {
                            self.showCopied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.showCopied = false
                        }
                        UIPasteboard.general.string = password
                    }
                    .squareNotifier(text: "Copied to\nClipboard", showNotifier: self.showCopied)
                }
            }
            .masterPasswordAlert(masterPassword: self.passwordItemWithoutMasterPassword?.masterPassword, isPresented: $showGetMasterPassword) { passwordText in
                    let hashedPassword = MasterPassword.hashPassword(passwordText)
                    UIPasteboard.general.string = try! self.passwordItemWithoutMasterPassword?.getPassword(hashedMasterPassword: hashedPassword)
                    self.model.savePassword(passwordText, forMasterPassword: self.passwordItemWithoutMasterPassword!.masterPassword)
                    self.passwordItemWithoutMasterPassword = nil
            }
            .navigationBarTitle(model.masterPasswords.count == 0 ? "Master Password" : "Passwords")
            .navigationBarItems(trailing: Button(action: {
                self.showCreatePassword = true;
            }) {
                if model.masterPasswords.count > 0 {
                    Image(systemName: "plus").padding()
                }
            }.sheet(isPresented: $showCreatePassword) {
                CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword) { passwordItem in
                    self.model.addPasswordItem(passwordItem)
                }
            })
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
