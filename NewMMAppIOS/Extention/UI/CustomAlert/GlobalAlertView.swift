import SwiftUI

// Глобальный алерт, который будет отображаться поверх всего экрана
struct GlobalAlertView: View {
    @EnvironmentObject var alertManager: GlobalAlertManager
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        alertManager.dismiss()
                        alertManager.onCancel?()
                    }
                }
            
            // Сам алерт
            VStack(spacing: 16) {
                // Заголовок
                Text(alertManager.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Сообщение (если есть)
                if let message = alertManager.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Кастомный контент (Toggle и т.д.)
                if let content = alertManager.content {
                    content
                        .padding(.vertical, 8)
                }
                
                // Кнопки
                HStack(spacing: 16) {
                    Button("Отмена") {
                        withAnimation {
                            alertManager.dismiss()
                            alertManager.onCancel?()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.secondary)
                    
                    Button("Подтвердить") {
                        withAnimation {
                            alertManager.dismiss()
                            alertManager.onConfirm?()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 4)
            )
            .padding(40)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.2), value: alertManager.isPresented)
    }
} 