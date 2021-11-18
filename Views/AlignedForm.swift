//
//  AlignedForm.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-09-04.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

// This fixes a bug where a Form with a picker is not
// left aligned in MacOS
struct AlignedForm<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        #if os(iOS)
        Form {
            content
        }
        #else
        ScrollView {
            VStack {
                content
            }
        }
        #endif
    }
}

struct AlignedSection<Header: View, Content: View>: View {

    let content: Content
    let header: Header

    init(header: Header, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        #if os(iOS)
        Section(header: header) {
            content
        }
        #else
        HStack {
            VStack(alignment: .leading) {
                header
                Spacer().frame(height: 8)
                content
            }
            Spacer()
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        #endif
    }
}


struct AlignedForm_Previews: PreviewProvider {
    static var previews: some View {
        AlignedForm {
            AlignedSection(header: Text("Header")) {
                TextField("FormField", text: Binding.constant("Form Field Value"))
            }
            AlignedSection(header: Text("Header 2")) {
                TextField("FormField", text: Binding.constant("Form Field Value"))
            }
        }
    }
}
