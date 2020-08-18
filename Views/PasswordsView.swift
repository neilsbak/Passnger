//
//  PasswordsView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PasswordsView<DetailView: View>: View {
    @ObservedObject var model: Model
    let selectedPassword: PasswordItem?
    let detailView: ((PasswordItem) -> DetailView)?
    let onSelected: ((PasswordItem) -> Void)?

    init(model: Model, selectedPassword: PasswordItem? = nil, detailView: ((PasswordItem) -> DetailView)? = nil, onSelected: ((PasswordItem) -> Void)? = nil) {
        self.model = model
        self.selectedPassword = selectedPassword
        self.detailView = detailView
        self.onSelected = onSelected
    }

    private let rowHeight: CGFloat = 32

    private func rowBody(passwordItem: PasswordItem) -> some View {
        PasswordItemRow(passwordItem: passwordItem, detailView: self.detailView?(passwordItem))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: self.rowHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                self.onSelected?(passwordItem)
        }.listRowBackground((self.selectedPassword == nil ? Color.clear : Color.blue).frame(height: self.rowHeight))
    }

    var body: some View {
        List {
            ForEach(model.passwordItems) { item in
                self.rowBody(passwordItem: item)
            }.onDelete() { indexSet in
                self.model.removePasswordItems(atOffsets: indexSet)
            }
        }
    }
}

extension PasswordsView where DetailView == EmptyView {

    init(model: Model, selectedPassword: PasswordItem? = nil, onSelected: ((PasswordItem) -> Void)? = nil) {
        self.init(model: model, selectedPassword: selectedPassword, detailView: nil, onSelected: onSelected)
    }

}

struct PasswordItemRow<DetailView: View>: View {
    @State private var linkIsActive = false
    let passwordItem: PasswordItem
    let detailView: DetailView?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(passwordItem.resourceDescription)
                    .fontWeight(.bold)
                Text(passwordItem.userName)
                    .font(.caption)
                    .opacity(0.625)
            }
            Spacer()
            detailView.map { dv in
                Button(action: { self.linkIsActive = true }) {
                    ZStack {
                        NavigationLink(destination: dv, isActive: self.$linkIsActive) {
                            EmptyView()
                            }.frame(width: 24, height: 24).padding()
                        Image("info").resizable().frame(width: 24, height: 24).padding()
                    }
                }.buttonStyle(BorderlessButtonStyle())
            }
        }
    }

}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView(model: Model.testModel())
    }
}
