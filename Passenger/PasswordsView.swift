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
    @State private var showCopied = false
    @State private var showCreatePassword = false

    var body: some View {
            NavigationView {
                ZStack {
                    List(model.passwordItems) { item in
                        Button(action: {
                            if (self.showCopied) {
                                return
                            }
                            withAnimation {
                                self.showCopied = true
                                UIPasteboard.general.string = try! item.passwordKeychainItem.readPassword()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showCopied = false
                            }
                        }) {
                            PasswordItemRow(passwordItem: item)
                        }
                    }
                    if (self.showCopied) {
                        Text("Copied to\nClipboard")
                            .padding(.all, 30)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                    }
                }.navigationBarTitle("Home")
                    .navigationBarItems(trailing: Button(action: {
                        self.showCreatePassword = true;
                    }) {
                        Image(systemName: "plus")
                    }.sheet(isPresented: $showCreatePassword) {
                        CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword) { passwordItem in
                            self.model.passwordItems.append(passwordItem)
                        }
                    }
                )

            }
    }
}

struct PasswordItemRow: View {
    let passwordItem: PasswordItem

    var body: some View {
        Text(passwordItem.userName)
    }
}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView()
    }
}
