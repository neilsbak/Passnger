//
//  PasswordsView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordsView: View {
    @ObservedObject var model: Model
    @State private var showCopied = false
    let selectedPassword: PasswordItem?
    let onSelected: ((PasswordItem) -> Void)?

    init(model: Model, selectedPassword: PasswordItem? = nil, onSelected: ((PasswordItem) -> Void)? = nil) {
        self.model = model
        self.selectedPassword = selectedPassword
        self.onSelected = onSelected
    }

    private let rowHeight: CGFloat = 32

    var body: some View {
        ZStack {
            List {
                ForEach(model.passwordItems) { item in
                    PasswordItemRow(passwordItem: item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: self.rowHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.onSelected?(item)
                        #if os(iOS)
                            if (self.showCopied) {
                                return
                            }
                            withAnimation {
                                self.showCopied = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.showCopied = false
                            }
                        #endif
                    }.listRowBackground((self.selectedPassword == nil ? Color.clear : Color.blue).frame(height: self.rowHeight))
                }.onDelete() { indexSet in
                    self.model.removePasswordItems(atOffsets: indexSet)
                }
            }
            if (self.showCopied) {
                Text("Copied to\nClipboard")
                    .padding(.all, 30)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
            }
        }
    }
}

struct PasswordItemRow: View {
    let passwordItem: PasswordItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(passwordItem.serviceName)
                .fontWeight(.bold)
            Text(passwordItem.userName)
                .font(.caption)
                .opacity(0.625)
        }
    }
}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView(model: Model.testModel())
    }
}
