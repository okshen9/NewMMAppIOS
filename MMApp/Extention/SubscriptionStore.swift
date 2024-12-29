//
//  SubscriptionStore.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation
import Combine

private var rawPointer = true

private class SubscriptionsBag: NSObject {
    var subscriptions = Set<AnyCancellable>()
}

public protocol SubscriptionStore: AnyObject {
    var subscriptions: Set<AnyCancellable> { get set }
}

public extension SubscriptionStore {
    private func synchronizedBag<T>(
        _ action: () -> T
    ) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }

    private var subscriptionsBag: SubscriptionsBag {
        get {
            synchronizedBag {
                if let subscriptionsBag = objc_getAssociatedObject(self, &rawPointer) as? SubscriptionsBag {
                    return subscriptionsBag
                }
                let subscriptionsBag = SubscriptionsBag()
                objc_setAssociatedObject(self, &rawPointer, subscriptionsBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return subscriptionsBag
            }
        }

        set {
            synchronizedBag {
                objc_setAssociatedObject(self, &rawPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var subscriptions: Set<AnyCancellable> {
        get {
            subscriptionsBag.subscriptions
        }

        set {
            subscriptionsBag.subscriptions = newValue
        }
    }
}

/// SwiftUI обертка для хранилища подписок
final class SubscriptionManager: ObservableObject, SubscriptionStore {}

