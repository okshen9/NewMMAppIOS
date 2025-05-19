//
//  File.swift
//  NewMMAppIOS
//
//  Created by artem on 07.05.2025.
//

import SwiftUI

struct StatusTargetIndicatorView: View {
	private let targetIndicatorSize: CGFloat = 28
	var categoryColor: Color
	let percentage: Double
	let status: TargetStatus
	
	init(category: TargetCategory, percentage: Double, status: TargetStatus, enable: Bool = true) {
		self.categoryColor = enable ? category.color : Color.secondary
		
		self.status = status
		switch status {
		case .done, .doneExpired:
			self.percentage = 100
		case .inProgress, .expired, .draft:
			self.percentage = percentage
		default:
			self.percentage = 0
		}
		
	}
	
	init(_ target: UserTargetDtoModel) {
		let category = target.category ?? .unknown
		let percentage = target.percentage ?? 0
		let status = target.targetStatus ?? .unknown
		self.init(category: category, percentage: percentage, status: status)
	}
	
	var body: some View {
		ZStack {
			Circle()
				.fill(categoryColor.opacity(0.15))
				.frame(width: targetIndicatorSize, height: targetIndicatorSize)
			
			// Прогресс-кольцо с градиентом
			Circle()
				.trim(from: 0, to: CGFloat((percentage) / 100))
				.stroke(
					LinearGradient(
						gradient: Gradient(colors: [
							categoryColor,
							categoryColor.opacity(0.7)
						]),
						startPoint: .topLeading,
						endPoint: .bottomTrailing
					),
					style: StrokeStyle(lineWidth: 3, lineCap: .round)
				)
				.frame(width: targetIndicatorSize - 4, height: targetIndicatorSize - 4)
				.rotationEffect(.degrees(-90))
			
			// Иконка цели
			AppIcons.Target.baseIcon(for: status)
				.font(MMFonts.caption)
				.foregroundColor(categoryColor)
		}
	}
}


#Preview {
	StatusTargetIndicatorView(category: .family, percentage: 100, status: .cancelled, enable: false)
}
