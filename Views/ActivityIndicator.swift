//
//  ActivityIndicator.swift
//  Passnger
//
//  Created by Neil Bakhle on 2020-12-27.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: View {

    let isAnimating: Bool

    var body: some View {
        if #available(macOS 11, iOS 14, *) {
            ProgressView().opacity(isAnimating ? 1 : 0)
        } else {
            LegacyActivityIndicator(isAnimating: isAnimating)
        }
    }
}


#if os(macOS)
import AppKit


private struct LegacyActivityIndicator: NSViewRepresentable {
    typealias Configuration = (NSProgressIndicator) -> Void

    var isAnimating: Bool = true
    public var configuration: Configuration

    public init(isAnimating: Bool, configuration: Configuration? = nil) {
        self.isAnimating = isAnimating
        self.configuration = configuration ?? { progressIndicator in
            progressIndicator.style = .spinning
        }
    }

    func makeNSView(context: Context) -> NSProgressIndicator {
        NSProgressIndicator()
     }

     public func updateNSView(_ nsView: NSProgressIndicator, context:
        Context) {
         isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
         configuration(nsView)
     }
}
#else
import UIKit

private struct LegacyActivityIndicator: UIViewRepresentable {
    var isAnimating: Bool = true
    public var configuration = { (indicator: UIActivityIndicatorView) in }

    public init(isAnimating: Bool, configuration: ((UIActivityIndicatorView) -> Void)? = nil) {
        self.isAnimating = isAnimating
        if let configuration = configuration {
            self.configuration = configuration
        }
    }

     public func makeUIView(context: Context) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
     }

     public func updateUIView(_ uiView: UIActivityIndicatorView, context:
        Context) {
         isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
         configuration(uiView)
     }
}
#endif

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: true)
    }
}
