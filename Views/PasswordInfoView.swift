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
    let password: String?

    @State private var showPassword: Bool = false

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
        self.password.map { password in
            PasswordInfoViewCell(width: width, title: "Password") {
                HStack {
                    if showPassword {
                        SelectableLabel(text: password).fixedSize()
                    } else {
                        Text(String(repeating: "*", count: password.count))
                    }
                    Button(action: { self.showPassword.toggle() }) {
                        #if os(macOS)
                        if #available(macOS 11, *) {
                            Image(systemName: self.showPassword ? "eye.slash": "eye")
                        } else {
                            Text(self.showPassword ? "Hide": "Show")
                        }
                        #else
                        Image(systemName: self.showPassword ? "eye.slash": "eye")
                        #endif
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        PasswordInfoViewCell(width: width, title: "Website URL", valueText: self.passwordItem.url)
        PasswordInfoViewCell(width: width, title: "Description", valueText: self.passwordItem.resourceDescription)
        PasswordInfoViewCell(width: width, title: "Username", valueText: self.passwordItem.userName)
        PasswordInfoViewCell(width: width, title: "Date Created", valueText: DateFormatter.localizedString(from: self.passwordItem.created, dateStyle: .medium, timeStyle: .none))
        PasswordInfoViewCell(width: width, title: "Master Password", valueText: String(self.passwordItem.masterPassword.name))
        PasswordInfoViewCell(width: width, title: "Renewal Number") {
            TextField("0", text: self.textFieldBinding)
                .keyboardNumeric()
                .frame(width: 100)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        Group {
            PasswordInfoViewCell(width: width, title: "Password Length", valueText: String(self.passwordItem.passwordLength))
            PasswordInfoViewCell(width: width, title: "Symbols", valueText: self.passwordItem.symbols)
            PasswordInfoViewCell(width: width, title: "Minimum Symbols", valueText: String(self.passwordItem.minSymbols))
            PasswordInfoViewCell(width: width, title: "Minimum Numbers", valueText: String(self.passwordItem.minNumeric))
            PasswordInfoViewCell(width: width, title: "Minimum Upper Case", valueText: String(self.passwordItem.minUpperCase))
            PasswordInfoViewCell(width: width, title: "Minimum Lower Case", valueText: String(self.passwordItem.minLowerCase))
        }
    }

    var body: some View {
        GeometryReader { metrics in
        #if os(iOS)
        List {
            self.contentRows(width: metrics.size.width)
        }.keyboardObserving()
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

extension PasswordInfoViewCell where Content == Text {
    init(width: CGFloat, title: String, valueText: String) {
        self.init(width: width, title: title, valueView: { Text(valueText).foregroundColor(.secondary) })
    }

}

struct PasswordInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordInfoView(passwordItem: Binding.constant(Model.testModel().passwordItems[0]), password: "testpassword")
    }
}
