//
//  TextAlert.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-07-05.
//  Copyright © 2020 Neil. All rights reserved.
//
import SwiftUI
import UIKit

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: nil, preferredStyle: .alert)
        addTextField { $0.placeholder = alert.placeholder }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            _ = alert.action(nil)
        })
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            _ = alert.action(textField?.text)
        })
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlert
    let content: Content

    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }

    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }


    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = { text in
                guard let text = text else {
                    self.isPresented = false
                    return false
                }
                let isValid = self.alert.action(text)
                self.isPresented = false
                if !isValid {
                    //The alert has been dismissed from the action button,
                    //So show a new one
                    self.isPresented = true
                }
                return isValid
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && context.coordinator.alertController != nil && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}

public struct TextAlert {
    public var title: String
    public var placeholder: String = ""
    public var accept: String = "OK"
    public var cancel: String = "Cancel"
    public var action: (String?) -> Bool
}

extension View {

    func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }

    func masterPasswordAlert(masterPassword: MasterPassword?, isPresented: Binding<Bool>, enteredPassword: @escaping (String) -> Void) -> some View {
            if masterPassword == nil || isPresented.wrappedValue == false {
                return AnyView(self)
            }
            return AnyView(self.alert(isPresented: isPresented, TextAlert(title: "Enter Master Password", placeholder: "Master Password") { passwordText in
                guard let passwordText = passwordText else {
                    return false
                }
                let doubleHashedPassword = MasterPassword.doubleHashPassword(passwordText)
                if doubleHashedPassword != masterPassword!.doubleHashedPassword {
                    return false
                }
                enteredPassword(passwordText)
                return true
            }))
    }
}
