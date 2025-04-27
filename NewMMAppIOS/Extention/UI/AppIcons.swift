import SwiftUI

/// Централизованное хранилище иконок приложения с учетом разных статусов
enum AppIcons {
    // MARK: - Иконки для целей (targets)
    enum Target {
        /// Получить иконку для цели в зависимости от статуса
        static func icon(for status: TargetStatus?) -> Image {
            guard let status = status else { return defaultIcon }
            
            switch status {
            case .inProgress:
                return inProgress
            case .done, .doneExpired:
                return completed
            case .expired:
                return expired
            default:
                return defaultIcon
            }
        }
        
        /// Получить системное имя иконки для цели в зависимости от статуса
        static func systemName(for status: TargetStatus?) -> String {
            guard let status = status else { return "star" }
            
            switch status {
            case .inProgress:
                return "star"
            case .done, .doneExpired:
                return "star.fill"
            case .expired:
                return "exclamationmark.circle"
            default:
                return "star"
            }
        }
        
        /// Получить цвет для иконки цели в зависимости от статуса
        static func color(for status: TargetStatus?) -> Color {
            guard let status = status else { return .green }
            
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
        static let defaultIcon = Image(systemName: "star")
        static let inProgress = Image(systemName: "star")
        static let completed = Image(systemName: "star.fill")
        static let expired = Image(systemName: "exclamationmark.circle")
    }
    
    // MARK: - Иконки для подцелей (subtargets)
    enum SubTarget {
        /// Получить иконку для подцели в зависимости от статуса
        static func icon(for status: TargetSubStatus?) -> Image {
            guard let status = status else { return defaultIcon }
            
            switch status {
            case .notDone:
                return notDone
            case .done:
                return done
            default:
                return defaultIcon
            }
        }
        
        /// Получить системное имя иконки для подцели в зависимости от статуса
        static func systemName(for status: TargetSubStatus?) -> String {
            guard let status = status else { return "circle" }
            
            switch status {
            case .notDone:
                return "circle"
            case .done:
                return "checkmark.circle.fill"
            default:
                return "circle"
            }
        }
        
        /// Получить цвет для иконки подцели в зависимости от статуса
        static func color(for status: TargetSubStatus?) -> Color {
            guard let status = status else { return .gray }
            
            switch status {
            case .notDone:
                return .gray
            case .done:
                return .green
            default:
                return .gray
            }
        }
        
        // Базовые иконки
        static let defaultIcon = Image(systemName: "circle")
        static let notDone = Image(systemName: "circle")
        static let done = Image(systemName: "checkmark.circle.fill")
    }
    
    // MARK: - Иконки для платежей (payments)
    enum Payment {
        /// Получить иконку для платежа в зависимости от статуса
        static func icon(for status: PaymentRequestStatus?) -> Image {
            guard let status = status else { return defaultIcon }
            
            switch status {
            case .wait:
                return waiting
            case .fullPaid:
                return completed
            case .canceled:
                return canceled
            case .overdue:
                return overdue
            default:
                return defaultIcon
            }
        }
        
        /// Получить системное имя иконки для платежа в зависимости от статуса
        static func systemName(for status: PaymentRequestStatus?) -> String {
            guard let status = status else { return "creditcard.fill" }
            
            switch status {
            case .wait:
                return "creditcard.fill"
            case .fullPaid:
                return "creditcard.fill"
            case .canceled:
                return "creditcard.circle.fill"
            case .overdue:
                return "exclamationmark.creditcard.fill"
            default:
                return "creditcard.fill"
            }
        }
        
        /// Получить цвет для иконки платежа в зависимости от статуса
        static func color(for status: PaymentRequestStatus?) -> Color {
            guard let status = status else { return .mainRed }
            
            switch status {
            case .wait:
                return .mainRed
            case .fullPaid:
                return .green
            case .canceled:
                return .secondary
            case .overdue:
                return .orange
            default:
                return .mainRed
            }
        }
        
        // Базовые иконки
        static let defaultIcon = Image(systemName: "creditcard.fill")
        static let waiting = Image(systemName: "creditcard.fill")
        static let completed = Image(systemName: "creditcard.fill")
        static let canceled = Image(systemName: "creditcard.circle.fill")
        static let overdue = Image(systemName: "exclamationmark.creditcard.fill")
    }
    
    // MARK: - Комбинированные иконки
    static let combined = Image(systemName: "calendar.badge.exclamationmark")
    
    // MARK: - Вспомогательные иконки
    static let calendar = Image(systemName: "calendar")
    static let add = Image(systemName: "plus")
    static let expand = Image(systemName: "chevron.down.circle.fill")
    static let collapse = Image(systemName: "chevron.up.circle.fill")
}
