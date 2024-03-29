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
        ScrollView {
            VStack {
                Text("Enter your master password to get started. This will be the only password you need to remember. This password should only be known to you and not written down anywhere.")
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                MasterPasswordFormView(formModel: self.$masterPasswordFormModel)
                Spacer().frame(height: 20)
                Button(action: {
                    self.masterPasswordFormModel.hasSubmitted = true
                    if self.masterPasswordFormModel.validate() {
                        self.onValidated(self.masterPasswordFormModel)
                    }
                }) {
                    Text("Submit")
                }.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }.padding()
        }.keyboardObserving()
    }
}

struct IntroSetupView_Previews: PreviewProvider {
    static var previews: some View {
        IntroSetupView() { _ in }
    }
}
