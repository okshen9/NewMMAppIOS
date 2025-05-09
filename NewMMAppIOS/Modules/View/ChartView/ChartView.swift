//
//  ChartView.swift
//  MMApp
//
//  Created by artem on 05.02.2025.
//

import SwiftUI

struct PiaView: View {
    @Binding var selectedFract: PiaViewFractionModel?
    @State private var totalPortfolioPrice: Double = 0
    
    @State private var zDictionary: [Int: Int] = [:]
    
    @State var values: [Double]
    var colors: [Color]
    var strongColor: [Color]
    var names: [String]
    
    //TODO: передалать
    private var fractals = [PiaViewFractionModel]()
    
    /// процент ширины занимаемый кругом от супер вью
    var widthFraction: CGFloat
    /// размер внутреннего круга, дробная часть от общего круга
    var innerRadiusFraction: CGFloat
    
    @State private var activeIndex: Int = -1
    @State private var taped: Bool = false
    
    
    
    
    /// - Parameters:
    ///    - values: значения
    ///    - colors:цвета для каждого значения
    ///    - widthFraction: процент ширины занимаемый кругом от супер вью
    ///    - innerRadiusFraction: размер внутреннего круга, дробная часть от общего круга
    init(
        values:[Double],
        colors: [Color] = [Color.blue, Color.green, Color.purple, Color.orange, Color.yellow, Color.blue, Color.red],
        names: [String] = [],
        widthFraction: CGFloat = 0.1,
        innerRadiusFraction: CGFloat = 0.6,
        strongColor: [Color] = [Color.blue, Color.green, Color.purple, Color.orange, Color.yellow, Color.blue, Color.red],
        selectedFract:  Binding<PiaViewFractionModel?>)
    {
        self.values = values
        self.colors = colors
        self.names = names
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
        self.strongColor = strongColor
        self._selectedFract = selectedFract
    }
    
//    let color: Color
//    let allStats: Double
//    let currnetValue: Double
//    let name: String?
    
    init(
        piaMdels: [PiaViewFractionModel],
        widthFraction: CGFloat = 0.9,
        innerRadiusFraction: CGFloat = 0.6,
        selectedFract:  Binding<PiaViewFractionModel?>
    ) {
        var values = [Double]()
        var colors = [Color]()
        var names = [String]()
        var strongColor = [Color]()
        piaMdels.forEach({ model in
            values.append(model.currnetValue)
            colors.append(model.color)
            names.append(model.name ?? .empty)
            strongColor.append(model.color)
            
            if let allStats = model.allStats {
                //TODO: Neshko Прозрачные цевета круга
                let delta = allStats > model.currnetValue ? allStats - model.currnetValue : 0
                values.append(delta)
                colors.append(model.color.lighter(by: 0.5))
                strongColor.append(model.color)
                names.append(model.name ?? .empty)
            }
        })
        
        self.init(
            values: values,
            colors: colors,
            names: names,
            widthFraction: widthFraction,
            innerRadiusFraction: innerRadiusFraction,
            strongColor: strongColor,
            selectedFract: selectedFract
        )
        self.fractals = piaMdels
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    VStack {
                                            sliceViews(geometry: geometry)
//                        Text("Этот текст отображается по центру")
                    }
                    .frame(
                        width: widthFraction * geometry.size.width,
                        height: widthFraction * geometry.size.width,
                        alignment: .center)
                    
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center)
            }
        }
        
    }
    
    @ViewBuilder
    private func sliceViews(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .center) {
            ForEach(Array(slices.enumerated()), id: \.0) { index, slice in
                zDictionary[index] = index
                return PortfolioStatisticSlice(portfolioSliceData: slice)
                    .shadow(color: self.activeIndex == index ? slice.strongColor : .clear,
                            radius: self.activeIndex == index ? 8 : 0)
                    .scaleEffect(self.activeIndex == index ? 1.05 : 1)
                    .animation(Animation.spring())
                    .zIndex(Double(zDictionary[index] ?? 0))
            }
            .frame(
                width: widthFraction * geometry.size.width,
                height: widthFraction * geometry.size.width,
                alignment: .center)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // находим радиус круга
                        let radius = 0.5 * widthFraction * geometry.size.width
                        
                        let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                        let dist = pow(pow(diff.x, 2.0) + pow(diff.y, 2.0), 0.5)
                        if (dist > radius || dist < radius * innerRadiusFraction) {
//                            self.activeIndex = -1
                            setActive(index: -1)
                            return
                        }
                        var radians = Double(atan2(diff.x, diff.y))
                        if (radians < 0) {
                            radians = 2 * Double.pi + radians
                        }
                        
                        for (i, slice) in slices.enumerated() {
                            if (radians < slice.endAngle.radians) {
//                                self.activeIndex = i
                                setActive(index: i)
                                let currentFract = fractals
                                    .filter({$0.name == names[self.activeIndex]})
                                    .first
                                selectedFract = currentFract
                                break
                            }
                        }
                    }
                    .onEnded { value in
//                                    self.activeIndex = -1
                    }
            )
            Circle()
                .fill(Color.white)
                .frame(width: widthFraction * geometry.size.width * innerRadiusFraction,
                       height: widthFraction * geometry.size.width * innerRadiusFraction)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            print("По всем категориям")
//                            self.activeIndex = -1
                            setActive(index: -1)
                            self.selectedFract = nil
                        }
                    )
                .zIndex(101.0)
            if names.contains(where: {!$0.isEmpty}) {
                
                if self.activeIndex != -1 {
                    let nameFract = names[self.activeIndex]
                    let currentFract = fractals
                        .filter({$0.name == nameFract})
                        .first
                    
                    
                    let isCurrent = if values[self.activeIndex] == currentFract?.currnetValue {
                        true
                    } else {
                        false
                    }
                    let status = isCurrent ? "выполнено" : "осталось"
                    
                    let all = String.doubleFormat((currentFract?.allStats ?? currentFract?.allStats) ?? 0)
                    
                    
                    
                    
                    let val1 = (currentFract?.currnetValue ?? 0)
                    let val2 = ((currentFract?.allStats ?? currentFract?.currnetValue) ?? 0) - (currentFract?
                        .currnetValue ?? 0)
                    let currentVal: Double =
                    isCurrent ?
                    val1 : val2
                    
                    let current =
                    String.doubleFormat(currentVal)
                    
                    VStack {
                        Text(nameFract)
                            .font(MMFonts.title)
                            .foregroundColor(.headerText)
                        Text("\(status) \(current) / \(all)")
                            .font(MMFonts.subTitle)
                            .foregroundColor(.subtitleText)
                    }
                    .zIndex(102.0)
                } else {
                    let all =
                    String.doubleFormat(fractals
                        .map({$0.allStats ?? $0.currnetValue})
                        .reduce(0, +)
                    )
                    let current =
                    String.doubleFormat(fractals
                        .map({$0.currnetValue})
                        .reduce(0, +)
                    )
                    VStack {
                        Text("По всем категориям")
                            .font(MMFonts.title)
                            .foregroundColor(.headerText)
                        Text("выполнено \(current) / \(all)")
                            .font(MMFonts.subTitle)
                            .foregroundColor(.subtitleText)
                    }
                    .zIndex(102.0)
                }
            }
        }
    }
    
    private func setActive(index: Int) {
        if activeIndex != -1 {
            zDictionary[activeIndex] = activeIndex
        }
        self.activeIndex = index
        if index != -1 {
            zDictionary[index] = 100
        }
    }
}

struct PiaView_Previews: PreviewProvider {
    static var previews: some View {
        let slis = [
            PiaViewFractionModel(color: .mainRed, allStats: 2, currnetValue: 1.5, name: "Семья"),
            PiaViewFractionModel(color: .green, allStats: 4, currnetValue: 1.5, name: "Здоровье"),
            PiaViewFractionModel(color: .blue, allStats: 3, currnetValue: 0.9, name: "Личное"),
            PiaViewFractionModel(color: .yellow, allStats: 7, currnetValue: 4, name: "Бизнес"),
        ]
//        PiaView(values: [1300, 500, 300, 600, 500])
        PiaView(piaMdels: slis, selectedFract: Binding<PiaViewFractionModel?>.constant(nil))
    }
}

extension PiaView {
    private var slices: [PortfolioSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PortfolioSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            tempSlices.append(PortfolioSliceData(
                startAngle: Angle(degrees: endDeg),
                endAngle: Angle(degrees: endDeg + degrees),
                color: colors[i],
                strongColor: strongColor[i]))
            endDeg += degrees
        }
        return tempSlices
    }
}

//
//#Preview {
//    PiaView()
//}
