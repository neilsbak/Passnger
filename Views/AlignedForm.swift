//
//  AlignedForm.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-04.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

// This fixes a bug where a Form with a picker is not
// left aligned in MacOS
struct AlignedForm<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        #if os(iOS)
        Form {
            content
        }
        #else
        VStack {
            content
        }
        #endif
    }
}
