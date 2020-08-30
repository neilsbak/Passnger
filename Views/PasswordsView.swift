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
        PasswordItemRow(passwordItem: passwordItem, model: self.model)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: self.rowHeight)
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
        }
    }
}


struct PasswordItemRow: View {
    @State private var hashedMasterPassword: String?
    @State private var showGetMasterPassword = false
    @State private var linkIsActive = false
    let passwordItem: PasswordItem
    let model: Model

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(passwordItem.resourceDescription)
                    .fontWeight(.bold)
                Text(passwordItem.userName)
                    .font(.caption)
                    .opacity(0.625)
            }
            Spacer()
            #if os(iOS)
            Button(action: {
                switch try! self.passwordItem.masterPassword.getHashedPassword() {
                case .cancelled:
                    return
                case .value(let hashedMasterPassword):
                    self.hashedMasterPassword = hashedMasterPassword
                    self.showGetMasterPassword = (self.hashedMasterPassword == nil)
                    self.linkIsActive = !self.showGetMasterPassword
                }
            }) {
                ZStack {
                    EmptyView().masterPasswordAlert(masterPassword: self.passwordItem.masterPassword, isPresented: $showGetMasterPassword) { (passwordText) in
                        self.model.addMasterPassword(self.passwordItem.masterPassword, passwordText: passwordText)
                        self.hashedMasterPassword = MasterPassword.hashPassword(passwordText)
                        self.showGetMasterPassword = false
                        self.linkIsActive = true
                    }
                    if linkIsActive {
                        NavigationLink(
                            destination: PasswordInfoModifier(
                                passwordItem: passwordItem) {updatedPasswordItem in
                                    self.model.addPasswordItem(updatedPasswordItem, hashedMasterPassword: self.hashedMasterPassword!)
                                }
                            .navigationBarTitle("Password Info", displayMode: .inline),
                            isActive: self.$linkIsActive
                        ) {
                            EmptyView()
                        }
                    }
                    Image("info").resizable().frame(width: 24, height: 24).padding()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: 24, height: 24).padding()
            #endif
        }
    }
}

// This only saves the passwordItem when the page is dismissed
private struct PasswordInfoModifier: View {
    @State var passwordItem: PasswordItem
    let onSave: (PasswordItem) -> Void

    var body: some View {
        return PasswordInfoView(passwordItem: $passwordItem).onDisappear {
            self.onSave(self.passwordItem)
        }
    }
}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView(model: Model.testModel())
    }
}
