//
//  ViewExtensions.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-06-01.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

extension View {
    func validatedField(errorText: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            errorText.map { Text($0).foregroundColor(Color.red) }?.font(.caption)
            self
        }
    }
}

extension View {
    func autoCapitalizationOff() -> some View {
        #if os(iOS)
            return autocapitalization(.none)
        #else
            return self
        #endif
    }

    func keyboardNumeric() -> some View {
        #if os(iOS)
            return keyboardType(.numberPad)
        #else
            return self
        #endif
    }
}

#if os(macOS)
extension NSColor {
    static var label: NSColor { .labelColor }
}
#endif

#if os(macOS)
extension View {
    func navigationBarTitle(_ title: String) -> some View {
        self
    }
}
#endif


extension View {
    func getMasterPassword(masterPassword: MasterPassword?, isPresented: Binding<Bool>, onGotPassword: @escaping (MasterPassword, String) -> Void) -> some View {
        #if os(iOS)
        return self.masterPasswordAlert(masterPassword: masterPassword, isPresented: isPresented, onGotPassword: onGotPassword)
        #else
        return self.sheet(isPresented: isPresented) {
            GetMasterPasswordView(masterPassword: masterPassword, isPresented: isPresented, onGotPassword: onGotPassword)
        }
        #endif
    }
}
