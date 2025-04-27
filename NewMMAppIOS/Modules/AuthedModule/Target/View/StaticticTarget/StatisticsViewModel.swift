import Foundation
import Combine
import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var tasks: [TaskProgress] = []
    @Published var pieModels: [PieModel] = []
    
    func loadData() {
        // TODO: Загрузка данных из сервиса
        // Временные тестовые данные
        tasks = [
            TaskProgress(progress: 0.7, color: .blue, name: "Личное", value: 1.0),
            TaskProgress(progress: 0.3, color: .green, name: "Здоровье", value: 1.0),
            TaskProgress(progress: 0.5, color: .mainRed, name: "Семья", value: 1.0),
            TaskProgress(progress: 0.8, color: .yellow, name: "Бизнес", value: 1.0)
        ]
        
        // Конвертируем данные для новой диаграммы
        convertToPieModels()
    }
    
    /// Конвертирует данные из TaskProgress в PieModel для использования в NewPieDiagram
    private func convertToPieModels() {
        pieModels = tasks.map { task in
            PieModel(
                totalValue: task.value, 
                currentValue: task.progress,
                color: task.color,
                title: task.name
            )
        }
    }
} 
