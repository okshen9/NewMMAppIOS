//
//  ConfirmationDialog.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct ConfirmationDialog: View {
    var message: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button("Да", action: onConfirm)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .contentShape(Rectangle())
            Button("Нет", action: onCancel)
                .padding()
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .background(Color.mainRed)
                .foregroundColor(.white)
                .cornerRadius(16)
                
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    ConfirmationDialog(message: "Test", onConfirm: {print("sdsd")}, onCancel: {print("ssdfsdf")})
}
