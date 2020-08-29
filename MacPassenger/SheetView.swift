//
//  SheetView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-08-26.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct SheetView<Content: View>: View {
    typealias OnSave = () -> Void
    typealias OnCancel = () -> Void

    let onSave: OnSave
    let onCancel: OnCancel
    let content: Content

    init(onSave: @escaping OnSave, onCancel: @escaping OnCancel, @ViewBuilder content: () -> Content) {
        self.onSave = onSave
        self.onCancel = onCancel
        self.content = content()
    }

    var body: some View {
        VStack {
            content
            Spacer()
            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: onSave) {
                    Text("Save")
                }
            }.padding(.top)
            }.frame(minWidth: 300, minHeight: 300).padding()
    }
}

struct SheetFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(onSave: {}, onCancel: {}) { Text("OK") }
    }
}
