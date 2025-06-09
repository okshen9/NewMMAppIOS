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

