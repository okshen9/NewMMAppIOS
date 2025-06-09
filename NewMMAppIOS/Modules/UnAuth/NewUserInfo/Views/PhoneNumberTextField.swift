//
//  PhoneNumberTextField.swift
//  MMApp
//
//  Created by artem on 24.03.2025.
//

import SwiftUI

struct PhoneNumberTextField: View {
    @Binding var phoneNumber: String
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Номер телефона")
                .font(MMFonts.title)
                .foregroundColor(Color.headerText)
            TextField("+X XXX XXX-XX-XX", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .foregroundColor(Color.headerText)
                .onChange(of: phoneNumber) { newValue in
                    phoneNumber = formatPhoneNumber(newValue)
                }
                .onAppear {
                    if !phoneNumber.isEmpty {
                        phoneNumber = formatPhoneNumber(phoneNumber)
                    }
                }
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(MMFonts.caption)
            }
        }
    }
    
    // Форматирование номера телефона из любого формата
    private func formatPhoneNumber(_ input: String) -> String {
        // Извлекаем только цифры из входной строки
        let digits = input.filter { $0.isNumber }
        
        // Если номер пустой, возвращаем пустую строку
        guard !digits.isEmpty else { return "" }
        
        var formattedNumber = "+"
        
        // Применяем форматирование в зависимости от количества цифр
        switch digits.count {
        case 1:
            // Только код страны
            formattedNumber += digits
        case 2...3:
            // Код страны
            formattedNumber += digits
        case 4...6:
            // Код страны и начало номера
            formattedNumber += digits.prefix(1) + " " + digits.dropFirst()
        case 7...10:
            // Типичный формат для многих стран
            let country = digits.prefix(1)
            let areaCode = digits.dropFirst().prefix(3)
            let firstPart = digits.dropFirst(4).prefix(3)
            let remainder = digits.dropFirst(7)
            
            formattedNumber += "\(country) \(areaCode) \(firstPart)"
            if !remainder.isEmpty {
                formattedNumber += "-\(remainder)"
            }
        case 11...:
            // Предполагаем российский номер +7 XXX XXX-XX-XX
            if digits.hasPrefix("7") || digits.hasPrefix("8") {
                let country = "7" // Всегда используем 7 для России
                let areaCode = digits.dropFirst().prefix(3)
                let firstPart = digits.dropFirst(4).prefix(3)
                let secondPart = digits.dropFirst(7).prefix(2)
                let thirdPart = digits.dropFirst(9).prefix(2)
                
                formattedNumber += "\(country) \(areaCode) \(firstPart)-\(secondPart)"
                if !thirdPart.isEmpty {
                    formattedNumber += "-\(thirdPart)"
                }
            } else {
                // Для других стран просто группируем цифры
                let country = digits.prefix(2)
                let remainder = digits.dropFirst(2)
                
                formattedNumber += "\(country) "
                
                var remainderStr = String(remainder)
                if remainderStr.count > 3 {
                    formattedNumber += remainderStr.prefix(3) + " "
                    remainderStr = String(remainderStr.dropFirst(3))
                    
                    if remainderStr.count > 4 {
                        formattedNumber += remainderStr.prefix(4) + "-"
                        remainderStr = String(remainderStr.dropFirst(4))
                    }
                    
                    formattedNumber += remainderStr
                } else {
                    formattedNumber += remainderStr
                }
            }
        default:
            formattedNumber += digits
        }
        
        return formattedNumber
    }
}

