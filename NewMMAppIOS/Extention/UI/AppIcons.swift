import SwiftUI

/// Централизованное хранилище иконок приложения с учетом разных статусов
enum AppIcons {
	enum General {
		// MARK: - Комбинированные иконки
		static let combined = Image(systemName: "calendar.badge.plus")
        
        static let cardCombined = Image("creditcard.combined")
        static let targetCombined = Image("star.combined")
        
		
		// MARK: - Вспомогательные иконки
		static let calendar = Image(systemName: "calendar")
		static let add = Image(systemName: "plus")
		static let expand = Image(systemName: "chevron.down.circle.fill")
		static let collapse = Image(systemName: "chevron.up.circle.fill")
		static let arrowTurnDownRight = Image(systemName: "arrow.turn.down.right")
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
				return .mainRed
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

// MARK: - Иконки для целей (target)
extension AppIcons {
    enum Target {
//        static func coloredWithBackGraundIcon(
//            category: TargetCategory,
//            target: UserTargetDtoModel
//        ) -> some View {
//            StatusTargetIndicatorView(category: category,
//                                      percentage: target.percentage ?? 0,
//                                      status: status)
//        }
        
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
                return Image(NameIcon.inProgress)
            case .done:
                return Image(NameIcon.done)
            case .doneExpired:
                return Image(NameIcon.doneExpired)
            case .expired:
                return Image(NameIcon.expired)
            case .draft:
                return Image(systemName: NameIcon.draft)
            case .cancelled, .failed:
                return Image(NameIcon.failed)
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
            case .expired, .failed:
                return .mainRed
            case .unknown, .cancelled:
                return .secondary
            case .draft:
                return .orange
            }
        }
        
        // Базовые иконки
        private enum NameIcon {
            static let inProgress = "mm.target"
            static let done = "mm.target.done"
            static let doneExpired = "mm.target.half"
            static let expired = "mm.target.clock"
            static let draft = "hand.raised.fill"
            static let failed = "mm.target.slash"
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
            backColor: Color
		) -> some View {
            return baseIcon(for: status, backColor: backColor)
                .offset(x: 0, y: 2)
		}
        
//            .resizable()
//            .renderingMode(.template)
		
        private static func baseIcon(for status: TargetSubStatus, backColor: Color) -> some View {
			switch status {
			case .inProgress, .notDone:
//				return Image(NameIcon.inProgress)
                return SubTargetInProgressView(backColor: backColor, fiilColor: color(for: status))
                    .eraseToAnyView()
			case .done:
                return SubTargetDoneView(backColor: backColor, fiilColor: color(for: status))
                    .eraseToAnyView()
                
			case .expiredDone:
				return Image(NameIcon.doneExpired)
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .foregroundStyle(Color.mainRed, .green)
                    .eraseToAnyView()
			case .expired:
				return Image(NameIcon.expired)
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .foregroundStyle(Color.mainRed, .gray)
                    .eraseToAnyView()
			case .failed:
				return Image(NameIcon.failed)
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .foregroundStyle(Color.mainRed, .gray)
                    .eraseToAnyView()
			case .unknown:
				return Image(systemName: NameIcon.unknown)
                    .resizable()
                    .foregroundStyle(.orange)
                    .eraseToAnyView()
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
			static let done = "mm.subtarget.done"
			static let doneExpired = "mm.subarget.done.clock"
			static let expired = "mm.subtarget.clock"
			static let failed = "mm.subtarget.xmark"
			static let unknown = "questionmark.diamond.fill"
		}
	}
}

#Preview {
	HStack(alignment: .top) {
		VStack(alignment: .leading, spacing: 8) {
			Text("Payment")
			ForEach(Array(PaymentRequestStatus.allCases.enumerated()), id: \.1) { index, status  in
				HStack {
					AppIcons.Payment.coloredIcon(for: status)
					Text(status.rawValue)
						.font(MMFonts.caption)
				}
			}
		}
		VStack(alignment: .leading, spacing: 8) {
			Text("Target")
			ForEach(Array(TargetStatus.allCases.enumerated()), id: \.1) { index, status  in
				HStack {
					AppIcons.Target.coloredIcon(for: status)
					Text(status.title)
						.font(MMFonts.caption)
				}
			}
		}
		VStack(alignment: .leading, spacing: 8) {
			Text("SubTarget")
            ForEach(Array(TargetSubStatus.allCases.enumerated()), id: \.1) { index, status  in
                HStack {
                    AppIcons.SubTarget.coloredIcon(
                        for: status,
                        backColor: .white)
                    .frameRect(22)
                    Text(status.title)
                        .font(MMFonts.caption)
                }
            }
//            HStack {
//                AppIcons.SubTarget.coloredIcon(for: .done, backColor: .white)
//                    .frameRect(22)
////                    .bred()
//                Text(TargetSubStatus.done.title)
//                    .font(MMFonts.caption)
//            }
//            SubTargetInProgressView(backColor: .white, fiilColor: .green)
//                .frameRect(22)
//            SubTargetDoneView(backColor: .white, fiilColor: .green)
//                .frameRect(22)
            Image("mm.subarget.done.clock")
            AppIcons.General.combined
            AppIcons.General.cardCombined
            AppIcons.General.targetCombined
//                .bred()
		}
	}
}

// Костыли
fileprivate struct SubTargetInProgressView: View {
    @State var backColor: Color
    @State var fiilColor: Color
    var body: some View {
        GeometryReader { geometry in
            let gwidth = geometry.size.width
            let gheight = geometry.size.height
            
            Image(systemName: "circle")
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: gwidth * 0.8,
                       height: gheight * 0.8)
                .overlay(alignment: .bottomTrailing, content: {
                    ZStack {
                        Image(systemName: "star.circle.fill")
                            .resizable()
                            .foregroundStyle(fiilColor)
                            .frame(width: gwidth * 0.45, height: gheight * 0.45)
                            .background(backColor)
                            .cornerRadius(gwidth * 0.5)
                        
                        Image(systemName: "circle")
                            .resizable()
                            .foregroundStyle(backColor)
                            .frame(width: gwidth * 0.5, height: gheight * 0.5)
                    }
                    .offset(x: gwidth * 0.2, y: gwidth * 0.2)
                })
        }
        .frame(idealWidth: 20, idealHeight: 20)
    }
}

fileprivate struct SubTargetDoneView: View {
    @State var backColor: Color
    @State var fiilColor: Color
    var body: some View {
        GeometryReader { geometry in
            let gwidth = geometry.size.width
            let gheight = geometry.size.height
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundStyle(fiilColor)
                .frame(width: gwidth * 0.8,
                       height: gheight * 0.8)
                .overlay(alignment: .bottomTrailing, content: {
                    ZStack {
                        Image(systemName: "star.circle.fill")
                            .resizable()
                            .foregroundStyle(fiilColor)
                            .frame(width: gwidth * 0.45, height: gheight * 0.45)
                            .background(backColor)
                            .cornerRadius(gwidth * 0.5)
                        
                        Image(systemName: "circle")
                            .resizable()
                            .foregroundStyle(backColor)
                            .frame(width: gwidth * 0.5, height: gheight * 0.5)
                    }
                    .offset(x: gwidth * 0.2, y: gwidth * 0.2)
                })
        }
    }
}
