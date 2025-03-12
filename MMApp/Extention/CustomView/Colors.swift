//
//  Colors.swift
//  MMApp
//
//  Created by artem on 20.12.2024.
//

import Foundation
import UIKit

extension UIColor {
    /// #828282
    static let textTertiarly = UIColor(hex: "828282")!
    
    static let controlSecondaryDefaultTransparent = UIColor(hex: "FFFFFF", alpha: 0.16)!
}

//public enum TextColor {
extension UIColor {
    /// #FFFFFF
    static let textHeadline = UIColor(hex: "FFFFFF")!
    /// #F6F6F6
    static let textPrimary = UIColor(hex: "F6F6F6")!
    /// #A1A1A1
    static let textSecondary = UIColor(hex: "A1A1A1")!
    /// #616161
    static let textTertiary = UIColor(hex: "616161")!
    /// #434343
    static let textQuaternary = UIColor(hex: "434343")!
    /// #151515
    static let textInverted = UIColor(hex: "151515")!
    /// #FD6851
    static let textError = UIColor(hex: "FD6851")!
    /// #91DB4B
    static let textSuccess = UIColor(hex: "91DB4B")!
    /// #8A66FF
    static let textActiveDefualt = UIColor(hex: "8A66FF")!
    /// 73A6FF
    static let textLink = UIColor(hex: "73A6FF")!
    /// 000000
    static let textBlack = UIColor(hex: "000000")!
    
    /// 0088cc
    static let tgColor = UIColor(hex: "0088cc")!
    
    /// 9DA1AF
    static let manColor = UIColor(hex: "FAFAFA")!
}

//public enum LayerColorName {
extension UIColor {
    /// #000000
    static let layerBackground = UIColor(hex: "000000")!
    /// #151515
    static let layerZero = UIColor(hex: "151515")!
    /// #1D1D1D
    static let layerFirst = UIColor(hex: "1D1D1D")!
    /// #282828
    static let layerSecond = UIColor(hex: "282828")!
    /// #303030
    static let layerThird = UIColor(hex: "303030")!
    /// #F6F6F6
    static let layerInverted = UIColor(hex: "F6F6F6")!
    
    ///  #FF4646
    static let mainRed = UIColor(hex: "FF4646")!
    /// #E2EBEE
    static let secondbackGraund = UIColor(hex: "E2EBEE")
    /// #000000 0.87
    static let headerText = UIColor(hex: "00000", alpha: 0.87)!
    /// #000000 0.54
    static let subtitleText = UIColor(hex: "00000", alpha: 0.54)!
    /// #F2F4F4
    static let textFieldBack = UIColor(hex: "F2F4F4")!
}

extension UIColor {
    static let layerFirstTransparent = UIColor.layerFirst.withAlphaComponent(0.56)
    static let layerSecondTransparent = UIColor.layerSecond.withAlphaComponent(0.56)
    static let layerThirdTransparent = UIColor.layerThird.withAlphaComponent(0.56)
    static let layerFourthTransparent = UIColor.textHeadline.withAlphaComponent(0.04)
    static let layerFifthTransparent = UIColor.textHeadline.withAlphaComponent(0.64)
}
