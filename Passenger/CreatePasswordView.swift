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
                VStack {
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
                    List {
                        ForEach(model.masterPasswords) { masterPassword in
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
                        }.onDelete() { indexSet in
                            self.model.removeMasterPasswords(atOffsets: indexSet)
                        }
                    }.padding(.bottom)
                }
                if (showCreateMasterPassword) {
                    MasterPasswordAlertView(presentedAsModal: $showCreateMasterPassword) { masterPassword in
                        self.selectedMasterPassword = masterPassword
                        self.model.addMasterPassword(masterPassword)
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
    @State private var submittedPassword: String?
    @State private var confirmPassword: String = ""
    @State private var submittedConfirmedPassword: String?
    @State private var hint: String = ""
    @State private var submittedHint: String?
    let onSave: (_ masterPassword: MasterPassword) -> Void

    private func save() {
        self.presentedAsModal = false
        self.submittedPassword = password
        self.submittedConfirmedPassword = confirmPassword
        self.submittedHint = hint
        if (passwordError == nil && confirmedPasswordError == nil && hintError == nil) {
            self.onSave(MasterPassword(name: self.hint, password: self.password))
        }
    }

    private var passwordError: String? {
        if (submittedPassword != password) {
            return nil
        }
        if (submittedPassword == "") {
            return "This field is required"
        }
        if (submittedPassword != submittedConfirmedPassword) {
            return "The passwords do not match"
        }
        return nil
    }

    private var confirmedPasswordError: String? {
        if (submittedConfirmedPassword != confirmPassword) {
            return nil
        }
        if (submittedConfirmedPassword == "") {
            return "This field is required"
        }
        if (submittedConfirmedPassword != submittedPassword) {
            return "The passwords do not match"
        }
        return nil
    }

    private var hintError: String? {
        if (submittedHint != hint) {
            return nil
        }
        if (submittedHint == "") {
            return "This field is required"
        }
        return nil
    }

    var body: some View {
        GeometryReader { (gemoetry: GeometryProxy) in
            ZStack {
                Color.black.opacity(0.3)
                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text("Create Password")
                            SecureField("Password", text: self.$password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.passwordError)
                            SecureField("Confirm Password", text: self.$confirmPassword)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.confirmedPasswordError)
                            TextField("Hint", text: self.$hint)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.hintError)
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
                                    self.save()
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

struct ValidatedField<Field: View>: View {
    let field: Field
    let errorText: String?
    var body: some View {
        VStack {
            errorText.map { Text($0).foregroundColor(Color.red) }?.font(.caption)
            field
        }
    }
}

extension View {
    func validatedField(errorText: String?) -> some View {
        VStack {
            errorText.map { Text($0).foregroundColor(Color.red) }?.font(.caption)
            self
        }
    }
}

struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _ in }
    }
}
