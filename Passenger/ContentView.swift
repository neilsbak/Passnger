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
    var showGetMasterPassword: Binding<Bool> {
        Binding<Bool>(get: { self.passwordItemWithoutMasterPassword != nil }, set: { showFlag in
            if !showFlag {
                self.passwordItemWithoutMasterPassword = nil
            }
        })
    }

    var body: some View {
        NavigationView {
            PasswordsView(model: model) { selectedPasswordItem in
                guard let password = try! selectedPasswordItem.getPassword() else {
                    self.passwordItemWithoutMasterPassword = selectedPasswordItem
                    return
                }
                UIPasteboard.general.string = password
            }.alert(isPresented: showGetMasterPassword, TextAlert(title: "Enter Master Password", placeholder: "Master Password") { passwordText in
                let hashedPassword = MasterPassword.hashPassword(passwordText ?? "")
                let doubleHashedPassword = MasterPassword.hashPassword(hashedPassword)
                if doubleHashedPassword != self.passwordItemWithoutMasterPassword!.masterPassword.doubleHashedPassword {
                    return false
                }
                UIPasteboard.general.string = try! self.passwordItemWithoutMasterPassword?.getPassword(hashedMasterPassword: hashedPassword)
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
