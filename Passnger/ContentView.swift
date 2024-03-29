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
    @State private var addPasswordResult: Result<Void, Error>? = nil

    var body: some View {
        return NavigationView {
            Group {
                if model.passwordItems.count == 0 && self.model.masterPasswords.count == 0 {
                    IntroSetupView() { masterPasswordFormModel in
                        let masterPassword = MasterPassword(name: masterPasswordFormModel.hint, password: masterPasswordFormModel.password, keychainService: model.keychainService)
                        self.model.addMasterPassword(masterPassword, passwordText: masterPasswordFormModel.password, saveOnDevice: masterPasswordFormModel.saveOnDevice)
                    }
                } else if model.passwordItems.count == 0 {
                    VStack {
                        Text("You have no saved passwords.")
                        HStack(spacing: 0) {
                            Text("Press the  ")
                            Image(systemName: "plus")
                            Text("  button to create a password.")
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        SearchBar(text: $model.searchText)
                        PasswordsView(model: model) { selectedPasswordItem in
                            switch try! selectedPasswordItem.getPassword(keychainService: self.model.keychainService) {
                            case .cancelled:
                                return
                            case .value(let password):
                                guard let password = password else {
                                    self.passwordItemWithoutMasterPassword = selectedPasswordItem
                                    self.showGetMasterPassword = true
                                    return
                                }
                                self.showCopiedNotifier()
                                UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: password]], options: [.localOnly: true, .expirationDate: Date(timeIntervalSinceNow: 60)]);
                            }
                        }
                    }
                    .keyboardObserving()
                    .squareNotifier(text: "Copied to\nClipboard", showNotifier: self.showCopied)
                }
            }
            .masterPasswordAlert(masterPassword: self.passwordItemWithoutMasterPassword?.masterPassword, isPresented: $showGetMasterPassword) { masterPassword, passwordText, saveMasterPassword in
                let hashedPassword = MasterPassword.hashPassword(passwordText)
                self.model.addMasterPassword(masterPassword, passwordText: passwordText, saveOnDevice: saveMasterPassword)
                UIPasteboard.general.string = try! self.passwordItemWithoutMasterPassword?.getPassword(hashedMasterPassword: hashedPassword)
                self.passwordItemWithoutMasterPassword = nil
                self.showCopiedNotifier()
            }
            .navigationBarTitle(model.masterPasswords.count == 0 ? "Master Password" : "Passwords")
            .navigationBarItems(trailing: Button(action: {
                self.showCreatePassword = true;
            }) {
                if model.masterPasswords.count > 0 {
                    Image(systemName: "plus").imageScale(.large).padding()
                }
            }.sheet(isPresented: $showCreatePassword) {
                CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword) { passwordItem, hashedMasterPassword, onComplete in
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
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    private func showCopiedNotifier() {
        withAnimation {
            self.showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showCopied = false
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView(model: Model.testModel())
        }
        NavigationView {
            ContentView(model: Model(keychainService: "emptyService"))
        }
    }
}
