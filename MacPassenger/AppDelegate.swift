//
//  AppDelegate.swift
//  MacPassenger
//
//  Created by Neil Bakhle on 2020-05-10.
//  Copyright © 2020 Neil. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let showCreatePassword = ShowCreatePasswordObservable()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.titleVisibility = NSWindow.TitleVisibility.hidden
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: ContentView(model: Model.loadModel(), showCreatePassword: showCreatePassword))
        window.toolbar = toolbar
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension NSToolbarItem.Identifier {
    static let title = NSToolbarItem.Identifier(rawValue: "Title")
    static let createPassword = NSToolbarItem.Identifier(rawValue: "CreatePassword")
}

extension AppDelegate: NSToolbarDelegate {

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .title, .flexibleSpace, .createPassword]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .title, .flexibleSpace, .createPassword]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier.title:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.title)
            toolbarItem.title = "Passenger"
            return toolbarItem
        case NSToolbarItem.Identifier.createPassword:
            let button = NSButton(image: NSImage(named: NSImage.addTemplateName)!, target: nil, action: nil)
            button.bezelStyle = .texturedRounded
            button.target = self
            button.action = #selector(createPassword)
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.createPassword)
            toolbarItem.label = "Create Password"
            toolbarItem.view = button
            return toolbarItem
        default:
            return nil
        }
    }

    @objc func createPassword() {
        showCreatePassword.showCreatePassword = true
    }
}

class ShowCreatePasswordObservable: ObservableObject {

    @Published
    var showCreatePassword = false

}

