//
//  SquareNotifierViewModifier.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-08-05.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct SquareNotifierViewModifier: ViewModifier {
    let text: String
    let showNotifier: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if self.showNotifier {
                Text(text)
                    .padding(.all, 30)
                    .background(Color.primary.opacity(0.3))
                    .cornerRadius(8)
            }
        }
    }
}

extension View {
    func squareNotifier(text: String, showNotifier: Bool) -> some View {
        self.modifier(SquareNotifierViewModifier(text: text, showNotifier: showNotifier))
    }
}

struct SquareNotifierViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        Color.blue.frame(width: 200, height: 300).squareNotifier(text: "Notify", showNotifier: true)
    }
}
