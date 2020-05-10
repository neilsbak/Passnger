//
//  CreatePasswordView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-25.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordView: View {
    @ObservedObject var model: Model
    @Binding var presentedAsModal: Bool
    let onSave: (_ passwordItem: PasswordItem) -> Void
    @State private var websiteName: String = "";
    @State private var websiteUrl: String = ""
    @State private var username: String = ""
    @State private var selectedMasterPassword: MasterPassword?
    @State private var showCreateMasterPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Website URL:")
                            TextField("example.com", text: $websiteUrl)                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("Description:")
                            TextField("Example", text: $websiteName)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("Username:")
                            TextField("username", text: $username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        Spacer().frame(height: 8)
                        HStack {
                            Text("Choose Master Password")
                            Button(action: {
                                withAnimation {
                                    self.showCreateMasterPassword = true
                                }
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }.padding([.leading, .top, .trailing])
                    VStack(alignment: .leading) {
                        ForEach(model.masterPasswords) { masterPassword in
                            Divider().padding(.leading)
                            Button(action: {
                                withAnimation {
                                    self.selectedMasterPassword = masterPassword
                                }
                            }) {
                                HStack {
                                    Text(masterPassword.name).frame(maxWidth: CGFloat.infinity, alignment: .leading)
                                    if masterPassword.id == self.selectedMasterPassword?.id {
                                        Image(systemName: "checkmark").foregroundColor(Color.black)
                                    }
                                }
                            }.padding([.leading, .trailing])
                        }
                        Divider().padding(.leading)
                    }.padding(.bottom)
                }
                if (showCreateMasterPassword) {
                    MasterPasswordAlertView(presentedAsModal: $showCreateMasterPassword) { masterPassword in
                        self.selectedMasterPassword = masterPassword
                        self.model.masterPasswords.append(masterPassword)
                    }
                }
            }
            .navigationBarTitle("Create Password", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.presentedAsModal = false
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    self.presentedAsModal = false
                    self.onSave(PasswordItem(userName: self.username, password: try! self.selectedMasterPassword!.passwordKeychainItem.readPassword(), url: self.websiteUrl, serviceName: self.websiteName))
                }) {
                    Text("Save")
                }
            )
        }
    }
}

struct MasterPasswordAlertView: View {
    @Binding var presentedAsModal: Bool
    @State private var password: String = ""
    @State private var hint: String = ""
    let onSave: (_ masterPassword: MasterPassword) -> Void

    var body: some View {
        GeometryReader { (gemoetry: GeometryProxy) in
            ZStack {
                Color.black.opacity(0.3)
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text("Create Password")
                            TextField("Password", text: self.$password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Hint", text: self.$hint)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }.padding()
                        Divider()
                        HStack {
                            Button(action: {
                                UIApplication.shared.windows.first?.endEditing(true)
                                withAnimation {
                                    self.presentedAsModal = false
                                }
                            }) {
                                Text("Cancel")
                            }
                            Spacer()
                            Button(action: {
                                UIApplication.shared.windows.first?.endEditing(true)
                                withAnimation {
                                    self.onSave(MasterPassword(name: self.hint, password: self.password))
                                    self.presentedAsModal = false
                                }
                            }) {
                                Text("Save")
                            }
                        }.padding()
                    }
                    .background(Color.white)
                    .frame(
                        width: gemoetry.size.width*0.7,
                        height: gemoetry.size.height*0.7
                    )
                    .cornerRadius(10)
                    .shadow(radius: CGFloat(1))
                }
            }
        }
    }

}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _ in }
    }
}
