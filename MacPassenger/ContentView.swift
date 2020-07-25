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

    var body: some View {
        Group {
            if self.model.masterPasswords.count == 0 && !toolbar.showCreatePassword {
                IntroSetupView() { masterPasswordFormModel in
                    let masterPassword = MasterPassword(name: masterPasswordFormModel.hint, password: masterPasswordFormModel.password, securityLevel: .protectedSave)
                    self.model.addMasterPassword(masterPassword)
                }
            } else if model.passwordItems.count == 0 {
                Text("You have no saved passwords.")
            } else {
                PasswordsView(model: model, selectedPassword: toolbar.selectedPassword) { passwordItem in
                    self.toolbar.selectedPassword = passwordItem
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EmptyView().sheet(isPresented: $toolbar.showCreatePassword) {
            CreatePasswordView(model: self.model, presentedAsModal: self.$toolbar.showCreatePassword) { passwordItem in
                self.model.addPasswordItem(passwordItem)
            }
        }.background(EmptyView().sheet(isPresented: self.$toolbar.showGetMasterPassword) {
            GetMasterPasswordView(masterPassword: self.toolbar.selectedPassword!.masterPassword, showGetMasterPassword: self.$toolbar.showGetMasterPassword) { (hashedMasterPassword) in
                self.toolbar.copyPassword(hashedMasterPassword: hashedMasterPassword)
            }}
        ))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel(), toolbar: ToolbarObservable())
    }
}
