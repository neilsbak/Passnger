//
//  NotifySquareViewModifier.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-08-05.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct SquareNotifierViewModifier: ViewModifier {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct NotifySquareViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        Color.blue.frame(width: 200, height: 300) SquareNotifierViewModifier()
    }
}
