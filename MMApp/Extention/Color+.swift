//
//  Colors.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation
import UIKit

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

