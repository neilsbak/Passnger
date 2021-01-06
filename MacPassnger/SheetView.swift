//
//  SheetView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-08-26.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct SheetView<Content: View>: View {
    typealias OnComplete = () -> Void
    typealias OnSave = () -> Void
    typealias OnSaveComplete = (@escaping OnComplete) -> Void
    typealias OnCancel = () -> Void

    let title: String?
    let onCancel: OnCancel
    let onSave: OnSave?
    let onSaveComplete: OnSaveComplete?
    let content: Content

    @State private var isSaving = false

    init(title: String? = nil, onCancel: @escaping OnCancel, onSave: OnSave? = nil, onSaveComplete: OnSaveComplete? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onCancel = onCancel
        self.onSave = onSave
        self.onSaveComplete = onSaveComplete
        self.content = content()
    }

    var body: some View {
        VStack {
            title.map { Text($0).font(.subheadline) }
            content
            Spacer()
            HStack {
                Button(action: onCancel) {
                    Text(self.onSave == nil && self.onSaveComplete == nil ? "Dismiss" : "Cancel")
                }
                onSave.map { sv in
                    onSaveButton(action: sv)
                } ?? onSaveComplete.map { sv in
                    onSaveButton() {
                        self.isSaving = true
                        sv { self.isSaving = false }
                    }
                }
            }.padding(.top)
            }.frame(minWidth: 400, minHeight: 300).padding()
    }

    private func onSaveButton(action: @escaping () -> Void) -> some View {
        Group {
            Spacer()
            if self.isSaving {
                ActivityIndicator(isAnimating: true)
            } else {
                Button(action: action) {
                    Text("Save")
                }
            }
        }
    }
}

struct SheetFooterView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(title: "Test", onCancel: {}) { Text("OK") }
    }
}
