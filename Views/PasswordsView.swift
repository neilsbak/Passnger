//
//  PasswordsView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordsView: View {
    @ObservedObject var model: Model
    let selectedPassword: PasswordItem?
    let onSelected: ((PasswordItem) -> Void)?

    init(model: Model, selectedPassword: PasswordItem? = nil, onSelected: ((PasswordItem) -> Void)? = nil) {
        self.model = model
        self.selectedPassword = selectedPassword
        self.onSelected = onSelected
    }

    private let rowHeight: CGFloat = 44

    private func rowBody(passwordItem: PasswordItem) -> some View {
        #if os(macOS)
            // have padding on mac so it looks better for selected cell
            let padding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        #else
            let padding = EdgeInsets()
        #endif
        return PasswordItemRow(passwordItem: passwordItem, model: self.model)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: self.rowHeight)
            .padding(padding)
            .contentShape(Rectangle())
            .onTapGesture {
                self.onSelected?(passwordItem)
            }.listRowBackground((self.selectedPassword == passwordItem ? Color.blue : Color.clear).frame(height: self.rowHeight))
    }

    var body: some View {
        List {
            ForEach(model.shownPasswordItems) { item in
                self.rowBody(passwordItem: item)
            }.onDelete() { indexSet in
                self.model.removePasswordItems(atOffsets: indexSet)
            }
        }.listStyle(PlainListStyle())
    }
}

struct PasswordItemRow: View {
    @State private var hashedMasterPassword: String?
    @State private var showGetMasterPassword = false
    @State private var linkIsActive = false
    let passwordItem: PasswordItem
    let model: Model
    @State private var errorMessage: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(passwordItem.resourceDescription)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(passwordItem.userName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            #if os(iOS)
            Button(action: {
                switch self.passwordItem.masterPassword.getHashedPassword(keychainService: self.model.keychainService) {
                case .cancelled:
                    return
                case .value(let hashedMasterPassword):
                    self.hashedMasterPassword = hashedMasterPassword
                    self.showGetMasterPassword = (self.hashedMasterPassword == nil)
                    self.linkIsActive = !self.showGetMasterPassword
                }
            }) {
                ZStack {
                    EmptyView().masterPasswordAlert(masterPassword: self.passwordItem.masterPassword, isPresented: $showGetMasterPassword) { (masterPassword, passwordText) in
                        self.model.addMasterPassword(masterPassword, passwordText: passwordText)
                        self.hashedMasterPassword = MasterPassword.hashPassword(passwordText)
                        self.showGetMasterPassword = false
                        self.linkIsActive = true
                    }
                    NavigationLink(
                        destination: PasswordInfoView(
                            passwordItem: passwordItem,
                            hashedMasterPassword: hashedMasterPassword,
                            model: model)
                        .navigationBarTitle("Password Info", displayMode: .inline),
                        isActive: self.$linkIsActive
                    ) {
                        EmptyView()
                    }.frame(width: 0).opacity(0)
                    Image(systemName: "info.circle").resizable().frame(width: 18, height: 18).padding()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 24, height: 24).padding()
            #endif
        }.alert(isPresented: Binding<Bool>(get: { self.errorMessage != nil }, set: { p in self.errorMessage = p ? self.errorMessage : nil })) { () -> Alert in
            Alert(title: Text("Could Not Generate Password"), message: Text(self.errorMessage ?? "Error"), dismissButton: Alert.Button.cancel() {
                self.errorMessage = nil
            })
        }
    }
}


struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView(model: Model.testModel())
    }
}
