//
//  StackViewBuilder.swift
//  MMApp
//
//  Created by artem on 20.12.2024.
//

import UIKit

final class StackViewBuilder {
    private var stackView = UIStackView()

    func with(subviews: [UIView]) -> Self {
        stackView = UIStackView(arrangedSubviews: subviews)
        return self
    }

    func vertical() -> Self {
        stackView.axis = .vertical
        return self
    }

    func horizontal() -> Self {
        stackView.axis = .horizontal
        return self
    }

    func spaced(_ spacing: CGFloat) -> Self {
        stackView.spacing = spacing
        return self
    }

    func with(axis: NSLayoutConstraint.Axis) -> Self {
        stackView.axis = axis
        return self
    }

    func with(alignment: UIStackView.Alignment) -> Self {
        stackView.alignment = alignment
        return self
    }

    func with(distribution: UIStackView.Distribution) -> Self {
        stackView.distribution = distribution
        return self
    }

    func with(spacing: CGFloat, after view: UIView) -> Self {
        stackView.setCustomSpacing(spacing, after: view)
        return self
    }

    func with(backgroundColor: UIColor) -> Self {
        stackView.backgroundColor = backgroundColor
        return self
    }

    func with(layoutMargin: UIEdgeInsets) -> Self {
        stackView.layoutMargins = layoutMargin
        stackView.isLayoutMarginsRelativeArrangement = true
        return self
    }

    func build() -> UIStackView {
        stackView
    }
}

extension Array where Element: UIView {
    func toHorizontalStackView() -> StackViewBuilder {
        StackViewBuilder().with(subviews: self).horizontal()
    }

    func toVerticalStackView() -> StackViewBuilder {
        StackViewBuilder().with(subviews: self).vertical()
    }
}
