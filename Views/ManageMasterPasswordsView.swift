//
//  ManageMasterPasswordsView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-08.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ManageMasterPasswordsView: View {
    @ObservedObject var model: Model
    let onCancel: () -> Void

    @State private var showCreateMasterPassword = false
    @State private var masterPasswordFormModel = MasterPasswordFormModel()
    
    private func mainBody() -> some View {
        List {
        ForEach(model.masterPasswords) { masterPassword in
            HStack {
                VStack(alignment: .leading) {
                    Text(masterPassword.name).bold()
                    Text(masterPassword.passwordIsSaved ? "Saved on device" : "Not saved on device").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                if masterPassword.passwordIsSaved {
                    Button(action: { model.removeMasterPasswordKeychainItem(masterPassword) }) {
                        Text("Forget")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
        }.onDelete(perform: {indexSet in
            model.removeMasterPasswords(atOffsets: indexSet)
        })
    }.listStyle(.plain)
    }
    
    private var sheetScaffoldView: some View {
#if os(iOS)
        return SheetScaffoldView(title: "Master Passwords", onCancel: nil, onSave: nil) {
            mainBody()
                .navigationBarItems(
                    leading: Button(action: self.onCancel) { Text("Cancel").padding([.trailing, .top, .bottom]) },
                    trailing: HStack {
                        Button(action: {self.showCreateMasterPassword = true }) {
                            Image(systemName: "plus").imageScale(.large).padding()
                        }
                    }
                )
        }
#else
        return SheetScaffoldView(title: "Master Passwords", onCancel: onCancel, onSave: nil) {
            VStack(alignment: .leading) {
                mainBody()
                Button(action: { self.showCreateMasterPassword = true }) {
                    Text("Add Master Password")
                }.frame(height: 20)
            }
        }
#endif
    }
    
    var body: some View {
        self.sheetScaffoldView.sheet(isPresented: self.$showCreateMasterPassword, title: "Create Master Password", onCancel: { self.showCreateMasterPassword = false }, onSave: submitMasterPassword) {
            ScrollView {
                MasterPasswordFormView(formModel: self.$masterPasswordFormModel).padding()
            }
        }
    }
    
    private func submitMasterPassword() {
        self.masterPasswordFormModel.hasSubmitted = true
        if (self.masterPasswordFormModel.validate()) {
            let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, keychainService: model.keychainService)
            model.addMasterPassword(masterPassword, passwordText: self.masterPasswordFormModel.password, saveOnDevice: self.masterPasswordFormModel.saveOnDevice)
            self.showCreateMasterPassword = false
        }
    }
    
}

#if os(macOS)
struct ListButton: View {
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(nsImage: NSImage(named: imageName)!)
                .resizable()
        } //
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 20, height: 20)
    }
}
#endif

struct ManageMasterPasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageMasterPasswordsView(model: Model.testModel(), onCancel: {})
    }
}
