//
//  UIView+.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import UIKit
import QuartzCore

public extension UIView {
    convenience init(backgroundColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
    }

    static func getFrame(from fromView: UIView, to toView: UIView) -> CGRect {
        return fromView.superview?.convert(fromView.frame, to: toView) ?? .zero
    }

    func touchInside(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        guard let touch = touches.first else { return false }
        let pointTouch = touch.location(in: self)
        return point(inside: pointTouch, with: event)
    }

    static func resizableVerticalSpaceView() -> UIView {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .vertical)
        v.backgroundColor = .clear
        return v
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = corners
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners.rectCorner(),
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
            layer.masksToBounds = true
        }
    }
}

extension CACornerMask {
    public func rectCorner() -> UIRectCorner {
        var cornerMask = UIRectCorner()
        if contains(.layerMinXMinYCorner) {
            cornerMask.insert(.topLeft)
        }
        if contains(.layerMaxXMinYCorner) {
            cornerMask.insert(.topRight)
        }
        if contains(.layerMinXMaxYCorner) {
            cornerMask.insert(.bottomLeft)
        }
        if contains(.layerMaxXMaxYCorner) {
            cornerMask.insert(.bottomRight)
        }
        return cornerMask
    }
}

extension CACornerMask {
    public static let all: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    public static let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
}

extension UIView {
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func setBorder(width: CGFloat, color: CGColor) {
        layer.borderWidth = width
        layer.borderColor = color
    }

    func setBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    func drawCornerRadius(
        rect: CGRect,
        cornerRadius: CGFloat,
        lineWidth: CGFloat,
        color: UIColor
    ) {
        setCornerRadius(cornerRadius)
        let stroke: CAShapeLayer = CAShapeLayer()
        let strokePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        stroke.path = strokePath.cgPath
        stroke.fillColor = nil
        stroke.lineWidth = lineWidth
        stroke.strokeColor = color.cgColor
        stroke.frame = rect
        layer.insertSublayer(stroke, at: 1)
    }

    func bindView(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor, constant: -insets.top),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: -insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right)
        ]
    }

    func bindViewSafeArea(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: -insets.top),
            safeAreaLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -insets.left),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            safeAreaLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right)
        ]
    }

    func bind(size: CGSize) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
    }

    func bindToCenter(_ view: UIView) -> [NSLayoutConstraint] {
        return [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }

    func bindView(_ view: UIView, frame: CGRect) -> [NSLayoutConstraint] {
        return [
            view.widthAnchor.constraint(equalToConstant: frame.width),
            view.heightAnchor.constraint(equalToConstant: frame.height),
            view.leftAnchor.constraint(equalTo: leftAnchor, constant: frame.minX),
            view.topAnchor.constraint(equalTo: topAnchor, constant: frame.minY)
        ]
    }

    func isSubview(_ view: UIView) -> Bool {
        return subviews.filter { $0 === view }.count > 0 // swiftlint:disable:this empty_count
    }
}

extension UILayoutGuide {
    func bindView(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor, constant: -insets.top),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: -insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right)
        ]
    }
}

extension UIView {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }

    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }

    func removeArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIView {
    func blink(withDuration: CGFloat = 0.2, currentAlpha: CGFloat = 1.0, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: withDuration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                self?.alpha = 0.3
            },
            completion: { [weak self] _ in
                self?.alpha = currentAlpha
                completion?()
            }
        )
    }
}

extension UIView {
    ///  Запуск анимации мерцания
    func startShimmerAnimation() {
        let fromColor = UIColor.layerFirst.withAlphaComponent(0.1).cgColor
        let toColor = UIColor.black.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [toColor, fromColor, toColor]
        gradientLayer.frame = CGRect(
            x: -self.bounds.size.width,
            y: -self.bounds.size.height,
            width: 3 * self.bounds.size.width,
            height: 3 * self.bounds.size.height
        )

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        gradientLayer.locations = [0.4, 0.6]
        self.layer.mask = gradientLayer

        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = CFTimeInterval(2)
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        CATransaction.commit()
    }

    ///  Остановка анимации мерцания
    func stopShimmerAnimation() {
        self.layer.mask = nil
    }
}

extension UIView {
    func overlay(color: UIColor, alpha: CGFloat) {
        let overlay = UIView().apply {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.frame = bounds
            $0.backgroundColor = color
            $0.alpha = alpha
        }
        addSubview(overlay)
    }

    func animateHidden(_ isHidden: Bool) {
        if isHidden {
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { _ in
                self.isHidden = true
            }
        } else {
            self.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }

    func toImage() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size).image { layer.render(in: $0.cgContext) }
    }
}

extension UIView {
    /// Добавляет слой круглого прогрессбара
    /// - Parameters:
    ///     - color: цвет отображаемой шкалы
    ///     - percent: процент заполнения
    ///     - size: диаметр добавляемого круга
    @discardableResult
    func addCircleLayer(
        percent: CGFloat,
        color: UIColor,
        size: CGFloat = 100
    ) -> UIView {
        let trackLayer = CAShapeLayer()
        let shapeLayer = CAShapeLayer()
        trackLayer.position = .zero
        shapeLayer.position = .zero
        configureTrackLayer(trackLayer, radius: self.bounds.height / 2)
        configureShapeLayer(shapeLayer, radius: self.bounds.height / 2, color: color, percent: percent)
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
        return self
    }

    /// конфигурация заднего слоя слоя круга
    /// - Parameters:
    ///     - baseTrackLayer: слой на котором отображаем задний фон прогресс бара
    ///     - radius: радиус отображаемого круга
    fileprivate func configureTrackLayer(
        _ baseTrackLayer: CAShapeLayer,
        radius: CGFloat,
        lineWidth: CGFloat = 10
    ) {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
            radius: radius - lineWidth / 2,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
        baseTrackLayer.path = circularPath.cgPath
        baseTrackLayer.strokeColor = UIColor.controlSecondaryDefaultTransparent.cgColor
        baseTrackLayer.lineWidth = lineWidth
        baseTrackLayer.fillColor = UIColor.clear.cgColor
        baseTrackLayer.lineCap = CAShapeLayerLineCap.round
    }

    /// конфигурация слоя заполнения шкалы
    /// - Parameters:
    ///     - baseTrackLayer: слой на котором отображаем задний фон прогресс бара
    ///     - radius: радиус отображаемого круга
    ///     - color: цвет отображаемой шкалы
    ///     - percent: процент заполнения
    fileprivate func configureShapeLayer(
        _ baseShapeLayer: CAShapeLayer,
        radius: CGFloat,
        color: UIColor,
        percent: CGFloat = 0,
        lineWidth: CGFloat = 10
    ) {
        let circularShapePath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
            radius: radius - lineWidth / 2,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )
        baseShapeLayer.path = circularShapePath.cgPath
        baseShapeLayer.strokeColor = color.cgColor
        baseShapeLayer.lineWidth = lineWidth
        baseShapeLayer.fillColor = UIColor.clear.cgColor
        baseShapeLayer.lineCap = CAShapeLayerLineCap.round
        baseShapeLayer.strokeEnd = percent

        baseShapeLayer.shadowOffset = .zero
        baseShapeLayer.shadowColor = color.cgColor
        baseShapeLayer.shadowRadius = 6
        baseShapeLayer.shadowOpacity = 0.4
    }
}

extension UIView {
    /// Найти родительский ViewController для View
    /// - Returns: родительский ViewController
    func parentViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.parentViewController()
        } else {
            return nil
        }
    }
}

extension UIView {
    /// Массив `UIView` относящихся к текущей `UIView`
    var allSubviews: [UIView] {
        subviews.flatMap { [$0] + $0.subviews }
    }

    /// Поиск текстового вью в массиве всех имеющихся `View`
    var findTextView: UITextView? {
        if let textView = allSubviews.first(where: { $0 is UITextView }) as? UITextView {
            return textView
        }

        return nil
    }

    /// Массив `UIView` относящихся к текущей `UIView` и ее subviews
    var allSubviewsFlat: [UIView] {
        var result = subviews.reduce([UIView](), { $0 + $1.allSubviewsFlat })
        result.append(contentsOf: subviews)
        return result
    }
}

extension UIView {
    /// Удаление constraints у текущей `UIView`
    public func removeAllConstraints() {
        var currentSuperview = self.superview
        while let superview = currentSuperview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            currentSuperview = superview.superview
        }
        self.removeConstraints(self.constraints)
    }

    /// Поиск subview определенного типа
    func findSubview<T: UIResponder>(ofType type: T.Type, in view: UIView) -> T? {
        for subview in view.subviews {
            // Проверяем все сабвью, если вью в них возращаем ее
            if let desiredSubview = subview as? T {
                return desiredSubview
                // Если не нашлось, то рекурсивно ищем в сабвью
            } else if let nestedSubview: T = findSubview(ofType: type, in: subview) {
                return nestedSubview
            }
        }
        // Возращаем nil если ничего не нашли
        return nil
    }

    /// Поиск superview определенного типа
    /// - Parameter ofType: Тип superview, который мы ищем
    /// - Returns: Возвращает superview определенного типа или nil
    func findSuperview<ViewType: UIResponder>(ofType: ViewType.Type) -> ViewType? {
        var currentView: UIView? = self

        while !currentView.isNil {
            if currentView is ViewType {
                break
            } else {
                currentView = currentView?.superview
            }
        }

        return currentView as? ViewType
    }
}

extension UIView {
    /// Добавлено для простецких анимаций, чтобы не рисовать скобочки closure :)
    static func animate(_ animations: @escaping @autoclosure () -> Void, withDuration: TimeInterval = 0.3, completion: ((Bool) -> Void)? = nil) {
        animate(withDuration: withDuration, animations: animations, completion: completion)
    }

    /// Добавить CATransition анимацию
    /// - Parameters:
    ///   - type: Тип анимации (Fade, Push)
    ///   - subtype: Направление анимации
    ///   - timingFunction: Темп анимации
    ///   - duration: Длительность  анимации
    func addTransition(type: CATransitionType,
                       subtype: CATransitionSubtype? = nil,
                       timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .easeInEaseOut),
                       duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.type = type
        transition.subtype = subtype
        transition.duration = duration
        transition.timingFunction = timingFunction
        layer.add(transition, forKey: nil)
    }
}

extension UIView {
    /// Поиск ближайшего родительского `UIScrollView` в иерархии вью.
    /// - Returns: Первый найденный экземпляр `UIScrollView` среди суперью, если такой имеется.
    func enclosingScrollView() -> UIScrollView? {
        var next: UIView? = self

        repeat {
            next = next?.superview
            if let scrollview = next as? UIScrollView {
                return scrollview
            }
        } while next != nil

        return nil
    }
}
