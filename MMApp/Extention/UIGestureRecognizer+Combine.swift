//
//  UIGestureRecognizer+Combine.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Combine
import UIKit

// MARK: - Gesture Publishers

extension UITapGestureRecognizer {
    /// Издатель, который выдает сигнал при срабатывании распознавателя жестов касания.
    var tapPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UIPinchGestureRecognizer {
    /// Издатель, который выдает сигнал, когда срабатывает распознаватель жестов Pinch.
    var pinchPublisher: AnyPublisher<UIPinchGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UIRotationGestureRecognizer {
    /// Издатель, который выдает сигнал при срабатывании распознавателя жестов вращения.
    var rotationPublisher: AnyPublisher<UIRotationGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UISwipeGestureRecognizer {
    /// Издатель, который выдает сообщение при срабатывании распознавателя жестов смахивания.
    var swipePublisher: AnyPublisher<UISwipeGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UIPanGestureRecognizer {
    /// Издатель, который выдает сигнал, когда срабатывает распознаватель жестов панорамирования.
    var panPublisher: AnyPublisher<UIPanGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UIScreenEdgePanGestureRecognizer {
    /// Издатель, который выдает сообщение при срабатывании распознавателя жестов края экрана.
    var screenEdgePanPublisher: AnyPublisher<UIScreenEdgePanGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

extension UILongPressGestureRecognizer {
    /// Издатель, который выдает сообщение при срабатывании распознавателя длительного нажатия.
    var longPressPublisher: AnyPublisher<UILongPressGestureRecognizer, Never> {
        gesturePublisher(for: self)
    }
}

// MARK: - Private Helpers

private func gesturePublisher<Gesture: UIGestureRecognizer>(for gesture: Gesture) -> AnyPublisher<Gesture, Never> {
    Publishers.ControlTarget(
        control: gesture,
        addTargetAction: { gesture, target, action in
            gesture.addTarget(target, action: action)
        },
        removeTargetAction: { gesture, target, action in
            gesture?.removeTarget(target, action: action)
        }
    )
    .subscribe(on: DispatchQueue.main)
    .map { gesture }
    .eraseToAnyPublisher()
}
