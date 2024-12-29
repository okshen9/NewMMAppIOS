//
//  RegisteredOrLockedField.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import UIKit
import Combine

final class RegisteredOrLockedField: UIView, SubscriptionStore {
    enum TextInputField {
        case lock
        case edit
        case error
    }
    
    
    enum TypeField {
        /// Имя
        case firstName
        /// Фамилия
        case secondName
        /// Город
        case city
        /// вид деятельности
        case activityType
    }
    
    
    
    
}

