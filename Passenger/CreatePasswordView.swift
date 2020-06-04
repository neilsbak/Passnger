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
    @State private var formModel = CreatePasswordFormModel()
    @State private var masterPasswordFormModel =  MasterPasswordFormModel()
    @State private var showCreateMasterPassword = false
    let onSave: (_ passwordItem: PasswordItem) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                CreatePasswordFormView(model: model, formModel: $formModel) {
                    self.masterPasswordFormModel = MasterPasswordFormModel()
                    self.showCreateMasterPassword = true
                }
                if showCreateMasterPassword {
                    GeometryReader { (gemoetry: GeometryProxy) in
                        ZStack {
                            Color.black.opacity(0.3)
                            ScrollView {
                                VStack {
                                    MasterPasswordView(formModel: self.$masterPasswordFormModel)
                                    Divider()
                                    HStack {
                                        Button(action: {
                                            UIApplication.shared.windows.first?.endEditing(true)
                                            withAnimation {
                                                self.showCreateMasterPassword = false
                                            }
                                        }) {
                                            Text("Cancel")
                                        }
                                        Spacer()
                                        Button(action: {
                                            UIApplication.shared.windows.first?.endEditing(true)
                                            withAnimation {
                                                self.masterPasswordFormModel.hasSubmitted = true
                                                if (self.masterPasswordFormModel.validate()) {
                                                    let masterPassword = MasterPassword(name: self.masterPasswordFormModel.hint, password: self.masterPasswordFormModel.password)
                                                    self.model.addMasterPassword(masterPassword)
                                                    self.formModel.selectedMasterPassword = masterPassword
                                                    self.showCreateMasterPassword = false
                                                }
                                            }
                                        }) {
                                            Text("Save")
                                        }
                                    }.padding()

                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(
                                    width: gemoetry.size.width*0.7,
                                    height: gemoetry.size.height*0.7
                                )
                                .shadow(radius: CGFloat(1))
                            }
                        }
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
                    self.formModel.hasSubmitted = true
                    if self.formModel.validate()  {
                        self.presentedAsModal = false
                        self.onSave(PasswordItem(userName: self.formModel.username, password: try! self.formModel.selectedMasterPassword!.passwordKeychainItem.readPassword(), url: self.formModel.websiteUrl, serviceName: self.formModel.websiteName))
                    }
                }) {
                    Text("Save")
                }
            )
        }
    }

}


struct CreatePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePasswordView(model: Model.testModel(), presentedAsModal: Binding<Bool>(get: { true }, set: {_ in })) { _ in }
    }
}
