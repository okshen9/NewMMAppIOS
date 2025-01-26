//
//  CustomActivityIndicator.swift
//  MMApp
//
//  Created by artem on 26.01.2025.
//

import UIKit

class CustomActivityIndicator: UIView {
    private static let animationKey = "rotationAnimation"

    // MARK: - Public Properties

    var isAnimating = false {
        didSet {
            if isAnimating { startAnimating() } else { stopAnimating() }
        }
    }

    private var animatingState = false

    // MARK: - Private Properties

    private let imageView = UIImageView().apply { $0.backgroundColor = .clear }

    // MARK: - Initialization

    /// Инициализация CustomActivityIndicator-а
    /// - Parameter image: Картинка для вращения
    init(image: UIImage, initiallyHidden: Bool = true) {
        super.init(frame: .zero)
        imageView.image = image
        isHidden = initiallyHidden
        configureLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Private Methods

    /// Анимация вращения вокруг своей оси
    private func rotate() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Float.pi * 2
        animation.duration = 1
        animation.isCumulative = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        imageView.layer.add(animation, forKey: Self.animationKey)
    }

    private func configureLayout() {
        addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - Public Methods

    /// Запускает анимацию снова и показывает view
    func startAnimating() {
        if animatingState { return }
        animatingState = true
        isHidden = false
        rotate()
    }

    /// Приостанавливает анимацию в текущем состоянии и прячет view
    func pauseAnimating(hiddenWhenPaused: Bool = true) {
        guard animatingState else { return }
        animatingState = false
        isHidden = hiddenWhenPaused
        imageView.layer.pauseAnimation()
    }

    /// Возобновляет анимацию в текущем состоянии и показывает view
    func resumeAnimating() {
        if animatingState { return }
        animatingState = true
        isHidden = false
        imageView.layer.resumeAnimation()
    }

    /// Останавливает анимацию полностью и прячет view и удаляет из layer tree.
    func stopAnimating() {
        guard animatingState else { return }
        animatingState = false
        isHidden = true
        imageView.layer.removeAllAnimations()
    }
}

// MARK: - CALayer

private extension CALayer {
    /// Останавливает анимацию
    func pauseAnimation() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    /// Возобновиновляет анимацию
    func resumeAnimation() {
        let pausedTime = timeOffset
        speed = 1
        timeOffset = 0
        beginTime = 0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
