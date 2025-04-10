//
//  AnyOptional.swift
//  NewMMAppIOS
//
//  Created by artem on 07.04.2025.
//


import Foundation

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

public extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool { self?.isEmpty ?? true }
}