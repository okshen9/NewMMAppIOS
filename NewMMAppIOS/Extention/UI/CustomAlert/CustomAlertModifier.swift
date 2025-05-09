import SwiftUI

/// Структура для создания кастомных модальных диалогов типа Alert
struct CustomAlert<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let alertContent: AlertContent
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    init(isPresented: Binding<Bool>, 
         title: String, 
         message: String? = nil,
         @ViewBuilder alertContent: () -> AlertContent,
         onConfirm: @escaping () -> Void,
         onCancel: @escaping () -> Void) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.alertContent = alertContent()
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
            
            if isPresented {
                // Затемненный фон
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                
                // Сам алерт
                VStack(spacing: 16) {
                    // Заголовок
                    Text(title)
                        .font(MMFonts.title)
                        .multilineTextAlignment(.center)
                    
                    // Сообщение (если есть)
                    if let message = message {
                        Text(message)
                            .font(MMFonts.subTitle)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Кастомный контент (Toggle и т.д.)
                    alertContent
                        .padding(.vertical, 8)
                    
                    // Кнопки
                    HStack(spacing: 16) {
                        Button("Отмена") {
                            withAnimation {
                                isPresented = false
                                onCancel()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.secondary)
                        
                        Button("Подтвердить") {
                            withAnimation {
                                isPresented = false
                                onConfirm()
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
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

// Удобное расширение для View
extension View {
    func customAlert<AlertContent: View>(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        @ViewBuilder alertContent: @escaping () -> AlertContent,
        onConfirm: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(
            CustomAlert(
                isPresented: isPresented,
                title: title,
                message: message,
                alertContent: alertContent,
                onConfirm: onConfirm,
                onCancel: onCancel
            )
        )
    }
} 