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
    var cornerRadius: CGFloat = 20

    // Для анимации углов
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.radians, endAngle.radians) }
        set {
            startAngle = .radians(newValue.first)
            endAngle = .radians(newValue.second)
        }
    }
}

#Preview() {
    @Previewable @State var angle: SimpleSliceModel = .init(
        color: .red.lighten(0.5),
        startAngle: .radians(0),
        endAngle: .radians(2 * .pi / 360 * 45),
        cornerRadius: 20
    )

    PieSimpleSliceView(model: angle)

    Button("Увеличить угол") {
        withAnimation(.linear(duration: 1)) {
            angle = SimpleSliceModel(
                color: .red,
                startAngle: .radians(0),
                endAngle: .radians(2 * .pi / 360 * 180),
                cornerRadius: 20
            )
        }
    }

    Button("Уменьшить угол") {
        withAnimation(.smooth(duration: 1)) {
            angle = SimpleSliceModel(
                color: .red,
                startAngle: .radians(0),
                endAngle: .radians(2 * .pi / 360 * 30),
                cornerRadius: 20
            )
        }
    }

    Button("Случайный цвет") {
        withAnimation(.spring(duration: 1)) {
            angle = SimpleSliceModel(
                color: [Color.red, .blue, .green, .orange].randomElement()!.lighten(0.5),
                startAngle: .radians(0),
                endAngle: .radians(2 * .pi / 360 * 180),
                cornerRadius: 20
            )
        }
    }
}


extension Color {
    func lighten(_ fraction: CGFloat = 0.7) -> Color {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Смешиваем с белым
        let newRed = min(red + (1 - red) * fraction, 1.0)
        let newGreen = min(green + (1 - green) * fraction, 1.0)
        let newBlue = min(blue + (1 - blue) * fraction, 1.0)

        return Color(red: Double(newRed), green: Double(newGreen), blue: Double(newBlue))
    }
}
