//
//  ShakeExtention.swift
//  MMApp
//
//  Created by artem on 06.04.2025.
//

import Foundation
import SwiftUI

extension UIDevice {
  static let deviceDidShake = Notification.Name(rawValue: "deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with: UIEvent?) {
    guard motion == .motionShake else { return }

    NotificationCenter.default.post(name: UIDevice.deviceDidShake, object: nil)
  }
}

struct ShakeGestureViewModifier: ViewModifier {
  // 1
  let action: () -> Void

  func body(content: Content) -> some View {
    content
      // 2
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShake)) { _ in
        action()
      }
  }
}

extension View {
  public func onShakeGesture(perform action: @escaping () -> Void) -> some View {
    self.modifier(ShakeGestureViewModifier(action: action))
  }
}
