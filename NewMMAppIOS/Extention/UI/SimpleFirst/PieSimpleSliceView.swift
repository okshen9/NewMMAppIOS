//
//  PieSimpleSliceView.swift
//  TestUISwift
//
//  Created by artem on 21.04.2025.
//

import SwiftUI

struct PieSliceShape: Shape, Animatable {
    var startAngle: Angle
    var endAngle: Angle
    var cornerRadius: CGFloat

    // Tell SwiftUI how to interpolate between old и new значениями
    var animatableData: AnimatablePair<Double, Double> {
        get { .init(startAngle.radians, endAngle.radians) }
        set {
            startAngle = .radians(newValue.first)
            endAngle   = .radians(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2 - (cornerRadius / 2)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

struct PieSimpleSliceView: View {
    var model: SimpleSliceModel

    var body: some View {
        PieSliceShape(
            startAngle: model.startAngle,
            endAngle: model.endAngle,
            cornerRadius: model.cornerRadius
        )
        .fill(model.color)
        .overlay(
          PieSliceShape(
            startAngle: model.startAngle,
            endAngle: model.endAngle,
            cornerRadius: model.cornerRadius
          )
          .stroke(
            model.color,
            style: .init(lineWidth: model.cornerRadius, lineCap: .round, lineJoin: .round)
          )
        )
        .animation(.easeInOut(duration: 2), value: model)
    }
}

struct SimpleSliceModel: Animatable, Equatable {
    let id = UUID()
    var color: Color
    var startAngle: Angle
    var endAngle: Angle
    var cornerRadius: CGFloat = 50

    // Для анимации углов
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.radians, endAngle.radians) }
        set {
            startAngle = .radians(newValue.first)
            endAngle = .radians(newValue.second)
        }
    }
}

