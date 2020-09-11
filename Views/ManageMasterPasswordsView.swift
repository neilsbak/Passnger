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
    @State private var selectedMasterPassword: MasterPassword? = nil

    private func mainBody(onTap: ((MasterPassword) -> Void)? = nil) -> some View {
        List {
            ForEach(self.masterPasswords) { masterPassword in
                Text(masterPassword.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture { onTap?(masterPassword) }
                    .listRowBackground(self.selectedMasterPassword == masterPassword ? Color.blue : Color.clear)
            }
            .onDelete(perform: onDelete)
        }
    }

    private var sheetScaffoldView: some View {
        #if os(iOS)
        return SheetScaffoldView(title: "Master Passwords", onCancel: nil, onSave: nil) {
            mainBody()
            .navigationBarItems(
                leading: Button(action: self.onCancel) { Text("Cancel") },
                trailing: HStack {
                    EditButton()
                    Button(action: {self.showCreateMasterPassword = true }) { Image(systemName: "plus")}
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
                }
            )
        }
        #else
        return SheetScaffoldView(title: "Master Passwords", onCancel: onCancel, onSave: nil) {
            VStack {
                mainBody {
                    if self.selectedMasterPassword == $0 {
                        self.selectedMasterPassword = nil
                    } else {
                        self.selectedMasterPassword = $0
                    }
                }
                HStack(spacing: 0) {
                    ListButton(imageName: NSImage.addTemplateName) {
                        self.showCreateMasterPassword = true
                    }
                    Divider()
                    ListButton(imageName: NSImage.removeTemplateName) {
                        guard let masterPassword = self.selectedMasterPassword else { return }
                        guard let index = self.masterPasswords.firstIndex(of: masterPassword) else { return }
                        self.onDelete(IndexSet(integer: index))
                    }.disabled(self.selectedMasterPassword == nil)
                    Divider()
                    Spacer()
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
            let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password, securityLevel: .protectedSave)
            self.onCreate(masterPassword, self.masterPasswordFormModel.password)
            self.showCreateMasterPassword = false
        }
    }

}

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

struct ManageMasterPasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageMasterPasswordsView(masterPasswords: Model.testModel().masterPasswords, onCancel: {}, onDelete: {_ in}, onCreate: {_,_ in })
    }
}
