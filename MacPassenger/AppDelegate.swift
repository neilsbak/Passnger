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

    private lazy var model: Model = {
        return Model.loadModel()
    }()

    private lazy var deleteToolbarButton: NSButton = {
        let button = NSButton(image: NSImage(imageLiteralResourceName: "trash").tint(color: NSColor.textColor), target: self, action: #selector(deletePassword))
        button.image?.isTemplate = true
        button.bezelStyle = .texturedRounded
        return button
    }()

    private lazy var copyButton: NSButton = {
        let button = NSButton(image: NSImage(imageLiteralResourceName: "doc.on.clipboard").tint(color: NSColor.textColor), target: self, action: #selector(copyPassword))
        button.image?.isTemplate = true
        button.bezelStyle = .texturedRounded
        return button
    }()

    private lazy var createButton: NSButton = {
        let button = NSButton(image: NSImage(named: NSImage.addTemplateName)!, target: self, action: #selector(createPassword))
        button.bezelStyle = .texturedRounded
        return button
    }()

    private lazy var infoButton: NSButton = {
        let button = NSButton(image: NSImage(imageLiteralResourceName: "info").tint(color: NSColor.textColor), target: self, action: #selector(showInfo))
        button.image?.isTemplate = true
        button.bezelStyle = .texturedRounded
        return button
    }()

    private lazy var searchField: NSSearchField = {
        let searchField = NSSearchField()
        searchField.delegate = self
        return searchField
    }()

    private var toolbarCancellable: AnyCancellable?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self

        toolbarCancellable = toolbarObservable.$selectedPassword.sink(receiveValue: { passwordItem in
            self.deleteToolbarButton.isEnabled = (passwordItem != nil)
            self.copyButton.isEnabled = (passwordItem != nil)
            self.infoButton.isEnabled = (passwordItem != nil)
            self.copyMenuItem?.isEnabled = (passwordItem != nil)
            self.deleteMenuItem?.isEnabled = (passwordItem != nil)
            self.infoMenuItem?.isEnabled = (passwordItem != nil)

        })

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.title = "Passenger"
        //window.titleVisibility = NSWindow.TitleVisibility.hidden
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: ContentView(model: model, toolbar: toolbarObservable))
        window.toolbar = toolbar
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate {

    private func menuItem(widthTitle title: String) -> NSMenuItem? {
        return NSApplication.shared.mainMenu?.item(withTitle: title)
    }

    var copyMenuItem: NSMenuItem? { menuItem(widthTitle: "Copy") }
    var deleteMenuItem: NSMenuItem? { menuItem(widthTitle: "Delete") }
    var infoMenuItem: NSMenuItem? { menuItem(widthTitle: "Info") }

    private func disableMenuItems() {
        copyMenuItem?.isEnabled = false
        deleteMenuItem?.isEnabled = false
        infoMenuItem?.isEnabled = false
    }

    @IBAction func newDocument(_ sender: Any) {
        createPassword()
    }

    @IBAction func copy(_ sender: Any) {
        copyPassword()
    }

    @IBAction func delete(_ sender: Any) {
        deletePassword()
    }

    @IBAction func info(_ sender: Any) {
        showInfo()
    }

    @IBAction func find(_ sender: Any) {
        searchField.becomeFirstResponder()
    }

}

extension AppDelegate: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        model.searchText = (obj.object as? NSSearchField)?.stringValue ?? ""
    }
}

extension NSToolbarItem.Identifier {
    static let createPassword = NSToolbarItem.Identifier(rawValue: "CreatePassword")
    static let delete = NSToolbarItem.Identifier(rawValue: "Delete")
    static let copy = NSToolbarItem.Identifier(rawValue: "Copy")
    static let info = NSToolbarItem.Identifier(rawValue: "Info")
    static let search = NSToolbarItem.Identifier(rawValue: "Search")
}

extension AppDelegate: NSToolbarDelegate {

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.createPassword, .flexibleSpace, .copy, .delete, .info, .flexibleSpace, .search]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.createPassword, .flexibleSpace, .copy, .delete, .info, .flexibleSpace, .search]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier.delete:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.delete)
            toolbarItem.toolTip = "Delete Password"
            toolbarItem.view = deleteToolbarButton
            return toolbarItem
        case NSToolbarItem.Identifier.copy:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.copy)
            toolbarItem.label = "Copy Password"
            toolbarItem.view = copyButton
            return toolbarItem
        case NSToolbarItem.Identifier.createPassword:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.createPassword)
            toolbarItem.label = "Create Password"
            toolbarItem.view = createButton
            return toolbarItem
        case NSToolbarItem.Identifier.info:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.info)
            toolbarItem.label = "Info"
            toolbarItem.view = infoButton
            return toolbarItem
        case NSToolbarItem.Identifier.search:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.search)
            toolbarItem.label = "Search"
            toolbarItem.view = searchField
            return toolbarItem
        default:
            return nil
        }
    }

    @objc func createPassword() {
        toolbarObservable.showCreatePassword = true
    }

    @objc func deletePassword() {
        toolbarObservable.confirmDelete = true
    }

    @objc func copyPassword() {
        guard let item = toolbarObservable.selectedPassword else { return }
        switch try! item.getPassword() {
        case .cancelled:
            return
        case .value(let password):
            if let password = password {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(password, forType: .string)
            } else {
                toolbarObservable.getMasterPasswordReason = .copy
            }
        }
    }

    @objc func showInfo() {
        guard let item = toolbarObservable.selectedPassword else { return }
        switch try! item.masterPassword.getHashedPassword() {
        case .cancelled:
            return
        case .value(let password):
            if let password = password {
                toolbarObservable.showInfoHashedMasterPassword = password
            } else {
                toolbarObservable.getMasterPasswordReason = .info
            }
        }
    }
}

class ToolbarObservable: ObservableObject {

    enum GetMasterPasswordReason {
        case copy
        case info
        case none
    }

    @Published
    var getMasterPasswordReason = GetMasterPasswordReason.none

    @Published
    var showCreatePassword = false

    @Published
    var selectedPassword: PasswordItem?

    @Published
    var confirmDelete = false

    @Published fileprivate var showInfoHashedMasterPassword: String? = nil

    var showInfo: Binding<Bool> {
        Binding<Bool>(
            get: { self.showInfoHashedMasterPassword != nil },
            set: { showFlag in
                if (!showFlag) {
                    self.showInfoHashedMasterPassword = nil
                }
            }
        )
    }

    func gotHashedMasterPassword(_ hashedMasterPassword: String) {
        switch getMasterPasswordReason {
        case .copy:
            copyPassword(hashedMasterPassword: hashedMasterPassword)
        case .info:
            showInfoHashedMasterPassword = hashedMasterPassword
        default:
            break
        }
    }

    private func copyPassword(hashedMasterPassword: String) {
        guard let item = selectedPassword else { return }
        let password = try! item.getPassword(hashedMasterPassword: hashedMasterPassword)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
    }

    func deleteSelectedPassword(fromModel model: Model) {
        guard let deletedPassword = selectedPassword else {
            return
        }
        model.removePasswordItem(deletedPassword)
        confirmDelete = false
    }

    func changeInfoForPasswordItem(_ passwordItem: PasswordItem, toModel model: Model) {
        guard let hashedMasterPassword = showInfoHashedMasterPassword else { return }
        model.addPasswordItem(passwordItem, hashedMasterPassword: hashedMasterPassword)
    }
}
