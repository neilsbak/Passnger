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
}

