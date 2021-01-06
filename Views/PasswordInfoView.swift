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
    let hashedMasterPassword: String?
    private var password: String? {
        self.hashedMasterPassword.flatMap { try? passwordItem.getPassword(hashedMasterPassword: $0, keychainService: self.model.keychainService) }
    }
    let model: Model

    @State private var updatedPasswordItem: PasswordItem
    @State private var isUpdatingPassword: Bool = false
    @State private var result: Result<Void, Error>? = nil
    @State private var showPassword: Bool = false

    init(passwordItem: PasswordItem, hashedMasterPassword: String?, model: Model) {
        self.passwordItem = passwordItem
        self.hashedMasterPassword = hashedMasterPassword
        self.model = model
        self._updatedPasswordItem = State(initialValue: passwordItem)
    }

    var textFieldBinding: Binding<String> {
        Binding<String>(
            get: { String(self.updatedPasswordItem.numRenewals) },
            set: { text in
                self.updatedPasswordItem.numRenewals = Int(text) ?? self.updatedPasswordItem.numRenewals
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
        PasswordInfoViewCell(width: width, title: "Renewal Number") { self.renewalColumn }
        PasswordInfoViewCell(width: width, title: "Website URL", valueText: self.passwordItem.url)
        PasswordInfoViewCell(width: width, title: "Description", valueText: self.passwordItem.resourceDescription)
        PasswordInfoViewCell(width: width, title: "Username", valueText: self.passwordItem.userName)
        PasswordInfoViewCell(width: width, title: "Date Created", valueText: DateFormatter.localizedString(from: self.passwordItem.created, dateStyle: .medium, timeStyle: .none))
        PasswordInfoViewCell(width: width, title: "Master Password", valueText: String(self.passwordItem.masterPassword.name))
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
        Button(action: { self.showPassword.toggle() }) {
        #if os(macOS)
            Text(self.showPassword ? "Hide": "Show")
        #else
            Image(systemName: self.showPassword ? "eye.slash": "eye").foregroundColor(.accentColor)
        #endif
        }.systemButtonStyle()
    }

    @ViewBuilder
    var renewalColumn: some View {
        HStack {
            if let hashedMasterPassword = self.hashedMasterPassword {
                TextField("0", text: self.textFieldBinding)
                    .keyboardNumeric()
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer().frame(width: 10)
                ZStack {
                    Button(action: {
                        self.isUpdatingPassword = true
                        self.model.addPasswordItem(self.updatedPasswordItem, hashedMasterPassword: hashedMasterPassword) { result in
                            self.isUpdatingPassword = false
                            self.result = result
                        }
                    }) {
                        Text("Regen Password")
                    }.systemButtonStyle().opacity(isUpdatingPassword ? 0 : 1)
                    ActivityIndicator(isAnimating: isUpdatingPassword)
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
        PasswordInfoView(passwordItem: Model.testModel().passwordItems[0], hashedMasterPassword: nil, model: Model.testModel())
    }
}
