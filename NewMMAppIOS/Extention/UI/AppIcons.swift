import SwiftUI

/// Централизованное хранилище иконок приложения с учетом разных статусов
enum AppIcons {
	enum General {
		// MARK: - Комбинированные иконки
		static let combined = Image(systemName: "calendar.badge.exclamationmark")
		
		// MARK: - Вспомогательные иконки
		static let calendar = Image(systemName: "calendar")
		static let add = Image(systemName: "plus")
		static let expand = Image(systemName: "chevron.down.circle.fill")
		static let collapse = Image(systemName: "chevron.up.circle.fill")
	}
}
	
// MARK: - Иконки для платежей (payments)
extension AppIcons {
	enum Payment {
		/// Получить цветную иконку для платежа в зависимости от статуса
		/// - Parameters:
		///  - for: устатус платежа
		///  - resizeble: включен ли режим resizeble для иконки
		static func coloredIcon(
			for status: PaymentRequestStatus?,
			resizeble: Bool = false
		) -> some View {
			if resizeble {
				return baseIcon(for: status)
					.resizable()
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			} else {
				return baseIcon(for: status)
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			}
		}
		
		/// Получить цвет для иконки платежа в зависимости от статуса
		static func color(for status: PaymentRequestStatus?) -> Color {
			switch status {
			case .wait:
				return .orange
			case .fullPaid:
				return .green
			case .canceled:
				return .secondary
			case .overdue:
				return .mainRed
			default:
				return .mainRed
			}
		}
		
		static func baseIcon(for status: PaymentRequestStatus?) -> Image {
			switch status {
			case .wait:
				return NameIcon.waiting
			case .fullPaid:
				return NameIcon.completed
			case .canceled:
				return NameIcon.canceled
			case .overdue:
				return NameIcon.overdue
			default:
				return NameIcon.defaultIcon
			}
		}
		
		// Базовые иконки
		private enum NameIcon {
			static let defaultIcon = Image("mm.creditcard")
			static let waiting = Image("mm.creditcard")
			static let completed = Image("mm.creditcard.checkmark")
			static let canceled = Image("mm.creditcard.xmark")
			static let overdue = Image("mm.creditcard.clock")
		}
	}
}


extension AppIcons {
	enum Target {
		/// Получить цветную иконку для платежа в зависимости от статуса
		/// - Parameters:
		///  - for: устатус платежа
		///  - resizeble: включен ли режим resizeble для иконки
		static func coloredIcon(
			for status: TargetStatus,
			resizeble: Bool = false
		) -> some View {
			if resizeble {
				return baseIcon(for: status)
					.resizable()
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			} else {
				return baseIcon(for: status)
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			}
		}
		
		static func baseIcon(for status: TargetStatus) -> Image {
			switch status {
			case .inProgress:
				return Image(systemName: NameIcon.inProgress)
			case .done:
				return Image(systemName: NameIcon.done)
			case .doneExpired:
				return Image(systemName: NameIcon.doneExpired)
			case .expired:
				return Image(systemName: NameIcon.expired)
			case .draft:
				return Image(systemName: NameIcon.draft)
			case .cancelled, .failed:
				return Image(systemName: NameIcon.failed)
			case .unknown:
				return Image(systemName: NameIcon.unknown)
			}
		}
		
		/// Получить цвет для иконки цели в зависимости от статуса
		static func color(for status: TargetStatus) -> Color {
			switch status {
			case .inProgress:
				return .green
			case .done, .doneExpired:
				return .green
			case .expired:
				return .orange
			default:
				return .green
			}
		}
		
		// Базовые иконки
		private enum NameIcon {
			static let inProgress = "star"
			static let done = "star.fill"
			static let doneExpired = "star.leadinghalf.filled"
			static let expired = "calendar.badge.clock"
			static let draft = "hand.raised.fill"
			static let failed = "star.slash.fill"
			static let unknown = "questionmark.diamond.fill"
		}
	}
}

extension AppIcons {
	enum SubTarget {
		/// Получить цветную иконку для платежа в зависимости от статуса
		/// - Parameters:
		///  - for: устатус платежа
		///  - resizeble: включен ли режим resizeble для иконки
		static func coloredIcon(
			for status: TargetSubStatus,
			resizeble: Bool = false
		) -> some View {
			if resizeble {
				return baseIcon(for: status)
					.resizable()
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			} else {
				return baseIcon(for: status)
					.renderingMode(.template)
					.foregroundStyle(color(for: status))
			}
		}
		
		static func baseIcon(for status: TargetSubStatus) -> Image {
			switch status {
			case .inProgress, .notDone:
				return Image(systemName: NameIcon.inProgress)
			case .done:
				return Image(systemName: NameIcon.done)
			case .expiredDone:
				return Image(systemName: NameIcon.doneExpired)
			case .expired:
				return Image(systemName: NameIcon.expired)
			case .failed:
				return Image(systemName: NameIcon.failed)
			case .unknown:
				return Image(systemName: NameIcon.unknown)
			}
		}
		
		/// Получить цвет для иконки цели в зависимости от статуса
		static func color(for status: TargetSubStatus) -> Color {
			switch status {
			case .inProgress, .notDone:
				return .green
			case .done, .expiredDone:
				return .green
			case .expired, .failed, .unknown:
				return .mainRed
			default:
				return .green
			}
		}
		
		// Базовые иконки
		private enum NameIcon {
			static let inProgress = "mm.subtarget"
			static let done = "mm.subtarget.checkmark"
			static let doneExpired = "mm.subtarget.exclamationmark"
			static let expired = "mm.subtarget.clock"
			static let failed = "mm.subtarget.xmark"
			static let unknown = "questionmark.diamond.fill"
		}
	}
}


#Preview {
	VStack {
		AppIcons.Payment.coloredIcon(for: .fullPaid)
			.font(.system(size: 22))
		AppIcons.Target.coloredIcon(for: .done)
			
	}
}
