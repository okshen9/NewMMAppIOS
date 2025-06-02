//
//  ValuePersent.swift
//  NewMMAppIOS
//
//  Created by artem on 02.06.25.
//

extension KeyedDecodingContainer {
    /// пробуем получить дабл значени из строки или дабл
    func getDoubleValue(forKey key: Key) -> Double? {
        // Пробуем сначала как строку
        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let doubleFromString = Double(stringValue) {
            return doubleFromString
        }

        // Затем как Double
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return doubleValue
        }

        return nil
    }
}
