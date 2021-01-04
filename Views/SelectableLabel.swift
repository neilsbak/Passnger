//
//  SelectableLabel.swift
//  Passnger
//
//  Created by Neil Bakhle on 2020-12-21.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit

struct SelectableLabel: View, NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField()
        label.isBezeled = false
        label.isEditable = false
        label.drawsBackground = false
        label.isSelectable = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }

    func updateNSView(_ label: NSTextField, context: Context) {
        label.stringValue = text
    }
}

#elseif os(iOS)
// can't find a good soution to this in iOS
struct SelectableLabel: View {
    let text: String
    var body: some View {
        Text(text)
    }
}
#endif

struct SelectableLabel_Previews: PreviewProvider {
    static var previews: some View {
        SelectableLabel(text: "Selectable Label")
    }
}
