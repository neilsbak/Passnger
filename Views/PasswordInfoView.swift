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
    @State private var isUpdatingPassword: Bool = false
    @State private var result: Result<Void, Error>? = nil
    let hashedMasterPassword: String?
    private var password: String? {
        self.hashedMasterPassword.flatMap { try? passwordItem.getPassword(hashedMasterPassword: $0, keychainService: self.model.keychainService) }
    }
    let model: Model

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
                        SelectableLabel(text: password).frame(alignment: .trailing)
                    } else {
                        Text(String(repeating: "*", count: password.count)).minimumScaleFactor(0.7).lineLimit(1)
                    }
                    passwordButton
                }
            }
        }
        PasswordInfoViewCell(width: width, title: "Website URL", valueText: self.passwordItem.url)
        PasswordInfoViewCell(width: width, title: "Description", valueText: self.passwordItem.resourceDescription)
        PasswordInfoViewCell(width: width, title: "Username", valueText: self.passwordItem.userName)
        PasswordInfoViewCell(width: width, title: "Date Created", valueText: DateFormatter.localizedString(from: self.passwordItem.created, dateStyle: .medium, timeStyle: .none))
        PasswordInfoViewCell(width: width, title: "Master Password", valueText: String(self.passwordItem.masterPassword.name))
        PasswordInfoViewCell(width: width, title: "Renewal Number") { self.renewalColumn }
        Group {
            PasswordInfoViewCell(width: width, title: "Password Length", valueText: String(self.passwordItem.passwordLength))
            PasswordInfoViewCell(width: width, title: "Symbols", valueText: self.passwordItem.symbols)
            PasswordInfoViewCell(width: width, title: "Minimum Symbols", valueText: String(self.passwordItem.minSymbols))
            PasswordInfoViewCell(width: width, title: "Minimum Numbers", valueText: String(self.passwordItem.minNumeric))
            PasswordInfoViewCell(width: width, title: "Minimum Upper Case", valueText: String(self.passwordItem.minUpperCase))
            PasswordInfoViewCell(width: width, title: "Minimum Lower Case", valueText: String(self.passwordItem.minLowerCase))
        }
    }

    @ViewBuilder
    var passwordButton: some View {
        #if os(macOS)
            Button(action: { self.showPassword.toggle() }) {
                Text(self.showPassword ? "Hide": "Show")
            }.buttonStyle(DefaultButtonStyle())
        #else
            Button(action: { self.showPassword.toggle() }) {
                Image(systemName: self.showPassword ? "eye.slash": "eye").foregroundColor(.accentColor)
            }.buttonStyle(PlainButtonStyle())
        #endif
    }

    @ViewBuilder
    var renewalColumn: some View {
        HStack {
            if let hashedMasterPassword = self.hashedMasterPassword {
                TextField("0", text: self.textFieldBinding)
                    .keyboardNumeric()
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if self.isUpdatingPassword {
                    ActivityIndicator(isAnimating: true)
                } else {
                    Button(action: {
                        self.isUpdatingPassword = true
                        self.model.addPasswordItem(self.passwordItem, hashedMasterPassword: hashedMasterPassword) { result in
                            self.result = result
                        }
                    }) {
                        Text("Regen Password")
                    }
                }
            } else {
                Text(String(passwordItem.numRenewals))
            }
        }.passwordGeneratorAlert(result: self.$result)
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

    init(width: CGFloat, title: String, @ViewBuilder valueView: @escaping () -> Content) {
        self.width = width
        self.title = title
        self.valueView = valueView
    }

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
        PasswordInfoView(passwordItem: Binding.constant(Model.testModel().passwordItems[0]), hashedMasterPassword: nil, model: Model.testModel())
    }
}
