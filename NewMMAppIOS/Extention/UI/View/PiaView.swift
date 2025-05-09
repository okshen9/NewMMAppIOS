import SwiftUI

struct CategoryPieChartView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    @State private var selectedSlice: UUID?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Круговая диаграмма
            ZStack {
                ForEach(tasks) { task in
                    let startAngle = getStartAngle(for: task)
                    let endAngle = getEndAngle(for: task)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 100, y: 100))
                        path.addArc(
                            center: CGPoint(x: 100, y: 100),
                            radius: 80,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(task.color)
                    .scaleEffect(selectedSlice == task.id ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedSlice)
                    .onTapGesture {
                        withAnimation {
                            selectedSlice = selectedSlice == task.id ? nil : task.id
                            selectedCategory = TargetCategory(rawValue: task.name)
                        }
                    }
                }
                
                // Центральный текст
                VStack {
                    if let selected = tasks.first(where: { $0.id == selectedSlice }) {
                        Text(selected.name)
                            .font(MMFonts.body)
                        Text("\(Int(selected.progress * 100))%")
                            .font(MMFonts.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Всего целей")
                            .font(MMFonts.body)
                        Text("\(tasks.count)")
                            .font(MMFonts.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(radius: 5)
            }
            .frame(height: 200)
            
            // Легенда
            VStack(spacing: 12) {
                ForEach(tasks) { task in
                    HStack {
                        Circle()
                            .fill(task.color)
                            .frame(width: 12, height: 12)
                        
                        Text(task.name)
                            .font(MMFonts.caption)
                        
                        Spacer()
                        
                        Text("\(Int(task.progress * 100))%")
                            .font(MMFonts.caption)
                            .foregroundColor(task.color)
                    }
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedSlice = selectedSlice == task.id ? nil : task.id
                            selectedCategory = TargetCategory(rawValue: task.name)
                        }
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func getStartAngle(for task: TaskProgress) -> Double {
        let total = tasks.reduce(0.0) { $0 + $1.value }
        let startPercentage = tasks.prefix(while: { $0.id != task.id })
            .reduce(0.0) { $0 + $1.value }
        return startPercentage / total * 360
    }
    
    private func getEndAngle(for task: TaskProgress) -> Double {
        let total = tasks.reduce(0.0) { $0 + $1.value }
        let endPercentage = tasks.prefix(while: { $0.id != task.id })
            .reduce(0.0) { $0 + $1.value } + task.value
        return endPercentage / total * 360
    }
}

#Preview {
    CategoryPieChartView(
        tasks: [
            TaskProgress(progress: 0.75, color: .blue, name: "Бизнес", value: 0.25),
            TaskProgress(progress: 0.5, color: .green, name: "Личное", value: 0.25),
            TaskProgress(progress: 0.9, color: .orange, name: "Семья", value: 0.25),
            TaskProgress(progress: 0.9, color: .yellow, name: "Здоровье", value: 0.25)
        ],
        selectedCategory: .constant(nil)
    )
} 
