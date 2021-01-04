//
//  PasswordGeneratorResultViewModifier.swift
//  Passnger
//
//  Created by Neil Bakhle on 2020-12-31.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordGeneratorResultViewModifier: ViewModifier {

    @Binding var result: Result<Void, Error>?

    private var errorMessage: String? {
        guard let result = result else {
            return nil
        }
        if case .failure(let error) = result {
            if let genError = error as? PasswordGenerator.PasswordGeneratorError {
                switch genError {
                case .passwordError(let message):
                    return message
                }
            }
            return "There was an error."
        }
        return nil
    }

    func body(content: Content) -> some View {
        return content.alert(isPresented: Binding<Bool>(get: { self.errorMessage != nil }, set: { p in self.result = p ? self.result : nil })) {
            Alert(title: Text("Could Not Generate Password"), message: Text(self.errorMessage ?? "Error"), dismissButton: Alert.Button.cancel(Text("Ok")) {
                self.result = nil
            })
        }
    }

}

extension View {
    func passwordGeneratorAlert(result: Binding<Result<Void, Error>?>) -> some View {
        self.modifier(PasswordGeneratorResultViewModifier(result: result))
    }
}
