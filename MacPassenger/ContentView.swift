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
        VStack {
            PasswordsView(model: model, selectedPassword: toolbar.selectedPassword) { passwordItem in
                self.toolbar.selectedPassword = passwordItem
            }
        }.background(EmptyView().sheet(isPresented: $toolbar.showCreatePassword) {
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
