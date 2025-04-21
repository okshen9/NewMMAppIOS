import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var tasks: [TaskProgress] = []
    
    func loadData() {
        // TODO: Загрузка данных из сервиса
        // Временные тестовые данные
        tasks = [
            TaskProgress(progress: 0.7, color: .blue, name: "Личное", value: 1.0),
            TaskProgress(progress: 0.3, color: .green, name: "Здоровье", value: 1.0),
            TaskProgress(progress: 0.5, color: .mainRed, name: "Семья", value: 1.0),
            TaskProgress(progress: 0.8, color: .yellow, name: "Бизнес", value: 1.0)
        ]
    }
} 
