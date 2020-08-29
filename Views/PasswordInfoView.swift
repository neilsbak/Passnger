//
//  PasswordInfoView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-26.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordInfoView: View {

    @Binding var passwordItem: PasswordItem

    var textFieldBinding: Binding<String> {
        Binding<String>(
            get: { String(self.passwordItem.numRenewals) },
            set: { text in
                self.passwordItem.numRenewals = Int(text) ?? self.passwordItem.numRenewals
            }
        )
    }

    var body: some View {
        return GeometryReader { metrics in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    PasswordInfoViewCell(width: metrics.size.width, title: "Website URL") {
                        Text(self.passwordItem.url)
                    }
                    PasswordInfoViewCell(width: metrics.size.width, title: "Description") {
                        Text(self.passwordItem.resourceDescription)
                    }
                    PasswordInfoViewCell(width: metrics.size.width, title: "Username") {
                        Text(self.passwordItem.userName)
                    }
                    PasswordInfoViewCell(width: metrics.size.width, title: "Date Created") {
                        Text(DateFormatter.localizedString(from: self.passwordItem.created, dateStyle: .medium, timeStyle: .none))
                    }
                    PasswordInfoViewCell(width: metrics.size.width, title: "Renewal Number") {
                        TextField("0", text: self.textFieldBinding)
                            .keyboardNumeric()
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                    }
                }
            }
        }
    }
}

struct PasswordInfoViewCell<Content: View>: View {
    let width: CGFloat
    let title: String
    let valueView: () -> Content

    var body: some View {
        HStack {
            Text(self.title).frame(width: width * 0.5, alignment: .leading)
            self.valueView().padding(.zero).frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct PasswordInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordInfoView(passwordItem: Binding.constant(Model.testModel().passwordItems[0]))
    }
}
