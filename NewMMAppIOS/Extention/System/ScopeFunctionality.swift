//
//  ScopeFunctionality.swift
//  MMApp
//
//  Created by artem on 17.12.2024.
//

import UIKit
import Combine

protocol ScopeFunctionality {}

extension ScopeFunctionality {
    ///  Apply settings to the object rethrowing error
    /// - Parameter setup: Throwing setup closure
    /// - Returns: the object itself - self
    func apply(_ setup: (Self) throws -> Void) rethrows -> Self {
        try setup(self)
        return self
    }
    
    func apply(_ setup: ((Self) throws -> Void)?) rethrows -> Self {
        try setup?(self)
        return self
    }

    func apply(_ setup: ((Self) async throws -> Void)?) async rethrows -> Self {
        try await setup?(self)
        return self
    }
}

extension NSObject: ScopeFunctionality {}
