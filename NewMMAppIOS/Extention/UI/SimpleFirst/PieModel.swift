//
//  PieModel.swift
//  TestUISwift
//
//  Created by artem on 21.04.2025.
//


import SwiftUI

struct PieModel: Identifiable, Equatable {
    typealias ID = String
    var id: Self.ID { get {
        self.title
    }}
    
    /// процент от общего значения Category
    var totalValue: Double
    /// текущее заполенение конкретной Category (0.0...1.0)
    var currentValue: Double
    /// дочерние модели
    var subModel: [PieModel]?
    /// цвет для модели
    var color: Color
    /// название модели
    var title: String
    
    /// Инициализатор с обязательными параметрами
    init(totalValue: Double, currentValue: Double, color: Color, title: String) {
        self.totalValue = totalValue
        self.currentValue = min(max(currentValue, 0.0), 1.0) // Ограничиваем значение между 0 и 1
        self.subModel = nil
        self.color = color
        self.title = title
    }
    
    /// Инициализатор со всеми параметрами
    init(totalValue: Double, currentValue: Double, subModel: [PieModel]? = nil, color: Color, title: String) {
        self.totalValue = totalValue
        self.currentValue = min(max(currentValue, 0.0), 1.0) // Ограничиваем значение между 0 и 1
        self.subModel = subModel
        self.color = color
        self.title = title
    }
}
