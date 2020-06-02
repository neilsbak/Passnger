//
//  CreatePasswordFormView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-23.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct CreatePasswordFormView: View {
    @ObservedObject var model: Model
    @Binding var formModel: CreatePasswordFormModel
    @State var showCreateMasterPassword = false

    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Website URL:")
                        TextField("example.com", text: $formModel.websiteUrl)
                            .autoCapitalizationOff()
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .validatedField(errorText: formModel.websiteUrlError)
                    }
                    HStack {
                        Text("Description:")
                        TextField("Example", text: $formModel.websiteName)
                            .autoCapitalizationOff()
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .validatedField(errorText: formModel.websiteNameError)
                    }
                    HStack {
                        Text("Username:")
                        TextField("username", text: $formModel.username)
                            .autoCapitalizationOff()
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .validatedField(errorText: formModel.usernameError)
                    }
                    Spacer().frame(height: 8)
                    HStack {
                        Text("Choose Master Password")
                        Button(action: {
                            withAnimation {
                                self.showCreateMasterPassword = true
                            }
                        }) {
                            Image("circle.plus")
                        }
                    }.validatedField(errorText: formModel.masterPasswordError)
                }.padding([.leading, .top, .trailing])
                List {
                    ForEach(model.masterPasswords) { masterPassword in
                        Button(action: {
                            withAnimation {
                                self.formModel.selectedMasterPassword = masterPassword
                            }
                        }) {
                            HStack {
                                Text(masterPassword.name).frame(maxWidth: CGFloat.infinity, alignment: .leading)
                                if masterPassword.id == self.formModel.selectedMasterPassword?.id {
                                    Image("checkmark").foregroundColor(Color.black)
                                }
                            }
                        }.padding([.leading, .trailing])
                    }.onDelete() { indexSet in
                        self.model.removeMasterPasswords(atOffsets: indexSet)
                    }
                }
            }
            if (showCreateMasterPassword) {
                MasterPasswordAlertView(presentedAsModal: $showCreateMasterPassword) { masterPassword in
                    self.formModel.selectedMasterPassword = masterPassword
                    self.model.addMasterPassword(masterPassword)
                }
            }
        }
    }
}

struct MasterPasswordAlertView: View {
    @Binding var presentedAsModal: Bool
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var hint: String = ""
    @State private var hasSubmitted = false;
    let onSave: (_ masterPassword: MasterPassword) -> Void

    private func save() {
        hasSubmitted = true
        if (passwordError == nil && confirmedPasswordError == nil && hintError == nil) {
            self.onSave(MasterPassword(name: self.hint, password: self.password))
            self.presentedAsModal = false
        }
    }

    private var passwordError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (password == "") {
            return "This field is required"
        }
        if (password != confirmPassword) {
            return "The passwords do not match"
        }
        return nil
    }

    private var confirmedPasswordError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (confirmPassword == "") {
            return "This field is required"
        }
        if (confirmPassword != password) {
            return "The passwords do not match"
        }
        return nil
    }

    private var hintError: String? {
        if (!hasSubmitted) {
            return nil
        }
        if (hint == "") {
            return "This field is required"
        }
        return nil
    }

    var body: some View {
        GeometryReader { (gemoetry: GeometryProxy) in
            ZStack {
                Color.black.opacity(0.3)
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 12.0) {
                            Text("Create Password")
                            SecureField("Password", text: self.$password)
                                .autoCapitalizationOff()
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.passwordError)
                            SecureField("Confirm Password", text: self.$confirmPassword)
                                .autoCapitalizationOff()
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.confirmedPasswordError)
                            TextField("Hint", text: self.$hint)
                                .autoCapitalizationOff()
                                .disableAutocorrection(true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .validatedField(errorText: self.hintError)
                        }.padding()
                        Divider()
                        HStack {
                            Button(action: {
                                self.endEditing()
                                withAnimation {
                                    self.presentedAsModal = false
                                }
                            }) {
                                Text("Cancel")
                            }
                            Spacer()
                            Button(action: {
                                self.endEditing()
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

    private func endEditing() {
        #if os(macOS)
        NSApplication.shared.windows.first?.endEditing(for: nil)
        #else
        UIApplication.shared.windows.first?.endEditing(true)
        #endif
    }

}

extension View {
    func validatedField(errorText: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            errorText.map { Text($0).foregroundColor(Color.red) }?.font(.caption)
            self
        }
    }
}

extension View {
    func autoCapitalizationOff() -> some View {
        #if os(iOS)
            return autocapitalization(.none)
        #else
            return self
        #endif
    }
}


struct CreatePasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordFormView(model: Model.testModel(), formModel: Binding<CreatePasswordFormModel>(get: { CreatePasswordFormModel() }, set: {_ in }))
    }
}
