//
//  UpcomingEvent.swift
//  MMApp
//
//  Created by artem on 19.03.2025.
//

import Foundation

struct UpcomingEvent {
    let title: String
    let type: UpcomingEventType
    let date: Date
    
    enum UpcomingEventType: String {
        case target
        case subTarget
        case payment
        case any
    }
    
//    var
}
