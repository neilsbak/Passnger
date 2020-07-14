//
//  ContentView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @State private var showCreatePassword = false
    @State private var passwordItemWithoutMasterPassword: PasswordItem?
    @State private var showGetMasterPassword = false

    var body: some View {
        NavigationView {
            PasswordsView(model: model) { selectedPasswordItem in
                guard let password = try! selectedPasswordItem.getPassword() else {
                    self.passwordItemWithoutMasterPassword = selectedPasswordItem
                    self.showGetMasterPassword = true
                    return
                }
                UIPasteboard.general.string = password
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
            .navigationBarTitle("Passwords")
                .navigationBarItems(trailing: Button(action: {
                    self.showCreatePassword = true;
                }) {
                    Image(systemName: "plus")
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
