//
//  UnknownCasedEnum.swift
//  MMApp
//
//  Created by artem on 09.02.2025.
//


protocol UnknownCasedEnum: RawRepresentable, CaseIterable where RawValue: Equatable {
    
    static var unknown: Self { get }
    init(rawValue: RawValue)
}

extension UnknownCasedEnum {
    init(rawValue: RawValue) {
        // Ищем кейс, соответствующий rawValue
        if let value = Self.allCases.first(where: { $0.rawValue == rawValue }) {
            self = value
        } else {
            // Если не нашли, используем unknown
            self = Self.unknown
        }
    }
}
