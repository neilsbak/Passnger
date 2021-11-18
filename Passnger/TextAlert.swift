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
        addTextField {
            $0.placeholder = alert.placeholder
            $0.isSecureTextEntry = alert.isSecure
        }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            _ = alert.action(alert.cancel, nil)
        })
        let textField = self.textFields?.first
        for item in alert.accept {
            addAction(UIAlertAction(title: item, style: .default) { _ in
                _ = alert.action(item, textField?.text)
            })
        }
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
        if isPresented && context.coordinator.alertController == nil {
            var alert = self.alert
            alert.action = { buttonTitle, text in
                context.coordinator.alertController = nil
                guard let text = text else {
                    self.isPresented = false
                    return false
                }
                self.isPresented = false
                let isValid = self.alert.action(buttonTitle, text)
                if !isValid {
                    //The alert has been dismissed from the action button,
                    //So show a new one
                    self.isPresented = true
                }
                return isValid
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            DispatchQueue.main.async {
                uiViewController.present(context.coordinator.alertController!, animated: true)
            }
        }
        if !isPresented && context.coordinator.alertController != nil && uiViewController.presentedViewController == context.coordinator.alertController {
            context.coordinator.alertController = nil
            DispatchQueue.main.async {
                uiViewController.dismiss(animated: true)
            }
        }
    }
}

struct TextAlert {
    var title: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var accept: [String] = ["OK"]
    var cancel: String = "Cancel"
    var action: (String, String?) -> Bool
}

extension View {

    func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }

    // Allowing masterPassword to be nil since this view modifier will remain hidden
    // unless password text for a master password is requested
    func masterPasswordAlert(masterPassword: MasterPassword?, isPresented: Binding<Bool>, onGotPassword: @escaping (MasterPassword, String, Bool) -> Void) -> some View {
        let submitTitle = "Submit"
        let submitAndSaveTitle = "Submit and Save to Device"
        return self.alert(isPresented: isPresented, TextAlert(title: "Enter Master Password", placeholder: masterPassword?.name ?? "", isSecure: true, accept: [submitTitle, submitAndSaveTitle]) { buttonTitle, passwordText in
                guard let passwordText = passwordText else {
                    return false
                }
                let doubleHashedPassword = MasterPassword.doubleHashPassword(passwordText)
                if doubleHashedPassword != masterPassword!.doubleHashedPassword {
                    return false
                }
                onGotPassword(masterPassword!, passwordText, buttonTitle == submitAndSaveTitle)
                return true
            })
    }
}
