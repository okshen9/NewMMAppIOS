import SwiftUI

/// Диаграмма, отображающая секторы с прогрессом и поддержкой иерархической навигации.
/// Поддерживает два режима отображения: с легендой снизу или сбоку.
/// Имеет возможность отключения интерактивности и скрытия центральных надписей.
struct NewPieDiagram: View {
    /// Данные для отображения в диаграмме
    let slices: [PieModel]
    /// Расстояние между секторами (0.0...1.0)
    let segmentSpacing: Double
    /// Радиус скругления углов секторов
    let cornerRadius: CGFloat
    
    // Анимируемое состояние для плавных переходов
    @State private var animatableSlices: [PieModel] = []
    @State private var id = UUID()
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var isChangingStructure = false
    
    // Состояние для навигации по иерархии моделей
    @State private var currentLevel: Int = 0
    @State private var navigationHistory: [[PieModel]] = []
    @State private var currentTitle: String = "Главная"
    
    /// Название диаграммы, отображаемое в центре на корневом уровне
    let diagramTitle: String
    
    /// Флаг для размещения легенды сбоку вместо внизу
    let legendOnSide: Bool
    
    // Биндинги для управления функциональностью извне
    /// Управляет отображением надписей в центральном круге
    @Binding var showCenterLabel: Bool
    /// Управляет возможностью взаимодействия с диаграммой (навигация по уровням)
    @Binding var isInteractive: Bool
    
    /// Инициализатор компонента диаграммы
    /// - Parameters:
    ///   - slices: Массив данных для отображения в диаграмме
    ///   - segmentSpacing: Расстояние между секторами (0.0...1.0)
    ///   - cornerRadius: Радиус скругления углов секторов
    ///   - title: Заголовок диаграммы
    ///   - legendOnSide: Флаг размещения легенды сбоку вместо внизу
    ///   - showCenterLabel: Биндинг для управления отображением надписей в центре
    ///   - isInteractive: Биндинг для управления возможностью взаимодействия
    init(
        slices: [PieModel],
        segmentSpacing: Double = 0.02,
        cornerRadius: CGFloat = 10,
        title: String = "Главная",
        legendOnSide: Bool = false,
        showCenterLabel: Binding<Bool> = .constant(true),
        isInteractive: Binding<Bool> = .constant(true)
    ) {
        self.slices = slices
        self.segmentSpacing = segmentSpacing
        self.cornerRadius = cornerRadius
        self.diagramTitle = title
        self.legendOnSide = legendOnSide
        self._showCenterLabel = showCenterLabel
        self._isInteractive = isInteractive
    }
    
    private var normalizedSlices: [(model: PieModel, normalizedValue: Double)] {
        let total = animatableSlices.map(\.totalValue).reduce(0, +) 
        let totalSpacing = segmentSpacing * Double(animatableSlices.count)
        let available = 1 - totalSpacing
        return animatableSlices.map { slice in
            let nv = (slice.totalValue / total) * available
            return (slice, nv)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if legendOnSide {
                    HStack(alignment: .center, spacing: 4) {
                        chartView(size: proxy.size)
                        
                        // Компактная легенда сбоку
                        legendView
                    }
                } else {
                    VStack(spacing: 0) {
                        // Заголовок с текущим уровнем
                        Text(currentTitle)
                            .font(.headline)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        
                        chartView(size: proxy.size)
                        
                        // Легенда снизу
                        legendView
                    }
                }
            }
            .onChange(of: slices) { oldValue, newValue in
                // Определяем тип изменения
                if hasSameStructureButDifferentValues(oldValue, newValue) {
                    // Только изменение прогресса - плавная анимация
                    withAnimation(.easeInOut(duration: 0.7)) {
                        animatableSlices = newValue
                    }
                } else {
                    // Изменение структуры - анимируем исчезновение всей диаграммы
                    isChangingStructure = true
                    
                    // Анимация уменьшения и исчезновения
                    withAnimation(.easeInOut(duration: 0.4)) {
                        scale = 0.1
                        opacity = 0
                    }
                    
                    // После исчезновения обновляем данные
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animatableSlices = newValue
                        id = UUID() // Принудительное обновление структуры диаграммы
                        
                        // Анимация появления и увеличения
                        withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                        
                        isChangingStructure = false
                    }
                }
            }
            .onAppear {
                // При первом появлении анимируем с нуля
                scale = 0.1
                opacity = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(duration: 0.8)) {
                        animatableSlices = slices
                        navigationHistory = [[]] // Инициализируем историю навигации
                        currentLevel = 0
                        currentTitle = diagramTitle // Устанавливаем начальный заголовок
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            }
        }
    }

    private func calculateStartAngle(index: Int) -> Angle {
        let previousTotal = normalizedSlices.prefix(index).reduce(0) { $0 + $1.normalizedValue }
        let offset = previousTotal + Double(index) * segmentSpacing
        return .degrees(360 * offset)
    }
    
    private func hasSameStructureButDifferentValues(_ old: [PieModel], _ new: [PieModel]) -> Bool {
        guard old.count == new.count else { return false }
        
        for i in 0..<old.count {
            if i >= old.count || i >= new.count { return false }
            if old[i].id != new[i].id || old[i].title != new[i].title || old[i].color != new[i].color {
                return false
            }
        }
        
        return true
    }
    
    // Функция для перехода на уровень ниже к дочерним моделям
    private func navigateToSubmodels(of model: PieModel) {
        guard let subModels = model.subModel, !subModels.isEmpty else { return }
        
        // Сохраняем текущий уровень в историю
        if navigationHistory.count <= currentLevel {
            navigationHistory.append(animatableSlices)
        } else {
            navigationHistory[currentLevel] = animatableSlices
        }
        
        // Переходим на уровень ниже
        withAnimation {
            currentLevel += 1
        }
        currentTitle = model.title
        
        // Анимируем переход
        withAnimation(.easeInOut(duration: 0.4)) {
            scale = 0.1
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Обновляем данные с новым уровнем
            animatableSlices = subModels
            id = UUID()
            
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    // Функция для перехода на уровень выше
    private func navigateToParentLevel() {
        guard currentLevel > 0 else { return }
        
        // Анимируем переход
        withAnimation(.easeInOut(duration: 0.4)) {
            scale = 0.1
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Уменьшаем уровень
            currentLevel -= 1
            
            // Обновляем заголовок
            if currentLevel == 0 {
                currentTitle = diagramTitle
            } else {
                // Для промежуточных уровней используем название из модели соответствующего уровня
                if let parentModel = self.navigationHistory.prefix(currentLevel).last?.first(where: { model in
                    model.subModel?.contains(where: { $0.title == self.currentTitle }) ?? false
                }) {
                    currentTitle = parentModel.title
                }
            }
            
            // Восстанавливаем данные предыдущего уровня
            if currentLevel < navigationHistory.count {
                animatableSlices = navigationHistory[currentLevel]
            } else {
                animatableSlices = slices
            }
            
            id = UUID()
            
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    // Вынесенное представление диаграммы, принимающее доступный размер
    private func chartView(size: CGSize) -> some View {
        let availableWidth = legendOnSide ? size.width * 0.7 : size.width * 0.9
        let availableHeight = legendOnSide ? size.height * 0.9 : size.height * 0.6
        let chartSize = min(availableWidth, availableHeight)
        
        return GeometryReader { geometry in
            // Диаграмма с анимацией масштаба и прозрачности
            ZStack {
                // Используем id для явного обновления всего содержимого
                ForEach(normalizedSlices, id: \.model.id) { entry in
                    let idx = animatableSlices.firstIndex(where: { $0.id == entry.model.id }) ?? 0
                    let start = calculateStartAngle(index: idx)
                    let norm = entry.normalizedValue
                    let bgEnd = start + .degrees(360 * norm)
                    let fgPortion = entry.model.currentValue * norm
                    let fgEnd = start + .degrees(360 * fgPortion)

                    // Фоновый слой
                    PieSimpleSliceView(
                        model: .init(
                            color: entry.model.color.lighten(),
                            startAngle: start,
                            endAngle: bgEnd,
                            cornerRadius: cornerRadius
                        )
                    )
                    .id("\(entry.model.id)-bg")
                    .contentShape(PieSliceShape(
                        startAngle: start,
                        endAngle: bgEnd,
                        cornerRadius: cornerRadius
                    ))
                    .onTapGesture {
                        if isInteractive {
                            navigateToSubmodels(of: entry.model)
                        }
                    }
                    .overlay {
                        if entry.model.subModel != nil && !(entry.model.subModel?.isEmpty ?? true) && isInteractive {
                            // Вычисляем позицию для индикатора
                            let midAngle = (start + bgEnd) / 2
                            let radius = min(geometry.size.width, geometry.size.height) / 2.5
                            let indicatorX = geometry.size.width / 2 + cos(midAngle.radians) * radius
                            let indicatorY = geometry.size.height / 2 + sin(midAngle.radians) * radius
                            
                            ZStack {
                                // Светящийся круг
                                Circle()
                                    .fill(entry.model.color.opacity(0.3))
                                    .blur(radius: 4)
                                    .frame(width: 30, height: 30)
                                
                                // Индикатор в виде круга со стрелкой
                                Circle()
                                    .fill(.white)
                                    .frame(width: 22, height: 22)
                                    .overlay {
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(entry.model.color)
                                            .rotationEffect(.radians(midAngle.radians - .pi/2))
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                            }
                            .position(x: indicatorX, y: indicatorY)
                        }
                    }

                    // Слой прогресса
                    PieSimpleSliceView(
                        model: .init(
                            color: entry.model.color,
                            startAngle: start,
                            endAngle: fgEnd,
                            cornerRadius: cornerRadius
                        )
                    )
                    .id("\(entry.model.id)-fg")
                    .contentShape(PieSliceShape(
                        startAngle: start,
                        endAngle: fgEnd,
                        cornerRadius: cornerRadius
                    ))
                    .onTapGesture {
                        if isInteractive {
                            navigateToSubmodels(of: entry.model)
                        }
                    }
                }
                
                // Центральный круг
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 1.5)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .contentShape(Circle())
                    .onTapGesture {
                        if isInteractive {
                            navigateToParentLevel()
                        }
                    }
                
                if showCenterLabel {
                    let present = (animatableSlices.reduce(0.0) { $0 + $1.currentValue }) / Double(animatableSlices.isEmpty ? 1 : animatableSlices.count)
                    VStack(spacing: 6) {
                        if currentLevel > 0 && isInteractive {
                            // Индикатор перехода на уровень выше в центре
                            ZStack {
                                // Светящийся эффект
                                Circle()
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 30, height: 30)
                                    .blur(radius: 4)
                                
                                // Иконка
                                Circle()
                                    .fill(.white)
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 1)
                            }
                            .frame(maxWidth: 20, maxHeight: 20)
                        }
                        
                        // Название текущего уровня
                        Text(currentLevel == 0 ? diagramTitle : currentTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                        
                        Text("Выполнено \(Int(present * 100))%")
                            .fontWeight(.semibold)
                    }
                    .frame(width: geometry.size.width / 1.5, height: geometry.size.height / 1.5)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .id(id) // Используем id для обновления всего ZStack
        }
        .frame(width: chartSize, height: chartSize)
        .padding(.horizontal, legendOnSide ? 0 : 8)
        .padding(.vertical, 8)
    }
    
    // Вынесенное представление легенды
    private var legendView: some View {
        Group {
            if legendOnSide {
                // Вертикальная легенда для горизонтального режима
                LazyVGrid(
                    columns: [GridItem(.flexible())],
                    alignment: .leading,
                    spacing: 6
                ) {
                    legendItems
                }
                .opacity(opacity)
                .padding(.horizontal, 4)
                .frame(width: UIScreen.main.bounds.width * 0.25)
            } else {
                // Двухстрочная легенда с горизонтальным скролом для вертикального режима
                VStack(spacing: 6) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(
                            rows: [
                                GridItem(.adaptive(minimum: 22, maximum: 40)),
                                GridItem(.adaptive(minimum: 22, maximum: 40))
                            ],
                            alignment: .top,
                            spacing: 10
                        ) {
                            legendItems
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .opacity(opacity)
                .frame(height: 90)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    // Элементы легенды, используемые в обоих режимах
    private var legendItems: some View {
        ForEach(animatableSlices) { slice in
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        // Цветной индикатор
                        Circle()
                            .fill(slice.color)
                            .frame(width: legendOnSide ? 8 : 10, height: legendOnSide ? 8 : 10)
                        
                        // Заголовок без процентов
                        Text(slice.title)
                            .font(.system(size: legendOnSide ? 12 : 13))
                            .lineLimit(legendOnSide ? 1 : 2)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.leading)
                        
                        // Индикатор наличия подуровней
                        if slice.subModel != nil && !(slice.subModel?.isEmpty ?? true) && isInteractive {
                            Image(systemName: "chevron.right")
                                .font(.system(size: legendOnSide ? 8 : 9))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Процент на отдельной строке (или вместе для бокового режима)
                    if !legendOnSide {
                        Text("\(Int(slice.currentValue * 100))%")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.leading, 14) // Отступ для выравнивания с названием
                    } else {
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: legendItemWidth(for: slice.title))
            .padding(.vertical, legendOnSide ? 4 : 4)
            .padding(.horizontal, legendOnSide ? 4 : 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
            .id("\(slice.id)-legend")
            .contentShape(Rectangle())
            .onTapGesture {
                if isInteractive {
                    navigateToSubmodels(of: slice)
                }
            }
        }
    }

    // Функция для расчета адаптивной ширины элемента легенды
    private func legendItemWidth(for title: String) -> CGFloat {
        let baseWidth: CGFloat = 60 // Базовая ширина для процентов и иконок
        let titleWidth = min(CGFloat(title.count) * 7.5, 150) // Примерная ширина текста
        
        if legendOnSide {
            return UIScreen.main.bounds.width * 0.23 // Боковой режим использует процент от ширины экрана
        } else {
            // Адаптивная ширина, но не менее 120 и не более 200
            return min(200, max(120, baseWidth + titleWidth))
        }
    }
}

// Создадим расширение для анимируемого PieModel
// Это позволит SwiftUI анимировать свойства этого типа
extension PieModel: Animatable {
    public var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(currentValue, totalValue) }
        set {
            currentValue = newValue.first
            totalValue = newValue.second
        }
    }
}

#Preview {
    @Previewable @State var value = PieModel(totalValue: 0.3, currentValue: 0.2, color: .red, title: "Категория 1")

    @Previewable @State var value2 = [
        PieModel(
            totalValue: 0.3, 
            currentValue: 0.2, 
            subModel: [
                PieModel(totalValue: 0.1, currentValue: 0.3, color: .orange, title: "Подкатегория 1.1"),
                PieModel(totalValue: 0.1, currentValue: 0.7, color: .pink, title: "Подкатегория 1.2"),
                PieModel(totalValue: 0.1, currentValue: 0.4, color: .red, title: "Подкатегория 1.3"),
                PieModel(totalValue: 0.1, currentValue: 0.6, color: .orange, title: "Подкатегория 1.4"),
//                PieModel(totalValue: 0.1, currentValue: 0.5, color: .pink.opacity(0.6), title: "Подкатегория 1.5"),
//                PieModel(totalValue: 0.1, currentValue: 0.8, color: .red.opacity(0.5), title: "Подкатегория длинное название"),
//                PieModel(totalValue: 0.1, currentValue: 0.2, color: .orange.opacity(0.7), title: "Подкатегория 1.7"),
//                PieModel(totalValue: 0.1, currentValue: 0.9, color: .pink.opacity(0.8), title: "Подкатегория 1.8"),
//                PieModel(totalValue: 0.1, currentValue: 0.7, color: .red.opacity(0.6), title: "Подкатегория 1.9"),
//                PieModel(totalValue: 0.1, currentValue: 0.3, color: .orange.opacity(0.9), title: "Подкатегория 1.10")
            ],
            color: .red, 
            title: "Здоровье"
        ),
        PieModel(
            totalValue: 0.4, 
            currentValue: 0.3, 
            subModel: [
                PieModel(totalValue: 0.3, currentValue: 0.6, color: .mint, title: "Подкатегория 2.1"),
                PieModel(totalValue: 0.3, currentValue: 0.4, color: .teal, title: "Подкатегория 2.2"),
                PieModel(totalValue: 0.4, currentValue: 0.2, color: .cyan, title: "Подкатегория 2.3")
            ],
            color: .green, 
            title: "Бизнес"
        ),
        PieModel(totalValue: 0.3, currentValue: 0.6, color: .blue, title: "Категория 3"),
        PieModel(totalValue: 0.3, currentValue: 0.9, color: .yellow, title: "Категория 4")
    ]
    
    @Previewable @State var showLabels = true
    @Previewable @State var isInteractive = true
    

        VStack {
            TabView {
                NewPieDiagram(
                    slices: value2,
                    title: "Стандартный режим",
                    showCenterLabel: $showLabels,
                    isInteractive: $isInteractive
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                NewPieDiagram(
                    slices: value2,
                    title: "С легендой сбоку",
                    legendOnSide: true,
                    showCenterLabel: $showLabels,
                    isInteractive: $isInteractive
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .tabViewStyle(.page)

            // Управляющие переключатели
            VStack {
                Toggle("Показывать надписи", isOn: $showLabels.animation())
                Toggle("Разрешить взаимодействие", isOn: $isInteractive.animation())
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
            .padding(.horizontal)
        }

}
