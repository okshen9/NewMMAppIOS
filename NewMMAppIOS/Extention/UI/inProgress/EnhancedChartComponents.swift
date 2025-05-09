import SwiftUI

// MARK: - Столбчатая диаграмма
struct BarChartView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    
    var body: some View {
        VStack(spacing: 8) {
            // Сетка и столбцы
            ZStack(alignment: .leading) {
                // Сетка
                VStack(alignment: .leading, spacing: 0) {
                    ForEach([0.25, 0.5, 0.75, 1.0].reversed(), id: \.self) { line in
                        HStack {
                            Text("\(Int(line * 100))%")
                                .font(MMFonts.subCaption)
                                .foregroundColor(.secondary)
                                .frame(width: 25, alignment: .trailing)
                            
                            Rectangle()
                                .fill(Color.secondary.opacity(0.1))
                                .frame(height: 1)
                        }
                        .frame(height: 45)
                    }
                }
                
                // Столбцы
                HStack(alignment: .bottom, spacing: 16) {
                    ForEach(tasks) { task in
                        VStack(spacing: 4) {
                            // Столбец
                            RoundedRectangle(cornerRadius: 8)
                                .fill(task.color)
                                .frame(height: max(30, 160 * task.progress))
                                .frame(width: 40)
                            
                            // Название
                            Text(task.name)
                                .font(MMFonts.subCaption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(height: 30)
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedCategory = TargetCategory(rawValue: task.name)
                            }
                        }
                    }
                }
                .padding(.leading, 30)
            }
        }
        .padding()
    }
}

// MARK: - Улучшенная столбчатая диаграмма
struct EnhancedBarChartView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(tasks) { task in
                    VStack {
                        Text("\(Int(task.progress * 100))%")
                            .font(MMFonts.caption)
                            .foregroundColor(task.color)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(task.color)
                            .frame(height: geometry.size.height * 0.6 * task.progress)
                        
                        Text(task.name)
                            .font(MMFonts.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedCategory = TargetCategory(rawValue: task.name)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Улучшенная круговая диаграмма
struct EnhancedPieChartView: View {
    let tasks: [TaskProgress]
    @Binding var selectedCategory: TargetCategory?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(tasks) { task in
                    PieSlice(
                        startAngle: getStartAngle(for: task),
                        endAngle: getEndAngle(for: task),
                        color: task.color
                    )
                    .scaleEffect(selectedCategory?.rawValue == task.name ? 1.1 : 1.0)
                    .animation(.spring(), value: selectedCategory)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let angle = getAngle(for: value.location, in: geometry.size)
                        if let task = getTask(at: angle) {
                            withAnimation {
                                selectedCategory = TargetCategory(rawValue: task.name)
                            }
                        }
                    }
            )
        }
    }
    
    private func getStartAngle(for task: TaskProgress) -> Angle {
        let index = tasks.firstIndex(where: { $0.id == task.id }) ?? 0
        let previousProgress = tasks.prefix(index).reduce(0) { $0 + $1.progress }
        return .degrees(previousProgress * 360)
    }
    
    private func getEndAngle(for task: TaskProgress) -> Angle {
        let startAngle = getStartAngle(for: task)
        return .degrees(startAngle.degrees + task.progress * 360)
    }
    
    private func getAngle(for point: CGPoint, in size: CGSize) -> Double {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angle = atan2(dy, dx)
        return (angle + .pi * 2).truncatingRemainder(dividingBy: .pi * 2)
    }
    
    private func getTask(at angle: Double) -> TaskProgress? {
        var currentAngle = 0.0
        for task in tasks {
            currentAngle += task.progress * .pi * 2
            if angle <= currentAngle {
                return task
            }
        }
        return nil
    }
}

// MARK: - Компоненты для круговой диаграммы
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview
struct EnhancedChartComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            BarChartView(
                tasks: [
                    TaskProgress(progress: 0.75, color: .blue, name: "Бизнес", value: 0.25),
                    TaskProgress(progress: 0.5, color: .green, name: "Личное", value: 0.25),
                    TaskProgress(progress: 0.9, color: .orange, name: "Семья", value: 0.25),
                    TaskProgress(progress: 0.9, color: .yellow, name: "Здоровье", value: 0.25)
                ],
                selectedCategory: .constant(nil)
            )
            
            EnhancedBarChartView(
                tasks: [
                    TaskProgress(progress: 0.75, color: .blue, name: "Бизнес", value: 0.25),
                    TaskProgress(progress: 0.5, color: .green, name: "Личное", value: 0.25),
                    TaskProgress(progress: 0.9, color: .orange, name: "Семья", value: 0.25),
                    TaskProgress(progress: 0.9, color: .yellow, name: "Здоровье", value: 0.25)
                ],
                selectedCategory: .constant(nil)
            )
            
            EnhancedPieChartView(
                tasks: [
                    TaskProgress(progress: 0.75, color: .blue, name: "Бизнес", value: 0.25),
                    TaskProgress(progress: 0.5, color: .green, name: "Личное", value: 0.25),
                    TaskProgress(progress: 0.9, color: .orange, name: "Семья", value: 0.25),
                    TaskProgress(progress: 0.9, color: .yellow, name: "Здоровье", value: 0.25)
                ],
                selectedCategory: .constant(nil)
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
} 
