//
//  KeyboardObserving.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-08-31.
//  Copyright © 2020 Neil. All rights reserved.
//

import SwiftUI

#if os(iOS)
struct KeyboardObserving: ViewModifier {

  @State var keyboardHeight: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .padding([.bottom], keyboardHeight)
      .edgesIgnoringSafeArea((keyboardHeight > 0) ? [.bottom] : [])
      .onReceive(
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
          .receive(on: RunLoop.main),
        perform: updateKeyboardHeight
      )
  }

  func updateKeyboardHeight(_ notification: Notification) {
    guard let info = notification.userInfo else { return }
    // Get the duration of the keyboard animation
    let keyboardAnimationDuration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25

    guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    // If the top of the frame is at the bottom of the screen, set the height to 0.
    withAnimation(.easeOut(duration: keyboardAnimationDuration)) {
        if keyboardFrame.origin.y == UIScreen.main.bounds.height {
          keyboardHeight = 0
        } else {
          // IMPORTANT: This height will _include_ the SafeAreaInset height.
          keyboardHeight = keyboardFrame.height
        }
    }
  }
}
#endif

extension View {
  func keyboardObserving() -> some View {
    #if os(iOS)
    return self.modifier(KeyboardObserving())
    #else
    return self
    #endif
  }
}
