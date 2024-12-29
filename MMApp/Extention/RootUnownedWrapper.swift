//
//  RootUnownedWrapper.swift
//  MMApp
//
//  Created by artem on 20.12.2024.
//

import protocol Combine.Publisher
import class Combine.AnyCancellable

private struct RootUnownedWrapper<R: AnyObject> {
    unowned var root: R
    init(_ root: R) { self.root = root }
}

private struct RootWeakWrapper<R: AnyObject> {
    weak var root: R!
    init(_ root: R) { self.root = root }
}

extension Publisher where Self.Failure == Never {
    typealias TRootKeyPath<T> = ReferenceWritableKeyPath<T, Self.Output>
    fileprivate typealias TWeakKeyPath<T: AnyObject> = WritableKeyPath<RootWeakWrapper<T>, T>
    func assignWeakly<Root: AnyObject>(to keyPath: TRootKeyPath<Root>, on object: Root) -> AnyCancellable {
        let wrapped = RootWeakWrapper(object)
        let wkp: TWeakKeyPath<Root> = \.root
        return assign(to: wkp.appending(path: keyPath), on: wrapped)
    }

    fileprivate typealias TUnownedKeyPath<T: AnyObject> = WritableKeyPath<RootUnownedWrapper<T>, T>
    func assignUnowned<Root: AnyObject>(to keyPath: TRootKeyPath<Root>, on object: Root) -> AnyCancellable {
        let wrapped = RootUnownedWrapper(object)
        let wkp: TUnownedKeyPath<Root> = \.root
        return assign(to: wkp.appending(path: keyPath), on: wrapped)
    }
}
