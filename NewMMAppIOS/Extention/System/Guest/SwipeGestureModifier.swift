//
//  SwipeGestureModifier.swift
//  NewMMAppIOS
//
//  Created by artem on 25.04.2025.
//

import CoreFoundation
import SwiftUI


struct SwipeGestureModifier: ViewModifier {
    var onSwipeUp: (() -> Void)?
    var onSwipeDown: (() -> Void)?
    var onSwipeLeft: (() -> Void)?
    var onSwipeRight: (() -> Void)?
    var minimumDistance: CGFloat = 30
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: minimumDistance)
                    .onEnded { gesture in
                        let horizontalAmount = gesture.translation.width
                        let verticalAmount = gesture.translation.height
                        
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            // Horizontal swipe
                            if horizontalAmount < 0 {
                                onSwipeLeft?()
                            } else {
                                onSwipeRight?()
                            }
                        } else {
                            // Vertical swipe
                            if verticalAmount < 0 {
                                onSwipeUp?()
                            } else {
                                onSwipeDown?()
                            }
                        }
                    }
            )
    }
}

extension View {
    func onSwipe(
        up: (() -> Void)? = nil,
        down: (() -> Void)? = nil,
        left: (() -> Void)? = nil,
        right: (() -> Void)? = nil,
        minimumDistance: CGFloat = 30
    ) -> some View {
        modifier(SwipeGestureModifier(
            onSwipeUp: up,
            onSwipeDown: down,
            onSwipeLeft: left,
            onSwipeRight: right,
            minimumDistance: minimumDistance
        ))
    }
}
