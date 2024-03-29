//
//  MasterPasswordFormView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-06-01.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct MasterPasswordFormView: View {
    @Binding var formModel: MasterPasswordFormModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            SecureField("Password", text: $formModel.password)
                .autoCapitalizationOff()
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .validatedField(errorText: formModel.passwordError)
            SecureField("Confirm Password", text: $formModel.confirmPassword)
                .autoCapitalizationOff()
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .validatedField(errorText: formModel.confirmedPasswordError)
            TextField("Hint", text: $formModel.hint)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .validatedField(errorText: formModel.hintError)
            Toggle("Remember your Master Password on this device", isOn: $formModel.saveOnDevice)

        }
    }

}

struct MasterPasswordFormView_Previews: PreviewProvider {
    static var previews: some View {
        MasterPasswordFormView(formModel: Binding(get: {MasterPasswordFormModel()}, set: {_ in}))
    }
}
