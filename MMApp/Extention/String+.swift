//
//  String+.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

/// Небольшое расширение для проверки строки на пригодность к обработке.
extension String {
    /// Удобное расширение для пустой строки, котрой нет в STL Swift.
    static let empty = ""

    /// Строка приогда если не пустая и не содержит только одни управляющие символы.
    var isValid: Bool { !isEmpty && !Set(self).isSubset(of: " \n\t\r") }

    /// Строка неприогда если либо пустая либо содержит только одни управляющие символы.
    var isNotValid: Bool { isEmpty || Set(self).isSubset(of: " \n\t\r") }

    var toInt: Int? { Int(self) }
    var toUInt64: UInt64? { UInt64(self) }
    var toInt64: Int64? { Int64(self) }
    var toDouble: Double? { Double(self) }
    var toBool: Bool? { Bool(self) }
    var toFloat: Float? { Float(self) }
}

