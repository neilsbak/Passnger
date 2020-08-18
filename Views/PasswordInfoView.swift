//
//  PasswordInfoView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-26.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordInfoView: View {

    let passwordItem: PasswordItem
    @State var numRenewals: String
    let onSave: (PasswordItem) -> Void

    init(passwordItem: PasswordItem, onSave: @escaping (PasswordItem) -> Void) {
        self.passwordItem = passwordItem
        self.onSave = onSave
        self._numRenewals = State(initialValue: String(passwordItem.numRenewals))
    }

    var body: some View {
        return GeometryReader { metrics in
            List {
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
                    TextField("0", text: self.$numRenewals)
                        .keyboardNumeric()
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                }
            }
        }.onDisappear {
            print("disappear");
            var updatedPasswordItem = self.passwordItem;
            updatedPasswordItem.numRenewals = Int(self.numRenewals) ?? self.passwordItem.numRenewals;
            self.onSave(updatedPasswordItem)
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
        PasswordInfoView(passwordItem: Model.testModel().passwordItems[0], onSave: {_ in })
    }
}
