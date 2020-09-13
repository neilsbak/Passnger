//
//  SheetScaffoldView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-09.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct SheetScaffoldView<Content: View>: View {
    typealias OnSave = () -> Void
    typealias OnCancel = () -> Void

    let title: String?
    let onCancel: OnCancel?
    let onSave: OnSave?
    let content: Content

    init(title: String? = nil, onCancel: OnCancel?, onSave: OnSave? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onCancel = onCancel
        self.onSave = onSave
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        #if os(iOS)
        NavigationView {
            //Setting onSave and onCancel to nil allows the parent to
            //create their own navigationBarItems
            if onSave == nil && onCancel == nil {
                content
                .navigationBarTitle(Text(self.title ?? ""), displayMode: .inline)
            } else {
                content
                .navigationBarTitle(Text(self.title ?? ""), displayMode: .inline)
                .navigationBarItems(
                    leading: onCancel.map { Button(action: $0) { Text("Cancel")}.padding([.trailing, .top, .bottom]) },
                    trailing: onSave.map { Button(action: $0) { Text("Save")}.padding([.leading, .top, .bottom]) }
                )
            }
        }
        #else
        SheetView(title: title, onCancel: onCancel ?? {}, onSave: onSave, content: { content })
        #endif
    }
}

extension View {
    func sheet<Content: View>(isPresented: Binding<Bool>, title: String, onCancel: @escaping () -> Void, onSave: (() -> Void)?, content: @escaping () -> Content) -> some View {
        return self.macSafeSheet(isPresented: isPresented) {
            SheetScaffoldView(title: title, onCancel: onCancel, onSave: onSave, content: content)
        }
    }
}

extension View {
    func macSafeSheet<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        #if os(macOS)
        return self.background(EmptyView().sheet(isPresented: isPresented, content: content))
        #else
        return self.sheet(isPresented: isPresented, content: content)
        #endif
    }
}

struct SheetScaffoldView_Previews: PreviewProvider {
    static var previews: some View {
        SheetScaffoldView(title: "Test", onCancel: { }, onSave: { }, content: { Color.red })
    }
}
