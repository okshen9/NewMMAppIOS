//
//  MapView.swift
//  MMApp
//
//  Created by artem on 03.03.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    var canInteactive: Bool = false
    var withSgift: Bool = true
    @StateObject var viewModel: MapViewModel
    
    // State для региона, чтобы не перестраивать его при каждой перерисовке
    @State private var region: MKCoordinateRegion?
    // Состояние для отслеживания загрузки карты
    @State private var isMapLoaded = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let coordinateRaw = viewModel.coordinateRaw,
                   let coordinatePoint = viewModel.coordinatePoint {
                    
                    // Используем сохраненный регион или создаем новый
                    let mapRegion = region ?? MKCoordinateRegion(
                        center: coordinateRaw,
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                    
                    // Упрощаем структуру, убираем вложенность
                    MapContent(
                        region: mapRegion,
                        canInteractive: canInteactive,
                        cityName: viewModel.cityForDisplay,
                        userName: viewModel.nameUser,
                        coordinate: withSgift ? coordinatePoint : coordinateRaw
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(20)
                    
                } else {
                    ShimmeringRectangle()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .cornerRadius(20)
                }
            }
        }
        .onAppear {
            loadMapData()
        }
    }
    
    private func loadMapData() {
        // Загрузка с приоритетом
        Task(priority: .userInitiated) {
            await viewModel.getCoordinates()
            // Сохраняем регион после получения координат
            if let coordinateRaw = viewModel.coordinateRaw {
                let newRegion = MKCoordinateRegion(
                    center: coordinateRaw,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                
                // Обновляем UI в главном потоке
                DispatchQueue.main.async {
                    region = newRegion
                    // Даем время для отображения и включаем высокое качество
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.highQualityEnabled = true
                        isMapLoaded = true
                    }
                }
            }
        }
    }
}

// Выносим Map в отдельную структуру для улучшения производительности
struct MapContent: View {
    let region: MKCoordinateRegion
    let canInteractive: Bool
    let cityName: String
    let userName: String
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(position: .constant(.region(region)),
            interactionModes: canInteractive ? [.pitch, .zoom, .pan] : [])
        {
            Annotation("\(cityName)\n\(userName)",
                       coordinate: coordinate)
            {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(MMFonts.title)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: canInteractive)
    }
}

#Preview {
    MapView(canInteactive: true, viewModel: .init(nameCity: "Саратов", nameUser: "Артем"))
        .frame(height: 200)
}
