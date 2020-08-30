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

    @ViewBuilder
    private func contentRows(width: CGFloat) -> some View {
        PasswordInfoViewCell(width:width, title: "Website URL") {
            Text(self.passwordItem.url)
        }
        PasswordInfoViewCell(width: width, title: "Description") {
            Text(self.passwordItem.resourceDescription)
        }
        PasswordInfoViewCell(width: width, title: "Username") {
            Text(self.passwordItem.userName)
        }
        PasswordInfoViewCell(width: width, title: "Date Created") {
            Text(DateFormatter.localizedString(from: self.passwordItem.created, dateStyle: .medium, timeStyle: .none))
        }
        PasswordInfoViewCell(width: width, title: "Renewal Number") {
            TextField("0", text: self.textFieldBinding)
                .keyboardNumeric()
                .frame(width: 100)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())

        }
    }

    var body: some View {
        GeometryReader { metrics in
        #if os(iOS)
            List {
                self.contentRows(width: metrics.size.width)
            }
        #else
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                self.contentRows(width: metrics.size.width)
            }
        }
        #endif
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
