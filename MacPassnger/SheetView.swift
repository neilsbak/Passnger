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

    let title: String?
    let onCancel: OnCancel
    let onSave: OnSave?
    let content: Content

    init(title: String? = nil, onCancel: @escaping OnCancel, onSave: OnSave? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onCancel = onCancel
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        VStack {
            title.map { Text($0) }
            content
            Spacer()
            HStack {
                Button(action: onCancel) {
                    Text(self.onSave == nil ? "Dismiss" : "Cancel")
                }
                onSave.map { sv in
                    Group {
                        Spacer()
                        Button(action: sv) {
                            Text("Save")
                        }
                    }
                }
            }.padding(.top)
            }.frame(minWidth: 300, minHeight: 300).padding()
    }
}

struct SheetFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(title: "Test", onCancel: {}) { Text("OK") }
    }
}
