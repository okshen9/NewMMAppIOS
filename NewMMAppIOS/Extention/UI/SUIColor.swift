//
//  SUIColor.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation
import SwiftUI

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

extension Color {
    ///  #FF4646
    static let mainRed = Color(hex: "FF4646")!
    /// #E2EBEE
    static let secondbackGraund = Color(hex: "E2EBEE")!
    /// #000000 0.87
    static let headerText = Color(hex: "000000", alpha: 0.87)!
    /// #000000 0.54
    static let subtitleText = Color(hex: "000000", alpha: 0.54)!
    /// #999999
    static let tabbarSecond = Color(hex: "999999")!
    /// 0088cc
    static let tgColor = Color(hex: "0088cc")!
    /// 9DA1AF
    static let manColor = Color(hex: "FAFAFA")!
}

extension UIColor {
    ///  #FF4646
    static let mainRed = UIColor(hex: "FF4646")!

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


struct BackGroundRedView: ViewModifier {
    var color: Color = .red
    func body(content: Content) -> some View {
        content
            .background(color)
    }
}

struct RandomBackGroundColor: ViewModifier {
    var color: Color = Color(
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    )
    func body(content: Content) -> some View {
        content
            .background(color)
    }
}

extension View {
    func bred(_ color: Color = .red) -> some View {
        modifier(BackGroundRedView())
    }
    
    func randomBColor() -> some View {
        modifier(RandomBackGroundColor())
    }
}
