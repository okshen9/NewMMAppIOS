//
//  Collection+.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

extension Collection where Self: BidirectionalCollection {

    /// Возвращает безопасный подмассив по указанному диапазону индексов.
    ///  - Parameters:
    ///  - bounds: переданный диапазону индексов.
    subscript(safe bounds: Range<Index>) -> SubSequence? {
        // Проверка нижней границы.
        guard let lowerBound = indices.first,
              bounds.lowerBound >= lowerBound else { return nil }

        // Проверка верхней границы.
        let upperBoundIndex = bounds.upperBound < endIndex ? bounds.upperBound : index(before: endIndex)

        return (bounds.lowerBound <= upperBoundIndex) ? self[bounds.lowerBound..<upperBoundIndex] : nil
    }
}
