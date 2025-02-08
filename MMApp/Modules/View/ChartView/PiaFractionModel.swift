//
//  PiaFractionModel.swift
//  MMApp
//
//  Created by artem on 07.02.2025.
//

import Foundation
import SwiftUI

struct PiaViewFractionModel: Equatable {
    let color: Color
    let allStats: Double?
    let currnetValue: Double
    let name: String?
    
    init(color: Color, allStats: Double?, currnetValue: Double, name: String?) {
        self.color = color
        self.allStats = allStats
        self.currnetValue = currnetValue
        self.name = name
    }
}
