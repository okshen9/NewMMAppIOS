import SwiftUI
import Combine

struct StatisticsView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Кольцевая диаграмма
                MultiProgressRingView(tasks: tasks, selectedCategory: $selectedCategory)
                    .padding()
            }
        }
    }
}

#Preview {
    @State var selectedCategory: TargetCategory? = nil
    StatisticsView(tasks: [
        TaskProgress(progress: 0.7, color: .blue, name: "Личное", value: 0.25),
        TaskProgress(progress: 0.3, color: .green, name: "Здоровье", value: 0.25),
        TaskProgress(progress: 0.5, color: .mainRed, name: "Семья", value: 0.25),
        TaskProgress(progress: 0.8, color: .yellow, name: "Бизнес", value: 0.25)
    ], selectedCategory: $selectedCategory)
}
