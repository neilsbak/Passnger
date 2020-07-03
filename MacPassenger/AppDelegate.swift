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
    private let toolbarObservable = ToolbarObservable()
    private lazy var deleteToolbarButton: NSButton = {
        let button = NSButton(image: NSImage(imageLiteralResourceName: "trash").tint(color: NSColor.textColor), target: self, action: #selector(deletePassword))
        button.bezelStyle = .texturedRounded
        return button
    }()
    private lazy var copyButton: NSButton = {
        let button = NSButton(image: NSImage(imageLiteralResourceName: "doc.on.clipboard").tint(color: NSColor.textColor), target: self, action: #selector(copyPassword))
        button.bezelStyle = .texturedRounded
        return button
    }()
    private var toolbarCancellable: AnyCancellable?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self

        toolbarCancellable = toolbarObservable.$selectedPassword.sink(receiveValue: { passwordItem in
            self.deleteToolbarButton.isEnabled = (passwordItem != nil)
            self.copyButton.isEnabled = (passwordItem != nil)
        })

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.titleVisibility = NSWindow.TitleVisibility.hidden
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: ContentView(model: Model.loadModel(), toolbar: toolbarObservable))
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
    static let delete = NSToolbarItem.Identifier(rawValue: "Delete")
    static let copy = NSToolbarItem.Identifier(rawValue: "Copy")
}

extension AppDelegate: NSToolbarDelegate {

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .title, .flexibleSpace, .copy, .delete, .createPassword]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .title, .flexibleSpace, .copy, .delete, .createPassword]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier.title:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.title)
            toolbarItem.title = "Passenger"
            return toolbarItem
        case NSToolbarItem.Identifier.delete:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.delete)
            toolbarItem.label = "Delete Password"
            toolbarItem.view = deleteToolbarButton
            return toolbarItem
        case NSToolbarItem.Identifier.copy:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.copy)
            toolbarItem.label = "Copy Password"
            toolbarItem.view = copyButton
            return toolbarItem
        case NSToolbarItem.Identifier.createPassword:
            let button = NSButton(image: NSImage(named: NSImage.addTemplateName)!, target: self, action: #selector(createPassword))
            button.bezelStyle = .texturedRounded
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.createPassword)
            toolbarItem.label = "Create Password"
            toolbarItem.view = button
            return toolbarItem
        default:
            return nil
        }
    }

    @objc func createPassword() {
        toolbarObservable.showCreatePassword = true
    }

    @objc func deletePassword() {
    }

    @objc func copyPassword() {
        guard let item = toolbarObservable.selectedPassword else { return }
        guard let password = try! item.getPassword() else {
            toolbarObservable.showGetMasterPassword = true
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
    }
}

class ToolbarObservable: ObservableObject {
    @Published
    var showCreatePassword = false

    @Published
    var selectedPassword: PasswordItem?

    @Published
    var showGetMasterPassword = false

    func copyPassword(hashedMasterPassword: String) {
        guard let item = selectedPassword else { return }
        let password = try! item.getPassword(hashedMasterPassword: hashedMasterPassword)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
        showGetMasterPassword = false
    }
}
