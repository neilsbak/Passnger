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
    @State var formModel = CreatePasswordFormModel()
    let onSave: (_ passwordItem: PasswordItem) -> Void

    var body: some View {
        NavigationView {
            CreatePasswordFormView(model: model, formModel: $formModel)
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
