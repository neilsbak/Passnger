//
//  ContentView.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: Model
    @State private var showCreatePassword = false

    var body: some View {
        NavigationView {
            PasswordsView(model: model).navigationBarTitle("Passwords")
                .navigationBarItems(trailing: Button(action: {
                    self.showCreatePassword = true;
                }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $showCreatePassword) {
                    CreatePasswordView(model: self.model, presentedAsModal: self.$showCreatePassword) { passwordItem in
                        self.model.addPasswordItem(passwordItem)
                    }
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView(model: Model.testModel())
        }
    }
}
