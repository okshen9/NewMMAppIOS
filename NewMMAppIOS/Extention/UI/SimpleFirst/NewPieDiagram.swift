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
    @Binding var currentLevel: Int
    @State private var navigationHistory: [[PieModel]] = []
    @State private var currentTitle: String = "Главная"
    @State private var selectedSectorId: String? = nil
    
    /// Название диаграммы, отображаемое в центре на корневом уровне
    let diagramTitle: String
    
    /// Флаг для размещения легенды сбоку вместо внизу
    let legendOnSide: Bool
    
    // Биндинги для управления функциональностью извне
    /// Управляет отображением надписей в центральном круге
    @Binding var showCenterLabel: Bool
    /// Управляет возможностью взаимодействия с диаграммой (навигация по уровням)
    @Binding var isInteractive: Bool
    /// Количество элементов текущего уровня
    @Binding var currentItemsCount: Int
    /// Обработчик выбора сектора
    var onSectorSelected: ((PieModel) -> Void)?
    
    /// Количество элементов текущего уровня
    var currentLevelItemsCount: Int {
        animatableSlices.count
    }
    
    /// Инициализатор компонента диаграммы
    /// - Parameters:
    ///   - slices: Массив данных для отображения в диаграмме
    ///   - segmentSpacing: Расстояние между секторами (0.0...1.0)
    ///   - cornerRadius: Радиус скругления углов секторов
    ///   - title: Заголовок диаграммы
    ///   - legendOnSide: Флаг размещения легенды сбоку вместо внизу
    ///   - showCenterLabel: Биндинг для управления отображением надписей в центре
    ///   - isInteractive: Биндинг для управления возможностью взаимодействия
    ///   - currentItemsCount: Биндинг для передачи количества элементов текущего уровня
    ///   - onSectorSelected: Замыкание, вызываемое при выборе сектора
    init(
        slices: [PieModel],
        segmentSpacing: Double = 0.02,
        cornerRadius: CGFloat = 10,
        title: String = "Главная",
        legendOnSide: Bool = false,
        showCenterLabel: Binding<Bool> = .constant(true),
        isInteractive: Binding<Bool> = .constant(true),
        currentItemsCount: Binding<Int> = .constant(0),
        onSectorSelected: ((PieModel) -> Void)? = nil,
        currentLevel: Binding<Int>
    ) {
        self.slices = slices
        self.segmentSpacing = segmentSpacing
        self.cornerRadius = cornerRadius
        self.diagramTitle = title
        self.legendOnSide = legendOnSide
        self._showCenterLabel = showCenterLabel
        self._isInteractive = isInteractive
        self._currentItemsCount = currentItemsCount
        self.onSectorSelected = onSectorSelected
        self._currentLevel = currentLevel
    }
    
    private var normalizedSlices: [(model: PieModel, normalizedValue: Double)] {
        // Общее количество секторов
        let count = Double(animatableSlices.count)
        // Общее пространство для отступов
        let totalSpacing = segmentSpacing * count
        // Доступное пространство для секторов
        let available = 1.0 - totalSpacing
        
        // Проверяем, все ли значения totalValue одинаковы
        let firstValue = animatableSlices.first?.totalValue ?? 0
        let allEqual = animatableSlices.allSatisfy { abs($0.totalValue - firstValue) < 0.000001 }
        
        if allEqual {
            // Если все значения равны, распределяем доступное пространство поровну
            let equalShare = available / count
            return animatableSlices.map { (model: $0, normalizedValue: equalShare) }
        } else {
            // Если значения разные, нормализуем их с учетом их пропорций
            let total = animatableSlices.map(\.totalValue).reduce(0, +)
            return animatableSlices.map { slice in
                let normalizedValue = (slice.totalValue / total) * available
                return (model: slice, normalizedValue: normalizedValue)
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if legendOnSide {
                    HStack(alignment: .center, spacing: 4) {
                        chartView(size: proxy.size)
                            .frame(width: proxy.size.width * 0.75)
                        
                        // Компактная легенда сбоку
                        ScrollView {
                            legendView
                        }
                        .frame(width: proxy.size.width * 0.25)
                    }
                } else {
                    VStack(spacing: 6) {
                        chartView(size: proxy.size)
                            .frame(height: proxy.size.width)
                        
                        // Легенда снизу
                        ScrollView {
                            legendView
                        }
                        .frame(maxHeight: proxy.size.height * 0.3)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .onChange(of: animatableSlices) { _, newValue in
                currentItemsCount = newValue.count
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
                
                // Подписываемся на уведомление о сбросе уровня
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("ResetPieChartLevel"),
                    object: nil,
                    queue: .main
                ) { [self] _ in
                    // Если мы не на верхнем уровне, возвращаемся на верх
                    if currentLevel > 0 {
                        // Анимируем возврат на верхний уровень
                        resetToRootLevel()
                    }
                }
            }
            .onDisappear {
                // Отписываемся от уведомлений при исчезновении
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name("ResetPieChartLevel"),
                    object: nil
                )
            }
        }
        .onSwipe(
            right: {
                print( "Swiped RIGHT →")
                navigateToParentLevel()}
            )
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
        // Вызываем обработчик выбора сектора, если он задан
        if let onSectorSelected = onSectorSelected {
            onSectorSelected(model)
        }
        
        // Устанавливаем выбранный сектор
        selectedSectorId = model.id
        
        // Проверяем наличие дочерних моделей
        guard let subModels = model.subModel, !subModels.isEmpty, isInteractive else { return }
        
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
        
        // Уведомляем о изменении уровня
        NotificationCenter.default.post(
            name: NSNotification.Name("PieChartLevelChanged"),
            object: currentLevel
        )
        
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
            
            // Уведомляем о изменении уровня
            NotificationCenter.default.post(
                name: NSNotification.Name("PieChartLevelChanged"),
                object: currentLevel
            )
            
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
        // Используем фиксированный размер чарта, равный размеру переданной ширины
        let chartSize = size.width
        
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
                    
                    // Вычисляем средний угол для размещения метки сектора
                    let midAngle = start + (bgEnd - start) / 2

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
                    .zIndex(1)

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
                    .zIndex(2)

                    if entry.model.subModel != nil && !(entry.model.subModel?.isEmpty ?? true) && isInteractive {
                        // Вычисляем позицию для индикатора
                        let midAngle = (start + bgEnd) / 2
                        let radius = chartSize / 2.5
                        let indicatorX = chartSize / 2 + cos(midAngle.radians) * radius
                        let indicatorY = chartSize / 2 + sin(midAngle.radians) * radius

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
                                        .font(MMFonts.subCaption)
                                        .foregroundColor(entry.model.color)
                                        .rotationEffect(.radians(midAngle.radians - .pi/2))
                                }
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        }
                        .position(x: indicatorX, y: indicatorY)
                        .zIndex(5)
                    }
                }

                // Центральный круг
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: chartSize / 1.5, height: chartSize / 1.5)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .contentShape(Circle())
                    .onTapGesture {
                        if isInteractive {
                            navigateToParentLevel()
                        }
                    }
                    .zIndex(3)
                
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
                                            .font(MMFonts.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 1)
                            }
                            .frame(maxWidth: 20, maxHeight: 20)
                        }
                        
                        // Название текущего уровня
                        Text(currentLevel == 0 ? diagramTitle : currentTitle)
                            .font(MMFonts.body)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                        
                        Text("Выполнено \(Int(present * 100))%")
                            .fontWeight(.semibold)
                    }
                    .frame(width: chartSize / 1.5, height: chartSize / 1.5)
                    .zIndex(4)
                }
                
                // Отдельный слой для меток секторов, чтобы они отображались поверх всего
                ForEach(normalizedSlices, id: \.model.id) { entry in
                    if entry.normalizedValue > 0.05 { // Показываем метку только для достаточно больших секторов
                        // Рассчитываем позицию для метки в середине сектора на краю центрального круга
                        let start = calculateStartAngle(index: animatableSlices.firstIndex(where: { $0.id == entry.model.id }) ?? 0)
                        let norm = entry.normalizedValue
                        let bgEnd = start + .degrees(360 * norm)
                        let midAngle = start + (bgEnd - start) / 2
                        let innerCircleRadius = chartSize / 3 // Радиус центрального круга
                        
                        // Рассчитываем координаты метки на краю центрального круга
                        let xPos = chartSize/2 + cos(midAngle.radians) * innerCircleRadius
                        let yPos = chartSize/2 + sin(midAngle.radians) * innerCircleRadius
                        
                        ZStack {
                            // Светящийся фон для лучшего выделения
                            Circle()
                                .fill(entry.model.color.opacity(0.3))
                                .blur(radius: 2)
                                .frame(width: 26, height: 26)
                            
                            // Фон метки
                            Circle()
                                .fill(entry.model.color)
                                .frame(width: 24, height: 24)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            // Инициалы или небольшая иконка для категории
                            Text(categoryInitials(of: entry.model.title))
                                .font(MMFonts.subCaption)
                                .foregroundColor(.white)
                        }
                        .position(x: xPos, y: yPos)
                        .opacity(opacity) // Анимируем вместе с диаграммой
                        .zIndex(10) // Отображаем поверх всех остальных элементов
                    }
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .id(id) // Используем id для обновления всего ZStack
        }
        .frame(width: chartSize, height: chartSize)
        .padding(.horizontal, legendOnSide ? 0 : 8)
        .padding(.vertical, 8)
    }
    
    // Получение инициалов или первой буквы названия категории/цели для отображения на метке
    private func categoryInitials(of title: String) -> String {
        let words = title.split(separator: " ")
        if words.count > 1 {
            // Берем первые буквы первых двух слов
            let firstInitial = words[0].first?.uppercased() ?? ""
            let secondInitial = words[1].first?.uppercased() ?? ""
            return "\(firstInitial)\(secondInitial)"
        } else if let first = title.first {
            // Если одно слово, берем первую букву
            return String(first).uppercased()
        }
        return "•" // Если нет названия, показываем точку
    }
    
    // Вынесенное представление легенды
    private var legendView: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 8) {
                    // Первая строка
                    HStack(spacing: 8) {
                        ForEach(firstRowItems) { slice in
                            legendItem(slice: slice)
                        }
                    }
                    .frame(minWidth: geometry.size.width)
                    
                    // Вторая строка (появляется только если есть элементы для второй строки)
                    if !secondRowItems.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(secondRowItems) { slice in
                                legendItem(slice: slice)
                            }
                        }
                        .frame(minWidth: geometry.size.width)
                    }
                }
            }
            .opacity(opacity)
        }
    }
    
    // Элементы для первой строки
    private var firstRowItems: [PieModel] {
        let itemsPerRow = Int(UIScreen.main.bounds.width / 160) // Примерная ширина элемента
        return Array(animatableSlices.prefix(itemsPerRow))
    }
    
    // Элементы для второй строки
    private var secondRowItems: [PieModel] {
        let itemsPerRow = Int(UIScreen.main.bounds.width / 160) // Примерная ширина элемента
        return Array(animatableSlices.dropFirst(itemsPerRow))
    }
    
    // Элемент легенды
    private func legendItem(slice: PieModel) -> some View {
        HStack(spacing: 4) {
            // Цветной индикатор с меткой
            ZStack {
                Circle()
                    .fill(slice.color)
                    .frame(width: 24, height: 24)
                
                Text(categoryInitials(of: slice.title))
                    .font(MMFonts.subCaption)
                    .foregroundColor(.white)
            }
            
            // Заголовок
            Text(slice.title)
                .font(MMFonts.caption)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Процент выполнения
            Text("\(Int(slice.currentValue * 100))%")
                .font(MMFonts.subCaption)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.1))
        )
        .onTapGesture {
            if isInteractive {
                navigateToSubmodels(of: slice)
            }
        }
    }
    
    // Функция для сброса диаграммы на верхний уровень
    private func resetToRootLevel() {
        // Анимируем переход
        withAnimation(.easeInOut(duration: 0.4)) {
            scale = 0.1
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Сбрасываем до корневого уровня
            currentLevel = 0
            
            // Уведомляем о изменении уровня
            NotificationCenter.default.post(
                name: NSNotification.Name("PieChartLevelChanged"),
                object: currentLevel
            )
            
            // Обновляем заголовок
            currentTitle = diagramTitle
            
            // Восстанавливаем данные корневого уровня
            animatableSlices = slices
            
            id = UUID()
            
            withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                scale = 1.0
                opacity = 1.0
            }
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
        PieModel(totalValue: 0.3, currentValue: 0.6,             subModel: [
            PieModel(totalValue: 0.3, currentValue: 0.6, color: .mint, title: "Подкатегория 2.1"),
            PieModel(totalValue: 0.3, currentValue: 0.4, color: .teal, title: "Подкатегория 2.2"),
            PieModel(totalValue: 0.4, currentValue: 0.2, color: .cyan, title: "Подкатегория 2.3")
        ],
                 color: .blue, title: "Категория 3"),
        PieModel(totalValue: 0.3, currentValue: 0.9, color: .yellow, title: "Категория 4")
    ]
    
    @Previewable @State var showLabels = true
    @Previewable @State var isInteractive = true
    

        VStack {
//            TabView {
                NewPieDiagram(
                    slices: value2,
                    title: "Стандартный режим",
                    showCenterLabel: $showLabels,
                    isInteractive: $isInteractive,
                    currentLevel: .constant(0)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                NewPieDiagram(
//                    slices: value2,
//                    title: "С легендой сбоку",
//                    legendOnSide: true,
//                    showCenterLabel: $showLabels,
//                    isInteractive: $isInteractive
//                )
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .tabViewStyle(.page)

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
