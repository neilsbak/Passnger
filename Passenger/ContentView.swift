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

    var body: some View {
        PasswordsView(model: model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testModel())
    }
}
