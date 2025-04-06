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
                .font(.headline)
            TextField("+7 (XXX) XXX-XX-XX", text: $phoneNumber)

                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .onChange(of: phoneNumber) { newValue in
                    phoneNumber = formatPhoneNumber(newValue)
                }
                .onAppear {
                    if !phoneNumber.isEmpty {
                        phoneNumber = formatPhoneNumber("7" + phoneNumber)
                    }

                }
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    // Форматирование номера по маске
    private func formatPhoneNumber(_ input: String) -> String {
        let cleanedInput = input.filter { $0.isNumber }
        guard !cleanedInput.isEmpty else { return "" }

        var result = ""
        let maxDigits = 11 // Максимум цифр: код страны + 10 цифр

        for (index, digit) in cleanedInput.prefix(maxDigits).enumerated() {
            switch index {
            case 0:
                result += "+\(digit)"
            case 1:
                result += " (\(digit)"
            case 4:
                result += ") \(digit)"
            case 7, 9:
                result += "-\(digit)"
            default:
                result += "\(digit)"
            }
        }

        // Удаление лишних символов при удалении цифр
        if cleanedInput.count < input.filter({ $0.isNumber }).count {
            return String(result.prefix(result.count))
        }

        return result
    }
}

#Preview {
    PhoneNumberTextField(phoneNumber: .constant(""), error: "error")
}


extension String : BidirectionalCollection {

    public func saveIndex(_ i: String.Index, offsetBy distance: Int) -> String.Index {
        guard let index = self.index(i, offsetBy: distance, limitedBy: self.endIndex) else {
            return self.endIndex
        }
        return index
    }
}
