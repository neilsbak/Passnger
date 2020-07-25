//
//  PageLayout.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-22.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct PageLayout<Content: View>: View {
    let content: Content
    var body: some View {
        VStack {
            content
            Spacer()
        }.padding()
    }
}

struct PageLayout_Previews: PreviewProvider {
    static var previews: some View {
        PageLayout(content: Color.red.frame(width: 200, height: 100))
    }
}
