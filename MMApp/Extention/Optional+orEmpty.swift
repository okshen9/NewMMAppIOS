//
//  Optional+orEmpty.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import UIKit

extension String? {
    var orEmpty: String {
        self ?? ""
    }
}

extension String.SubSequence? {
    var orEmpty: String {
        String(self ?? "")
    }
}

extension AttributedString? {
    var orEmpty: AttributedString {
        self ?? AttributedString()
    }
}

extension UIView? {
    /// В случае отсутствия вью - подставляем пустую вью
    var orEmpty: UIView {
        self ?? UIView()
    }
}
