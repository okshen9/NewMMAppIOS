//
//  UIView+Combine.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation
import Combine
import UIKit

extension UIView {
    var publisher: Publishers.UIViewPublisher {
        return Publishers.UIViewPublisher(view: self)
    }

    var longTapPublisher: Publishers.UIViewLongTapPublisher {
        return Publishers.UIViewLongTapPublisher(view: self)
    }
}

extension Publishers {
    struct UIViewPublisher: Publisher {
        typealias Output = UITapGestureRecognizer
        typealias Failure = Never

        private let view: UIView

        init(view: UIView) { self.view = view }

        func receive<S>(subscriber: S)
        where S: Subscriber, Publishers.UIViewPublisher.Failure == S.Failure, Publishers.UIViewPublisher.Output == S.Input {
            let subscription = UIViewSubscription(subscriber: subscriber, view: view)
            subscriber.receive(subscription: subscription)
        }
    }

    class UIViewSubscription<S: Subscriber>: Subscription where S.Input == UITapGestureRecognizer, S.Failure == Never {
        private var subscriber: S?
        private weak var view: UIView?

        init(subscriber: S, view: UIView) {
            self.subscriber = subscriber
            self.view = view
            subscribe()
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            subscriber = nil
            view = nil
        }

        private func subscribe() {
            let tapAction = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
            view?.addGestureRecognizer(tapAction)
        }

        @objc private func tap(_ sender: UITapGestureRecognizer) {
            _ = subscriber?.receive(sender)
        }
    }

    struct UIViewLongTapPublisher: Publisher {
        typealias Output = UILongPressGestureRecognizer
        typealias Failure = Never

        private let view: UIView

        init(view: UIView) { self.view = view }

        func receive<S>(subscriber: S)
        where S: Subscriber,
              Publishers.UIViewLongTapPublisher.Failure == S.Failure,
              Publishers.UIViewLongTapPublisher.Output == S.Input {
            let subscription = UIViewLongTapSubscription(subscriber: subscriber, view: view)
            subscriber.receive(subscription: subscription)
        }
    }

    class UIViewLongTapSubscription<S: Subscriber>: Subscription
    where S.Input == UILongPressGestureRecognizer, S.Failure == Never {
        private var subscriber: S?
        private weak var view: UIView?

        init(subscriber: S, view: UIView) {
            self.subscriber = subscriber
            self.view = view
            subscribe()
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            subscriber = nil
            view = nil
        }

        private func subscribe() {
            let tapAction = UILongPressGestureRecognizer(target: self, action: #selector(tap(_:)))
            view?.addGestureRecognizer(tapAction)
        }

        @objc private func tap(_ sender: UILongPressGestureRecognizer) {
            _ = subscriber?.receive(sender)
        }
    }
}

