//
//  ContentView.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @ObservedObject var showCreatePassword: ShowCreatePasswordObservable

    var body: some View {
        NavigationView {
            VStack {
                PasswordsView(model: model)
            }.sheet(isPresented: $showCreatePassword.showCreatePassword) {
                CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword.showCreatePassword) { passwordItem in
                    self.model.addPasswordItem(passwordItem)
                }.frame(width: 400, height: 360)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel(), showCreatePassword: ShowCreatePasswordObservable())
    }
}
