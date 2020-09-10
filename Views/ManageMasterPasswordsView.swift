//
//  ManageMasterPasswordsView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-08.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ManageMasterPasswordsView: View {
    let masterPasswords: [MasterPassword]
    let onCancel: () -> Void
    let onDelete: (IndexSet) -> Void
    let onCreate: (MasterPassword, String) -> Void

    @State private var showCreateMasterPassword = false
    @State private var masterPasswordFormModel = MasterPasswordFormModel()

    private var mainBody: some View {
        List {
            ForEach(self.masterPasswords) { masterPassword in
                Text(masterPassword.name)
            }
            .onDelete(perform: onDelete)
        }
    }

    private var iOSBody: some View {
        mainBody
        .navigationBarItems(
            leading: Button(action: self.onCancel) { Text("Cancel") },
            trailing: HStack {
                EditButton()
                Button(action: {self.showCreateMasterPassword = true }) { Image(systemName: "plus")}
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
            }
        )
    }

    private var macOSBody: some View {
        mainBody
    }

    var body: some View {
        SheetScaffoldView(title: "Master Passwords", onCancel: nil, onSave: nil) {
            #if os(iOS)
            self.iOSBody
            #else
            self.macOSBody
            #endif
        }.sheet(isPresented: self.$showCreateMasterPassword, title: "Create Master Password", onCancel: { self.showCreateMasterPassword = false }, onSave: submitMasterPassword) {
            ScrollView {
                MasterPasswordView(formModel: self.$masterPasswordFormModel).padding()
            }
        }
    }

    private func submitMasterPassword() {
        self.masterPasswordFormModel.hasSubmitted = true
        if (self.masterPasswordFormModel.validate()) {
            let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, securityLevel: .protectedSave)
            self.onCreate(masterPassword, self.masterPasswordFormModel.password)
            self.showCreateMasterPassword = false
        }
    }

}

struct ManageMasterPasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageMasterPasswordsView(masterPasswords: Model.testModel().masterPasswords, onCancel: {}, onDelete: {_ in}, onCreate: {_,_ in })
    }
}
