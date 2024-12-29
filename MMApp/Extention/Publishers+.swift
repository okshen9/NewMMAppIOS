//
//  Publishers+.swift
//  wasd
//
//  Created by Сутормин Кирилл on 11.12.2023.
//

import Combine
import Foundation
import UIKit

// MARK: - Publisher
extension Publishers {
    /// Издатель, который обертывает объекты, использующие механизм Target & Action,
    /// например - UIBarButtonItem, который не совместим с KVO и не использует UIControlEvent(s).
    ///
    /// Вместо этого вы передаете общий элемент управления и две функции:
    /// Один для добавления действия таргета к предоставленному элементу управления, а второй для
    /// удаления действия таргета из предоставленного элемента управления.
    struct ControlTarget<Control: AnyObject>: Publisher {
        typealias Output = Void
        typealias Failure = Never

        private let control: Control
        private let addTargetAction: (Control, AnyObject, Selector) -> Void
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void

        /// Инициализируйте издателя, который выдает Void всякий раз, когда
        /// при условии, что элемент управления запускает действие.
        ///
        /// - parameter control: UI Control.
        /// - parameter addTargetAction: Функция, которая принимает Control, Target и Selector и
        ///                              отвечает за добавление действия таргета в предоставленный элемент управления.
        /// - parameter removeTargetAction: Функция, которая принимает Control, Target и Selector и
        ///                                 отвечает за удаление действия таргета из предоставленного элемента управления.
        init(
            control: Control,
            addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void
        ) {
            self.control = control
            self.addTargetAction = addTargetAction
            self.removeTargetAction = removeTargetAction
        }

        func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(
                subscriber: subscriber,
                control: control,
                addTargetAction: addTargetAction,
                removeTargetAction: removeTargetAction
            )

            subscriber.receive(subscription: subscription)
        }
    }

    /// A Control Event is a publisher that emits whenever the provided
    /// Control Events fire.
    struct ControlEvent<Control: UIControl>: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event

        /// Initialize a publisher that emits a Void
        /// whenever any of the provided Control Events trigger.
        ///
        /// - parameter control: UI Control.
        /// - parameter events: Control Events.
        public init(
            control: Control,
            events: Control.Event
        ) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Publishers.ControlEvent.Subscription(
                subscriber: subscriber,
                control: control,
                event: controlEvents
            )

            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription

extension Publishers.ControlTarget {
    private final class Subscription<S: Subscriber, ControlObject: AnyObject>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: ControlObject?

        private let removeTargetAction: (ControlObject?, AnyObject, Selector) -> Void
        private let action = #selector(handleAction)

        init(
            subscriber: S,
            control: ControlObject,
            addTargetAction: @escaping (ControlObject, AnyObject, Selector) -> Void,
            removeTargetAction: @escaping (ControlObject?, AnyObject, Selector) -> Void
        ) {
            self.subscriber = subscriber
            self.control = control
            self.removeTargetAction = removeTargetAction

            addTargetAction(control, self, action)
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
            removeTargetAction(control, self, action)
        }

        @objc private func handleAction() {
            _ = subscriber?.receive()
        }
    }
}

// MARK: - Subscription
extension Publishers.ControlEvent {
    private final class Subscription<S: Subscriber, C: UIControl>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: C?

        init(subscriber: S, control: C, event: C.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(handleEvent), for: event)
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
        }

        @objc private func handleEvent() {
            _ = subscriber?.receive()
        }
    }
}
