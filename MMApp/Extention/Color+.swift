//
//  Colors.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    /// Черный ли цвет
    func isBlackColor() -> Bool {
        var red = CGFloat.zero, green = CGFloat.zero, blue = CGFloat.zero, alpha = CGFloat.zero
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return red < 0.05 && green < 0.05 && blue < 0.05
    }

    /// Белый ли цвет
    func isWhiteColor() -> Bool {
        var red = CGFloat.zero, green = CGFloat.zero, blue = CGFloat.zero, alpha = CGFloat.zero
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return red > 0.95 && green > 0.95 && blue > 0.95
    }
}

extension UIColor {
    /// Получить hue, saturation, lightness
    /// - Returns: hue, saturation, lightness
    func getHSL() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) {
        var hue = CGFloat.zero
        var saturation = CGFloat.zero
        var brightness = CGFloat.zero
        var alpha: CGFloat = 1.0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return (hue, saturation, brightness)
    }
}

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb = UInt64.zero

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        guard rgb <= 0xFFFFFF else {
            return nil
        }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func toHex() -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#535353"
        }

        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

extension Color {
    init?(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb = UInt64.zero

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        guard rgb <= 0xFFFFFF else {
            return nil
        }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
        self.init(cgColor: uiColor)
        
    }

    func toHex() -> String {
        guard let components = cgColor?.components, components.count >= 3 else {
            return "#535353"
        }

        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

extension Color {
    /// Возвращает более светлый цвет, увеличивая значения RGB-компонентов.
    /// - Parameter amount: Коэффициент осветления (от 0 до 1). Значение 0 не изменяет цвет, 1 делает его белым.
    /// - Returns: Осветленный цвет.
    func lighter(by amount: Double) -> Color {
        guard amount >= 0, amount <= 1 else { return self }

        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let newRed = min(red + (1 - red) * CGFloat(amount), 1)
            let newGreen = min(green + (1 - green) * CGFloat(amount), 1)
            let newBlue = min(blue + (1 - blue) * CGFloat(amount), 1)
            return Color(red: newRed, green: newGreen, blue: newBlue)
        }
        
        return self
    }
}
