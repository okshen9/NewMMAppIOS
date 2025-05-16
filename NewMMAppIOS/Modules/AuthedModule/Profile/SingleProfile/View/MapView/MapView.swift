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
    
    // Используем MapCameraPosition вместо региона для лучшего контроля
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var originalPosition: MapCameraPosition = .automatic
    
    // Состояние для отслеживания загрузки карты
    @State private var isMapLoaded = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let coordinateRaw = viewModel.coordinateRaw,
                   let coordinatePoint = viewModel.coordinatePoint {
                    
                    // Создаем карту с управляемой позицией камеры
                    Map(position: Binding(
                        get: { cameraPosition },
                        set: { newPosition in
                            if canInteactive {
                                cameraPosition = newPosition
                            }
                        }
                    ), interactionModes: canInteactive ? [.pitch, .zoom, .pan] : [])
                    {
                        // Основная отметка профиля
                        Annotation("\(viewModel.cityForDisplay)\n\(viewModel.nameUser)",
                                   coordinate: withSgift ? coordinatePoint : coordinateRaw)
                        {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(MMFonts.title)
                        }
                        
                        // Дополнительная отметка текущего пользователя, если она отличается
                        if let userCoord = viewModel.currentUserCoordinate, 
                           let userLocation = viewModel.currentUserLocation,
                           userLocation != viewModel.cityForDisplay {
                            Annotation("Вы здесь\n\(userLocation)",
                                      coordinate: userCoord)
                            {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(MMFonts.title)
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(20)
                    .animation(.easeInOut(duration: 0.3), value: canInteactive)
                    
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
        .onChange(of: canInteactive) { oldValue, newValue in
            if oldValue && !newValue {
                // При закрытии карты возвращаемся к исходной позиции
                withAnimation(.easeInOut(duration: 0.5)) {
                    cameraPosition = originalPosition
                }
            }
        }
    }
    
    private func loadMapData() {
        // Загрузка с приоритетом
        Task(priority: .userInitiated) {
            await viewModel.getCoordinates()
            // Настраиваем камеру после получения координат
            if let coordinateRaw = viewModel.coordinateRaw {
                let initialRegion = MKCoordinateRegion(
                    center: coordinateRaw,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                
                // Обновляем UI в главном потоке
                DispatchQueue.main.async {
                    let position = MapCameraPosition.region(initialRegion)
                    cameraPosition = position
                    originalPosition = position
                    
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

#Preview {
    MapView(canInteactive: true, viewModel: .init(nameCity: "Саратов", nameUser: "Артем"))
        .frame(height: 200)
}
