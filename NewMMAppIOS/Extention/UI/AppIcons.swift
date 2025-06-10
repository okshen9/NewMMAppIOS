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

// MARK: - Helper Views
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
        .frame(idealWidth: 20, idealHeight: 20)
    }
}

// MARK: - Previews
#Preview("General Icons") {
    VStack(spacing: 20) {
        Text("General Icons")
            .font(.title2)
            .bold()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            VStack {
                AppIcons.General.combined
                    .font(.title)
                Text("Combined")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.cardCombined
                    .font(.title)
                Text("Card Combined")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.targetCombined
                    .font(.title)
                Text("Target Combined")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.calendar
                    .font(.title)
                Text("Calendar")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.add
                    .font(.title)
                Text("Add")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.expand
                    .font(.title)
                Text("Expand")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.collapse
                    .font(.title)
                Text("Collapse")
                    .font(.caption)
            }
            
            VStack {
                AppIcons.General.arrowTurnDownRight
                    .font(.title)
                Text("Arrow Turn")
                    .font(.caption)
            }
        }
    }
    .padding()
}

#Preview("Payment Icons") {
    VStack(spacing: 20) {
        Text("Payment Icons")
            .font(.title2)
            .bold()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            VStack {
                AppIcons.Payment.coloredIcon(for: .wait)
                    .font(.title)
                Text("Wait")
                    .font(.caption)
                Text("(.wait)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Payment.coloredIcon(for: .fullPaid)
                    .font(.title)
                Text("Full Paid")
                    .font(.caption)
                Text("(.fullPaid)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Payment.coloredIcon(for: .canceled)
                    .font(.title)
                Text("Canceled")
                    .font(.caption)
                Text("(.canceled)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Payment.coloredIcon(for: .overdue)
                    .font(.title)
                Text("Overdue")
                    .font(.caption)
                Text("(.overdue)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Payment.coloredIcon(for: nil)
                    .font(.title)
                Text("Default")
                    .font(.caption)
                Text("(nil)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("Target Icons") {
    VStack(spacing: 20) {
        Text("Target Icons")
            .font(.title2)
            .bold()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            VStack {
                AppIcons.Target.coloredIcon(for: .inProgress)
                    .font(.title)
                Text("In Progress")
                    .font(.caption)
                Text("(.inProgress)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .done)
                    .font(.title)
                Text("Done")
                    .font(.caption)
                Text("(.done)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .doneExpired)
                    .font(.title)
                Text("Done Expired")
                    .font(.caption)
                Text("(.doneExpired)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .expired)
                    .font(.title)
                Text("Expired")
                    .font(.caption)
                Text("(.expired)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .draft)
                    .font(.title)
                Text("Draft")
                    .font(.caption)
                Text("(.draft)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .cancelled)
                    .font(.title)
                Text("Cancelled")
                    .font(.caption)
                Text("(.cancelled)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .failed)
                    .font(.title)
                Text("Failed")
                    .font(.caption)
                Text("(.failed)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.Target.coloredIcon(for: .unknown)
                    .font(.title)
                Text("Unknown")
                    .font(.caption)
                Text("(.unknown)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("SubTarget Icons") {
    VStack(spacing: 20) {
        Text("SubTarget Icons")
            .font(.title2)
            .bold()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .inProgress, backColor: .black)
                    .frame(width: 30, height: 30)
                Text("In Progress")
                    .font(.caption)
                Text("(.inProgress)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .notDone, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Not Done")
                    .font(.caption)
                Text("(.notDone)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .done, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Done")
                    .font(.caption)
                Text("(.done)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .expiredDone, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Expired Done")
                    .font(.caption)
                Text("(.expiredDone)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .expired, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Expired")
                    .font(.caption)
                Text("(.expired)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .failed, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Failed")
                    .font(.caption)
                Text("(.failed)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack {
                AppIcons.SubTarget.coloredIcon(for: .unknown, backColor: .blue)
                    .frame(width: 30, height: 30)
                Text("Unknown")
                    .font(.caption)
                Text("(.unknown)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("All Icons Overview") {
    ScrollView {
        VStack(spacing: 30) {
            Text("All App Icons Overview")
                .font(.title)
                .bold()
            
            // General Section
            VStack(spacing: 15) {
                Text("General Icons")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 20) {
                    VStack {
                        AppIcons.General.combined
                            .font(.title)
                        Text("Combined")
                            .font(.caption)
                    }
                    
                    VStack {
                        AppIcons.General.cardCombined
                            .font(.title)
                        Text("Card")
                            .font(.caption)
                    }
                    
                    VStack {
                        AppIcons.General.targetCombined
                            .font(.title)
                        Text("Target")
                            .font(.caption)
                    }
                }
            }
            
            // Payment Section
            VStack(spacing: 15) {
                Text("Payment States")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 15) {
                    VStack {
                        AppIcons.Payment.coloredIcon(for: .wait)
                            .font(.title)
                        Text("Wait")
                            .font(.caption)
                    }
                    
                    VStack {
                        AppIcons.Payment.coloredIcon(for: .fullPaid)
                            .font(.title)
                        Text("Paid")
                            .font(.caption)
                    }
                    
                    VStack {
                        AppIcons.Payment.coloredIcon(for: .canceled)
                            .font(.title)
                        Text("Canceled")
                            .font(.caption)
                    }
                    
                    VStack {
                        AppIcons.Payment.coloredIcon(for: .overdue)
                            .font(.title)
                        Text("Overdue")
                            .font(.caption)
                    }
                }
            }
            
            // Target Section
            VStack(spacing: 15) {
                Text("Target States")
                    .font(.title2)
                    .bold()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    VStack {
                        AppIcons.Target.coloredIcon(for: .inProgress)
                            .font(.title2)
                        Text("Progress")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.Target.coloredIcon(for: .done)
                            .font(.title2)
                        Text("Done")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.Target.coloredIcon(for: .expired)
                            .font(.title2)
                        Text("Expired")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.Target.coloredIcon(for: .draft)
                            .font(.title2)
                        Text("Draft")
                            .font(.caption2)
                    }
                }
            }
            
            // SubTarget Section
            VStack(spacing: 15) {
                Text("SubTarget States")
                    .font(.title2)
                    .bold()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    VStack {
                        AppIcons.SubTarget.coloredIcon(for: .inProgress, backColor: .blue)
                            .frame(width: 25, height: 25)
                        Text("Progress")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.SubTarget.coloredIcon(for: .done, backColor: .blue)
                            .frame(width: 25, height: 25)
                        Text("Done")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.SubTarget.coloredIcon(for: .expired, backColor: .blue)
                            .frame(width: 25, height: 25)
                        Text("Expired")
                            .font(.caption2)
                    }
                    
                    VStack {
                        AppIcons.SubTarget.coloredIcon(for: .failed, backColor: .blue)
                            .frame(width: 25, height: 25)
                        Text("Failed")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
    }
}

