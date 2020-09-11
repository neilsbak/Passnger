//
//  IntroSetupView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-22.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct IntroSetupView: View {
    @State private var masterPasswordFormModel = MasterPasswordFormModel()
    let onValidated: (MasterPasswordFormModel) -> Void
    var body: some View {
        VStack {
            Text("Enter you master password to get started. This will be the only password you need to remember. This password should only be known to you and not written down anywhere.")
            MasterPasswordFormView(formModel: self.$masterPasswordFormModel)
            Button(action: {
                self.masterPasswordFormModel.hasSubmitted = true
                if self.masterPasswordFormModel.validate() {
                    self.onValidated(self.masterPasswordFormModel)
                }
            }) {
                Text("Submit")
            }
            Spacer()
        }.padding()
    }
}

struct IntroSetupView_Previews: PreviewProvider {
    static var previews: some View {
        IntroSetupView() { _ in }
    }
}
