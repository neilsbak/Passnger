//
//  NSImageExtension.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-06-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Cocoa

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
